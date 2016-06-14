//
//  JsonDataTableViewController.swift
//  SUSHMobileTask
//
//  Created by Yanbing Peng on 14/06/16.
//  Copyright © 2016 Yanbing Peng. All rights reserved.
//

import UIKit

class JsonDataTableViewController: UITableViewController, NSURLSessionDelegate {

    // MARK : - Variables
    let JSON_DATA_URL = "https://dl.dropboxusercontent.com/s/8bz9e8aq223hcz7/test.json"
    
    var personDataArray : [PersonData] = [PersonData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadJsonData()
    }

    // MARK: - Private function for loading JSON data
    func loadJsonData(){
        if let requestUrl = NSURL.init(string: JSON_DATA_URL){
            let getRequest = NSMutableURLRequest(URL: requestUrl)
            getRequest.HTTPMethod = "GET"
            NSURLSession.sharedSession().dataTaskWithRequest(getRequest, completionHandler: {[weak self] (data, response, error) in
                guard error == nil && data != nil else{
                    print("Error: \(error)")
                    return
                }
                do{
                    let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    //print("JSON DATA: \(jsonResponse)")
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = ""
                    if let people  = jsonResponse["people"] as? [[String:String]]{
                        for person in people{
                            //print("[person]: \(person)")
                            let personData = PersonData()
                            if let imageURL = person["image"]{
                                personData.image = imageURL
                            }
                            if let name = person["name"]{
                                personData.name = name
                            }
                            if let title = person["title"]{
                                personData.title = title
                            }
                            if let dOB = person["date of birth"]{
                                if let date = self?.processDateString(dOB){
                                    personData.dateOfBirth = date
                                }
                            }
                            self?.personDataArray.append(personData)
                        }
                        print("[persion Array]: \(self?.personDataArray.count)")
                        self?.tableView.reloadData()
                    }
                    
                }
                catch{
                    print("Error serializing JSON: \(error)")
                }
            }).resume()
        }
    }

    private func processDateString(dateString:String)->NSDate?{
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        let dateStringSplit = dateString.componentsSeparatedByString(",")
        let year = dateStringSplit[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let monthDay = dateStringSplit[0].componentsSeparatedByString(" ")
        let monthString = monthDay[0]
        let day = monthDay[1]
        var month = 1
        for (index, m) in months.enumerate(){
            if m == monthString{
                month = index + 1
                break
            }
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.dateFromString("\(year)-\(month)-\(day)")
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personDataArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personDataCell", forIndexPath: indexPath)
        print("tablview cellForRowAtIndex")
        if let personDataCell = cell as? PersonDataTableViewCell{
            print("is PersonDataTableViewCell")
            let rowIndex = indexPath.row
            personDataCell.currentRowIndex = rowIndex
            let personData = personDataArray[indexPath.row]
            if let name = personData.name{
                print("\(name)")
                personDataCell.nameLabel.text = name
            }
            if let title = personData.title{
                personDataCell.titleLabel.text = title
            }
            if let imageURLString = personData.image{
                if let imageURL = NSURL(string: imageURLString){
                    let request = NSURLRequest(URL: imageURL, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad , timeoutInterval: 5000)
                    let cachedURLResponse = NSURLCache.sharedURLCache().cachedResponseForRequest(request)
                    if cachedURLResponse == nil{
                        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
                        config.URLCache = NSURLCache.sharedURLCache()
                        config.URLCache = NSURLCache(memoryCapacity: 512000, diskCapacity: 10000, diskPath: "urlCache")
                        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
                        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                            guard error == nil && data != nil && response != nil else{
                                print("\(error)")
                                return
                            }
                            if rowIndex == personDataCell.currentRowIndex{ //check if the cell is already been reused
                                let img = UIImage(data: data!)
                                personDataCell.imgView.image = img
                            }
                            let cacheResponse = NSCachedURLResponse(response: response!, data: data!)
                            NSURLCache.sharedURLCache().storeCachedResponse(cacheResponse, forRequest: request)
                        }).resume()
                    }
                    else{
                        if rowIndex == personDataCell.currentRowIndex{  //check if the cell is already been reused
                            let img = UIImage(data: cachedURLResponse!.data)
                            personDataCell.imgView.image = img
                        }
                    }
                    
                }
            }
            if let dob = personData.dateOfBirth{
                let year = NSCalendar.currentCalendar().components(.Year, fromDate: dob, toDate: NSDate(), options: []).year
                personDataCell.ageLabel.text = "\(year)"
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
