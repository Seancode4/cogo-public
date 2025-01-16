//
//  UserSettings.swift
//  CoGo
//
//  Created by Sean Noh on 2/3/22.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @Published var storedEmail = UserDefaults.standard.string(forKey: "account")
    
    func logIn () {
        isLoggedIn = true
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }
    func logOut () {
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        storedEmail = ""
        UserDefaults.standard.set("", forKey: "account")
    }
    func storeEmail (email: String) {
        UserDefaults.standard.set(email, forKey: "account")
        storedEmail = email
    }

    /*
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn") //set false when logging out
        }
    }
    
    init() {
        self.username = UserDefaults.standard.object(forKey: "username") as? String ?? ""
        self.isLoggedIn = UserDefaults.standard.object(forKey: "isLoggedIn") as? Bool ?? false
    }
     */
}

//access user settings using:     @ObservedObject var userSettings = UserSettings()
//for specific var (username):     $userSettings.username
