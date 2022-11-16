//
//  ViewController.swift
//  coredata-device
//
//  Created by Brian Bansenauer on 10/13/19.
//  Copyright © 2019 Cascadia College. All rights reserved.

//  Core Data Exploration

import CoreData
import UIKit
class Cell: UITableViewCell {
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    //TODO: refactor in-app storage to use NSManagedObject array
    var devices: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Devices"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1 pull up the AppDelegate file
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // and get a ref to NSManagedObjectContext
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2 NSFetchRequest is the class responsible for fetching from Core Data.
        // Fetch requests have several qualifiers used to refine the set of results returned. For now, you should know NSEntityDescription is one of these required qualifiers.
        // NSFetchRequest is a generic type. This use of generics specifies a fetch request’s expected return type, in this case NSManagedObject
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
       
        // Bonus part 1: Add a predicate to the fetch request to display only iPad device types. Feel free to creatively populate the device type data in your code.
        // filters Devices of type iPad or iPhone, while ignoring others
//        fetchRequest.predicate = NSPredicate(format: "(type == %@ || type == %@)", "iPad", "iPhone")
        fetchRequest.predicate = NSPredicate(format: "type like \"iPad\"", "type like \"iPhone\" ")
        
        //3
        do {
            devices = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print ( " Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addDevice(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Device", message: "Enter Device Serial Number", preferredStyle: .alert)
        
        alert.addTextField { ( textField) in textField.placeholder = "Serial Number" }
        alert.addTextField { ( textField) in textField.placeholder = "Device Type" }
        // Add an additional text field for device types in the Alert dialog

        
        // Save Button
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
           [unowned self] action in
            guard let textField = alert.textFields?[0],
                  let serialNumber = textField.text else { return }
                
            guard let textField2 = alert.textFields?[1],
                  let type = textField2.text else { return }
            
            self.save(serialNumber: serialNumber, type: type)
           
            self.tableView.reloadData()
        })
        
        // Cancel Button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
//        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    // Takes the text in the text fields and passes it over to a new method
    func save(serialNumber:String, type:String) {
       
        //TODO:Use the MOC with the Device entity to create a newDevice object, update it's property and save it to persistent storage
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1 Before you can save or retrieve anything from your Core Data store, you first need to get your hands on an NSManagedObjectContext.
        //   You can consider a managed object context as an in-memory “scratchpad” for working with managed objects.
        //    Think of saving a new managed object to Core Data as a two-step process: first, you insert a new managed object into a managed object context;
        //    once you’re happy, you “commit” the changes in your managed object context to save it to disk.
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        // 2  You create a new managed object and insert it into the managed object context. You can do this in one step with NSManagedObject’s static method: entity(forEntityName:in:)
        //    NSManagedObject was called a shape-shifter class because it can represent any entity.
        //   An entity description is the piece linking the entity definition from your Data Model with an instance of NSManagedObject at runtime.
        let entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext)!
        
        
        // 3  With an NSManagedObject in hand, you set the name attribute using key-value coding.
        //    You must spell the KVC key (name in this case) exactly as it appears in your Data Model, otherwise, your app will crash at runtime
        let newDevice = NSManagedObject(entity: entity, insertInto: managedContext)
       
        let uuid = NSUUID()
        
        newDevice.setValue(serialNumber, forKey: "serialNum")
        newDevice.setValue(type, forKey: "type")
        newDevice.setValue(uuid, forKey: "id")
        
        // 4  You commit your changes to person and save to disk by calling save on the managed object context
        //    Note save can throw an error, which is why you call it using the try keyword within a do-catch block.
        //    Finally, insert the new managed object into the people array so it shows up when the table view reloads.
        do {
            try managedContext.save()
            devices.append(newDevice)
        } catch let error as NSError {
            print ( " Could not save. \(error), \(error.userInfo)")
        }
        
    }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
extension ViewController:UITableViewDataSource{
    
    // dequeues table view cells and populates them with the corresponding string from the items[] array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! Cell
        // TODO: refactor to get the device object and use it's value(forKeyPath: ) method to pull the serialNumber text
        let newDevice = devices[indexPath.row]
                
//        cell.textLabel?.text = newDevice.value(forKeyPath: "serialNum") as? String

        let serialNum = newDevice.value(forKey: "serialNum") as? String
        let type = newDevice.value(forKey: "type") as? String
        let id = newDevice.value(forKey: "id")
        cell.serialNumberLabel.text = serialNum!
        cell.typeLabel.text = type!
        cell.idLabel.text = "\(id!)"
        
        cell.serialNumberLabel.text = newDevice.value(forKeyPath: "serialNum") as? String
        cell.typeLabel.text = newDevice.value(forKeyPath: "type") as? String
        cell.idLabel.text = newDevice.value(forKeyPath: "id") as? String

        
        
        return cell
    }
    
    // returns the total number of rows in the table as the number of items in our items[String] array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
