//
//  MapViewController.swift
//  Mann_Ambani_FE_8860123
//
//  Created by user230729 on 12/4/23.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //some useful variables
    var locationManager = CLLocationManager()
    var cityName = ""
    var selectedModeOfTransport = "car"
    var from = ""
    var startingDest = ""
    //context used for core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //some outlets
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var carButton: UIButton!
    
    @IBOutlet weak var bikeButton: UIButton!
    
    @IBOutlet weak var walkButton: UIButton!
    
    //slider action for zoom in and out
    @IBAction func zoomSlider(_ sender: UISlider) {
        // Getting new zoom value from slider
        let newZoomvalue = CLLocationDegrees(sender.value)
        
        // Getting new span with the new vlaue assigned
        let newSpan = MKCoordinateSpan(latitudeDelta: newZoomvalue, longitudeDelta: newZoomvalue)
        
        // Assigning center of the view of map
        let center = myMap.region.center
        
        // Assigning new region as per center and span(zoom value)
        let newRegion = MKCoordinateRegion(center: center, span: newSpan)
        
        // Setting latest region value to our mapView
        myMap.setRegion(newRegion, animated: true)
    }
    
    //Car button action
    @IBAction func carButtonAction(_ sender: UIButton) {
        //        setting transport type
        selectedModeOfTransport = "car"
        from = "From Map"
        //converting city name into lat long
        self.convertAddress()
        //selected button is true
        carButton.isSelected = true
        bikeButton.isSelected = false
        walkButton.isSelected = false
    }
    
    //bike button action
    @IBAction func bikeButtonAction(_ sender: UIButton) {
        //transport type
        selectedModeOfTransport = "bike"
        from = "From Map"
        //converting city name to lat long
        self.convertAddress()
        //seleted button is true
        bikeButton.isSelected = true
        carButton.isSelected = false
        walkButton.isSelected = false
    }
    
    //walk button
    @IBAction func walkButtonAction(_ sender: UIButton) {
        //transport type
        selectedModeOfTransport = "walk"
        from = "From Map"
        //converting city name to lat long
        self.convertAddress()
        bikeButton.isSelected = false
        carButton.isSelected = false
        walkButton.isSelected = true
    }
    
    //showing alert dialog
    @IBAction func showAlertDialogForCity(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Get Directions", message: "Enter city name to get directions.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = "Write a item"
        }
        
        
        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default){ _ in
            
            self.cityName = alertController.textFields![0].text!
            self.from = "From Map"
            //converting city name to coordinates
            self.convertAddress()
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        
        present(alertController, animated: true, completion: nil)
    }
    
    // converts address from text to coordinates Longtide and latitude
    func convertAddress() {
        
        //use geocoder to convert city name to coordinates
        let geocoder = CLGeocoder()
        
        //passing city name and getting location coordinates
        geocoder.geocodeAddressString(cityName) { [self]
            
            (placemarks, error) in guard let placemarks = placemarks,
                                         
                                            let location = placemarks.first?.location
                                            
            else {
                
                print ("no location found")
                
                return
                
            }
            
            //calculating distance
            let distance = location.distance(from: (self.locationManager.location)!)
            
            //soring data into core data
            self.addToCoreData(startLocation: self.startingDest, endLocation: self.cityName, trasportType: selectedModeOfTransport, distance: String(format: "%.2f", distance / 1000) + "km")
           
            //main function that has code ti draw poly line
            self.mapThis(desitiationCor: location.coordinate)
            
        }
        
    }
    
    //getting city name from lat and long
    func convertLatLongToCityName(){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude:  locationManager.location?.coordinate.longitude ?? 0) // will give us city name
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
            
            placemarks?.forEach { (placemark) in
                //getting city name
                if let city = placemark.locality {
                    
                    
                    DispatchQueue.main.async {
                        self.startingDest = city
                    }
                    
                    
                }
            }
        })
    }
    
    //adding data to core data history model
    func addToCoreData(startLocation:String,endLocation:String,trasportType:String,distance:String){
        if(!cityName.isEmpty){
            //core data
            //by passing context we say that this is a part of core data and when we save data this gets save
            let history1:History = History(context: context)
            history1.interaction = "Directios"
            history1.cityName = cityName
            history1.source = from
            history1.title = startLocation
            history1.desc = endLocation
            history1.transportType = trasportType
            history1.result = distance
            history1.dateTime = Date()
            
            do{
                //save data to database
                try self.context.save()
            }
            catch{
                print("Error in saving data")
            }
        }
    }
    
    //route line and color
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let routeline = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        routeline.strokeColor = .green
        
        return routeline
    }
    
    
    //this function consist of all the code needed to show line and pins on map from one point to another
    func mapThis(desitiationCor: CLLocationCoordinate2D) {
        
        //we will remove all existing overlays as we will add news one so this will prevent overlapping
        self.myMap.removeOverlays(self.myMap.overlays)
        //amount of zoom on map
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        //current location
        let myLocation = CLLocationCoordinate2D(latitude: desitiationCor.latitude, longitude: desitiationCor.longitude)
        //region that renders when app starts getting location
        let region = MKCoordinateRegion(center: myLocation, span: span)
        //set region of user to map
        myMap.setRegion(region, animated: true)
        myMap.showsUserLocation = true
        
        //start location
        let sourceCoordinate = (locationManager.location?.coordinate)!
        //start place amrk
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        //end place mark
        let destinationPlacemark = MKPlacemark(coordinate: desitiationCor)
        //start and end items
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        //request destination
        let destinationRequest = MKDirections.Request()
        
        //start and end
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        
        // Mode of travel
        if(selectedModeOfTransport == "car"){
            destinationRequest.transportType = .automobile
            
        }
        else if(selectedModeOfTransport == "bike"){
            destinationRequest.transportType = .automobile
        }else{
            destinationRequest.transportType = .walking
        }
        
        // one route = false multi = true
        
        destinationRequest.requestsAlternateRoutes = true
        
        // submit request to calculate directions
        
        let directions = MKDirections(request: destinationRequest)
        
        directions.calculate { (response, error) in
            
            // if there is a response make it the response else make error
            
            guard let response = response else { if error != nil {
                
                print("something went wrong")
            }
                return
            }
            //we want the first response
            
            let route = response.routes[0]
            
            // adding overlay to routes
            
            self.myMap.addOverlay(route.polyline)
            
            self.myMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
            // setting endpoint pin
            
            let pin = MKPointAnnotation()
            
            let coordinate = CLLocationCoordinate2D(latitude: desitiationCor.latitude, longitude: desitiationCor.longitude)
            
            pin.coordinate = coordinate
            
            pin.title = "END POINT"
            
            self.myMap.addAnnotation(pin)
            
            
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //important initializations
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        myMap.delegate = self
        convertLatLongToCityName()
        convertAddress()
    }
    
    
}
