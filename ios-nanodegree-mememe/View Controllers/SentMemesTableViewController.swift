//
//  SentMemesTableViewController.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/7/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var memeTable: UITableView!
    
    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memeTable.reloadData()
    }
}

// MARK: - Navigation
extension SentMemesTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewMeme" {
            if let viewMemeController = segue.destination as? ViewMemeViewController {
                if let meme = sender as? (Int, Meme) {
                    viewMemeController.memeIndex = meme.0
                    viewMemeController.meme = meme.1
                }
            }
        }
    }
}

// MARK: - Table View Controller
extension SentMemesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SentMemesTableViewCell
        
        // round corners of the image
        cell.memeImage.layer.cornerRadius = 2
        cell.memeImage.clipsToBounds = true
        
        // round corners of the container view surrounding the image and add a border
        cell.containerView.layer.cornerRadius = 4
        cell.containerView.clipsToBounds = true
        cell.containerView.layer.borderColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 0.5).cgColor
        cell.containerView.layer.borderWidth = 1
        
        // apply values from memes array
        cell.memeImage.image = appDelegate.memes[indexPath.row].originalImage
        cell.topText.text = appDelegate.memes[indexPath.row].topText
        cell.bottomText.text = appDelegate.memes[indexPath.row].bottomText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewMeme", sender: (indexPath.row, appDelegate.memes.remove(at: indexPath.row)))
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            appDelegate.memes.remove(at: indexPath.row)
            memeTable.deleteRows(at: [indexPath], with: .bottom)
        }
    }
}
