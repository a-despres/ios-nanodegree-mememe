//
//  UITextField.swift
//  ios-nanodegree-mememe
//
//  Created by Andrew Despres on 11/18/18.
//  Copyright © 2018 Andrew Despres. All rights reserved.
//

import UIKit

extension UITextField {
    // MARK: - Fonts
    enum Font: String {
        case helveticaneue = "HelveticaNeue-CondensedBlack"
        case avenir = "AvenirNextCondensed-Heavy"
        case impact = "Impact"
    }
    
    /// Return the font being used in the *UITextField*.
    func currentFont() -> Font {
        if self.isSelectedFont(.avenir) {
            return .avenir
        } else if self.isSelectedFont(.helveticaneue) {
            return .helveticaneue
        }
        return .impact
    }
    
    /**
     Check if a particular font is being used in the *UITextField*.
     - parameter font: The *Font* being checked.
     - returns: This method returns a boolean value indicating whether a particular font is being used.
     */
    func isSelectedFont(_ font: Font) -> Bool {
        if self.font?.fontName == font.rawValue {
            return true
        }
        return false
    }
}
