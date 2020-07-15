import UIKit
 
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
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
            imageView.layer.cornerRadius = imageView.frame.size.width/2
            imageView.clipsToBounds = true
            
            sendImageConfirmViewController.view.addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 340).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 340).isActive = true
            imageView.centerXAnchor.constraint(lessThanOrEqualTo: imageView.superview!.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(lessThanOrEqualTo: imageView.superview!.centerYAnchor).isActive = true
            
            //Create Buttons
            createImageSendButtons(sendImageConfirmViewController, title: "Pick", selector: #selector(pickImage), primaryButton: true)
            createImageSendButtons(sendImageConfirmViewController, title: "Cancel", selector: #selector(cancelImageSelect), primaryButton: false)
        
            self.selectedImageToUse = selectedImage
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
    @objc func pickImage() {
        //set profile image
        registerImageView.image = selectedImageToUse

        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelImageSelect() {
        dismiss(animated: true, completion: nil)
    }
}
