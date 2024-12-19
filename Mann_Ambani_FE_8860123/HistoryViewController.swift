//
//  History.swift
//  Mann_Ambani_FE_8860123
//
//  Created by user230729 on 12/4/23.
//

import UIKit

class HistoryViewController: UITableViewController {
    
    
    var historyList:[History] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetch data
        fetchHistorData()
        //storing first five elements
        addFiveLoadedElement()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //initializing custom histor cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! CustomHistoryCell
        //setting cell data
        cell.interactionType.text = self.historyList[indexPath.row].interaction
        cell.interactionSource.text = self.historyList[indexPath.row].source
        cell.cityName.text = self.historyList[indexPath.row].cityName
        
        //data changes with interaction type so we set data accordingly
        if(self.historyList[indexPath.row].interaction == "Weather"){
            cell.title.text = "Temperature: " + self.historyList[indexPath.row].title!
            cell.actualDescription.text = "Description" + self.historyList[indexPath.row].desc!
            cell.articleSource.text = "Humidity: " + self.historyList[indexPath.row].transportType!
            cell.author.text =  "Wind: " + self.historyList[indexPath.row].result!
            
        }else if(self.historyList[indexPath.row].interaction == "Directios"){
            cell.title.text = "Start Location: " + self.historyList[indexPath.row].title!
            cell.actualDescription.text = "End Location: " + self.historyList[indexPath.row].desc!
            cell.articleSource.text = "Transport type: " + self.historyList[indexPath.row].transportType!
            cell.author.text =  "Distance: " + self.historyList[indexPath.row].result!
            
        }else{
            cell.title.text = "Title: " + self.historyList[indexPath.row].title!
            cell.actualDescription.text = "Descricption: " + self.historyList[indexPath.row].desc!
            cell.articleSource.text = "Source: " + self.historyList[indexPath.row].transportType!
            cell.author.text =  "Author: " + self.historyList[indexPath.row].result!
        }
        
        //taking date from Date() as dd MMM yyyy format
        if let date = self.historyList[indexPath.row].dateTime{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            let someDateTime = formatter.string(from: date)
            cell.date.text = "Date: \(String(describing: someDateTime))"
            
        }
        //        taking time from Date() as HH:mm a format
        if let date = self.historyList[indexPath.row].dateTime{
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm a"
            let someDateTime = formatter.string(from: date)
            cell.time.text = "Time: \(String(describing: someDateTime))"
            
        }
        
        
        
        
        return cell
    }
    
    
    //fetching histor data from core database
    func fetchHistorData(){
        do{
            //storing data into list
            self.historyList = try context.fetch(History.fetchRequest())
            
            DispatchQueue.main.async {
                //reload the table view after getting data
                self.tableView.reloadData()
            }
            self.historyList.reverse()
        }
        catch{
            print("No Data")
        }
    }
    
    
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //code that runs when user delete data
        if editingStyle == .delete {
            //taking deleted data from index
            let dataToDelete = self.historyList[indexPath.row]
            //removing data from core database
            self.context.delete(dataToDelete)
            do{
                //saving core database
                try self.context.save()
            }catch{
                print("error in data storage")
            }
            //remove data from the list
            self.historyList.remove(at: indexPath.row)
            //delete row from table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    //adding five elements
    func addFiveLoadedElement(){
        //if there is no item we will pre load 5 items
        if(historyList.count == 0){
            let history:History = History(context: context)
            history.interaction = "News"
            history.cityName = "Waterloo"
            history.source = "From Main"
            history.title = "Conestoga waterloo campus is cool"
            history.desc = "People akgdjhadgsdjfskfhad,h,fzldsh,laj vjashdkjfhk,as fahshdf,lakhs  ajsfdhkahksd khaldfshkas hlfkalsdhfklu ald ahsdf galksdh fkaku lglfausf lukhlahfsd lh laudfhl klaslkf gluash fdlaosdfhlh"
            history.transportType = "Unknown"
            history.result = "Mann"
            history.dateTime = Date()
            historyList.insert(history, at: historyList.count)
            
            
            
            let history1:History = History(context: context)
            history1.interaction = "Weather"
            history1.cityName = "Kitchener"
            history1.source = "From Weather"
            history1.title = "0°"
            history1.desc = "Raining"
            history1.transportType = "10%"
            history1.result = "10Km/h"
            history1.dateTime = Date()
            //        historyList.append(history1)
            historyList.insert(history1, at: historyList.count)
            
            let history2:History = History(context: context)
            history2.interaction = "Directions"
            history2.cityName = "Toronto"
            history2.source = "From Directions"
            history2.title = "waterloo"
            history2.desc = "toronto"
            history2.transportType = "car"
            history2.result = "20Km"
            history2.dateTime = Date()
            //        historyList.append(history2)
            historyList.insert(history2, at: historyList.count)
            
            let history3:History = History(context: context)
            history3.interaction = "Weather"
            history3.cityName = "Winnipeg"
            history3.source = "From Weather"
            history3.title = "0°"
            history3.desc = "Raining"
            history3.transportType = "10%"
            history3.result = "10Km/h"
            history3.dateTime = Date()
            //        historyList.append(history3)
            historyList.insert(history3, at: historyList.count)
            
            let history4:History = History(context: context)
            history4.interaction = "Directions"
            history4.cityName = "Windsor"
            history4.source = "From Directions"
            history4.title = "waterloo"
            history4.desc = "toronto"
            history4.transportType = "car"
            history4.result = "20Km"
            history4.dateTime = Date()
            //        historyList.append(history4)
            historyList.insert(history4, at: historyList.count)
            
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
