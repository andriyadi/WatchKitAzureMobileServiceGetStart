//
//  ToDoEngine.swift
//  ZumoGetStart
//
//  Created by Andri Yadi on 4/9/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

import Foundation

class ToDoEngine {
    class var shared: ToDoEngine {
        struct Static {
            static let instance: ToDoEngine = ToDoEngine()
        }
        
        return Static.instance
    }
    
    lazy var client: MSClient = MSClient(applicationURLString: "https://ngoprek.azure-mobile.net/", applicationKey: "GPTSMqwKQWhjlaLkOVwFVUHJtgPFjE79")
    var todoTable: MSTable?
    
    init() {
        if let currentUserId = NSUserDefaults.standardUserDefaults().objectForKey("MOBILE_SERVICE_USER_ID") as? String {
            if let currentToken = NSUserDefaults.standardUserDefaults().objectForKey("MOBILE_SERVICE_TOKEN") as? String {
                self.client.currentUser = MSUser(userId: currentUserId)
                self.client.currentUser.mobileServiceAuthenticationToken = currentToken
            }
        }
    }
    
    func isSignedIn() -> Bool {
        if let currUser = self.client.currentUser {
            return true
        }
        return false
    }
    
    func signInWithTwitter(controller: UIViewController, completion: MSClientLoginBlock) {
        self.client.loginWithProvider("twitter", controller:controller, animated:true) {
            //trailing closure for completion handler
            (user, error) -> Void in
            if user != nil {
                NSUserDefaults.standardUserDefaults().setObject(user.userId, forKey: "MOBILE_SERVICE_USER_ID")
                NSUserDefaults.standardUserDefaults().setObject(user.mobileServiceAuthenticationToken, forKey: "MOBILE_SERVICE_TOKEN")
                self.registerSignedInUser(user);
            }
            completion(user, error)
        }
    }
    
    private func registerSignedInUser(user: MSUser) {
        let userTable = self.client.tableWithName("TodoUser")
        userTable?.insert(["userId": user.userId]){
            (item, error) in
            if let err = error {
                println("Error: " + err.description)
            }
        }
    }
    
    func getMyTasks(completed: Bool, completion: MSReadQueryBlock) {
        
        if !isSignedIn() {
            let error = NSError(domain: "ToDoList", code: 10, userInfo: ["localizedDescription": "Not signed in"])
            completion(nil, 0, error)
            return
        }
        
        let predicate = NSPredicate(format: "complete == %@ && (user == %@ || assigneeId == %@)", completed, self.client.currentUser.userId, self.client.currentUser.userId)
        
        if todoTable == nil {
            todoTable = self.client.tableWithName("UserTodoItem")
        }
        
        let query = todoTable?.queryWithPredicate(predicate)
        query?.includeTotalCount = true
        query?.selectFields = ["id", "text", "complete"]
        
        
        query?.readWithCompletion(completion)
    }
    
    func getMyUncompletedTasks(completion: MSReadQueryBlock) {
        getMyTasks(false, completion: completion)
    }
    
    func completeTask(task: NSMutableDictionary, completion: MSItemBlock) {
        task["complete"] = true
        
        if todoTable == nil {
            todoTable = self.client.tableWithName("UserTodoItem")
        }
        
        todoTable?.update(task as [NSObject : AnyObject], completion: completion)
    }
    
    func createTask(text: String, assigneeId: String?, photo: UIImage?, completion: MSItemBlock)
    {
        if text.isEmpty {
            return
        }
        
        let userId = self.client.currentUser.userId
        var itemToInsert:Dictionary<String, AnyObject> = ["text": text, "complete": false, "user": self.client.currentUser.userId]
        
        if let assigneeId = assigneeId {
            itemToInsert["assigneeId"] = assigneeId
        }
        else {
            itemToInsert["assigneeId"] = self.client.currentUser.userId
        }
        
        if let thePhoto = photo {
            let photoData = UIImageJPEGRepresentation(thePhoto, 0.9)
            let photoBase64 = photoData.base64EncodedStringWithOptions(nil)
            itemToInsert["photo"] = photoBase64
        }
        
        if todoTable == nil {
            todoTable = self.client.tableWithName("UserTodoItem")
        }
        
        todoTable?.insert(itemToInsert, completion: completion)
    }
}