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
        
        // round corners
        cell.layer.cornerRadius = 2.0
        cell.layer.masksToBounds = true
        
        // set image
        cell.memeImage.image = appDelegate.memes[indexPath.row].memeImage
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
