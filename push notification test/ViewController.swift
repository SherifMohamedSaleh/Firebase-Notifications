//
//  ViewController.swift
//  push notification test
//
//  Created by Sherif Saleh on 4/6/20.
//  Copyright © 2020 inova. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces
import Crashlytics


class ViewController: UIViewController {

    // MARK: - Declare the location manager, current location, map view, places client, and default zoom level at the class level.
    
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
        var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 2.0


    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        addMAp()
        addCrashBtn()
    }
    
    // firebase Crashlytics

     func  addCrashBtn() {
     let button = UIButton(type: .roundedRect)
     button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
     button.setTitle("Crash", for: [])
     button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
     view.addSubview(button)
     }
     @IBAction func crashButtonTapped(_ sender: AnyObject) {
     Crashlytics.sharedInstance().crash()
     }

    
    // Populate the array with the list of likely places.

    
    
    func initLocationManager (){
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
        }
        
        placesClient = GMSPlacesClient.shared()
        
    }
    
    
    
    func addMAp(){
        let camera = GMSCameraPosition.camera(withLatitude: (currentLocation?.coordinate.latitude) ?? 30.797498,
                                              longitude: (currentLocation?.coordinate.longitude) ?? 29.7525508,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        addMarker()
    }
    
    func addStaticMap(){
        let camera = GMSCameraPosition.camera(withLatitude: 30.797498, longitude: 29.7525508, zoom: zoomLevel)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 30.797498, longitude: 29.7525508)
        marker.title = "Alexandria"
        marker.snippet = "Egypt"
        marker.icon = UIImage(named: "group400")
        marker.map = mapView
    }
    // Update the map once the user has made their selection.
    func addMarker() {
        // Clear the map.
        mapView?.clear()
        
        // Add a marker to the map.
        if currentLocation != nil {
            let marker = GMSMarker(position: (self.currentLocation?.coordinate)!)
            marker.map = mapView
        }
    }
    
}


extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        print("locations = \(location.coordinate.latitude) \(location.coordinate.longitude)")
        currentLocation = location
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        addMarker()
        mapView.animate(to: camera)
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
}
