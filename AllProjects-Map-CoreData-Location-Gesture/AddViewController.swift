//
//  AddViewController.swift
//  AllProjects-Map-CoreData-Location-Gesture
//
//  Created by Ömer Saitoğlu on 29.12.2024.
//

import UIKit
import MapKit
import CoreData
import CoreLocation



protocol AddLocationDelegate : AnyObject{
    func didSelectLocation()
}


final class AddViewController: UIViewController {

    // MARK: - UI Elements:
    @IBOutlet weak var travelName: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    // MARK: - Properties:
    private var locationManager = CLLocationManager()
    private var selectedLatitude = Double()
    private var selectedLongitude = Double()
    weak var delegate : AddLocationDelegate!
    
    // MARK: - Lifefcycles:
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManagerConfigure()
        gestureMapView()
        endEditingWhenViewTapped()
    }

    
    
    @IBAction func saveButtonTap(_ sender: UIButton) {
        // DATA TO BE INSERTED:
        guard let locationName = travelName.text else {return}
        guard let countryName = country.text else{return}
        let latitude = selectedLatitude
        let longitude = selectedLongitude
        
        CoreDataService.shared.geziEkle(locationName: locationName, country: countryName, latitude: latitude, longitude: longitude) { error in
            if let error = error{
                self.showAlert(error: "\(error)")
            }else{
                print("success")
                DispatchQueue.main.async {
                    self.delegate.didSelectLocation()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        
    }
    
    
}

// MARK: Location
extension AddViewController: CLLocationManagerDelegate {
    // Konumu Başlatma Ayarları
    private func locationManagerConfigure(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Konumu Harita Göster
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Konumu Harita Üzerinde Gösterme
        let pinAnnotion = MKPointAnnotation()
        pinAnnotion.coordinate = location.coordinate
        mapView.addAnnotation(pinAnnotion)
        
        // Haritayı Pinin Olduğu Yere Odakla
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setCenter(location.coordinate, animated: true)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    private func showAlert(error : String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
}

extension AddViewController {
    // Haritaya Üzerine Dokunmayı Aktif Etme
    private func gestureMapView(){
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    // Lokasyon Seçme ve Pin Ekleme
    @objc func choseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            // Dokunulan Yerin Koordinat Bilgileri
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let touchCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            selectedLatitude = touchCoordinate.latitude
            selectedLongitude = touchCoordinate.longitude
            
            // Yeni Pin Oluşturma ve Haritaya Ekleme
            let annotion = MKPointAnnotation()
            annotion.coordinate = touchCoordinate
            mapView.addAnnotation(annotion)
        }
    }
    
    private func endEditingWhenViewTapped(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(editingEnded))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }
    @objc private func editingEnded(){
        view.endEditing(true)
    }
    
}
