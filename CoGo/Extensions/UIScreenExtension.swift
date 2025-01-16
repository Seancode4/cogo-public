//
//  UIScreenExtension.swift
//  CoGo
//
//  Created by Sean Noh on 4/29/22.
//

import Foundation
import SwiftUI

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
    
    static let nativeScreenWidth = UIScreen.main.nativeBounds.width
    static let nativeScreenHeight = UIScreen.main.nativeBounds.height
    static let nativescreenSize = UIScreen.main.nativeBounds.size
}
