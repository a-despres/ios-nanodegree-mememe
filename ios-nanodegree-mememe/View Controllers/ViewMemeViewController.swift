//
//  ViewMemeViewController.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/7/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

class ViewMemeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topAlignmentConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var meme: Meme!
    var memeIndex: Int!

    // MARK: - Edit Meme Button
    /// Segue to the Meme Editor and pass along the meme and meme index for the meme being viewed.
    @objc func editMeme(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editMeme", sender: (memeIndex, meme))
    }
    
    // MARK: - Meme
    /**
     Reinsert the meme into the meme array. This is necessary because the original meme object is removed from the array when it is passed to this view.
     Removing the meme object from the array prevents duplicate memes from being saved to the array when a meme is edited. This function assumes no
     changes have been made, reinserts the unaltered meme object into the array at its original position and dismisses the view.
     */
    @objc func reinsertMeme(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        appDelegate.memes.insert(meme, at: memeIndex)
    }
    
    // MARK: - Notifications
    /// Subscribe to the didFinishEditing notification that is posted when the user has successfully made changes to the meme.
    func subscribeToEditingNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEditingNotification(_:)), name: EditMemeViewController.didFinishEditing, object: nil)
    }
    
    /// Unsubscribe to the didFinishEditing notification that is posted when the user has successfully made changes to the meme.
    func unsubscribeToEditingNotification() {
        NotificationCenter.default.removeObserver(self, name: EditMemeViewController.didFinishEditing, object: nil)
    }
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add edit button
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMeme(_:)))
        navigationItem.rightBarButtonItem = editButton
        
        // add function to back button
        let backButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(reinsertMeme(_:)))
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide tab bar
        tabBarController?.tabBar.isHidden = true
        
        // add tap gesture to the image that toggles the navigation bar on/off.
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        memeImageView.addGestureRecognizer(tap)
        
        // set the image view to the meme image.
        memeImageView.image = meme.memeImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // show tab bar
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Gesture Recognition
extension ViewMemeViewController: UIGestureRecognizerDelegate {
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // toggle navigation bar visibility
        navigationController?.setNavigationBarHidden(!(navigationController?.isNavigationBarHidden)!, animated: true)
        
        // toggle image constraints
        topAlignmentConstraint.constant = topAlignmentConstraint.constant == ImageContraints.Top.default ? ImageContraints.Top.fullscreen : ImageContraints.Top.default
    }
}

// MARK: - Image Contraints
extension ViewMemeViewController {
    struct ImageContraints {
        struct Top {
            static let `default`: CGFloat = 64
            static let fullscreen: CGFloat = 0
        }
    }
}

// MARK: - Navigation
extension ViewMemeViewController {
    @objc func handleEditingNotification(_ notification: Notification) {
        
        // unubscribe to editing notification
        unsubscribeToEditingNotification()
        
        // show navigation bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // return to root view controller
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMeme" {
            if segue.identifier == "editMeme" {
                if let editMemeNavController = segue.destination as? UINavigationController {
                    // set title of navgation controller
                    editMemeNavController.viewControllers[0].title = "Edit Meme"
    
                    // pass Meme object to destination view controller
                    if let editMemeController = editMemeNavController.viewControllers[0] as? EditMemeViewController {
                        
                        // subscribe to editing notification
                        subscribeToEditingNotification()
                        
                        // pass meme object and table row number to meme editor
                        if let meme = sender as? (Int, Meme) {
                            editMemeController.existingMemeIndex = meme.0
                            editMemeController.existingMeme = meme.1
                        }
                    }
                }
            }
        }
    }
}
