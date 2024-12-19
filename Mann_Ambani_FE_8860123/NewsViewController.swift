//
//  News.swift
//  Mann_Ambani_FE_8860123
//
//  Created by user230729 on 12/4/23.
//

import UIKit
//newsViewController which extends UITableViewController
class NewsViewController: UITableViewController {
    
    //some usefull variables
    var newsList:[Article] = []
    var newsCityName = ""
    var from = ""
    //context needed for core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Url for news Api
    var url:String = "https://newsapi.org"
    var endPoint:String = "/v2"
    var apiKey:String = "eb30d0fe8c004d0984b349d656f98416"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Fetching data in view did load
        fetchData()
    }
    
    //Alert dialog for user input
    @IBAction func alertDialogForCity(_ sender: Any) {
        //showing title and message
        let alertController = UIAlertController(title: "Get News", message: "Enter city name to get news.", preferredStyle: .alert)
        //adding a text field
        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = "Write a city name"
        }
        
        
        // add the buttons/actions to the view controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default){ _ in
            //setting data
            self.newsCityName = alertController.textFields![0].text!
            self.from = "From News"
            //fatching data for new city
            self.fetchData()
            
        }
        //adding actions
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        //show alert dialog
        present(alertController, animated: true, completion: nil)
    }
    
    //add core data
    func addToCoreData(title:String,description:String,source:String,author:String){
        if(!newsCityName.isEmpty){
            //core data
            //creating and inserting data into history model
            let history1:History = History(context: context)
            history1.interaction = "News"
            history1.cityName = newsCityName
            history1.source = from
            history1.title = title
            history1.desc = description
            history1.transportType = source
            history1.result = author
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //implimentation of custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! CustomNewsCell
        //passing data to custom cell lables
        cell.title.text = self.newsList[indexPath.row].title
        cell.descricption.text = self.newsList[indexPath.row].description
        if let sourceName = self.newsList[indexPath.row].source?.name{
            cell.source.text = "Source: \(sourceName)"
        }
        
        cell.author.text = "Author: \(self.newsList[indexPath.row].author ?? "")"
        return cell
    }
    
    //fetching data from api and storing it in list
    func fetchData(){
        var urlString:String
        //if user goes directly into the directions page then the default city is kitchener. i did this because i want to display something when user goes directly
        if(newsCityName.isEmpty){
            urlString = url + endPoint  + "/everything?q=kitchener&apiKey=\(apiKey)"
        }
        //else it will pass selected city name in url
        else{
            print(newsCityName)
            urlString = url + endPoint  + "/everything?q=\(newsCityName)&apiKey=\(apiKey)"
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
                        let readableData = try jsonDecoder.decode(News.self, from: data)
                        
                        //displaying or performing storing task in main thread
                        DispatchQueue.main.async {
                            if let article = readableData.articles {
                                self.newsList = article
                                
                                //adding first news to history using code data
                                self.addToCoreData(title: self.newsList.first?.title ?? "", description: self.newsList[0].description ?? "", source: self.newsList[0].source?.name ?? "", author: self.newsList[0].author ?? "")
                            }
                            self.tableView.reloadData()
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
