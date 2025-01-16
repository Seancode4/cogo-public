//
//  RoomCreationView.swift
//  CoGo
//
//  Created by Sean Noh on 5/6/22.
//

import SwiftUI

struct RoomCreationView: View {
    @EnvironmentObject var user: User
    @StateObject var model = RoomCreationModel()
    var body: some View {
        
        if (model.isRunning)
        {
            Text("Loading")
        }
        else
        {
            VStack {
                Button {
                    Task {
                        await model.createRoom(owner: user, name: "NEW GOAL BB", target: 1, color: "000000")
                    }
                } label: {
                    Text("Create Room")
                }
                Button {
                    Task {
                        await model.joinRoom(user: user, code: "orwfyw")
                    }
                } label: {
                    Text("Join Room orwfyw")
                }
                Button {
                    Task {
                        await Room(roomId: "orwfyw").removeUser(username: user.username, removeSelf: true)
                    }
                } label: {
                    Text("Remove User From orwfyw")
                }

            }
        }
    }
}

struct RoomCreationView_Previews: PreviewProvider {
    static var previews: some View {
        RoomCreationView()
    }
}
