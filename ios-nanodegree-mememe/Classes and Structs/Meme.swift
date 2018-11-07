//
//  Meme.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/4/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    
    // MARK: - Properties
    public var bottomText: String!
    public var memeImage: UIImage!
    public var originalImage: UIImage!
    public var topText: String!
    
    // Initilization
    init(bottomText: String, topText: String, originalImage: UIImage, memeImage: UIImage) {
        self.bottomText = bottomText
        self.topText = topText
        self.originalImage = originalImage
        self.memeImage = memeImage
    }
}
