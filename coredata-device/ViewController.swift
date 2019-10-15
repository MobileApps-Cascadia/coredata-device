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

    
    var devices: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Devices"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Device")
        
        let myType: String = "iPad"
        
        fetchRequest.predicate = NSPredicate(format: "type == %@", myType)
        //3
        do {
            devices = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    @IBAction func addDevice(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Device", message: "Enter Device Serial Number then Type", preferredStyle: .alert)
        
        alert.addTextField()
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                  let serialNumber = textField.text else {
                return
            }
            
            guard let typeField = alert.textFields?[1], let deviceType = typeField.text else {return}
            
            self.save(with: serialNumber, deviceType: deviceType)
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(with serialNumber:String, deviceType: String){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Device",
                                       in: managedContext)!
        
        let newDevice = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        let uuid = NSUUID() // generate a UUID

        newDevice.setValue(serialNumber, forKeyPath: "serialNumber")
        newDevice.setValue(deviceType, forKey: "type")
        newDevice.setValue(uuid, forKey: "id")
        
        // 4
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

        let device = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellReuseID", for: indexPath) as! CellTableViewCell

        cell.uuidField?.text = "ID: \(device.value(forKeyPath: "id") as? String ?? "-")"
        
        cell.serialNumberField?.text = "serial #: \(device.value(forKeyPath: "serialNumber") as? String ?? "-")"
        cell.deviceTypeField?.text = "type: \(device.value(forKeyPath: "type") as? String ?? "-")"
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
