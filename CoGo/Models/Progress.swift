//
//  Progress.swift
//  CoGo
//
//  Created by Sean Noh on 6/22/22.
//

import Foundation
import Firebase

class UserProgress: Identifiable, Hashable, ObservableObject {
    var username: String
    var room: Room
    var isCurrentUser = false
    @Published var id: String = ""
    @Published var color: String = "000000"
    @Published var dailyCount: Int = 0
    @Published var totalCount: Int = 0
    @Published var streak: Int = 0
    @Published var history: Dictionary<String, Int> = Dictionary<String, Int>()
    @Published var completedToday: Bool = false
    @Published var configured: Bool = false
    
    init (username: String, room: Room)
    {
        self.username = username
        self.room = room
        if (username != "")
        {
            configure()
        }
        else
        {
            print("unconfigured")
        }
    }
    init (placeholder: Bool)
    {
        username = ""
        room = Room(placeholder: true)
    }
    
    init (id: String, username: String, color: String, dailyCount: Int, totalCount: Int, streak: Int, history: Dictionary<String, Int>, room: Room, isCurrentUser: Bool)
    {
        self.id = id
        self.username = username
        self.color = color
        self.dailyCount = dailyCount
        self.totalCount = totalCount
        self.streak = streak
        self.history = history
        self.completedToday = room.completed(on: Day.today, history: history)
        self.room = room
        self.isCurrentUser = isCurrentUser
        if (!self.isCurrentUser)
        {
            Firestore.firestore().collection("rooms").document(self.room.id).collection("progress").document(self.username)
                .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    if let savedRoom = SavedProgress.shared.currentRoom?.room
                    {
                        if (savedRoom.id == self.room.id && self.username == SavedProgress.shared.currentUser.username)
                        {
                            SavedProgress.shared.currentRoom?.delete()
                        }
                    }
                    if (self.username == SavedProgress.shared.currentUser.username)
                    {
                        SavedProgress.shared.currentUser.removeRoom(self.room.id)
                    }
                    SavedProgress.shared.removeUser(username: self.username, roomId: self.room.id)
                    let roomToUpdate = SavedProgress.shared.currentUser.rooms.filter { $0.id == self.room.id }
                    roomToUpdate.first?.leaderboard.removeUser(username: self.username)
                    roomToUpdate.first?.updateOrdered()
                    return
                }
                //unchangeable self.id = data["id"] as! String
                //unchangeable username
                //not going to update color cuz bleh
                if (!self.isCurrentUser) {
                    self.totalCount = data["totalCount"] as! Int
                    self.streak = data["streak"] as! Int
                    self.history = data["history"] as! Dictionary<String, Int>
                    self.dailyCount = self.history[Date().formatted(date: .abbreviated, time: .omitted)] ?? 0
                    self.completedToday = self.room.completed(on: Day.today, history: self.history)
                    self.color = data["color"] as! String
                    let roomToUpdate = SavedProgress.shared.currentUser.rooms.filter { $0.id == self.room.id }
                    roomToUpdate.first?.leaderboard.order()
                    roomToUpdate.first?.updateOrdered()
                    print("snapshot")
                }
            }
        }
        self.configured = true
    }
    func configure () {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            Firestore.firestore().collection("rooms").document(self.room.id).collection("progress").document(self.username).getDocument() { document, error in
                ReadTracker.shared.read(label: "Get Initial UserProgress")
                 self.id = (document!.get("id") as? String ?? "-@*#$NONEFOUND")
                 self.totalCount = (document!.get("totalCount") as? Int ?? -1)
                 self.streak = (document!.get("streak") as? Int ?? -1)
                 self.history = (document!.get("history") as? Dictionary<String, Int> ?? Dictionary())
                 self.color = (document!.get("color") as? String ?? "000000")
                group.leave()
            }
        }
        group.notify(queue: .main)
        {
            self.dailyCount = self.history[Date().formatted(date: .abbreviated, time: .omitted)] ?? 0
            self.completedToday = self.room.completed(on: Day.today, history: self.history)
            self.isCurrentUser = self.username == SavedProgress.shared.currentUser.username
                
            if (!self.isCurrentUser)
            {
                Firestore.firestore().collection("rooms").document(self.room.id).collection("progress").document(self.username)
                    .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        if let savedRoom = SavedProgress.shared.currentRoom?.room
                        {
                            if (savedRoom.id == self.room.id && self.username == SavedProgress.shared.currentUser.username)
                            {
                                SavedProgress.shared.currentRoom?.delete()
                            }
                        }
                        if (self.username == SavedProgress.shared.currentUser.username)
                        {
                            SavedProgress.shared.currentUser.removeRoom(self.room.id)
                        }
                        SavedProgress.shared.removeUser(username: self.username, roomId: self.room.id)
                        let roomToUpdate = SavedProgress.shared.currentUser.rooms.filter { $0.id == self.room.id }
                        roomToUpdate.first?.leaderboard.removeUser(username: self.username)
                        roomToUpdate.first?.updateOrdered()
                        return
                    }
                    //unchangeable self.id = data["id"] as! String
                    //unchangeable username
                    //not going to update color cuz bleh
                    if (!self.isCurrentUser) {
                        self.totalCount = data["totalCount"] as! Int
                        self.streak = data["streak"] as! Int
                        self.history = data["history"] as! Dictionary<String, Int>
                        self.dailyCount = self.history[Date().formatted(date: .abbreviated, time: .omitted)] ?? 0
                        self.completedToday = self.room.completed(on: Day.today, history: self.history)
                        self.color = data["color"] as! String
                        let roomToUpdate = SavedProgress.shared.currentUser.rooms.filter { $0.id == self.room.id }
                        roomToUpdate.first?.leaderboard.order()
                        roomToUpdate.first?.updateOrdered()
                        print("snapshot")
                    }
                }
            }
            self.configured = true
        }
    }
    static func == (lhs: UserProgress, rhs: UserProgress) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    var hashValue: Int {
        return (username + room.id).hashValue
    }
}

class SavedProgress: ObservableObject {
    //in rooms -> generate progress for user when first creating it and save it.
    //when needed, pull from here.
    //when changes occur, also change them here

    //    changeable values
    //    var color: String
    //    var dailyCount: Int
    //    var totalCount: Int
    //    var streak: Int
    //    var history: Dictionary<String, Int>
    //    var completedToday: Bool
    //when a user is removed / deleted, remove it from saved progress.... alsso have to make sure this works when others leave room / delete
    
    static let shared = SavedProgress()
    var currentUser = User()
    let code = "CODE*%&^#@!"
    var currentDay = ""
    
    @Published var progress: [String: UserProgress] = [:]
    @Published var chartData: [String: ChartData] = [:]
    @Published var currentRoom: RoomScreenView?
    
    func setCurrentUser(_ user: User)
    {
        currentUser = user
    }
    func getSavedUser (username: String) -> [UserProgress]
    {
        var returnable: [UserProgress] = []
        for key in progress.keys {
            let str = key
            var substring = ""
            if let range = str.range(of: code) {
                substring = String(str[..<range.lowerBound]) // or str[str.startIndex..<range.lowerBound]
            }
            else {
              print("String not present")
            }
            if (substring == username)
            {
                returnable.append(progress[key]!)
            }
        }
        return returnable
    }
    func contains (username: String, roomId: String) -> Bool
    {
        return progress[generateCode(username, roomId)] != nil
    }
    func getUser(username: String, roomId: String) -> UserProgress
    {
        return progress[generateCode(username, roomId)] ?? UserProgress(placeholder: true)
    }
    func addUser(_ userProgress: UserProgress)
    {
        progress[generateCode(userProgress.username, userProgress.room.id)] = userProgress
    }
    func addData(username: String, roomId: String, chartData: ChartData)
    {
        self.chartData[generateCode(username, roomId)] = chartData
    }
    func getData (username: String, roomId: String) -> ChartData?
    {
        return self.chartData[generateCode(username, roomId)] 
    }
    func removeUser(username: String, roomId: String)
    {
        progress[generateCode(username, roomId)] = nil
    }
    func generateCode(_ a: String, _ b: String) -> String
    {
        return a + code + b
    }
    func newDay (username: String) {
        for progress in getSavedUser(username: username) {
            if progress.history[Day.yesterday] ?? 0 < progress.room.target
            {
                progress.streak = 0
            }
            progress.history["\(Date().formatted(date: .abbreviated, time: .omitted))"] = 0
            progress.dailyCount = 0
            progress.completedToday = false
            if let data = getData(username: username, roomId: progress.room.id)
            {
                data.dailyReset()
            }
            //getData(username: username, roomId: progress.room.id).set(values: progress.room.lastWeek(history: progress.history))
        }
        currentDay = Day.today
        objectWillChange.send()
    }
    func clear ()
    {
        currentUser = User()
        progress.removeAll()
        chartData.removeAll()
    }
}
