//
//  EditMemeViewController.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/3/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

class EditMemeViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    
    // MARK: - Properties
    var memeImage: UIImage!
    var selectedTextField: UITextField?
    
    // MARK: - IBActions
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        // choose the appropriate source type based on the button tag (int)
        // 0 = photo library; 1 = camera
        if sender.tag == 1 {
            pickerController.sourceType = .camera
        } else {
            pickerController.sourceType = .photoLibrary
        }
        
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
        memeImage = generateMemeImage()
        let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        
        // save meme object after the activity has been shared.
        activityController.completionWithItemsHandler = {
            [weak self]
            (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                return
            }
            self?.saveMeme()
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: - Configure UI
    /**
     Sets the appearance of a UITextField.
     - parameter textField: The *UITextField* to be configured.
     - parameter defaultText: The default text displayed in the *UITextField* before editing.
     - remark: This method sets the delegate of the *UITextField* to *self*.
     */
    func formatTextField(_ textField: UITextField, with defaultText: String? = nil) {
        // set self as delegate
        textField.delegate = self
        
        // set default text
        if let defaultText = defaultText {
            textField.text = defaultText
        }
        
        // format font appearance and alignment
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.strokeWidth: -5
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    /// Toggle the visibility of the navigation and toolbars on/off.
    func toggleNavigation() {
        // set the value to the opposite of the current value
        navigationController?.setNavigationBarHidden(!(navigationController?.isNavigationBarHidden)!, animated: false)
        navigationController?.setToolbarHidden(!(navigationController?.isToolbarHidden)!, animated: false)
    }
    
    // MARK: - Manage Keyboard and Keyboard Notifications
    /**
     Get the height of the onscreen keyboard.
     - parameter notification: The *Notification* observed by the Notification Center.
     - returns: The height of the onscreen keyboard as a *CGFloat*.
     */
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    /**
     Reset the origin of the view to zero.
     - parameter notification: The *Notification* observed by the Notification Center.
     */
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    /**
     Adjust the origin of the view to accomodate the height of the onscreen keyboard if is determined that
     the onscreen keyboard will obscure the selected *UITextField*.
     - parameter notification: The *Notification* observed by the Notification Center.
     */
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification)
        
        if let textField = selectedTextField {
            if textField.frame.origin.y > keyboardHeight {
                view.frame.origin.y = -keyboardHeight
            }
        }
    }
    
    /// Subscribe to the keyboardWillHide and keyboardWillShow notifications.
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    /// Unsubscribe from the keyboardWillHide and keyboardWillShow notifications.
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: - Meme
    /**
     Render the view to an image that can be shared or saved to the device.
     - returns: An image of the view without navigation or toolbars.
     */
    func generateMemeImage() -> UIImage {
        // hide toolbar and navbar
        toggleNavigation()
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        toggleNavigation()
        
        return image
    }
    
    /// Generate and save a Meme object to the device.
    func saveMeme() {
        let meme = Meme(bottomText: bottomTextField.text!, topText: topTextField.text!, originalImage: imageView.image!, memeImage: memeImage)
    }
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable share button
        shareButton.isEnabled = false
        
        // format text fields
        formatTextField(topTextField, with: "TOP")
        formatTextField(bottomTextField, with: "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
}

// MARK: - Image Picker Delegate w/ Navigation Controller Delegate
extension EditMemeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let count = navigationController?.viewControllers.count {
                if let viewController = navigationController?.viewControllers[count - 1] as? EditMemeViewController {
                    
                    // set image on view controller
                    viewController.imageView.image = image
                    
                    // change content mode of image view so image does not distort
                    viewController.imageView.contentMode = UIView.ContentMode.scaleAspectFit
                    viewController.imageView.clipsToBounds = true
                    
                    // enable share button
                    viewController.shareButton.isEnabled = true
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Text Field Delegate
extension EditMemeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedTextField = nil
        textField.resignFirstResponder()
        return true
    }
}
