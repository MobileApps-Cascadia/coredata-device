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
    var devices:[NSManagedObject] = []
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Devices"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        
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
            
            self.save(with: serialNumber)
            self.reload()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(with serialNumber:String){
        //TODO:Use the MOC with the Device entity to create a newDevice object, update it's property and save it to persistent storage
        let newDevice = NSManagedObject(entity: entity, insertInto: managedContext)
        newDevice.setValue(serialNumber, forKey: "serialNumber")
        
        do {
            try managedContext.save()
            print("device with serial number \(serialNumber) saved")
        } catch {
            print("error saving context")
        }
    }
    
    func reload(){
        if let fetchedDevices = try? managedContext.fetch(Device.fetchRequest()) as [Device] {
            devices = fetchedDevices
        }
        tableView.reloadData()
    }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
extension ViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //TODO: refactor to get the device object and use it's value(forKeyPath: ) method to pull the serialNumber text
        if let serialNumber = devices[indexPath.row].value(forKeyPath: "serialNumber") as? String {
            cell.textLabel?.text = serialNumber
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
