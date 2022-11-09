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
    var friends: [NSManagedObject] = []

    
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
        NSFetchRequest<NSManagedObject>(entityName: "Friends")
      
      //3
      do {
        friends = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }


    @IBAction func addDevice(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Friends", message: "Enter your friends name", preferredStyle: .alert)
        
//        let aler = UIAlertController(title: "New Friends", message: "Enter your friends lastname", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            action in
            guard let textField = alert.textFields?.first,
                  let firstname = textField.text else
            {
                return
            }
            
            self.save(name: firstname)
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(name: String) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      // 1
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      // 2
      let entity =
        NSEntityDescription.entity(forEntityName: "Friends",
                                   in: managedContext)!
      
      let person = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      // 3
      person.setValue(name, forKeyPath: "firstname")
      
      // 4
      do {
        try managedContext.save()
        friends.append(person)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return friends.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
                 -> UITableViewCell {

    let person = friends[indexPath.row]
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "Cell",
                                    for: indexPath)
    cell.textLabel?.text =
      person.value(forKeyPath: "firstname") as? String
    return cell
  }
}

