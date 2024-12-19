//
//  ViewController.swift
//  Mann_Ambani_FE_8860123
//
//  Created by user230729 on 12/4/23.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    
    
    @IBOutlet weak var myMap: MKMapView!
    let manager = CLLocationManager()
    
    
    
    
    @IBAction func openAlertDialog(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Where would you like to go", message: "Enter your destination", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = "Write a item"
        }
        
        
        // add the buttons/actions to the view controller
        let newsAction = UIAlertAction(title: "News", style: .default){ _ in
            //navigating and passing data into view controller
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "news") as! NewsViewController
            viewController.newsCityName = alertController.textFields![0].text!
            viewController.from = "From Main"
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        let directionAction = UIAlertAction(title: "Directions", style: .default) { _ in
            //navigating and passing data into view controller
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "map") as! MapViewController
            viewController.cityName = alertController.textFields![0].text!
            viewController.from = "From Main"
            self.navigationController?.pushViewController(viewController, animated: true)
            
            
        }
        let weatherAction = UIAlertAction(title: "Weather", style: .default){ _ in
            //navigating and passing data into view controller
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "weather") as! WeatherViewController
            viewController.weatherCity = alertController.textFields![0].text!
            viewController.from = "From Main"
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
        alertController.addAction(newsAction)
        alertController.addAction(directionAction)
        alertController.addAction(weatherAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //from the array of location 0 is the current location
        let locations = locations[0]
        
        //amount of zoom on map
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        //current location
        let myLocation = CLLocationCoordinate2D(latitude: locations.coordinate.latitude, longitude: locations.coordinate.longitude)
        //region that renders when app starts getting location
        let region = MKCoordinateRegion(center: myLocation, span: span)
        //set region of user to map
        myMap.setRegion(region, animated: true)
        myMap.showsUserLocation = true
        let pin = MKPointAnnotation()
        myMap.addAnnotation(pin)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    
}

