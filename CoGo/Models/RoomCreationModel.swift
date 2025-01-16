//
//  RoomCreationModel.swift
//  CoGo
//
//  Created by Sean Noh on 5/6/22.
//

import Foundation
import Firebase

class RoomCreationModel: ObservableObject {
    @Published var isRunning = false
    @Published var newRoom: Room?
    @Published var code: String?
    
    @MainActor
    func createRoom (owner: User, name: String, target: Int, color: String) async -> String{
        isRunning = true
        let code = await generateCode()
        let docRef = Firestore.firestore().collection("rooms").document(code)
        do {
            try await docRef.setData(["name": name, "owner": owner.username, "target": target, "color": color, "groupCompletion": 0, "totalProgress": 0, "created": Day.today, "lastReset": Day.today, "users": [owner.username]])
        }
        catch
        {
            print(error.localizedDescription)
        }
        try? await Firestore.firestore().collection("rooms").document(code).collection("progress").document(owner.username).setData( ["id": owner.id, "color": owner.color, "totalCount": 0, "streak": 0, "history": [Date().formatted(date: .abbreviated, time: .omitted): 0]])
        try? await Firestore.firestore().collection("users").document(owner.id).updateData(["rooms": FieldValue.arrayUnion([code])])
        newRoom = Room(roomId: code)
        owner.addRoom(newRoom!)
        isRunning = false
        
        return code
    }
    @MainActor
    private func generateCode () async -> String {
        var code = getString()
        var unique = false
        while (!unique)
        {
            let query = try? await Firebase.Firestore.firestore().collection("rooms").whereField(Firebase.FieldPath.documentID(), isEqualTo: code).getDocuments()
            ReadTracker.shared.read(label: "Check if Code is Unique")
            if let querySnapshot = query
            {
                if querySnapshot.isEmpty
                {
                    unique = true
                }
                else
                {
                    code = getString()
                }
            }
            
//            Firebase.Firestore.firestore().collection("rooms").whereField(Firebase.FieldPath.documentID(), isEqualTo: code).getDocuments { querySnapshot, err in
//                print("finished")
//                if let err = err {
//                    print("Error: \(err)")
//                    return
//                }
//                else {
//                    print(code)
//                    if querySnapshot!.isEmpty
//                    {
//                        unique = true
//                    }
//                    else
//                    {
//                        code = self.getString()
//                    }
//                }
//            }
            /*do {
                let doc = try await Firestore.firestore().collection("rooms").document(code).getDocument()
                if (doc.exists)
                {
                    code = getString()
                }
                else
                {
                    unique = true
                }
            }
            catch {
                print(error.localizedDescription)
            }*/
        }
        return code
    }
    @MainActor
    func joinRoom (user: User, code: String) async -> Bool {
        isRunning = true
        var roomExists = false
        
        do {
            let roomQuery = try? await Firebase.Firestore.firestore().collection("rooms").whereField(Firebase.FieldPath.documentID(), isEqualTo: code).getDocuments()
            ReadTracker.shared.read(label: "Check if Room Exists to Join")
            if let querySnapshot = roomQuery
            {
                if querySnapshot.isEmpty
                {
                    roomExists = false
                }
                else
                {
                    roomExists = true
                }
            }
            let userDoc = try await Firestore.firestore().collection("rooms").document(code).collection("progress").document(user.username).getDocument()
            ReadTracker.shared.read(label: "Create Progress Doc for Room")
            if (roomExists && !userDoc.exists)
            {
                isRunning = false
                try? await Firestore.firestore().collection("rooms").document(code).collection("progress").document(user.username).setData( ["id": user.id, "color": user.color, "totalCount": 0, "streak": 0, "history": [Date().formatted(date: .abbreviated, time: .omitted): 0]])
                try? await Firestore.firestore().collection("users").document(user.id).updateData(["rooms": FieldValue.arrayUnion([code])])
                try? await Firestore.firestore().collection("rooms").document(code).updateData(["users": FieldValue.arrayUnion([user.username])])
                newRoom = Room(roomId: code)
                while (newRoom?.configured == false)
                {
                    try? await Task.sleep(nanoseconds: UInt64(0.1) * 1_000_000_000)
                }
                if (newRoom?.lastReset != Day.today)
                {
                    newRoom!.resetOthers(user.username)
                }
                //let data = try await Firestore.firestore().collection("rooms").document(code).collection("progress").document(user.username).getDocument().data()!
                //let progress = UserProgress(id: data["id"] as! String, username: user.username, color: data["color"] as! String, dailyCount: 0, totalCount: 0, streak: 0, history: data["history"] as! Dictionary<String, Int>, room: newRoom!, isCurrentUser: true)
                var history = Dictionary<String, Int>()
                history[Day.today] = 0
                let progress = UserProgress(id: user.id, username: user.username, color: user.color, dailyCount: 0, totalCount: 0, streak: 0, history: history, room: newRoom!, isCurrentUser: true)
                SavedProgress.shared.addUser(progress)
                user.addRoom(newRoom!)
                await newRoom?.newUserGroupCompletion()
                print("new room")
                return true
            }
            else
            {
                isRunning = false
                print("no new room")
                return false
            }
        }
        catch {
            print(error.localizedDescription)
        }
        isRunning = false
        return false
    }
    private func getString () -> String {
        let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        return String("\(alphabet.randomElement()!)\(alphabet.randomElement()!)\(alphabet.randomElement()!)\(alphabet.randomElement()!)\(alphabet.randomElement()!)\(alphabet.randomElement()!)")
    }
    func getCode() -> String {
        return code ?? ""
    }
}
