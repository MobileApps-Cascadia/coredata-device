//
//  ViewController.swift
//  coredata-device
//
//  Created by Brian Bansenauer on 10/13/19.
//  Copyright © 2019 Cascadia College. All rights reserved.
//

import CoreData
import UIKit

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
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        fetchRequest.predicate = NSPredicate(format: "type == %@", "iPad")

        //3
        do {
            devices = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print ( " Could not fetch. \(error), \(error.userInfo)")
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
            
//            self.save(with: serialNumber, type, id)
           
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(with serialNumber:String, type:String, id: UUID) {
        //TODO:Use the MOC with the Device entity to create a newDevice object, update it's property and save it to persistent storage
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext)!
        
        let newDevice = NSManagedObject(entity: entity, insertInto: managedContext)
        
       
        newDevice.setValue(serialNumber, forKey: "serialNum")
        newDevice.setValue(type, forKey: "type")
        
        newDevice.setValue(id, forKey: "id")
        
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //TODO: refactor to get the device object and use it's value(forKeyPath: ) method to pull the serialNumber text
        let newDevice = devices[indexPath.row]
        cell.textLabel?.text = newDevice.value(forKeyPath: "serialNum") as? String
        let serialNum = newDevice.value(forKey: "serialNum") as? String
        let type = newDevice.value(forKey: "type") as? String
        let id = newDevice.value(forKey: "id")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
