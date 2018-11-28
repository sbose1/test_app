//
//  NotebksTableViewController.swift
//  FirebaseInClass01
//
//  Created by Snigdha Bose on 11/10/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit
import Firebase
class NotebksTableViewController: UITableViewController {
    
    let rootref = Database.database().reference()
    var notebooks:[NoteBook] = []
    let uuid = UserDefaults.standard.object(forKey: "uuid") as! String
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotebooks(uuid: uuid)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notebooks.count
    }
    
    @IBAction func creatNoteBook(_ sender: Any) {
        let addNotebookAlertController = UIAlertController(title: "Create new notebook", message: "Enter  Name", preferredStyle: UIAlertController.Style.alert)
        addNotebookAlertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Name"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction:UIAlertAction) in
            
            let textfield = addNotebookAlertController.textFields![0] as UITextField
            if let name = textfield.text{
                if name != ""{
                    let date = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
                    let ref = self.rootref.child("Notebooks").child(self.uuid).childByAutoId()
                    let object = [
                        "name" : notebookname,
                        "date" : date
                    ]
                    ref.setValue(object)
                    self.fetchNotebooks(uuid: self.uuid)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Exit", style: .default, handler: nil)
        
        addNotebookAlertController.addAction(cancelAction)
        
        self.navigationController?.present(addNotebookAlertController, animated: true, completion: nil)
    }
    @IBAction func logoutProfile(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "uuid")
        do {
            try Auth.auth().signOut()
        } catch let signoutError as NSError {
            print(signoutError.localizedDescription)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    func fetchNotebooks(uuid:String) {
        let refData = self.rootref.child("Notebooks").child(self.uuid)
        refData.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary{
                self.notebooks.removeAll()
                for value in values {
                    let key = value.key as! String
                    let object = value.value as? [String:Any]
                    let name = object!["name"] as! String
                    let date = object!["date"] as! String
                    let notebook = NoteBook(name: name, date: date, key: key)
                    self.notebooks.append(notebook)
                }
                self.tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notebook", for: indexPath)
        let notebook = notebooks[indexPath.row]
        cell.textLabel?.text = notebook.name
        cell.detailTextLabel?.text = "notebook.date"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notebook = notebooks[indexPath.row]
        let notebookKey = notebook.key
        performSegue(withIdentifier: "showNotes", sender: notebookKey)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let key = sender as? String{
            let notesVC = segue.destination as? NotesTableViewController
            notesVC?.key = key
        }
    }
    
    
    
}
