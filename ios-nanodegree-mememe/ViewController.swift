//
//  ViewController.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/3/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    
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
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // format text fields
        formatTextField(topTextField, with: "TOP")
        formatTextField(bottomTextField, with: "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}

// MARK: - Image Picker Delegate w/ Navigation Controller Delegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let viewController = picker.presentingViewController as? ViewController {
                
                // set image on view controller
                viewController.imageView.image = image
                
                // change content mode of image view so image does not distort
                viewController.imageView.contentMode = UIView.ContentMode.scaleAspectFit
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Text Field Delegate
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
