// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func loadTasks(reply: (([NSObject : AnyObject]!) -> Void)!) {
        
        ToDoEngine.shared.getMyUncompletedTasks { (result, recordCount, error) -> Void in
            if error != nil {
                reply(["error": error.localizedDescription])
                println("Error: \(error)")
            }
            else {
                reply(["data": result])
                println("Result: \(result)")
            }
        }
        
    }
    
    func completeTask(task: Dictionary<String, AnyObject>, reply: (([NSObject : AnyObject]!) -> Void)!) {
        
        let mutTask = (task as NSDictionary).mutableCopy() as NSMutableDictionary
        
        mutTask["complete"] = true
        
        ToDoEngine.shared.completeTask(mutTask, completion: { (result, error) -> Void in
            if error != nil {
                reply(["error": error.localizedDescription])
                println("Error: \(error)")
            }
            else {
                reply(["data": result])
                println("Result: \(result)")
            }
        })
    }
    
    func application(application: UIApplication!, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]!, reply: (([NSObject : AnyObject]!) -> Void)!) {

        if let action = userInfo["action"] as? String {
            if action == "loadTasks" {
                println("userInfo: \(userInfo)")
                //reply(["reply": "OK"])
                
                loadTasks (reply)
            }
            else if action == "completeTask" {
                if let data = userInfo["data"] as? Dictionary<String, AnyObject> {
                    completeTask(data, reply: reply)
                }
            }
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        
        let appearance = UINavigationBar.appearance()
        
        appearance.barTintColor = UIColor(red: 69.2/255.0, green: 177.2/255.0, blue: 255.0/255.0, alpha: 1.0)
        appearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont(name: "Helvetica-Light", size: 20.0)!]
        appearance.tintColor = UIColor.whiteColor()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

