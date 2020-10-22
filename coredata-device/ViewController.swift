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
    var serialNumberArray:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "DeviceEntity"
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
        NSFetchRequest<NSManagedObject>(entityName: "DeviceEntity")
      
      //3
      do {
        serialNumberArray = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }



    @IBAction func addDevice(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Device", message: "Enter Device Serial Number", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
          [unowned self] action in
          
          guard let textField = alert.textFields?.first,
            let serialNumberToSave = textField.text else {
              return
          }
          
          self.save(serialNumberVar: serialNumberToSave)
          self.tableView.reloadData()
        }

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(serialNumberVar:String){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
          
          // 1
          let managedContext =
            appDelegate.persistentContainer.viewContext
          
          // 2
          let entity =
            NSEntityDescription.entity(forEntityName: "DeviceEntity",
                                       in: managedContext)!
          
          let device = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
          
          // 3
          device.setValue(serialNumberVar, forKeyPath: "serialNumberAttribute")
          
          // 4
          do {
            try managedContext.save()
            serialNumberArray.append(device)
          } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
          }
        }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return serialNumberArray.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
                 -> UITableViewCell {

    let device = serialNumberArray[indexPath.row]
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "Cell",
                                    for: indexPath)
    cell.textLabel?.text =
      device.value(forKeyPath: "serialNumberAttribute") as? String
    return cell
  }
}


