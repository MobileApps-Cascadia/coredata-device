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
        
        //EXTRA CREDIT PT 1
        //fetchRequest.predicate = NSPredicate(format: "type like \"ipad\"")
        
      //3
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
        let saveAction = UIAlertAction(title: "Save", style: .default) {
          [unowned self] action in
          
          guard let serialNumber = alert.textFields?.first,
            let serialNumberToSave = serialNumber.text else {
              return
          }
            guard let type = alert.textFields?[1],
                    let typeToSave = type.text else {
                return
            }
          
            self.save(serial: serialNumberToSave, type: typeToSave)
          self.tableView.reloadData()
        }

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(serial: String, type: String) {
      
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
      
      let device = NSManagedObject(entity: entity,
                                   insertInto: managedContext)

      //UUID Assignment
        let uuid = NSUUID()
        
      
      // 3
      device.setValue(serial, forKeyPath: "serialNumber")
        device.setValue(type, forKeyPath: "type")
        device.setValue(uuid, forKeyPath: "id")
      
      // 4
      do {
        try managedContext.save()
        devices.append(device)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
    extension ViewController: UITableViewDataSource {
      func tableView(_ tableView: UITableView,
                     numberOfRowsInSection section: Int) -> Int {
        return devices.count
      }

      func tableView(_ tableView: UITableView,
                     cellForRowAt indexPath: IndexPath)
                     -> UITableViewCell {

        let device = devices[indexPath.row]
           
        let cell =
          tableView.dequeueReusableCell(withIdentifier: "Cell",
                                        for: indexPath)
        cell.textLabel?.text =
          device.value(forKeyPath: "serialNumber") as? String
        
        return cell
      }
    }

