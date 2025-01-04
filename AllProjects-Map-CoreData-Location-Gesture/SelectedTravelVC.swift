//
//  SelectedTravelVC.swift
//  AllProjects-Map-CoreData-Location-Gesture
//
//  Created by Mert Ziya on 2.01.2025.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class SelectedTravelVC : UIViewController, MKMapViewDelegate{
    
    
    // MARK: - UI Elements:
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var countryName: UITextField!
    var changeNameButton = UIButton()
    var changeCountryButton = UIButton()
    @IBOutlet weak var placeNameErrorLabel: UILabel!
    @IBOutlet weak var countryNameErrorLabel: UILabel!
    
    
    
    
    // MARK: - Properties:
    var travel = Travels()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Basic UI Configurations
        
        locationManagerConfigure() // initializes the location service.
        
        showLocationOnMap() // shows the location with the 'lat' and 'long' values coming from the coredata.
        
        addNavigationButtonToNav() // Adds the button to the top right corner of the navigation item,  will be used to set directions to that location.
        
        hideKeyboardWhenViewClicked() // Hides the keyboard when user clicks somewhere inside the view (textfields not included)
        
        setButtonActions() // Sets the actions triggered when 'changeNameButton' and 'changeCountryButton' are clicked.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    @objc private func keyboardWillShow(_ notification: Notification){
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height // the height of the keyboard when it is on
            
            if view.frame.origin.y == 0{
                view.frame.origin.y -= keyboardHeight
            }
        }
    }
    @objc private func keyboardWillHide(_ notification : Notification){
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    
    
}



// MARK: - UI Configurations:
extension SelectedTravelVC{
    
    private func setupUI(){
        view.backgroundColor = .systemBackground

        placeName.text = travel.name!
        countryName.text = travel.country!
        mapView.layer.cornerRadius = 8
        mapView.delegate = self
        
        addRightView(tf: placeName, button: changeNameButton)
        addRightView(tf: countryName , button: changeCountryButton)
        
        placeNameErrorLabel.text = ""
        countryNameErrorLabel.text = ""
        
        
        let countryLabel = UILabel()
        let placeLabel = UILabel()
        view.addSubview(countryLabel)
        view.addSubview(placeLabel)
        placeLabel.text = "Place:" ; placeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold); placeLabel.textColor = .link
        countryLabel.text = "Country:" ; countryLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold) ; countryLabel.textColor = .link
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            placeLabel.bottomAnchor.constraint(equalTo: placeName.topAnchor, constant: 0),
            countryLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            countryLabel.bottomAnchor.constraint(equalTo: countryName.topAnchor, constant: 0),
        ])
        
    }
    
    private func addRightView(tf : UITextField, button : UIButton){
        let _height = tf.bounds.height
        let _width = CGFloat(80)
        button.frame =  CGRect(x: tf.bounds.maxX - _width, y: tf.bounds.maxY - _height, width: _width, height: _height)
        
        button.setImage(UIImage(systemName: "pencil.line")?.withTintColor(.systemOrange), for: .normal)
        button.setTitle("Edit", for: .normal)
        button.tintColor = .systemOrange
        button.setTitleColor(.systemOrange, for: .normal)
        tf.addSubview(button)
    }
}



extension SelectedTravelVC : CLLocationManagerDelegate{
    private func locationManagerConfigure(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func showLocationOnMap() {
        // Create the annotation
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2D(latitude: travel.latitude, longitude: travel.longitude)
        annotation.coordinate.latitude = travel.latitude
        annotation.coordinate.longitude = travel.longitude
        annotation.title = travel.name
        // Add annotation to the map
        mapView.addAnnotation(annotation)
        
        // Center the map around the annotation
        let region = MKCoordinateRegion(
            center: locationCoordinate,
            latitudinalMeters: 1000, // Adjust the zoom level
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: true)
    }
}



// MARK: - Actions:
extension SelectedTravelVC {
    private func addNavigationButtonToNav(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location"), style: .done, target: self, action: #selector(navigateTapped))
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    @objc private func navigateTapped(){
        let coordinate = CLLocationCoordinate2D(latitude: travel.latitude, longitude: travel.longitude)
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = travel.name
        
        mapItem.openInMaps(launchOptions: nil)
    }
    
    private func hideKeyboardWhenViewClicked(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didHideKeyboard))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }
    @objc private func didHideKeyboard(){
        view.endEditing(true)
    }
    
    private func setButtonActions(){
        self.changeNameButton.addTarget(self, action: #selector(nameChanged), for: .touchUpInside)
        self.changeCountryButton.addTarget(self, action: #selector(countryChanged), for: .touchUpInside)
    }
    
    @objc private func nameChanged(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.placeNameErrorLabel.text = ""
            self.placeNameErrorLabel.textColor = .systemRed
        }
        
        if placeName.text == travel.name {
            shakingAnimation(tf: placeName)
            self.placeNameErrorLabel.text = "Value Not Changed"
        }else{
            print("changed")
            self.placeNameErrorLabel.text = "Place Updated"
            self.placeNameErrorLabel.textColor = .systemGreen
            CoreDataService.shared.updatePlace(updatedPlace: placeName.text!, userid: travel.id!)
        }
    }
    @objc private func countryChanged(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.countryNameErrorLabel.text = ""
            self.countryNameErrorLabel.textColor = .systemRed
        }
        
        if countryName.text == travel.country {
            shakingAnimation(tf: countryName)
            self.countryNameErrorLabel.text = "Value Not Changed"
            CoreDataService.shared.updateCountry(updatedCountry: countryName.text!, userid: travel.id!)
        }else{
            print("changed")
            self.countryNameErrorLabel.text = "Country Updated"
            self.countryNameErrorLabel.textColor = .systemGreen
        }
    }
}


// Animations:
extension SelectedTravelVC {
    private func shakingAnimation(tf: UITextField){
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0,5,-5,10,-10,0]
        animation.keyTimes = [0,0.125,0.25,0.5,0.75,1]
        animation.duration = 0.4
        
        animation.isAdditive = true
        tf.layer.add(animation, forKey: "shake")
    }
}
