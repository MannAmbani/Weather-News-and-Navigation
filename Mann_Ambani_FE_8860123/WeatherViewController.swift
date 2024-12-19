//
//  Weather.swift
//  Mann_Ambani_FE_8860123
//
//  Created by user230729 on 12/4/23.
//

import UIKit
import MapKit
import CoreLocation


class WeatherViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    //importing core location to get weather data for current location
    let manager = CLLocationManager()
    var weatherCity:String = ""
    var from:String = ""
    //context for core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //api for weather and image
    var url = "https://api.openweathermap.org"
    var urlEndPoint = "/data"
    var version = "/2.5"
    var apiKey = "a07861f31bab1fa9482a4fc601076a75"
    var unit = "metric"
    
    var imageUrl = "https://openweathermap.org"
    var imageUrlEndpoint = "/img/wn/"
    var imageType = "@2x.png"
    
    @IBOutlet weak var temperature: UILabel!
    
    
    @IBOutlet weak var region: UILabel!
    
    
    @IBOutlet weak var weather: UILabel!
    
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var wind: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var feelsLike: UILabel!
    
    
    @IBOutlet weak var descripton: UILabel!
    
    
    
    
    //to get current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        //getting data from api
        fetchData(lat: location.coordinate.latitude, long: location.coordinate.longitude)
    }
    
    
    
    //alert dialog for city selection
    @IBAction func showAlertDialogForCitySelection(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Weather Information", message: "Enter the city name to get weather details.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = "Write a item"
        }
        
        
        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default){ _ in
            self.weatherCity = alertController.textFields![0].text!
            self.from = "From Weather"
            //fetching data for selected city
            self.fetchData(lat: 0, long: 0)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        
        present(alertController, animated: true, completion: nil)
    }
    
    //adding data to core database
    func addToCoreData(temperature:String,description:String,humidity:String,wind:String){
        if(!weatherCity.isEmpty){
            //core data
            
            let history1:History = History(context: context)
            history1.interaction = "Weather"
            history1.cityName = weatherCity
            history1.source = from
            history1.title = temperature
            history1.desc = description
            history1.transportType = humidity
            history1.result = wind
            history1.dateTime = Date()
            
            do{
                //save data into database
                try self.context.save()
            }
            catch{
                print("Error in saving data")
            }
        }
    }
    
    //fetch data
    func fetchData(lat:Double,long:Double){
        var urlString:String
        //        if city name is empty then it will fetch data from current location
        if(weatherCity.isEmpty){
            urlString = url + urlEndPoint + version + "/weather?lat=\(lat)&lon=\(long)&appid=\(apiKey)&units=\(unit)"
        }else{
            //if we have city name then will use kind of diffrent url which only needs city name
            print(weatherCity)
            urlString = url + urlEndPoint + version + "/weather?q=\(weatherCity)&appid=\(apiKey)&units=\(unit)"
        }
        // Create an instance of a URLSession Class and assign the value of your URL to the The URL in the Class
        let urlSession = URLSession(configuration:.default)
        let url = URL(string: urlString)
        
        
        // Check for Valid URL
        if let url = url {
            // Create a variable to capture the data from the URL
            let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
                // If URL is good then get the data and decode
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        // Create an variable to store the structure from the decoded stucture
                        let readableData = try jsonDecoder.decode(Welcome.self, from: data)
                        //getting weather data
                        let weatherIconUrl = self.imageUrl + self.imageUrlEndpoint + readableData.weather[0].icon + self.imageType
                        print(readableData)
                        if let url = URL(string: weatherIconUrl) {
                            
                            
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if let data = data, let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.weatherImage.image = image
                                    }
                                }
                            }.resume()
                        }
                        //storing data into ui in main thread
                        DispatchQueue.main.async {
                            
                            self.temperature.text = "\(Int(readableData.main.temp))°"
                            self.humidity.text = "\(readableData.main.humidity)%"
                            self.region.text = "\(readableData.name)"
                            self.weather.text = readableData.weather[0].main
                            self.descripton.text = readableData.weather[0].description
                            self.wind.text = "\(String(format: "%.1f", readableData.wind.speed * 3.6))Km/h"
                            self.feelsLike.text = "\(Int(readableData.main.feelsLike))°"
                            
                            self.addToCoreData(temperature: "\(Int(readableData.main.temp))°", description: readableData.weather[0].description, humidity: "\(readableData.main.humidity)%", wind: "\(String(format: "%.1f", readableData.wind.speed * 3.6))Km/h")
                        }
                        
                    }
                    //Catch the Broken URL Decode
                    catch {
                        print ("Can't Decode")
                    }
                }
            }
            dataTask.resume()// Resume the datatask method
            
            
            
            
        }
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
