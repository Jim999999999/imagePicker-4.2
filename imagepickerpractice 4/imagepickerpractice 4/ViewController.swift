//
//  ViewController.swift
//  imagepickerpractice 4
//
//  Created by James Miller on 3/17/20.
//  Copyright © 2020 James Miller. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var MemeStruct: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            //Intitial format setup
        setFormat(topText, " TOP")
        setFormat(bottomText, " BOTTOM")
        setTextAttributes()
        topToolbar.isHidden = true
             // Do any additional setup after loading the view.
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    
    }
    
    fileprivate func setFormat(_ textField: UITextField, _ text: String) {
        textField.delegate = self
        textField.textAlignment = .center
        textField.placeholder = text
    }
    
    fileprivate func setTextAttributes () {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.white,
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40) as Any,
            NSAttributedString.Key.strokeWidth: 5]
        
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
            textField.placeholder = nil
        }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomText.isEditing, view.frame.origin.y == 0
        {
                view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomText.isEditing, view.frame.origin.y != 0
        {
            view.frame.origin.y = 0
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        self.topToolbar.isHidden = true
        self.bottomToolbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func save() {
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memeImage: generateMemedImage())
        bottomToolbar.isHidden = false
    }
    
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications () {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }



    @IBAction func chooseImage(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Image Source", message: "Choose a Source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                self.presentImagePicker(imagePicker, .camera)
                
            } else {
                print("Camera not available")
                let alertController = UIAlertController(title: "Camera Not Available", message: "Camera feature is not available", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            
            self.presentImagePicker(imagePicker, .photoLibrary)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
        topToolbar.isHidden = false
    }
    
    @IBAction func shareImage(_ sender: Any) {
        if imageView.image == nil {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true}
        
        let sharedImage = generateMemedImage()
        
        let activityController = UIActivityViewController(activityItems: [sharedImage], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
            
        activityController.completionWithItemsHandler = {(activity, success, items, error) in
            self.save()
        }
    
    }
    
    @IBAction func cancelButton(_ sender: Any) {

        imageView.image = nil
        topText.text = nil
        bottomText.text = nil
        topToolbar.isHidden = true
        setFormat(topText, "TOP")
        setFormat(bottomText, "BOTTOM")
        setTextAttributes()
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func presentImagePicker(_ picker: UIImagePickerController, _ source: UIImagePickerController.SourceType){
        picker.sourceType = source
        self.present(picker, animated: true, completion: nil)
    }
}

