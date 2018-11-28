//
//  ImageViewController.swift
//  FirebaseInClass01
//
//  Created by Snigdha Bose on 11/25/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit
import Firebase
class ImageViewController: UIViewController {
    
    
    
    var key:String?
    
    let root = Database.database().reference()
    
    let storage = Storage.storage()
    let uuid = UserDefaults.standard.object(forKey: "uuid") as! String
    var url:URL?
    var date:String?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.downloadedFrom(url: url!)
        
    }
    
   
    
    @IBAction func delete(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Remove", message: "Do you want to proceed", preferredStyle: UIAlertController.Style.alert)
        //delete action
        let clickOhk = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
            let savedInsatnce = self.storage.reference(withPath: "Images/\(self.uuid)/\(self.date!).jpg")
            
            let imageRef = self.root.child("Users").child(self.uuid).child("Images").child(self.key!)
            imageRef.removeValue()
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(clickOhk)
        //for cacel action
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
}
