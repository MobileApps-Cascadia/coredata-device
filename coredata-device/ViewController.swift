//
//  ViewController.swift
//  coredata-device
//
//  Created by Brian Bansenauer on 10/13/19.
//  Copyright © 2019 Cascadia College. All rights reserved.
//

import UIKit
import CoreData

class Cell: UITableViewCell {
    
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDelegate {
    //TODO: refactor in-app storage to use NSManagedObject array
    @IBOutlet weak var tableView: UITableView!
    
    var devices: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Devices"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        //filters Devices with type of ipad
        //fetchRequest.predicate = NSPredicate(format: "type LIKE %@", "ipad")
      
        do {
            devices = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    @IBAction func addDevice(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Device", message: "Enter Device Serial Number", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Serial Number"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Type"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            action in
            let serialNumber = alert.textFields![0] as UITextField
            let type = alert.textFields![1] as UITextField
            self.save(with: serialNumber.text!, type: type.text!)
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(with serialNumber:String, type: String){
        //TODO:Use the MOC with the Device entity to create a newDevice object, update it's property and save it to persistent storage
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext)!
        let newDevice = NSManagedObject(entity: entity, insertInto: managedContext)
        let uuid = NSUUID()

        newDevice.setValue(uuid, forKeyPath: "id")
        newDevice.setValue(serialNumber, forKeyPath: "serialNumber")
        newDevice.setValue(type, forKeyPath: "type")
        
        do {
          try managedContext.save()
            devices.append(newDevice)
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }

    }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
extension ViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! Cell
        //TODO: refactor to get the device object and use it's value(forKeyPath: ) method to pull the serialNumber text
        let device = devices[indexPath.row]
        let serialNumber = device.value(forKeyPath: "serialNumber") as? String
        let type = device.value(forKeyPath: "type") as? String
        let id = device.value(forKeyPath: "id")
//        cell.textLabel?.text = "\(serialNumber!), \(type!), \(id!)"
        cell.idLabel.text = "\(id!)"
        cell.typeLabel.text = type!
        cell.serialNumberLabel.text = serialNumber!
        
        
//        serialNumberLabel.text = device.value(forKeyPath: "serialNumber") as? String
//        typeLabel.text = device.value(forKeyPath: "type") as? String
//        idLabel.text = device.value(forKeyPath: "id") as? String
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
