//
//  ViewController.swift
//  coredata-device
//
//  Created by Brian Bansenauer on 10/13/19.
//  Copyright © 2019 Cascadia College. All rights reserved.
//

import UIKit
import CoreData //CREATE AND USE A CORE DATA ENTITY MODEL #3

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    // refactor in-app storage to use NSManagedObject array
    var devices:[NSManagedObject] = []
    
    // cordata reqires a context
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // use of lazy allows late assignment declared before constructor
    lazy var device = NSEntityDescription.entity(forEntityName: "Device", in: managedContext)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Devices"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // Overrides viewWillAppear to fetch data from storage
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        do {
            devices = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
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
                return // ignores error condition
            }
            
            // save and reload
            let result = self.save(with: serialNumber)
            if result {
                self.tableView.reloadData()
                self.viewWillAppear(true)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(with serialNumber:String) -> Bool {
        var result : Bool = true // will become false on error
        
        //Instantiate and initialize a new entity, saving the serial number
        do {
            let newDevice = NSManagedObject(entity: device, insertInto: managedContext)
            newDevice.setValue(serialNumber, forKey: "serialNumber")
            try managedContext.save()
        } catch {
            result = false
        }
        
        
        // DISPLAY THE RESULTS
        // Create a tuple with result message and duration
        let display = ( result
                            ? (message: "Device Saved", duration: 2.0)
                            : (message: "Error Saving Device", duration: 5.0)
        )
        
        
        // Display the message
        let alert = UIAlertController(title: nil, message: display.message, preferredStyle: .alert)
        
        self.present(alert, animated: true)

        // Dismiss the message based on duration
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + display.duration) {
            alert.dismiss(animated: true)
        }
        
        // Returns true on success
        return result
    }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
extension ViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //TODO: refactor to get the device object and use it's value(forKeyPath: ) method to pull the serialNumber text
        cell.textLabel?.text = devices[indexPath.row].value(forKeyPath: "serialNumber") as? String
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
