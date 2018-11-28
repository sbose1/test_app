//
//  NotesTableViewController.swift
//  FirebaseInClass01
//
//  Created by Snigdha Bose on 11/10/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit
import Firebase
class NotesTableViewController: UITableViewController {
    var key:String?
    let rootref = Database.database().reference()
    var notes:[Note] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func createNotes(_ sender: Any) {
        let addNoteAlertController = UIAlertController(title: "Create", message: "Enter Text here", preferredStyle: UIAlertController.Style.alert)
        addNoteAlertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Sample"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction:UIAlertAction) in
            
            let textfield = addNoteAlertController.textFields![0] as UITextField
            if let notesText = textfield.text{
                if notesText != ""{
                    let date = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
                    let noteItem = self.rootref.child("Notes").child(self.key!).childByAutoId();
                    let obj = [
                        "post" : notesText,
                        "date" : date
                    ]
                    noteItem.setValue(obj)
                    self.getNotesFromNotebook(key: self.key!)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel Action", style: .default, handler: nil)
        addNoteAlertController.addAction(okAction)
        addNoteAlertController.addAction(cancelAction)
        self.navigationController?.present(addNoteAlertController, animated: true, completion: nil)    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath) as! NoteTableViewCell
        let note = notes[indexPath.row]
        cell.note.text = note.post
        cell.date.text = note.date
        cell.delete.tag = indexPath.row
        return cell
    }
    
    
    func fetchNotes(key:String) {
        let item = self.rootref.child("Notes").child(self.key!)
        item.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary{
                self.notes.removeAll()
                for value in values {
                    let key = value.key as! String
                    let object = value.value as? [String:Any]
                    let post = object!["post"] as! String
                    let date = object!["date"] as! String
                    let note = Note(post: post, date: date, key: key)
                    self.notes.append(note)
                }
                
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func delete(_ sender: UIButton) {
        print(sender.tag)
        let del = notes[sender.tag]
        let ref = self.rootref.child("Notes").child(self.key!).child(del.key)
        ref.removeValue()
        notes.remove(at: sender.tag)
        self.fetchNotes(key: self.key!)
    }
    
    
}
