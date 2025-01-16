//
//  Rooms.swift
//  CoGo
//
//  Created by Sean Noh on 1/7/22.
//

import Foundation
import Firebase
import SwiftUI

class Room: Identifiable,  ObservableObject{
    
    @Published var id: String = ""
    @Published var name: String = ""
    var color: String = ""
    var target: Int = 0
    var created: String = ""
    @Published var owner: String = ""
    @Published var lightMode: Bool = false
    @Published var contrastColor: Color = .black
    //var progress: [String] = [] //list of users
    @Published var totalProgress: Int = 0
    @Published var groupCompletion: Int = 0
    var lastReset: String = ""
    @Published var configured = false
    @Published var leaderboard = Leaderboard()
    @Published var ordered: [UserProgress] = []
    var users: [String] = []
   // var userProgress: [(String, Int)] = [("",0)]
    
    init (roomId: String) {
        self.id = roomId
        Firestore.firestore().collection("rooms").document(id).getDocument() {document,error in
            self.name = (document!.get("name") as? String)!
            self.color = (document!.get("color") as? String)!
            self.target = (document!.get("target") as? Int)!
            //self.code = (document!.get("code") as? String)!
            self.totalProgress = (document!.get("totalProgress") as? Int)!
            self.groupCompletion = (document!.get("groupCompletion") as? Int)!
            self.owner = (document!.get("owner") as? String)!
            self.created = (document!.get("created") as? String)!
            self.lastReset = (document!.get("lastReset") as? String)!
            
            self.users = (document!.get("users") as? [String])!
            self.setColorMode()
            self.configured = true
            ReadTracker.shared.read(label: "Get Initial Room Data")
            
            //self.userProgress = (document!.get("userProgress") as? [(String, Int)])!
        }
        Task {
            await generateLeaderboard()
        }
        //listener. should make this deactivatable when not needed
        Firestore.firestore().collection("rooms").document(id)
            .addSnapshotListener { documentSnapshot, error in
                ReadTracker.shared.read(label: "Room Listener")
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                print("Document data was empty.")
                return
              }
                //print("Current data: \(String(describing: data["totalProgress"]))")
                //self.totalProgress = data["totalProgress"] as! Int
                self.groupCompletion = data["groupCompletion"] as! Int
                self.owner = data["owner"] as! String
                var currentUsers = data["users"] as? [String]
                if currentUsers == nil
                {
                    currentUsers = []
                }
                if (currentUsers != self.users) {
                    self.users = currentUsers!
                    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { timer in
                        Task {
                            await self.generateLeaderboard()
                        }
                    }
                }
                if (data["lastReset"] != nil)
                {
                    self.lastReset = data["lastReset"] as! String
                }
            }
    }
    
    init (placeholder: Bool)
    {
        id = ""
    }
    //pre: uid should be id of user being added
    /*func addUser (newUser: User) async {
        let db = Firestore.firestore()

        try? await db.collection("rooms").document(id).collection("progress").document(newUser.username).setData( ["id": newUser.id, "color": newUser.color, "totalCount": 0, "streak": 0, "history": [Date().formatted(date: .abbreviated, time: .omitted): 0]])
        try? await db.collection("users").document(newUser.id).updateData(["rooms": FieldValue.arrayUnion([id])])
            //.addDocument(data: ["username": newUser.username, "count": 0])
            //.document(newUser.id).setData(["name": newUser.username, "count": 0])
    }*/
    func changeUserColor (username: String, color: String)
    {
        Firestore.firestore().collection("rooms").document(id).collection("progress").document(username).updateData(["color": color])
    }
    func removeUser(username: String, removeSelf: Bool) async
    {
        let roomDeleted = await attemptToDeleteRoom(username: username)
        //getUser(username, caller: "removeuser") { user in
        let user = getUser(username)
            let db = Firestore.firestore()
            if (!roomDeleted)
            {
                try? await db.collection("rooms").document(self.id).updateData(["totalProgress": FieldValue.increment(Int64(user.totalCount * -1))])
                if (user.username == self.owner)
                {
                    self.updateOwner()
                }
            }
            if (removeSelf)
            {
                await earlyGroupCompletion()
            }
            else
            {
                try? await db.collection("users").document(user.id).collection("deletes").document("deleteInfo").updateData(["rooms": FieldValue.arrayUnion([self.id]), "actionNeeded": true])
            }
            try? await db.collection("rooms").document(self.id).updateData(["users": FieldValue.arrayRemove([username])])
            try? await db.collection("rooms").document(self.id).collection("progress").document(user.username).delete()
            if removeSelf
            {
                try? await db.collection("users").document(user.id).updateData(["rooms": FieldValue.arrayRemove([self.id])])
                SavedProgress.shared.currentUser.removeRoom(self)
            }
            if (user.completedToday == false && !roomDeleted && !removeSelf)
            {
                checkGroupCompletion(completion: true)
            }
            SavedProgress.shared.removeUser(username: username, roomId: self.id)
            objectWillChange.send()
        //}
    }
    func updateOwner()
    {
        Firestore.firestore().collection("rooms").document(self.id).collection("progress").order(by: "totalCount", descending: true).order(by: "streak", descending: true).limit(to: 2).getDocuments() { snapshot, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            else
            {
                for document in snapshot!.documents {
                    ReadTracker.shared.read(label: "Get New Owner")
                    let username = document.documentID
                    if (username != self.owner)
                    {
                        Firestore.firestore().collection("rooms").document(self.id).updateData(["owner": username])
                        self.owner = username
                        return
                    }
                }
            }
        }
    }
    
    private func attemptToDeleteRoom(username: String) async -> Bool
    {
        let db = Firestore.firestore()
        do
        {
            let documents = try await db.collection("rooms").document(self.id).collection("progress").getDocuments()
            ReadTracker.shared.read(label: "See if Room is Deleted")
            let userCount = documents.count
            //let containsUser = documents -> Could change to check that the user is included, but costs a read
            if (userCount <= 1)
            {
                try await db.collection("rooms").document(self.id).delete()
                return true
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        return false
    }
    func increment (username: String, value: Int?, chartData: ChartData) {
        //getUser(username, caller: "increment") { (user) in
        let user = getUser(username)
        if !user.configured
        {
            return
        }
            if (user.dailyCount + (value ?? 1) >= 0)
            {
                Firestore.firestore().collection("rooms").document(self.id).collection("progress").document(username).updateData(["history."+Date().formatted(date: .abbreviated, time: .omitted): FieldValue.increment(Int64(value ?? 1)), "totalCount": FieldValue.increment(Int64(value ?? 1))])
                Firestore.firestore().collection("rooms").document(self.id).updateData(["totalProgress": FieldValue.increment(Int64(value ?? 1))])
                // always current userif (user.isCurrentUser)
               // {
                
                    user.totalCount += value ?? 1
                    if (user.history[Day.today] == nil)
                    {
                        user.history[Day.today] = 0
                    }
                    user.history[Day.today]! += value ?? 1
                    user.dailyCount = user.history[Day.today]!
                    //user.completedToday = user.room.completed(on: Day.today, history: user.history)
                //}
                chartData.update(day: Day.today, count: Double(user.dailyCount))
                if (user.dailyCount >= self.target && !user.completedToday)
                {
                    Firestore.firestore().collection("rooms").document(self.id).collection("progress").document(username).updateData(["streak": FieldValue.increment(Int64(1))])
                    if (user.isCurrentUser)
                    {
                        user.streak += 1
                    }
                    user.completedToday = true
                    self.checkGroupCompletion(completion: true)
                }
                if (value ?? 1 < 0 && user.dailyCount < self.target && user.completedToday)
                {
                    Firestore.firestore().collection("rooms").document(self.id).collection("progress").document(username).updateData(["streak": FieldValue.increment(Int64(-1))])
                    if (user.isCurrentUser)
                    {
                        user.streak -= 1
                    }
                    user.completedToday = false
                    self.checkGroupCompletion(completion: false)
                }
                let roomToUpdate = SavedProgress.shared.currentUser.rooms.filter { $0.id == self.id }
                roomToUpdate.first?.leaderboard.order()
                roomToUpdate.first?.updateOrdered()
            }
        //}
    }
    func resetDaily (username: String) {
        let user = getUser(username)
            //MIGHT NOT BE CONFIGURED!!!
        //getUser(username, caller: "resetdaily") { (user) in
        
        if (!user.configured)
        {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                self.resetDaily(username: username)
            }
            return
        }
            if (!self.completed(on: Day.yesterday, history: user.history))
            {
                Firestore.firestore().collection("rooms").document(self.id).collection("progress").document(username).updateData(["history."+Date().formatted(date: .abbreviated, time: .omitted): 0, "streak": 0])
            }
            else
            {
                Firestore.firestore().collection("rooms").document(self.id).collection("progress").document(username).updateData(["history."+Date().formatted(date: .abbreviated, time: .omitted): 0])
            }
            if (lastReset != Day.today)
            {
                self.resetOthers(username)
            }
        //}
    }
    func resetOthers (_ username: String) {
        Firestore.firestore().collection("rooms").document(self.id).updateData(["lastReset": Day.today])
        Firestore.firestore().collection("rooms").document(self.id).collection("progress").getDocuments { snapshot, error in
            print("entered")
            if let error = error {
                print("Error: \(error)")
                return
            }
            else
            {
                for document in snapshot!.documents {
                    ReadTracker.shared.read(label: "Resetting Other Users in Room")
                    if (document.documentID != username)
                    {
                        print(document.documentID)
                        let currentUser = document.documentID
                        let history = document.get("history") as! Dictionary<String, Int>
                        let streak = document.get("streak") as! Int
                        if (streak > 0 && !self.completed(on: Day.today, history: history)  && !self.completed(on: Day.yesterday, history: history) && !self.completed(on: Day.twoEarly, history: history)) {
                            Firestore.firestore().collection("rooms").document(self.id).collection("progress").document(currentUser).updateData(["streak":0])
                        }
                    }
                }
            }
        }
    }
    
    /*func getColor(){
        let group = DispatchGroup()
        var color: String = ""
        
        group.enter()
        DispatchQueue.main.async {
            Firestore.firestore().collection("rooms").document(self.id).getDocument(){ document, error in
                
                color = (document!.get("color") as? String)!
                group.leave()
            }
        }
    }*/
    func getUser (_ username: String) -> UserProgress {
        if (username == "")
        {
            return UserProgress(username: "PLACEHOLDER", room: self)
        }
        if (SavedProgress.shared.contains(username: username, roomId: self.id))
        {
            print("saved")
            return SavedProgress.shared.getUser(username: username, roomId: self.id)
        }
        else
        {
            print("read")
            let returnable = UserProgress(username: username, room: self)
            //returnable.configure()
            SavedProgress.shared.addUser(returnable)
            return returnable
        }
    }
    /*
    func getUser (_ username: String, caller: String, completion: @escaping (UserProgress) -> () ) {
        let group = DispatchGroup()
        var id: String = ""
        var color: String = ""
        var dailyCount: Int = -1
        var totalCount: Int = -1
        var streak: Int = -1
        var history: Dictionary<String, Int> = [:]
        
        
        if (SavedProgress.shared.contains(username: username, roomId: self.id))
        {
            print("saved")
            completion(SavedProgress.shared.getUser(username: username, roomId: self.id))
        }
        else
        {
            print("generated")
            group.enter()
            DispatchQueue.main.async {
                 Firestore.firestore().collection("rooms").document(self.id).collection("progress").document(username).getDocument() { document, error in
                     id = (document!.get("id") as? String ?? "-@*#$NONEFOUND")
                     totalCount = (document!.get("totalCount") as? Int ?? -1)
                     streak = (document!.get("streak") as? Int ?? -1)
                     history = (document!.get("history") as? Dictionary<String, Int> ?? Dictionary())
                     //not in order
                    //color = (document!.get("color") as? String)!
                    group.leave()
                }
            }
            group.notify(queue: .main)
            {
                let group2 = DispatchGroup()
                group2.enter()
                DispatchQueue.main.async {
                    Firestore.firestore().collection("users").document(id).getDocument() { document, error in
                        color = (document!.get("color") as? String ?? "-@*#$NONEFOUND")
                        group2.leave()
                    }
                }
                group2.notify(queue: .main)
                {
                    dailyCount = history[Date().formatted(date: .abbreviated, time: .omitted)] ?? 0
                    let returnable = UserProgress(id: id, username: username, color: color, dailyCount: dailyCount, totalCount: totalCount, streak: streak, history: history, room: self, caller: caller)
                    if (id == "-@*#$NONEFOUND")
                    {
                        print("No user found")
                        SavedProgress.shared.removeUser(username: username, roomId: self.id)
                    }
                    else
                    {
                        SavedProgress.shared.addUser(returnable)
                    }
                    completion(returnable)
                }
            }
    //        group.notify(queue: .main) -> UserProgress in
    //        {
    //            return UserProgress(username: username, count: count) //return happens too fast, for some reason geting run time error abt not finding count
    //        }
            
    //       DispatchQueue.global(qos: .background).async {
    //           //first
    //           DispatchQueue.main.async {
    //                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
    //                    return UserProgress(username: <#String#>, count: <#Int#>)
    //                }
    //            }
    //        }

           
            
            

        }
        
    }*/
    func changeColor(newColor: Color){
        
        let newRoomColorHex = newColor.toHex() ?? "000000"
        
        let db = Firestore.firestore()
        
        //set the data to update
        //set data -> whole thing gets replaced and only data in .setData() will be there unless you use merge: true
        db.collection("rooms").document(id).setData(["color": newRoomColorHex], merge: true) { error in
            //check for errors
            if error == nil {
                //get the new data
                //self.getData()
            }
        }
        color = newRoomColorHex
        setColorMode()
    }
    
    func generateLeaderboard () async {
        
        if (!configured) {
            try? await Task.sleep(nanoseconds: UInt64(0.1) * 1_000_000_000)
            await generateLeaderboard()
            return
        }
        var leaderboardMembers: [UserProgress] = []
        /*
        let query = try? await Firestore.firestore().collection("rooms").document(self.id).collection("progress").order(by: "streak", descending: true).order(by: "totalCount", descending: true).getDocuments()
        query?.documents.forEach({ doc in
            ReadTracker.shared.read(label: "Generate Leaderboard")
            let user = getUser(doc.documentID)
            leaderboardMembers.append(getUser(doc.documentID))
        })*/
        self.users.forEach { username in
            leaderboardMembers.append(getUser(username))
        }
        leaderboard.set(leaderboardMembers)
        updateOrdered()
        objectWillChange.send()
    }
    
    /*func getLeaderboard (completion: @escaping ([UserProgress]) -> ()) {
        var usernames: [String] = []
        let group = DispatchGroup()
       
        group.enter()
        DispatchQueue.main.async {
            Firestore.firestore().collection("rooms").document(self.id).collection("progress").order(by: "streak", descending: true).order(by: "totalCount", descending: true).getDocuments() { snapshot, error in
                
                if let error = error {
                    print("Errors: \(error)")
                    return
                }
                else
                {
                    for document in snapshot!.documents {
                        ReadTracker.shared.read(label: "Room Leaderboard")
                        usernames.append(document.documentID)
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main){
            let dispatchQueue = DispatchQueue(label: "noh-sean-cogo")
            var returnable: [UserProgress] = []
            let group = DispatchGroup()
            let dispatchSemaphore = DispatchSemaphore(value: 0)
            
            group.enter()
            dispatchQueue.async {
                for user in usernames {
                    let info = self.getUser(user)
                    //self.getUser(user, caller: "leaderboard") {  info in
                        returnable.append(info)
                        dispatchSemaphore.signal()
                    //}
                    dispatchSemaphore.wait()
                }
                group.leave()
            }
            group.notify(queue: .main)
            {
                completion(returnable)
                
            }
            
        }
        
       // return returnable
    }*/
    
//     func lastCompletion (history: Dictionary<String, Int>) -> String {
//        var returnable: String = "NONE"
//         print(history)
//         for (day, count) in history {
//             if (count >= self.target) {
//                 returnable = day
//             }
//         }
//         print(returnable)
//         return returnable
//
//     }
    func completed (on day: String, history: Dictionary<String, Int>) -> Bool{
        return history[day] ?? 0 >= self.target && history[day] ?? 0 != 0
    }
    
    func lastWeek(history: Dictionary<String, Int>) -> [(String, Int)] {
        var returnable: [(String, Int)]
        let week: [String] = Day.lastWeek
        var count: [Int] = [0,0,0,0,0,0,0]
        
        
        
        Day.lastWeek.forEach { day in
            count[week.firstIndex(of: day)!] = history[day] ?? 0
        }
        
        
        returnable = [(week[0], count[0]), (week[1], count[1]), (week[2], count[2]), (week[3], count[3]), (week[4], count[4]), (week[5], count[5]), (week[6], count[6])]
        
        //test:
        //returnable = [(week[0], 4), (week[1], 0), (week[2], 0), (week[3], 0), (week[4], 0), (week[5], 0), (week[6], 3)]
 
       /* print("inside returnable: ")
        returnable.forEach{ i in
            print(i)
        }*/
        return returnable
    }
    
    
    /* ORIGINAL:
    func lastWeek(history: Dictionary<String, Int>) -> Dictionary<String, Int> {
        var returnable: Dictionary<String, Int>
        let week: [String] = Day.lastWeek
        var count: [Int] = [0,0,0,0,0,0,0]
        Day.lastWeek.forEach { day in
            count[week.firstIndex(of: day)!] = history[day] ?? 0
        }
        //returnable = [(week[0], count[0]),  (week[1], count[1]), (week[2], count[2]),  (week[3], count[3]), (week[4], count[4]), (week[5], count[5]), (week[6], count[6])]
        
       returnable = [week[0]: count[0], week[1]: count[1], week[2]: count[2], week[3]: count[3], week[4]: count[4], week[5]: count[5], week[6]: count[6]]
        
        return returnable
    } */
    
    private func checkGroupCompletion(completion: Bool) {
        //increments only if everyone has completed for today. check today, if not already completed then increment. if already completed and shoudl not be, decrement.
        var groupFails = 0
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            Firestore.firestore().collection("rooms").document(self.id).collection("progress").getDocuments() { snapshot, error in
                for document in snapshot!.documents {
                    ReadTracker.shared.read(label: "Checking for Room Completion")
                    //MARK: maybe make it query for smallest and just look at one to seee if at least one is zero
                    let history = (document.get("history") as? Dictionary<String, Int>)!
                    if (history[Day.today] ?? 0 < self.target)
                    {
                        groupFails += 1
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if (completion) {
                if (groupFails == 0)
                {
                    //increment group
                    Firestore.firestore().collection("rooms").document(self.id).updateData(["groupCompletion": FieldValue.increment(Int64(1))])
                    self.groupCompletion += 1
                }
            }
            else {
                //check if everyone else succeeded. if so then decrement
                if (groupFails == 1)
                {
                    //decrementgroup
                    Firestore.firestore().collection("rooms").document(self.id).updateData(["groupCompletion": FieldValue.increment(Int64(-1))])
                    self.groupCompletion -= 1
                }
            }
        }
    }
    private func earlyGroupCompletion()  async {
        //increments only if everyone has completed for today. check today, if not already completed then increment. if already completed and shoudl not be, decrement.
        var groupFails = -1
        let snapshot = try? await Firestore.firestore().collection("rooms").document(self.id).collection("progress").getDocuments()
        for document in snapshot!.documents
        {
            ReadTracker.shared.read(label: "Checking For Room Uncompletion")
            let history = (document.get("history") as? Dictionary<String, Int>)!
            if (history[Day.today] ?? 0 < self.target)
            {
                groupFails += 1
            }

        }
        if (groupFails == 0)
        {
            //increment group
            try? await Firestore.firestore().collection("rooms").document(self.id).updateData(["groupCompletion": FieldValue.increment(Int64(1))])
            //self.groupCompletion += 1
        }
    }
    func newUserGroupCompletion () async {
        if (!configured) {
            try? await Task.sleep(nanoseconds: UInt64(0.2) * 1_000_000_000)
            await newUserGroupCompletion()
            return
        }
        var groupFails = 0
        let snapshot = try? await Firestore.firestore().collection("rooms").document(self.id).collection("progress").getDocuments()
        for document in snapshot!.documents
        {
            ReadTracker.shared.read(label: "Update Room Completion")
            let history = (document.get("history") as? Dictionary<String, Int>)!
            if (history[Day.today] ?? 0 < self.target)
            {
                groupFails += 1
            }
        }
        if (groupFails == 1)
        {
            //decrement group
            try? await Firestore.firestore().collection("rooms").document(self.id).updateData(["groupCompletion": FieldValue.increment(Int64(-1))])
        }

    }
    func updateOrdered () {
        ordered = leaderboard.viewable
    }
    private func setColorMode ()
    {
        let red = Color(color)?.cgColor?.components?[0] ?? 1
        let green = Color(color)?.cgColor?.components?[1] ?? 1
        let blue = Color(color)?.cgColor?.components?[2] ?? 1
        if (red + green + blue > 2)
        {
            contrastColor = .black
            lightMode = true
        }
        else
        {
            contrastColor = .white
            lightMode = false
        }
    }
    func getOwner() -> String
    {
        return owner
    }
    func isOwner(username: String) -> Bool
    {
        return username == owner
    }
    
//    func getTotalProgress () -> Int {
//        Firestore.firestore().collection("rooms").document(id).getDocument() {document,error in
//            self.totalProgress = (document!.get("totalProgress") as? Int)!
//        }
//        return totalProgress
//    }
    
    /*func getUser (uid: String) -> userProgress
    {
        return userProgress(uid: <#String#>, name: <#String#>, count: <#Int#>)
    }*/
    
        /*static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.color == rhs.color && lhs.target == rhs.target && lhs.code == rhs.code && lhs.totalProgress == rhs.totalProgress
    } */
    
    //var endDate: Date()
    
}

class Leaderboard: ObservableObject {
    //make this a property of room -> when userprogress changes, get the room of the user from savedprogress user and do leaderboard.order()
    //new user or logged out user needs to not update leaderboard...actually it can if it exists
    
    
    //userprogress doesnt update from added or removed users...
    
    @Published var viewable: [UserProgress] = []
    var users: [UserProgress] = []
    
    init () {
        
    }
    func set (_ users: [UserProgress]) {
        self.users = users
        order()
    }
    func removeUser(username: String) {
        users.removeAll { userProgress in
            userProgress.username == username
        }
        order()
    }
    func order() {
        users.forEach { progress in
            if (!progress.configured) {
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                    self.order()
                }
                return
            }
        }
        var temp: [UserProgress] = []
        users.forEach { progress in
            if (temp.count == 0)
            {
                temp.append(progress)
            }
            else
            {
                var completed = false
                for index in 0...temp.count - 1
                {
                    if (temp[index].streak < progress.streak && !completed)
                    {
                        temp.insert(progress, at: index)
                        completed = true
                    }
                    else if (temp[index].streak == progress.streak && !completed && temp[index].totalCount < progress.totalCount)
                    {
                        temp.insert(progress, at: index)
                        completed = true
                    }
                }
                if (!completed)
                {
                    temp.append(progress)
                }
            }
        }
        viewable = temp
    }
    func getViewable () -> [UserProgress]
    {
        return viewable
    }
}

class Day {
    static let calendar = Calendar.current
    
    static var todayDate = Date()
    static var yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date())
    
    static var today = todayDate.formatted(date: .abbreviated, time: .omitted)
    static var yesterday = yesterdayDate!.formatted(date: .abbreviated, time: .omitted)
    static var twoEarly = calendar.date(byAdding: .day, value: -2, to: Date())!.formatted(date: .abbreviated, time: .omitted)
    static var threeEarly = calendar.date(byAdding: .day, value: -3, to: Date())!.formatted(date: .abbreviated, time: .omitted)
    static var fourEarly = calendar.date(byAdding: .day, value: -4, to: Date())!.formatted(date: .abbreviated, time: .omitted)
    static var fiveEarly = calendar.date(byAdding: .day, value: -5, to: Date())!.formatted(date: .abbreviated, time: .omitted)
    static var sixEarly = calendar.date(byAdding: .day, value: -6, to: Date())!.formatted(date: .abbreviated, time: .omitted)

    static var lastWeek: [String] = [sixEarly, fiveEarly, fourEarly, threeEarly, twoEarly, yesterday, today]
    
    static func update ()
    {
        Day.todayDate = Date()
        Day.yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date())
        
        Day.today = todayDate.formatted(date: .abbreviated, time: .omitted)
        Day.yesterday = yesterdayDate!.formatted(date: .abbreviated, time: .omitted)
        Day.twoEarly = calendar.date(byAdding: .day, value: -2, to: Date())!.formatted(date: .abbreviated, time: .omitted)
        Day.threeEarly = calendar.date(byAdding: .day, value: -3, to: Date())!.formatted(date: .abbreviated, time: .omitted)
        Day.fourEarly = calendar.date(byAdding: .day, value: -4, to: Date())!.formatted(date: .abbreviated, time: .omitted)
        Day.fiveEarly = calendar.date(byAdding: .day, value: -5, to: Date())!.formatted(date: .abbreviated, time: .omitted)
        Day.sixEarly = calendar.date(byAdding: .day, value: -6, to: Date())!.formatted(date: .abbreviated, time: .omitted)
        Day.lastWeek = [sixEarly, fiveEarly, fourEarly, threeEarly, twoEarly, yesterday, today]
    }
}


