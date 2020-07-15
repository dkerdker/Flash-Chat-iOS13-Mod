//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var registerImageView: UIImageView!
    
    let db = Firestore.firestore()
    //let storage = Storage.storage()
    
    var selectedImageToUse: UIImage? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerImageView.layer.borderWidth = 3.0
        registerImageView.layer.masksToBounds = false
        registerImageView.layer.borderColor = UIColor.white.cgColor
        registerImageView.layer.cornerRadius = registerImageView.frame.size.height/2
        registerImageView.clipsToBounds = true
        
        navigationController?.navigationBar.barTintColor = UIColor(named: C.BrandColors.blue)
        title = C.appName
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: C.appTitleFont, size: 25)!
        ]
        
        registerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {

            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let message = e.localizedDescription
                    print(message)
                    let alert = UIAlertController(title: "Opps!", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Understood", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                } else {
                    self.db.collection(C.FStore.userCollectionName).addDocument(data: [ //package the stuff to send to DB
                        C.FStore.userEmail: email,
                        C.FStore.imageRegister: "", //holds ntg now
                    ]) { (error) in
                        if let e = error {
                            print("There was an issue saving registration data to firestore, \(e)")
                            return
                        } else {
                            print("Successfully saved registration data")
                        }
                    }
                    //Navigate to the ChatViewController
                    self.performSegue(withIdentifier: C.registerSegue, sender: self)
                }
            }
        }
    }
    
}
