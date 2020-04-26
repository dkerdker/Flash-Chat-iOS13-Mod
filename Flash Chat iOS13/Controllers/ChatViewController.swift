//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var appTitle: UINavigationItem!
    
    //var lastClick: TimeInterval = 0.0
    //var lastIndexPath: IndexPath?
    
    let db = Firestore.firestore()
    
    var selectedIndexPath: IndexPath? = nil
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        messageTextfield.delegate = self
        
        navigationController?.navigationBar.barTintColor = UIColor(named: C.BrandColors.blue)
        title = C.appName
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: C.appTitleFont, size: 25)!
        ]
        
        navigationItem.hidesBackButton = true
        
        self.tableView.backgroundColor = .white
        
        tableView.register(UINib(nibName: C.cellNibName, bundle: nil), forCellReuseIdentifier: C.cellIdentifier)
        
        if let addImageButtonImage = UIImage(systemName: "photo") {
            self.addRightAddImageButtonTo(textField: messageTextfield, with: addImageButtonImage)
            print("got image")
        }
        
        loadMessages()
    }
    
    //MARK: - Sending to Firebase Storage
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text,
            let messageSender = Auth.auth().currentUser?.email {    //get the stuff to send to DB

            self.messageTextfield.text = "" //refresh the textField
            
            db.collection(C.FStore.collectionName).addDocument(data: [ //package the stuff to send to DB
                C.FStore.senderField: messageSender,
                C.FStore.bodyField: messageBody,
                C.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                    if let e = error {
                        print("There was an issue saving data to firestore, \(e)")
                    } else {
                        print("Successfully saved data")
                    }
            }
        }
    }
    
    //THIS IS HOW YOU USE READ with FIREBASE, FIRESTORE
    func loadMessages() {
        
        db.collection(C.FStore.collectionName)
            .order(by: C.FStore.dateField)//.limit(toLast: 5)
            .addSnapshotListener { (querySnapshot, error) in
            
            self.messages = []
            
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    //querySnapshot?.document[0].data()[C.FStore.senderField] --> Value of the senderField
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[C.FStore.senderField] as? String,
                            let messageBody = data[C.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            //self.messages.insert(newMessage, at: 0)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.scrollToNewMessage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func scrollToNewMessage() {
        let numberOfSections = self.tableView.numberOfSections
        let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)

        let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        
        let alert = UIAlertController(title: "Log out?", message: "Your password will not be saved, are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            do {
                try firebaseAuth.signOut()
                self.navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        //This is a message from the current user.
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: C.BrandColors.purple)
            cell.label.textColor = UIColor(named: C.BrandColors.lightPurple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: C.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: C.BrandColors.purple)
            
        }
        
        return cell
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if let index = self.tableView.indexPathForSelectedRow{
//            self.tableView.deselectRow(at: index, animated: true)
//        }
//    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row) //TEST
        //let now: TimeInterval = Date().timeIntervalSince1970
        //let timeInBetweenClicks = now - lastClick
        
        //if timeInBetweenClicks < 0.5, lastIndexPath?.row == indexPath.row {
        //   print("Double Tap!")
            if selectedIndexPath == indexPath {
                //it was already selected
                selectedIndexPath = nil
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                selectedIndexPath = indexPath
                tableView.deselectRow(at: indexPath, animated: true)
                //Insert code for DELETE function here
                let alert = UIAlertController(title: "Delete message?", message: "Message will be permanently deleted.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    
                    self.db.collection(C.FStore.collectionName)
                        .order(by: C.FStore.dateField)
                        .getDocuments { (querySnapshot, error) in
                            if let e = error {
                                print("There was an issue retrieving data from Firestore. \(e)")
                            } else {
                                if let snapshotDocuments = querySnapshot?.documents {
                                    let deletingMessageByID = snapshotDocuments[indexPath.row].documentID
                                    print(deletingMessageByID) //TEST
                                    DispatchQueue.main.async {
                                        self.db.collection(C.FStore.collectionName).document(deletingMessageByID).delete { (error) in
                                            if let e = error {
                                                print("There was an issue saving data to firestore, \(e)")
                                            } else {
                                                self.loadMessages()
                                                print("Successfully deleted data")
                                            }
                                        }
                                    }
                                }
                            }
                    }
                    
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
    }
}
