//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var appTitle: UINavigationItem!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var selectedIndexPath: IndexPath? = nil
    
    var messages: [Message] = []
    
    var selectedImageToUse: UIImage? = nil
    
    let messageCell = MessageCell()
    
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
        }
        
        loadMessages()
    }
    
    //MARK: - Sending to Firebase Storage
    @IBAction func sendPressed(_ sender: UIButton) {
        sendMessage()
    }
    
    func sendMessageWithImage(with image: UIImage? = nil) {
        if let uploadData = image?.jpegData(compressionQuality: 0.75) {
            let imageName = NSUUID().uuidString
            let storageRef = storage.reference().child("\(imageName).png")
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                
                guard metadata != nil else {
                    print("Error saving image to storage, \(error!)")
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard url != nil else {
                        if let error = error {
                            print("Error saving image to storage, \(error)")
                        }
                        return
                    }
                    if let imageURLString = url?.absoluteString {
                        print("GOT UPLOADED, HERE IS THE IMAGEURL: \(imageURLString)")
                        self.sendMessage(with: imageURLString)
                    }
                }
            }
        }
    }
    
    func sendMessage(with imageURL: String? = nil) {
        if let messageBody = messageTextfield.text,
            let messageSender = Auth.auth().currentUser?.email {    //get the stuff to send to DB
            
            self.messageTextfield.text = "" //refresh the textField
            
            self.db.collection(C.FStore.collectionName).addDocument(data: [ //package the stuff to send to DB
                C.FStore.senderField: messageSender,
                C.FStore.bodyField: messageBody,
                C.FStore.dateField: Date().timeIntervalSince1970,
                C.FStore.imageURL: imageURL ?? "N/A"
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
                                let messageBody = data[C.FStore.bodyField] as? String,
                                let imageURL = data[C.FStore.imageURL] as? String {
                                let newMessage = Message(sender: messageSender, body: messageBody, image: imageURL)
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
        let imageURL = message.image
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
//        NSLayoutConstraint.activate([
//            cell.cellMessageStack.bottomAnchor.constraint(equalTo: cell.cellMessageStack.superview!.bottomAnchor, constant: -10)
//        ])
        
        if imageURL != "N/A" {
            
            
            let url = URL(string: imageURL)
            URLSession(configuration: .default).dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print("downloading image hit an error, \(error!)")
                    return
                }
                
                DispatchQueue.main.async {
                    let image = UIImage(data: data!)
                    //cell.messageImage.image = image
                }

            }.resume()
            
        }
        
        //message from the current user.
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: C.BrandColors.purple)
            cell.label.textColor = UIColor(named: C.BrandColors.lightPurple)
        } else {    //message from other user
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: C.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: C.BrandColors.purple)
        }
        
        return cell
    }
    
}

//expandMessageBubbleToFit(cell, image: selectedImageToUse)
func expandMessageBubbleToFit(_ cell: MessageCell, image: UIImage) {
    print("check if messageBubble need expanding")
    let imageView = UIImageView(image: image)
    imageView.layer.cornerRadius = 8.0
    imageView.clipsToBounds = true
    cell.messageBubble.addSubview(imageView)
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if selectedIndexPath == indexPath {
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
