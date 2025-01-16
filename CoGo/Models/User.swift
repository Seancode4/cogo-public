//
//  User.swift
//  CoGo
//
//  Created by Sean Noh and Abigail Joseph on 1/7/22.
//
 
import Foundation
import Firebase
import FirebaseAuth
import SwiftUI

class User: Identifiable, ObservableObject {
    
    //var userSettings = UserSettings()
    
    var id: String = ""
    @Published var username: String = ""
    //var password: String = ""
    @Published var color: String = ""
    @Published var roomIds: [String] = []
    @Published var email: String = ""
    @Published var rooms: [Room] = []
    @Published var lastAccessed: String = ""
    @Published var isConfigured = false
    //@Published var viewableRooms: [Room] = []
    
    
    init (){
        
    }
    public func getRoomIds () -> [String] {
        return roomIds
    }
    public func getRoom () -> [Room] {
        return rooms
    }
    func configure () {
        
       // print("in configure")
        isConfigured = false
        
            let user = Auth.auth().currentUser
            if let user = user {
                id = user.uid
            }
      //  print("id: " + id)
 
        let db = Firestore.firestore()
 
        let docRef = db.collection("users").document(id)
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.username = (document.get("username") as? String?)! ?? ""
                    self.color = (document.get("color") as? String?)! ?? ""
                    self.roomIds = (document.get("rooms") as? [String]?)! ?? []
                    self.email = (document.get("email") as? String?)! ?? ""
                    self.lastAccessed = ((document.get("lastAccessed") as? String)!)
                } else {
                    print("Document does not exist")
                }
                ReadTracker.shared.read(label: "Get Initial User Data")
                group.leave()
            }
        }
        group.notify(queue: .main) {
            Task
            {
                await self.updateRooms()
                if (self.lastAccessed != Date().formatted(date: .abbreviated, time: .omitted)) {
                    //self.resetDaily()
                    self.newDay()
                }
                /*else   probably not necessary?
                {
                    self.rooms.forEach { room in
                        room.resetOthers(self.username)
                    }
                }*/
                //self.accessed() only need to mark accessed if a new day
                SavedProgress.shared.setCurrentUser(self)
                self.makeCurrentUser()
                self.createListener()
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                    self.isConfigured = true
                }
            }
        }
        
        
        //populates the rooms array witht the room objects that correspond to the room ids the user is part of in the roomids array
        // nothing in roomids so rooms array isnt populated
//            var index = 0
//            roomIds.forEach { room in
//                print(index)
//                rooms[index] = Room(roomId: room)
//                index+=1
//            }
        
        
            //rooms.append(contentsOf: returnable)
        
 
    }
    func createListener () {
        
        //when removing another user, add the room id to this array
        //no self snapshots
        
        //creating user, create these
        Firestore.firestore().collection("users").document(self.id).collection("deletes").document("deleteInfo")
            .addSnapshotListener { documentSnapshot, error in
                ReadTracker.shared.read(label: "User Listener")
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if let data = document.data() {
                let actionNeeded: Bool = data["actionNeeded"] as! Bool
                if actionNeeded {
                    let rooms: [String] = (data["rooms"] ?? []) as! [String]
                    for roomId in rooms {
                        if let savedRoom = SavedProgress.shared.currentRoom?.room
                        {
                            if (savedRoom.id == roomId && self.username == SavedProgress.shared.currentUser.username)
                            {
                                SavedProgress.shared.currentRoom?.delete()
                            }
                        }
                        self.removeRoom(roomId)
                        SavedProgress.shared.removeUser(username: self.username, roomId: roomId)
                    }
                    Firestore.firestore().collection("users").document(self.id).collection("deletes").document("deleteInfo").setData(["actionNeeded": false])
                }
            }
    }

    }
    func openApp () async {
        await self.updateRooms()
        if (self.lastAccessed != Date().formatted(date: .abbreviated, time: .omitted)) {
            //self.resetDaily()
            newDay()
        }
        else
        {
            //do we need to do this...? already reset them earlier today because it was already accessed
            /*self.rooms.forEach { room in
                room.resetOthers(self.username)
            }*/
        }
        //self.accessed()
        SavedProgress.shared.setCurrentUser(self)
    }
    func newDay () {
        if (SavedProgress.shared.currentDay != Date().formatted(date: .abbreviated, time: .omitted) || SavedProgress.shared.currentUser.id != self.id)
        {
            Day.update()
            resetDaily()
            SavedProgress.shared.newDay(username: username)
            accessed()
        }
    }
    func clearRooms() {
        roomIds.removeAll()
        rooms.removeAll()
    }
    func makeCurrentUser() {
        for progress in SavedProgress.shared.getSavedUser(username: username)
        {
            progress.isCurrentUser = true
        }
    }
    @MainActor
    func updateRooms() async {
        for (_, element) in roomIds.enumerated() {
            let inRoom = await isInRoom(roomID: element, username: username)
            if inRoom {
                var hasRoom = false
                if rooms.contains(where: { room in
                    room.id == element
                }) {
                    hasRoom = true
                }
                if !hasRoom {
                    let newRoom = Room(roomId: element)
                    rooms.append(newRoom)
                    newRoom.getUser(username)
                }

            }
            else
            {
                try? await Firestore.firestore().collection("users").document(id).updateData(["rooms": FieldValue.arrayRemove([element])])
                if let deleteIndex = roomIds.firstIndex(of: element)
                {
                    roomIds.remove(at: deleteIndex)
                }

            }
        }
        try? await Firestore.firestore().collection("users").document(self.id).collection("deletes").document("deleteInfo").setData(["actionNeeded": false])
    }
    private func isInRoom(roomID: String, username: String) async -> Bool
    {
        do{
            let document = try await Firestore.firestore().collection("rooms").document(roomID).collection("progress").document(username).getDocument()
            ReadTracker.shared.read(label: "Check if Room Exists")
            if document.exists
            {
                return true
            }
            else
            {
                return false
            }
        }
        catch {
            print(error.localizedDescription)
            return false
        }
    }

    func accessed () {
        lastAccessed = Date().formatted(date: .abbreviated, time: .omitted)
        Firestore.firestore().collection("users").document(id).updateData(["lastAccessed": lastAccessed])
    }
    func resetDaily() {
        print("resetting")
        rooms.forEach { room in
            room.resetDaily(username: username)
        }
    }
    
    
    //maybe multiple indices of room id?
    func addRoom(_ room: Room) {
        roomIds.append(room.id)
        rooms.append(room)
        room.getUser(username)
        //updateViewableRooms()
    }
    
    func removeRoom(_ room: Room) {
        if let index = roomIds.firstIndex(of: room.id) {
            roomIds.remove(at: index)
            rooms.remove(at: index)
            objectWillChange.send()
            //updateViewableRooms()
            removeRoom(room)
        }
    }
    func removeRoom(_ roomId: String) {
        if let index = roomIds.firstIndex(of: roomId) {
            roomIds.remove(at: index)
            rooms.remove(at: index)
            objectWillChange.send()
            // else ->updateViewableRooms()
            removeRoom(roomId)
        }
    }
    /*
    func updateViewableRooms () {
        viewableRooms = []
        for room in rooms
        {
            if viewableRooms.contains(where: { element in
                if element.id == room.id {
                    return false
                }
                else {
                    return true
                }
            }) {
                viewableRooms.append(room)
            }
        }
    }*/
    func changeColor(newColor: Color){
        let newColorHex = newColor.toHex() ?? "000000"
        let db = Firestore.firestore()
        db.collection("users").document(id).updateData(["color": newColorHex])
        color = newColorHex
        
        for room in rooms
        {
            room.changeUserColor(username: username, color: newColorHex)
            SavedProgress.shared.getUser(username: username, roomId: room.id).color = newColorHex
        }
    }
    func reset () {
        rooms = []
        roomIds = []
        id = ""
        username = ""
        color = ""
        email = ""
        lastAccessed = ""
        isConfigured = false
    }
    
//    func getRooms() -> [Room] {
//        var returnable: [Room] = []
//        var index = 0
//        rooms.forEach { room in
//            returnable[index] = Room(roomId: room)
//            index+=1
//        }
//        return returnable
//    }
    /*
    .getDocument {
    if let document = document, document.exists {
        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
        print("Document data: \(dataDescription)")
        let fieldValue = document.get("myFieldName") as? Int
        let fieldValueType2 = document.data()["myFieldName"] as? Int
    } else {
        print("Document does not exist")
    }
 
 
}*/
 
//    func getData() {
//        //get a reference to the database
//        let db = Firestore.firestore()
//        //read the documents to a specific path
//        db.collection("users").getDocuments { snapshot, error in
//            //check for errors
//            if error == nil {
//                //no errors
//                if let snapshot = snapshot {
//                    //update the list property in the main thread
//                    DispatchQueue.main.async {
//                        snapshot.
//
//
//
//
//                        self.list = snapshot.documents.map { d in
//                            //create a user item for each document returned
//                            return Room(
//                                id: d.documentID,
//                                name: d["name"] as? String ?? "",
//                                color: d["color"] as? String ?? "",
//                                target: d["target"] as? Int? ?? 0,
//                                code: d["code"] as? String ?? "",
//                                totalProgress: d["total progress"] as? Int? ?? 0,
//                                userProgress: d["user progress"] as? [(String, Int)] ?? [("", 0)]
//                                )
//                        }
//                    }
//                }
//            }
//            else {
//                //handle errors
//            }
//        }
 
    
}
