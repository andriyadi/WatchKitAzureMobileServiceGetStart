
import Foundation
import UIKit

class ToDoTableViewController: UITableViewController, ToDoItemDelegate {
    
    var records = [NSMutableDictionary]()
    private lazy var imageCache: NSMutableDictionary = NSMutableDictionary(capacity: 10)
    var table : MSTable?
    var viewDidAppearOnce = false
    
    var engine: ToDoEngine = ToDoEngine.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (viewDidAppearOnce) {
            return
        }
        
        viewDidAppearOnce = true
        
        if engine.isSignedIn() {
            refresh()
        }
        else {
            signin()
        }
    }
    
    func signin() {
        engine.signInWithTwitter(self, completion: { (user, error) -> Void in
            if user != nil {
                self.refresh()
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "addItem" {
            let todoController = segue.destinationViewController as! ToDoItemViewController
            todoController.delegate = self
        }
    }
    
    func refresh() {
        self.refreshControl?.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl?.beginRefreshing()
        self.onRefresh(self.refreshControl)
    }
    
    func onRefresh(sender: UIRefreshControl!) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        engine.getMyUncompletedTasks { (result, recordCount, error) -> Void in
            self.refreshControl?.endRefreshing()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                println("Error: " + error.description)
                
                let alert = UIAlertController(title: "Oppss...", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                    (action) -> Void in
                    if error.code == -1302 {
                        self.engine.client.logout()
                        self.signin()
                    }
                })
                
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                
                
                
            }
            else {
                self.records = result as! [NSMutableDictionary]
                println("Information: retrieved %d records", result.count)
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Table
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!
    {
        return "Complete"
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        let record = self.records[indexPath.row]

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        engine.completeTask(record, completion: { (result, error) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                println("Error: " + error.description)
            }
            else {
                self.records.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        })
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.records.count
    }
    
    func loadImageForIndexPath(indexPath: NSIndexPath) {
        let record = self.records[indexPath.row]
        let recordId = record["id"] as! String!
        
        if let image = self.imageCache[recordId] as? UIImage {
            
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
                cell.imageView?.image = image
            }
        }
        else {
            
            let predicate = NSPredicate(format: "id == %@", record["id"] as! String!)
            let query = self.table?.queryWithPredicate(predicate)
            
            weak var wself: ToDoTableViewController? = self
            
            query?.fetchLimit = 1
            query?.selectFields = ["photo"]
            query?.readWithCompletion({ (results, recordCount, error) -> Void in
                if results.count > 0 {
                    if let cell = wself?.tableView.cellForRowAtIndexPath(indexPath) {
                        
                        if let imageBase64 = results[0]["photo"] as? String {
                            //let imageBase64 = results[0]["photo"] as String
                            record["photo"] = imageBase64
                            let imageData = NSData(base64EncodedString: imageBase64, options: NSDataBase64DecodingOptions())!
                            let image = UIImage(data: imageData)
                            
                            self.imageCache[recordId] = image
                            
                            cell.imageView?.image = image
                            cell.setNeedsLayout()
                        }
                    }
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let item = self.records[indexPath.row]
        
        cell.textLabel?.text = item["text"] as? String
        cell.textLabel?.textColor = UIColor.blackColor()
        
        loadImageForIndexPath(indexPath)
        
        return cell
    }
    
    // Navigation
    
    @IBAction func addItem(sender : AnyObject) {
        self.performSegueWithIdentifier("addItem", sender: self)
    }
    
    @IBAction func unwindFromItemForm(segue: UIStoryboardSegue?) {
        
    }
    
    // ToDoItemDelegate

    func didSaveItem(text: String, assigneeId: String?, photo: UIImage?, completion: (NSError?, NSDictionary?) -> Void)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        engine.createTask(text, assigneeId: assigneeId, photo: photo) {
            (item, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                println("Error: " + error.description)
                completion(error, nil)
                
            } else {
                let newItem = NSMutableDictionary(dictionary: item)
                self.records.append(newItem)
                self.tableView.reloadData()
                
                completion(nil, newItem)
            }
        }
    }
}
