//
//  RoomModel.swift
//  CoGo
//
//  Created by Abigail Joseph and Sean Noh on 1/7/22.
//
/*
import Foundation
import Firebase
import SwiftUI

class RoomModel: ObservableObject {
    @Published var list = [Room]()
    //adds updated in front of name
    func updateData(roomToUpdate: Room) {
        //get a reference to the database
        let db = Firestore.firestore()
        
        //set the data to update
        //set data -> whole thing gets replaced and only data in .setData() will be there unless you use merge: true
        db.collection("rooms").document(roomToUpdate.id).setData(["name": "Updated:\(roomToUpdate.name)"], merge: true) { error in
            //check for errors
            if error == nil {
                //get the new data
                self.getData()
            }
        }
    }
    
    func deleteData(roomToDelete: Room){
        
        //get a reference to the database
        let db = Firestore.firestore()
        
        //specify the document to delete
        db.collection("rooms").document(roomToDelete.id).delete { error in
            //check for errors
            
            if error == nil{
                //no errors
                //update the UI from the main thread
                DispatchQueue.main.async {
                    //remove the todo that was just deleted
                    self.list.removeAll{ room in
                        return room.id == roomToDelete.id
                    }
                }
            }
            
        }
    }

    
    //need to change the parameters
    func addData (name: String, owner: String, color: String, target: Int?) {
        //get a reference to the database
        
        let db = Firestore.firestore()
 
        //add a document to a collection
        db.collection("rooms").addDocument(data: ["name":name,"owner":owner,"color":color, "target":target!, "id": ]) { error in
            //check for errors
            if error == nil{
                //no errors
                
                //call get date to retrive latest data
                self.getData()
            }
            else{
                //Handle the error
                
            }
        }
    }
    

    
    func getData() {
        //get a reference to the database
        let db = Firestore.firestore()
        //read the documents to a specific path
        db.collection("rooms").getDocuments { snapshot, error in
            //check for errors
            if error == nil {
                //no errors
                if let snapshot = snapshot {
                    //update the list property in the main thread
                    DispatchQueue.main.async {
                        //get all the documents and create Users
                        self.list = snapshot.documents.map { d in
                            //create a user item for each document returned
                            return Room(
                                id: d.documentID,
                                name: d["name"] as? String ?? "",
                                color: d["color"] as? String ?? "",
                                target: d["target"] as? Int? ?? 0,
                                code: d["code"] as? String ?? "",
                                totalProgress: d["total progress"] as? Int? ?? 0,
                                userProgress: d["user progress"] as? [(String, Int)] ?? [("", 0)]
                                )
                        }
                    }
                }
            }
            else {
                //handle errors
            }
        }
    }
}

************/
