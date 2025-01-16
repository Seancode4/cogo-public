//
//  BottomTabView.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/16/22.
//

import Foundation
import SwiftUI

struct BottomTabView: View{
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var user: User
    @EnvironmentObject var userSettings: UserSettings
    @State private var tabSelection = 1
    let tabBar = UITabBar.appearance()
    
    init () {
        //UITabBar.appearance().barTintColor = UIColor(named: "bgColor")
        
    }
    
    var body: some View{
        
        TabView(selection: $tabSelection){
            MainScreenView()
                .environmentObject(userSettings)
                .environmentObject(user)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }.tag(1)
            JoinRoomView(tabSelection: $tabSelection).environmentObject(user)
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Join Room")
                }.tag(2)
            CreateRoomView()
                .tabItem {
                    Image(systemName: "person.fill.badge.plus")
                    Text("Create Room")
                }.tag(3)
            HomeSettingsView()
                .environmentObject(userSettings)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }.tag(4)
            
            
        }.accentColor(Color("F97878"))
        .preferredColorScheme(.light)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task
                {
                    await SavedProgress.shared.currentUser.openApp()
                }
                
                //MARK: Check
                if (timeUntilMidnight() < 4 * 60 * 60) //less than 4 hours
                {
                    Timer.scheduledTimer(withTimeInterval: TimeInterval(timeUntilMidnight()), repeats: false) { timer in
                        user.newDay()
                    }
                }
            }
            
            
        }
        .onChange(of: tabSelection, perform: { _ in
            setTabViewBackground()
        })
        .onAppear(){
           setTabViewBackground()
           print("tabselection: \(tabSelection)")
           print(user.rooms.count)
        }
        .id(tabSelection)
    
    }
    
    func setTabViewBackground() {
        if tabSelection == 2{
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
            tabBar.backgroundColor = nil
            tabBar.clipsToBounds = false
            
            // UITabBar.appearance().clipsToBounds = true
            
        }else{
            //tabBar.barTintColor = UIColor(named: "bgColor")
             //UITabBar.appearance().shadowImage = UIImage(named: "tabViewBG")
            tabBar.backgroundImage = UIImage(named: "tabViewBG")
            tabBar.clipsToBounds = true
            tabBar.backgroundColor = UIColor(named: "bgColor")

        }
    }
}

func getTime () -> (Int, Int)
{
    let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
    let hour = components.hour ?? 0
    let minute = components.minute ?? 0
    return (hour, minute)
}
func timeUntilMidnight () -> Int
{
    let time = getTime()
    let hours = 23 - time.0
    let minutes = 60 - time.1
    
    let leftMinutes = hours * 60 + minutes
    let leftSeconds = leftMinutes * 60
    return leftSeconds
}
func resetTimer(user: User)
{
    if (timeUntilMidnight() < 4 * 60 * 60) //less than 4 hours
    {
        Timer.scheduledTimer(withTimeInterval: TimeInterval(timeUntilMidnight()), repeats: false) { timer in
            user.newDay()
        }
    }

}
