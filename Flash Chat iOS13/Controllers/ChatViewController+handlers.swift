import UIKit

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Image Picker
    @objc func addImageMessage() {
        print("clicked on button to add image to message")
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
    }
    
    //Add Button
    func addRightAddImageButtonTo(textField: UITextField, with image: UIImage) {
        let rightAddImageButton = UIButton()
        let boldConfig = UIImage.SymbolConfiguration(weight: .regular)
        let systemImage = UIImage(systemName: "photo", withConfiguration: boldConfig)
        rightAddImageButton.setImage(systemImage, for: .normal)
        rightAddImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        rightAddImageButton.frame = CGRect(x: CGFloat(textField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        rightAddImageButton.tintColor = .lightGray
        rightAddImageButton.addTarget(self, action: #selector(addImageMessage), for: .touchUpInside)
        
        textField.rightView = rightAddImageButton
        textField.rightViewMode = .always
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled image picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            print("image chosen to be used")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let sendImageConfirmViewController = storyboard.instantiateViewController(withIdentifier: "sendImageConfirmViewController")
            DispatchQueue.main.async() {
                self.present(sendImageConfirmViewController, animated: true, completion: nil)
            }
            
            let imageView = UIImageView(image: selectedImage)
            imageView.layer.cornerRadius = 8.0
            imageView.clipsToBounds = true
            
            sendImageConfirmViewController.view.addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 340).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 340).isActive = true
            imageView.centerXAnchor.constraint(lessThanOrEqualTo: imageView.superview!.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(lessThanOrEqualTo: imageView.superview!.centerYAnchor).isActive = true
            
            //Create Buttons
            createImageSendButtons(sendImageConfirmViewController, title: "Send", selector: #selector(sendImageAsChat), primaryButton: true)
            createImageSendButtons(sendImageConfirmViewController, title: "Cancel", selector: #selector(cancelSendImage), primaryButton: false)
            
            selectedImageToUse = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //Function to create Buttons
    func createImageSendButtons(_ sendImageConfirmViewController: UIViewController, title: String, selector: Selector, primaryButton: Bool){
        let sendButton = UIButton()
        let weight: UIFont.Weight = primaryButton ? .bold : .regular
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: weight)
        sendButton.setTitle(title, for: .normal)
        sendButton.backgroundColor = UIColor(named: C.BrandColors.blue)
        sendButton.layer.cornerRadius = 5.0
        sendButton.clipsToBounds = true
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.addTarget(self, action: selector, for: .touchUpInside)
        
        sendImageConfirmViewController.view.addSubview(sendButton)
        print(Int(sendButton.superview!.frame.size.width/2))
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        _ = primaryButton ?
            NSLayoutConstraint.activate([
                sendButton.bottomAnchor.constraint(equalTo: sendButton.superview!.bottomAnchor, constant: -30),
                sendButton.trailingAnchor.constraint(equalTo: sendButton.superview!.trailingAnchor, constant: -1*((sendButton.superview!.frame.size.width/2)-140)),
                sendButton.heightAnchor.constraint(equalToConstant: 50),
                sendButton.widthAnchor.constraint(equalToConstant: 130)
            ]) :
            NSLayoutConstraint.activate([
                sendButton.bottomAnchor.constraint(equalTo: sendButton.superview!.bottomAnchor, constant: -30),
                sendButton.leadingAnchor.constraint(equalTo: sendButton.superview!.leadingAnchor, constant: (sendButton.superview!.frame.size.width/2)-140),
                sendButton.heightAnchor.constraint(equalToConstant: 50),
                sendButton.widthAnchor.constraint(equalToConstant: 130)
            ])
    }
    
    //Button Functions
    @objc func sendImageAsChat() {
        sendMessageWithImage(with: selectedImageToUse)
        

        
//        if let selectedImage = selectedImageToUse {
//            var testIP = IndexPath()
//            testIP.append([0,20])
//            let testImageInCell = tableView.cellForRow(at: testIP) as! MessageCell
//
//            expandMessageBubbleToFit(testImageInCell, image: selectedImage)
//            selectedImageToUse = nil
//        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelSendImage() {
        dismiss(animated: true, completion: nil)
    }
    
}
