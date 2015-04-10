//
//  TaskDetailInterfaceController.swift
//  ZumoGetStart
//
//  Created by Andri Yadi on 4/7/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

import WatchKit
import Foundation


class TaskDetailInterfaceController: WKInterfaceController {

    @IBOutlet weak var taskLabel: WKInterfaceLabel!
    
    @IBOutlet weak var completingSwitch: WKInterfaceSwitch!
    
    var task:Dictionary<String, AnyObject>?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        self.setTitle("Task")
        //println(context)
        if let theTask = context as? Dictionary<String, AnyObject> {
            self.task = theTask
            taskLabel.setText(theTask["text"] as? String)
            completingSwitch.setOn(theTask["complete"] as Bool)
        }
    }
    
    @IBAction func taskSwitchChanged(value: Bool) {
        //println("Switch \(value)")
        
        let userInfo = ["action": "completeTask", "data": self.task!]
        WKInterfaceController.openParentApplication(userInfo, reply: { (replyInfo, error) -> Void in
            println("Reply: \(replyInfo)")
        })
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
