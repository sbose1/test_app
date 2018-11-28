//
//  LoginViewController.swift
//  FirebaseInClass01
//
//  Created by Snigdha Bose on 11/9/18.
//  Copyright © 2018 UNC Charlotte. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
   
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "notebooksegue", sender: nil)
        }
    }
    
   
    @IBAction func loginAction(_ sender: AnyObject) {
        
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            
           
            
            let alertController = UIAlertController(title: "Error", message: "Enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    
                    
                    print("Successfully logged in")
                    
                   /* let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                    */
                    let uuid = user?.user.uid
                    UserDefaults.standard.set(uuid, forKey: "uuid")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "notebooksegue", sender: nil)
                        
                        
                        
                    }
                    
                    
                    
                } else {
                    
                   
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
