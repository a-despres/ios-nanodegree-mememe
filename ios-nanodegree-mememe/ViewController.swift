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
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
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
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
