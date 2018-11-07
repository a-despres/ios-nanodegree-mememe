//
//  SentMemesTableViewController.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/7/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {

    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Navigation
extension SentMemesTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMeme" {
            if let editMemeNavController = segue.destination as? UINavigationController {
                editMemeNavController.viewControllers[0].title = "Edit Meme"
            }
        }
    }
}

// MARK: - Table View Controller
extension SentMemesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SentMemesTableViewCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editMeme", sender: nil)
    }
}
