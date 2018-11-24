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
    // buttons
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    // editing tools
    @IBOutlet weak var editingToolPane: UIView!
    @IBOutlet weak var editingToolVerticalConstraint: NSLayoutConstraint!
    // image view
    @IBOutlet weak var imageView: UIImageView!
    // text fields
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var topTextConstraint: NSLayoutConstraint!
    // text position tool
    @IBOutlet weak var leftTextPositionHandleConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightTextPositionHandleConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightTextPositionHandle: UIImageView!
    @IBOutlet weak var textPositionHandleContainer: UIView!
    @IBOutlet weak var textPositionToolPane: UIView!
    @IBOutlet weak var textPositionToolVerticalConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var existingMeme: Meme?
    var existingMemeIndex: Int?
    var memeImage: UIImage!
    var selectedTextField: UITextField?
    
    // text field positions
    struct InitialTextPositions {
        static let bottom: CGFloat = 16.0
        static let top: CGFloat = 16.0
    }
    struct PreviousTextPositions {
        var bottom: CGFloat = InitialTextPositions.bottom
        var top: CGFloat = InitialTextPositions.top
    }
    var previousTextPositions = PreviousTextPositions()
    
    // MARK: - IBActions
    /// Close the Meme Editor and return to the previous View Controller.
    @IBAction func closeMemeEditor(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Hide the text position tool pane and restore positions of textFields.
    @IBAction func handleCancelTextPositionTool(_ sender: UIButton) {
        toggleTextPositionTool()
        
        // reset text to previous positions
        resetTextPositions(toPrevious: true)
    }
    
    /// Hide the text position tool pane, keeping new positions of textFields.
    @IBAction func handleConfirmTextPositionTool(_ sender: UIButton) {
        toggleTextPositionTool()
    }
    
    /// Toggle the edit tool pane on/off and hide the text position tool if needed.
    @IBAction func handleEditingTool(_ sender: UIBarButtonItem) {
        if !textPositionToolPane.isHidden {
            resetTextPositions(toPrevious: true)
            toggleTextPositionTool()
        }
        
        toggleEditingToolsPane()
    }
    
    /// Choose the font for the meme text.
    @IBAction func handleFontTool(_ sender: UIButton) {
        // define action sheet
        let actionSheet = UIAlertController(title: "Select Font", message: "", preferredStyle: .actionSheet)
        
        // add button for Impact
        let impact = UIAlertAction(title: "Impact", style: .default, handler: {
            [weak self] action in
            self?.chooseFont(.impact)
        })
        impact.setValue(topTextField.isSelectedFont(.impact), forKey: "checked")
        actionSheet.addAction(impact)
        
        // add button for Avenir
        let arial = UIAlertAction(title: "Avenir", style: .default, handler: {
            [weak self] action in
            self?.chooseFont(.avenir)
        })
        arial.setValue(topTextField.isSelectedFont(.avenir), forKey: "checked")
        actionSheet.addAction(arial)
        
        // add button for Helvetica Neue
        let helvetica = UIAlertAction(title: "Helvetica Neue", style: .default, handler: {
            [weak self] action in
            self?.chooseFont(.helveticaneue)
        })
        helvetica.setValue(topTextField.isSelectedFont(.helveticaneue), forKey: "checked")
        actionSheet.addAction(helvetica)
        
        // add cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        
        // show action sheet
        present(actionSheet, animated: true, completion: nil)
    }
    
    /// Reset the positions of the textFields.
    @IBAction func handleResetTextPositionTool(_ sender: UIButton) {
        resetTextPositions()
    }
    
    /// Reset the font, positions and text of the textFields.
    @IBAction func handleResetTextTool(_ sender: UIButton) {
        resetText(withPosition: true)
    }
    
    // Toggle the text position tool on/off and set the previous position values to the current position.
    @IBAction func handleTextPositionTool(_ sender: UIButton) {
        toggleTextPositionTool()
        
        // set previous positions
        previousTextPositions.bottom = bottomTextConstraint.constant
        previousTextPositions.top = topTextConstraint.constant
    }
    
    /// Pick an image from either the photo library or the device's camera if available.
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
    
    /// Open an activity view to allow the user to share the meme.
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
            
            if self?.existingMeme != nil {
                self?.dismiss(animated: true) {
                    NotificationCenter.default.post(name: EditMemeViewController.didFinishEditing, object: nil)
                }
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: - Configure UI
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
        // create the meme
        let meme = Meme(bottomText: bottomTextField.text!, font: topTextField.currentFont(), memeImage: memeImage, originalImage: imageView.image!, topText: topTextField.text!)

        // add meme to array
        if let index = existingMemeIndex {
            appDelegate.memes.insert(meme, at: index)
        } else {
            appDelegate.memes.append(meme)
        }
    }
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set textField delegates
        bottomTextField.delegate = self
        topTextField.delegate = self
        
        // set textField and image values
        if let meme = existingMeme {
            bottomTextField.setFont(meme.font)
            bottomTextField.text = meme.bottomText
            
            topTextField.setFont(meme.font)
            topTextField.text = meme.topText
            
            imageView.image = meme.originalImage
        } else {
            bottomTextField.setFont(.impact)
            bottomTextField.text = PlaceholderText.bottom
            
            topTextField.setFont(.impact)
            topTextField.text = PlaceholderText.top
            
            shareButton.isEnabled = false
        }
        
        // setup initial UI values for tools panes
        // hide text positioning handles
        textPositionHandleContainer.isHidden = true
        
        // flip orientation of right handle image
        let handleScale = (rightTextPositionHandle.image?.scale)!
        let handleImage = (rightTextPositionHandle.image?.cgImage)!
        rightTextPositionHandle.image = UIImage(cgImage: handleImage, scale: handleScale, orientation: .upMirrored)
        
        // change appearance of editing tools pane
        editingToolPane.layer.cornerRadius = 8
        editingToolPane.clipsToBounds = true
        editingToolPane.isHidden = true
        editingToolPane.alpha = 0.0
        editingToolVerticalConstraint.constant = 32
        
        // change appearance of positioning tools pane
        textPositionToolPane.layer.cornerRadius = 8
        textPositionToolPane.clipsToBounds = true
        textPositionToolPane.isHidden = true
        textPositionToolVerticalConstraint.constant = 0
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // slide out positioning handles if touch is inside handle container
        if let touch = touches.first {
            if let touchView = touch.view {
                if textPositionHandleContainer == touchView || textPositionHandleContainer.subviews.contains(touchView) {
                    UIView.animate(withDuration: 0.2, animations: {
                        [weak self] in
                        self?.leftTextPositionHandleConstraint.constant = -12
                        self?.rightTextPositionHandleConstraint.constant = -12
                        self?.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // reposition handle and text to touch position
        if let touch = touches.first {
            if let touchView = touch.view {
                if textPositionHandleContainer == touchView || textPositionHandleContainer.subviews.contains(touchView) {
                    let position = ceil(touch.location(in: view).y)
                    let padding: CGFloat = 32.0
    
                    if (position > view.layoutMargins.top + padding) && (position < view.center.y - topTextField.frame.height) {
                        textPositionHandleContainer.center.y = position
                        topTextField.center.y = position
                        bottomTextField.center.y = view.frame.height - topTextField.center.y + 5
                    }
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // slide in positioning handles
        UIView.animate(withDuration: 0.2, animations: {
            [weak self] in
            self?.leftTextPositionHandleConstraint.constant = 0
            self?.rightTextPositionHandleConstraint.constant = 0
            self?.view.layoutIfNeeded()
        })
        
        // update constraints
        topTextConstraint.constant = topTextField.frame.minY - view.layoutMargins.top
        bottomTextConstraint.constant = view.frame.height - bottomTextField.frame.maxY - view.layoutMargins.bottom
    }
}

// MARK: - Notifications
extension EditMemeViewController {
    static public let didFinishEditing = Notification.Name("MemeMe.DidFinishEditing")
}

// MARK: - Placeholder Text Struct
extension EditMemeViewController {
    struct PlaceholderText {
        static let bottom: String = "BOTTOM"
        static let top: String = "TOP"
    }
}

// MARK: - Editing Tools
extension EditMemeViewController {
    /// Set the font for both textFields.
    func chooseFont(_ font: UITextField.Font) {
        bottomTextField.setFont(font)
        topTextField.setFont(font)
    }
    
    /**
     Reset the font being used to the default.
     - parameter position: Resets the position of the textFields if set to true.
     */
    func resetText(withPosition position: Bool = false) {
        bottomTextField.setFont(.impact)
        bottomTextField.text = PlaceholderText.bottom
        
        topTextField.setFont(.impact)
        topTextField.text = PlaceholderText.top
        
        if position {
            resetTextPositions()
        }
    }
    
    /**
     Reset the position of the textFields.
     - parameter position: Resets the position of the textFields to the previous position if set to true.
     */
    func resetTextPositions(toPrevious position: Bool = false) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            if position {
                self?.bottomTextConstraint.constant = (self?.previousTextPositions.bottom)!
                self?.topTextConstraint.constant = (self?.previousTextPositions.top)!
            } else {
                self?.bottomTextConstraint.constant = InitialTextPositions.bottom
                self?.topTextConstraint.constant = InitialTextPositions.top
            }
            self?.view.layoutIfNeeded()
        })
    }
    
    /// Toggle the edit tool pane on/off.
    func toggleEditingToolsPane() {
        if editingToolPane.isHidden {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.editingToolPane.isHidden = false
                self?.editingToolPane.alpha = 1.0
                self?.editingToolVerticalConstraint.constant = 0
                self?.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.editingToolPane.isHidden = false
                self?.editingToolPane.alpha = 0.0
                self?.editingToolVerticalConstraint.constant = 32
                self?.view.layoutIfNeeded()
                }, completion: { [weak self] completed in
                    self?.editingToolPane.isHidden = true
            })
        }
    }
    
    /// Toggle the text position tool on/off.
    func toggleTextPositionTool() {
        bottomTextField.isEnabled = !bottomTextField.isEnabled
        topTextField.isEnabled = !topTextField.isEnabled
        textPositionToolPane.isHidden = !textPositionToolPane.isHidden
        
        // animate positioning handles and show/hide container
        if textPositionHandleContainer.isHidden {
            self.textPositionHandleContainer.isHidden = false
            
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.leftTextPositionHandleConstraint.constant = 0
                self?.rightTextPositionHandleConstraint.constant = 0
                self?.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.leftTextPositionHandleConstraint.constant = -36
                self?.rightTextPositionHandleConstraint.constant = -36
                self?.view.layoutIfNeeded()
                }, completion: { [weak self] completed in
                    self?.textPositionHandleContainer.isHidden = true
            })
        }
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
        if (textField == topTextField && textField.text == PlaceholderText.top) || (textField == bottomTextField && textField.text == PlaceholderText.bottom) {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedTextField = nil
        textField.resignFirstResponder()
        return true
    }
}
