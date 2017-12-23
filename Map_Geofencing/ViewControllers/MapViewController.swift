//
//  MapViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 10/31/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {

    var photoStore: PhotoStore!
    var fetchedPlants = [Plant]()
    var locationManager = CLLocationManager()
    var userCurrentLocation:CLLocation?
    lazy var mapView = GMSMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get photoStore from TabBarController
        let tabBar = self.tabBarController as! TabBarController
        self.photoStore = tabBar.photoStore
        
        // Google Maps setting
        let camera = GMSCameraPosition.camera(withLatitude: 37.7669, longitude: -122.4716, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true
        self.view = mapView
        self.mapView.delegate = self
        
        // Initialize Segmented Control
        let items = ["Standard", "Hybrid", "Satellite"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        
        // Set up SegmentedControl
        segmentedControl.frame = CGRect(x: 90, y: 75,
                                      width: 200, height: 25)
        segmentedControl.addTarget(self, action: #selector(mapType(sender:)), for: .valueChanged)
        segmentedControl.backgroundColor = .white
        segmentedControl.tintColor = .black
        self.view.addSubview(segmentedControl)
        
        //Location Manager code to fetch current location
        setUpLocationManager()
        
        // Fetch all plant markers
        fetchAllPlantMarkers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.clear()
        fetchAllPlantMarkers()
    }
    
    func setUpLocationManager() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    // Change map types
    func mapType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .normal
        case 1:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .satellite
        }
    }
    
    // Fetch all saved pins with annotation
    func fetchAllPlantMarkers() {
        
        photoStore.fetchAllMarkers() { (plantsResult) in
            
            switch plantsResult {
                
            case let .success(plants):
                
                self.fetchedPlants = plants
                
                if self.fetchedPlants.count > 0 {

                    for plant in self.fetchedPlants {
                        
                        let plantMarker = GMSMarker()
                        plantMarker.position = CLLocationCoordinate2D(latitude: plant.latitude, longitude: plant.longitude)
                        plantMarker.title = plant.scientificName
                        plantMarker.snippet = plant.commonName
                        plantMarker.map = self.mapView
                        
                    }
                    
                } else {
                    print("Nothing to fetch")
                }
                
            case .failure(_):
                self.fetchedPlants = []
            }
        }
        
    }
    
    @IBAction func mapTypeChange(_ sender: UISegmentedControl!) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .normal
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .normal
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let _ = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        // User's current location to calculate distance to specific plant
        userCurrentLocation = userLocation
        
        locationManager.stopUpdatingLocation()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
    }
}

// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {

        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        if let index = fetchedPlants.index(where: { $0.scientificName == marker.title }) {
            let selectedPlant = fetchedPlants[index]
            detailVC.plant = selectedPlant
        }
        
        self.navigationController?.pushViewController(detailVC, animated: true)

    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 225, height: 50))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 25
        
        let plantImage =  UIImageView(frame: CGRect(x: view.frame.origin.x + 2.5, y: view.frame.origin.y + 2.5, width: 45, height: 45))
        plantImage.layer.cornerRadius = 22.5
        plantImage.image = UIImage(named: "sample")
        plantImage.clipsToBounds = true
        view.addSubview(plantImage)
        
        let scientificNameLabel = UILabel(frame: CGRect.init(x: 58, y: 8, width: view.frame.size.width - 16, height: 16))
        scientificNameLabel.text = marker.title
        scientificNameLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(scientificNameLabel)
        
        let distanceLabel = UILabel(frame: CGRect.init(x: 58, y: 28, width: view.frame.size.width - 16, height: 14))
        if let distance = userCurrentLocation?.distance(from: CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)) {
            distanceLabel.text = self.formatDistance(distance)
            distanceLabel.font = UIFont.systemFont(ofSize: 14)
            distanceLabel.textColor = .lightGray
        }
        view.addSubview(distanceLabel)
        
        return view
    }
    
    // Format distance(meters) to miles in String
    func formatDistance(_ distance: Double) -> String {
        
        let distanceMeters = Measurement(value: distance, unit: UnitLength.meters)
        let miles = distanceMeters.converted(to: UnitLength.miles).value
        print("\(miles) miles")
        
        let numDecimalDigits = (miles >= 4) ? 0 : 1
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = numDecimalDigits
        
        let formattedDistance: String = formatter.string(for: miles)!
        return "Distance: \(formattedDistance) miles"
    }
}
