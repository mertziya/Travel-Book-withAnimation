//
//  ViewController.swift
//  AllProjects-Map-CoreData-Location-Gesture
//
//  Created by Ömer Saitoğlu on 29.12.2024.
//

import UIKit

final class ViewController: UIViewController, AddLocationDelegate {
    
    func didSelectLocation() {
        
        // CORE DATA CREATE OPERATION:
        CoreDataService.shared.fetchAllTravels { result in
            switch result{
            case .success(let travels):
                self.travels = travels
            case .failure(let error):
                print(error)
            }
        }
    
    }
    
    
    @IBOutlet private weak var listView: UITableView!
    
    private var travels: [Travels] = [] {
        didSet{
            listView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDataToTravels()
    }
    
    
    private func navButton(){
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonTap))
    }
    
    @objc func addButtonTap(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "AddVC") as? AddViewController else{return}
        vc.delegate = self
        show(vc, sender: nil)
    }
  
    
        
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return travels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = travels[indexPath.row].name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        guard let uid = self.travels[indexPath.row].id else{return} // the field wants to be deleted related with the selected table view row.
        CoreDataService.shared.deleteTravel(id: uid)
        fetchDataToTravels()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storybaord = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storybaord.instantiateViewController(withIdentifier: "selected") as? SelectedTravelVC else{return}
        vc.travel = self.travels[indexPath.row]
        
        self.show(vc, sender: self)
    }
    
    func fetchDataToTravels(){
        CoreDataService.shared.fetchAllTravels { result in
            switch result{
            case .failure(let error):
                print("DEBUG: \(error.localizedDescription)")
            case .success(let travels):
                self.travels = travels
            }
        }
    }
}
