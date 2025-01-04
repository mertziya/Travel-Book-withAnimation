//
//  CoreDataService.swift
//  AllProjects-Map-CoreData-Location-Gesture
//
//  Created by Mert Ziya on 2.01.2025.
//

import Foundation
import UIKit
import CoreData


enum CoreDataError: Error{
    case fetchAllError
    
    case locationError
    case countryError
    case coordinateError
}


class CoreDataService{
    // Singleton
    static let shared = CoreDataService()
    private init(){}
    
    private var context : NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
   
    // GEZI EKLE:           CREATE
    
    func geziEkle(locationName: String, country: String, latitude: Double, longitude: Double , completion: @escaping (Error?) -> () ){
        
        // Handling error cases
        if locationName.isEmpty {completion(CoreDataError.locationError) ; return}
        else if country.isEmpty {completion(CoreDataError.countryError) ; return}
        else if latitude == 0 || longitude == 0 {completion(CoreDataError.coordinateError) ; return}
        else{
            do{
                let newTravel = Travels(context: context)
                
                newTravel.id = UUID()
                newTravel.name = locationName
                newTravel.country = country
                newTravel.latitude = latitude
                newTravel.longitude = longitude
                
                try context.save()
                completion(nil)
            }catch{
                completion(error)
            }
        }
    }
    
    
    
    // TUM GEZILERI CAGIR:          READ
    
    func fetchAllTravels(completion : @escaping (Result<[Travels],Error>) -> ()){
        let request: NSFetchRequest<Travels> = Travels.fetchRequest()
        
        do{
            let travels = try context.fetch(request)
            completion(.success(travels))
        }catch{
            completion(.failure(CoreDataError.fetchAllError))
        }
    }
    
    
    
    // BIR GEZIYI SIL:              DELETE
    
    func deleteTravel(id: UUID){
        print("called")
        let request : NSFetchRequest<Travels> = Travels.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        do{
            let results = try context.fetch(request)
            if let travelToDelete = results.first{
                context.delete(travelToDelete)  // delete the travel with the given id
                try context.save()
                print("Travel deleted succesfully")
            }else{
                print("No travel found with the id = \(id.uuidString)")
            }
        }catch{
            print("Error while deleting the person \(error.localizedDescription)")
        }
    }
    
    
    
    // BIR GEZIYI GUNCELLE              UPDATE
    
    func updatePlace(updatedPlace : String, userid : UUID){
        let request : NSFetchRequest<Travels> = Travels.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userid.uuidString)
        do{
            let results = try context.fetch(request)
            if let travelToUpdate = results.first{
                travelToUpdate.name = updatedPlace
                // Save the context to persist the changes
                try context.save()
                
                print("Successfully updated the place to: \(updatedPlace)")
            }else{
                print("No Travels entity found with the given UUID.")
            }
        }catch let error as NSError{
            print("Error fetching or updating data: \(error), \(error.userInfo)")
        }
    }
    
    func updateCountry(updatedCountry : String, userid : UUID){
        let request : NSFetchRequest<Travels> = Travels.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", userid.uuidString)
        do{
            let results = try context.fetch(request)
            if let travelToUpdate = results.first{
                travelToUpdate.country = updatedCountry
                // Save the context to persist the changes
                try context.save()
                
                print("Successfully updated the place to: \(updatedCountry)")
            }else{
                print("No Travels entity found with the given UUID.")
            }
        }catch let error as NSError{
            print("Error fetching or updating data: \(error), \(error.userInfo)")
        }
    }
    
}
