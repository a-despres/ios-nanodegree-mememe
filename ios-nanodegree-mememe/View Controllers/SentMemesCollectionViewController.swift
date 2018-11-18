//
//  SentMemesCollectionViewController.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/7/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let columns: CGFloat = 3.0
        let margin: CGFloat = 6.0
        let space: CGFloat = 8.0
        let dimensions = (view.frame.size.width / columns) - space
        
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        flowLayout.minimumInteritemSpacing = space / 2
        flowLayout.minimumLineSpacing = margin
        flowLayout.itemSize = CGSize(width: dimensions, height: dimensions)
    }
}

// MARK: - Collection View Controller
extension SentMemesCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SentMemesCollectionViewCell
        
        // round corners and border to cell
        cell.layer.cornerRadius = 4
        cell.clipsToBounds = true
        cell.layer.borderColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 0.5).cgColor
        cell.layer.borderWidth = 1
        
        // round corners of the image
        cell.memeImage.layer.cornerRadius = 2
        cell.memeImage.clipsToBounds = true
        
        // set labels
        cell.bottomLabel.text = appDelegate.memes[indexPath.row].bottomText
        cell.topLabel.text = appDelegate.memes[indexPath.row].topText
        
        // set image
        cell.memeImage.image = appDelegate.memes[indexPath.row].originalImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewMeme", sender: (indexPath.row, appDelegate.memes.remove(at: indexPath.row)))
    }
}

// MARK: - Navigation
extension SentMemesCollectionViewController {
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
