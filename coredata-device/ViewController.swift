//
//  ViewController.swift
//  coredata-device
//
//  Created by Brian Bansenauer on 10/13/19.
//  Copyright © 2019 Cascadia College. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    //TODO: refactor in-app storage to use NSManagedObject array
    var serialNumbers:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Devices"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        //1 get a reference to appdelegate again like in
        guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext =
              appDelegate.persistentContainer.viewContext
        //2
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Device")
        
        //add predicate 
        let deviceType = "ipad"
        
        fetchRequest.predicate = NSPredicate(format: "type == %@", deviceType)
        //3
        do {
              serialNumbers = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
        
        
    }

    @IBAction func addDevice(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Device", message: "Enter Device Serial Number", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            action in
            guard let textField = alert.textFields?.first,
                  let serialNumber = textField.text else
            {
                return
            }
            //call the save() to update the model and not the array append
            self.save(with: serialNumber)
            //self.serialNumbers.append(serialNumber)
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(with serialNumber:String){
        //TODO:Use the MOC with the Device entity to create a newDevice object, update it's property and save it to persistent storage
        
        guard let appDelegate =
               UIApplication.shared.delegate as? AppDelegate else {
               return
             }
        // 1 get a NSManagedObjectContex an inmemory scratchpad for working with managed objects
        let managedContext =
          appDelegate.persistentContainer.viewContext
        //2 Use the MOC with the Device entity to create a newDevice object, update it's property and save it to persistent storage

        let entity =
          NSEntityDescription.entity(forEntityName: "Device",
                                     in: managedContext)!
        
        let newDevice = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        // 3 must spell the name attribute the same as it appears in the data model. this sets the attribute using keyvalue pair
         newDevice.setValue(serialNumber, forKeyPath: "serialNumber")
             
        //4 commint changes to the serialNumbers
        do {
          try managedContext.save()
          serialNumbers.append(newDevice)
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
extension ViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //TODO: refactor to get the device object and use it's value(forKeyPath: ) method to pull the serialNumber text
     let serialNumber = serialNumbers[indexPath.row]
        
        cell.textLabel?.text = serialNumber.value(forKeyPath: "serialNumber") as? String//serialNumber[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serialNumbers.count
    }
}
