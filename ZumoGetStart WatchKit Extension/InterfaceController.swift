//
//  InterfaceController.swift
//  ZumoGetStart WatchKit Extension
//
//  Created by Andri Yadi on 4/7/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    var records:[Dictionary<String, AnyObject>] = []
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    @IBOutlet weak var activityImage: WKInterfaceImage!
    @IBOutlet weak var errorLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.errorLabel.setHidden(true)
        self.setTitle("Loading...")
    }
    
    @IBAction func refreshData() {
        loadData()
    }
    
    func configureTable() {
        tableView.setNumberOfRows(records.count, withRowType: "taskRowType")
        
        for (index, val) in enumerate(records) {
            if let taskRow = tableView.rowControllerAtIndex(index) as? TaskRowController {
                let taskName = val["text"] as! String
                taskRow.taskLabel.setText(taskName)
            }
        }
        
        self.errorLabel.setHidden(true)
        self.tableView.setHidden(false)
        self.activityImage.setHidden(true)
        self.setTitle("Tasks")
    }
    
    func showError(msg: String) {
        self.activityImage.setHidden(true)
        self.errorLabel.setHidden(false)
        self.errorLabel.setText(msg)
    }
    
    func loadData() {
        self.errorLabel.setHidden(true)
        self.tableView.setHidden(true)
        
        self.activityImage.setHidden(false)
        self.activityImage.setActivityIndicatorImageWithColor(UIColor(red: 0.8588, green:0.0196, blue:0.0706, alpha:1.0))
        
        WKInterfaceController.openParentApplication(["action": "loadTasks"], reply: { (replyInfo, error) -> Void in
            //println("Reply: \(replyInfo)")
            
            if error != nil {
                self.showError(error.localizedDescription)
            }
            
            let replyDict = replyInfo as [NSObject : AnyObject]
            if let errorMsg = replyDict["error"] as? String {
                if !errorMsg.isEmpty {
                    self.showError(errorMsg)
                    return
                }
            }
            
            self.records = replyDict["data"] as! [Dictionary<String, AnyObject>]
            self.configureTable()
        })
    }
        

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return records[rowIndex]
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //configureTable()
        loadData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
