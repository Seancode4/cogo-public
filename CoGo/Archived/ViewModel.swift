//
//  ViewModel.swift
//  CoGo
//
//  Created by Abigail Joseph and Sean Noh on 1/7/22.
//
/*
import Foundation
import Firebase

class ViewModel: ObservableObject {
    @Published var list = [User]()
    
    /* func addData (name: String, notes: String) {
        let db = Firestore.d
    } */
    
    func getData() {
        //get a reference to the database
        let db = Firestore.firestore()
        //read the documents to a specific path
        db.collection("users").getDocuments { snapshot, error in
            //check for errors
            if error == nil {
                //no errors
                if let snapshot = snapshot {
                    //update the list property in the main thread
                    DispatchQueue.main.async {
                        //get all the documents and create Users
                        self.list = snapshot.documents.map { d in
                            //create a user item for each document returned 
                            return User(id: d.documentID, username: d["username"] as? String ?? "", password: d["password"] as? String ?? "", color: d["color"] as? String ?? "", /*, friends: d["friends"] as? [String] ?? [""]*/)
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
*/
