//
//  CollectionViewController.swift
//  FirebaseInClass01
//
//  Created by Snigdha Bose on 11/25/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit
import Firebase
private let reuseIdentifier = "Custom"

class CollectionViewController: UICollectionViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    let imagePicker = UIImagePickerController()
    let uuid = UserDefaults.standard.object(forKey: "uuid") as! String
    var imageColl = [UIImage]()
    
    let rootref = Database.database().reference()
    let storage = Storage.storage()
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(activityIndicator)
        imagePicker.delegate = self
        getPhotos()
    }
    
    
    var arrayPhotos:[NSDictionary] = [NSDictionary]()
    override func viewWillAppear(_ animated: Bool) {
        arrayPhotos.removeAll()
        getPhotos()
    }
    
    @IBAction func pressAdd(_ sender: UIBarButtonItem) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @objc func imageController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageColl.append(pickedImage)
        dismiss(animated: true, completion: nil)
        
        
        
        
        var status = false
        let date = Date()
        let storageRef = storage.reference(withPath: "Images/\(self.uuid)/\(date).jpg")
        let imageData:Data = pickedImage.jpegData(compressionQuality: 0.5)!
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let task = storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                
                status = false
            } else {
                
                var urltemp: String!
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error!!")
                        return
                    }
                    urltemp = downloadURL.absoluteString
                    
                    status = true
                    
                    //check upload success
                    let stringURL = downloadURL.absoluteString
                    let imageRef = self.rootref.child("Users").child(self.uuid).child("Images").childByAutoId()
                    let imageObject = [
                        "ref" : imageRef.key,
                        "url" : stringURL,
                        "date": String(date.timeIntervalSince1970)
                    ]
                    imageRef.setValue(imageObject)
                    self.activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                    getPhotos()
                }
                
                
            }
        }
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        //reload
        collectionView?.reloadData()
        
    }
    
    
    func imageControllerDidCancel(_ imagePicker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    func getPhotos() {
        let ref = self.rootref.child("Users").child(self.uuid).child("Images")
        ref.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if let values = snapshot.value as? NSDictionary{
                self.arrayPhotos.removeAll()
                for value in values{
                    let object = value.value as? [String:Any]
                    let url = object!["url"] as! String
                    let ref = object!["ref"] as! String
                    let date = object!["date"] as! String
                    
                    
                    let dictionaryObject = [
                        "url" : url,
                        "ref" : ref,
                        "date": date
                    ]
                    self.arrayPhotos.append(dictionaryObject as NSDictionary)
                }
                
            }
            self.collectionView?.reloadData()
        }
        
    }
    
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrayPhotos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let thisCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomCollectionViewCell
        
        let imageObject = arrayPhotos[indexPath.row]
        let imageURL = URL.init(string: urlText)
        let urlText = imageObject.object(forKey: "url") as! String
        thisCell.image.getImageFromURL(url: imageURL!)
        
        return thisCell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       performSegue(withIdentifier: "viewPhoto", sender: indexPath.row)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPhoto" {
            let picView = segue.destination as! PhotoViewController
            
            let index = sender as! Int
            let imageObject = arrayPhotos[index]
            let urlText = imageObject.object(forKey: "url") as! String
            let imageURL = URL.init(string: urlText)
            picView.imageKey = imageObject.object(forKey: "ref") as! String
            picView.imageURL = imageURL
            picView.date = imageObject.object(forKey: "date") as! String
            
        }
    }
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        UserDefaults.standard.removeObject(forKey: "uuid")
        do {
            try Auth.auth().signOut()
        } catch let signoutError as NSError {
            print(signoutError.localizedDescription)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}


extension UIImageView {
    
    func getImageFromURL(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
      contentMode = mode
      URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
               let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
             self.image = image
            }
            }.resume()
        
    }
    
    
    
}

