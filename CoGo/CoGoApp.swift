//
//  CoGoApp.swift
//  CoGo
//
//  Created by Sean Noh and Abigail Joseph on 1/7/22.

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct CoGoApp: App {
    
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @ObservedObject var userSettings = UserSettings()
    @ObservedObject var user = User()
    //@State var doneLoading = false


    init () {
        //FirebaseApp.configure()
        let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        let firbaseOptions = FirebaseOptions(contentsOfFile: path!)
        FirebaseApp.configure(options: firbaseOptions!)
        if (userSettings.isLoggedIn)
        {
            login()
            user.configure()
            resetTimer(user: user)
        }
        if #available(iOS 13.0, *) {
                  UIWindow.appearance().overrideUserInterfaceStyle = .light
         }
        //load()
        //if time > 11:00 pm, every minute call time to reset at 12:00..??
    }
//    func load() {
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
//            doneLoading = true
//        }
//    }
    var body: some Scene {
        WindowGroup {
            
            //LoginView().environmentObject(userSettings).environmentObject(user)
            
            //RoomCreationView().environmentObject(user)
           if (!userSettings.isLoggedIn)
           {
//               if (doneLoading)
//               {
                   LoginView().environmentObject(userSettings).environmentObject(user)
//               }
//               else
//               {
//                   LoadingView()
//               }
            }
            else {
              if (user.isConfigured)
                {
                    BottomTabView()
                        .environmentObject(userSettings)
                        .environmentObject(user)
                }
                else
                {
                    LoadingView()
                }
            }
            
        }
    }
    
    
    private func login () {
        Auth.auth().signIn(withEmail: userSettings.storedEmail ?? "", password: getStoredPassword()) {
            result, err in
            if let err = err {
                print("Failed to login user:", err)
                userSettings.logOut()
                return
                
            }
            print ("Successfully logged in user: \(result?.user.uid ?? "")") 
            userSettings.logIn()
        }
    }
    private func getStoredPassword() -> String {
      let kcw = KeychainWrapper()
      if let password = try? kcw.getGenericPasswordFor(
        account: userSettings.storedEmail!, //! means aborts if stored email is nil
        service: "unlockPassword") {
        return password
      }

      return ""
    }
    
}
/*
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any] ?= nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
*/

//}
public class ReadTracker {
    static let shared = ReadTracker()
    var reads = 0
    
    enum ReadType {
        case originalData
        case snapshotUpdate
    }
    
    func read(label: String) {
        reads += 1
        print(reads.description + " " + label)
    }
}
