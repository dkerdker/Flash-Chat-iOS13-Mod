//
//  Constants.swift
//  Flash Chat iOS13
//
//  Created by Dee Ker Khoo on 23/03/2020.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation

struct C {
    static let registerSegue = "RegisterToChat"
    static let loginSegue = "LoginToChat"
    static let appName = "⚡️FlashChat"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let appTitleFont = "Kailasa-Bold"
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FStore {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
    }
}
