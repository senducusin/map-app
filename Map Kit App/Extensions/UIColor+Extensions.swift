//
//  UIColor+Extensions.swift
//  Map Kit App
//
//  Created by Jansen Ducusin on 4/12/21.
//

import UIKit

extension UIColor {
    static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    static let themePink = UIColor.rgba(red: 221, green: 94, blue: 86, alpha: 1)
    
    static let themeBlue = UIColor.rgba(red: 55, green: 120, blue: 250, alpha: 1)
    
    static let themeGreen = UIColor.rgba(red: 76, green: 217, blue: 100, alpha: 1)
}

