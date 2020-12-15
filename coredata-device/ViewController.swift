//
//  ViewController.swift
//  coredata-device
//
//  Created by Brian Bansenauer on 10/13/19.
//  Copyright © 2019 Cascadia College. All rights reserved.
//

import UIKit
import CoreData

class SubtitleTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "Cell")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    //TODO: refactor in-app storage to use NSManagedObject array
    var devices:[NSManagedObject] = []
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Devices"
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        
    }
    
    @IBAction func addDevice(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Device", message: "Enter Device Serial Number and Type", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { action in
            
            guard let serialNumberTextField = alert.textFields?.first, let serialNumber = serialNumberTextField.text else { return }
            guard let deviceTypeTextField = alert.textFields?[1], let deviceType = deviceTypeTextField.text else { return }
            self.save(with: serialNumber, with: deviceType)
            self.reload()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(with serialNumber: String, with deviceType: String){
        //TODO:Use the MOC with the Device entity to create a newDevice object, update it's property and save it to persistent storage
        let newDevice = NSManagedObject(entity: entity, insertInto: managedContext)
        let id = UUID()
        newDevice.setValue(serialNumber, forKey: "serialNumber")
        newDevice.setValue(deviceType, forKey: "type")
        newDevice.setValue(id, forKey: "id")
        do {
            try managedContext.save()
//            print("device with serial number \(serialNumber), type \(deviceType), and id \(id) saved")
        } catch {
            print("error saving context")
        }
    }
    
    func reload(){
        let request = Device.fetchRequest() as NSFetchRequest<Device>
        let predicate = NSPredicate(format: "type == %@", "iPad")
        request.predicate = predicate
        if let fetchedDevices = try? managedContext.fetch(request) as [Device] {
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
        let device = devices[indexPath.row]
        let serialNumber = device.value(forKeyPath: "serialNumber") as? String ?? ""
        let deviceType = device.value(forKeyPath: "type") as? String ?? ""
        let id = (device.value(forKey: "id") as? UUID)?.uuidString ?? ""
        
        cell.textLabel?.text = serialNumber
        cell.detailTextLabel?.text = deviceType + " - " + id
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
