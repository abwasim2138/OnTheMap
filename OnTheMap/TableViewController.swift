//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Abdul-Wasai Wasim on 2/4/16.
//  Copyright © 2016 Laylapp. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard StudentCollection.studentCollection.students.count != 0 else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alertController = UIAlertController(title: "Failed To Download Info", message: "", preferredStyle: .Alert)
                let okayAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okayAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            })
            return
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentCollection.studentCollection.students.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let student = StudentCollection.studentCollection.students[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text =  "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mapString
    
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var http = "http://"
         let urlString = StudentCollection.studentCollection.students[indexPath.row].mediaURL
            if urlString.containsString("//") == true {
                http = ""
                }
            if let url = NSURL(string: http + urlString) {
                UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        APIClient.logout { (result, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else{
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        tableView.reloadData()
    }


}
