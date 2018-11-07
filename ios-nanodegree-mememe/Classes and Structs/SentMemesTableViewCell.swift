//
//  SentMemesTableViewCell.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/7/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

class SentMemesTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var bottomText: UILabel!
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var topText: UILabel!
    
    // MARK: - Cell
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
