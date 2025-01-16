//
//  RoomSettingsView.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/7/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

struct RoomSettingsView: View{
    
    @ObservedObject var room: Room
    
    @State var temp: [UserProgress]
    @Binding var isClicked: Bool
    @Binding var inRoom: Bool
    @State var newRoomColor: Color
    @EnvironmentObject var user: User
    
    @State var logout = false
    //@ObservedObject var memberArray = MemberArray()
    @State var buttonText = "Copy code to clipboard"
    private let pasteboard = UIPasteboard.general
   // @State var newRoomColorHex = ""
    //@State var id = ""
    
    init(room: Room, isClicked: Binding<Bool>, inRoom: Binding<Bool>){
        self.room = room
        self.temp = []
        self._isClicked = isClicked
        self._inRoom = inRoom
        self.newRoomColor = Color(hex: room.color)//Color(room.color)
        
        //memberArray.reload(room: room)
    }
    
    var body: some View{
        
        ZStack{
            Color(UIColor(named: "bgColor")!)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
                //.statusBarStyle(.darkContent, ignoreDarkMode: true)
            
            ScrollView{
                
                VStack{
                    
                    //page title and x button
                    VStack{
                        HStack{
                            
                            Text("Room Settings")
                                .foregroundColor(.black)
                                .font(Font.custom("Futura-Medium", size: 40))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                                
                            
                            Spacer()
                            
                            Button{
                                isClicked = false
                            }label:{
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(Color("F97878"))
                                    .font(Font.title.weight(.semibold))
                            }
                            
                        }.frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.05)//hstack
                        Spacer()
                            .frame(height: UIScreen.screenHeight * 0.02)
                         
                    }//.frame(height: UIScreen.screenHeight * 0.35)//v
                    
                    
                    //color rectangle
                   
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(room.color))
                        .frame(width: UIScreen.screenWidth * 0.30, height: UIScreen.screenHeight * 0.13, alignment: .center)
                  
                    HStack{
                        
                        ColorPicker("Change Room Color:", selection: $newRoomColor, supportsOpacity: false)
                            .foregroundColor(Color(UIColor(named: "black")!))
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                            .onChange(of: newRoomColor) { newValue in
                                room.changeColor(newColor: newRoomColor)
                            }
                        
                    }.frame(width: UIScreen.screenWidth * 0.50)
                    
                    //info rectagle
                    ZStack{
                    

                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white.opacity(0.5))
                            .addBorder(Color.gray, cornerRadius: 20)
                            .frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.3, alignment: .center)
                        
                        VStack{
                           Spacer()
                            HStack{
                                Text("Room Summary:")
                                    .foregroundColor(Color(UIColor(named: "black")!))
                                    .font(Font.custom("Futura-Medium", size: 20))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    //.border(Color.red)
                                Spacer()
                            }//.border(Color.blue)
                            Spacer()
                                //.frame(height: UIScreen.screenHeight * 0.015)
                            HStack{
                                Text("This room's goal is to \(room.name) \(room.target) times a day. \(room.getOwner()) created this room on \(room.created).")
                                    .foregroundColor(Color(UIColor(named: "black")!))
                                    .font(Font.custom("Futura-Medium", size: 12))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .scaledToFit()
                                    .minimumScaleFactor(0.5)
                                    //.border(Color.blue)
                                Spacer()
                            }
                            Spacer()
                            
                            HStack{
                                Text("Room Code:")
                                    .foregroundColor(Color(UIColor(named: "black")!))
                                    .font(Font.custom("Futura-Medium", size: 17))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                
                                Text("\(room.id)")
                                    .foregroundColor(Color(UIColor(named: "black")!))
                                    .font(Font.custom("Arial", size: 15))
                                    .padding(10)
                                    .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.black, lineWidth: 2)
                                        )
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            HStack{
                                Button{
                                    copyToClipboard()
                                    
                                }label:{
                                    Label(buttonText, systemImage: "doc.on.doc.fill")
                                        .foregroundColor(.black)
                                        .font(Font.custom("Futura-Medium", size: 20))
                                        .scaledToFit()
                                        .minimumScaleFactor(0.01)
                                        .lineLimit(1)
                                        .labelStyle(.titleAndIcon)
                                        .frame(width: UIScreen.screenWidth * 0.80)
                                }
                                
                            }
                            
                            Spacer()
                            
                        }.frame(width: UIScreen.screenWidth * 0.80, height:  UIScreen.screenHeight * 0.3)//vstack
                    }//zstack
                    
                    Spacer()
                        .frame(height: UIScreen.screenHeight * 0.03)
                    
                    //second rectangle
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white.opacity(0.5))
                            .addBorder(Color.gray, cornerRadius: 20)
                            .frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.10 * CGFloat(room.users.count + 1), alignment: .center)
                        VStack{
                               // .frame(height: UIScreen.screenHeight * 0.015)
                            
                            Spacer()
                            
                            HStack{
                                Text("Room Members:")
                                    .foregroundColor(Color(UIColor(named: "black")!))
                                    .font(Font.custom("Futura-Medium", size: 20))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.1)
                                    .lineLimit(1)
                                    //.border(Color.green)
                                
                                Spacer()
                            }
                            Spacer()
                            ForEach(room.users, id: \.self){ member in
                                MemberView(member: room.getUser(member), room: room).environmentObject(user)//.environmentObject(memberArray)
                                
                            }
                            
                            Spacer()
                           
                            Button{
                                Task {
                                    user.removeRoom(room)
                                    isClicked = false
                                    withoutAnimation {
                                        inRoom = false
                                    }
                                    await room.removeUser(username: user.username, removeSelf: true)
                                }
                                
                                
                            } label:{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("FF000056"))
                                    
                                    Text("Leave Room")
                                        .foregroundColor(.black)
                                        .scaledToFit()
                                        .minimumScaleFactor(0.01)
                                        .lineLimit(1)
                                }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)//zstack
                            }
                            
                            
                            Spacer()
                            
                        }.frame(width: UIScreen.screenWidth * 0.80, height: UIScreen.screenHeight * 0.10 * CGFloat(room.users.count + 1), alignment: .center)//vstack
                    }//zstack
                    
                    Spacer()
                   
                }.frame(maxWidth: .infinity)//vstack
                
            }//scroll view
            
            
        }//.statusBarStyle(.darkContent, ignoreDarkMode: true)//zstack
        
        
        
    }//someview
    
    /*func getMembers() -> Array<UserProgress>{
        room.getLeaderboard() { users in
            temp = users
        }
        
        return temp
    }*/
    
    func colorFunc(newColor: Color) -> Color{
        newRoomColor = newColor
        return newRoomColor
    }
    func copyToClipboard(){
        pasteboard.string = self.room.id
        self.buttonText = "Copied!"
        
        
    }
    
    
//    private func changeRoomColor(newColor: Color, roomToUpdate: Room){
//
//        newRoomColorHex = newColor.toHex() ?? "000000"
//
//        let db = Firestore.firestore()
//
//        //set the data to update
//        //set data -> whole thing gets replaced and only data in .setData() will be there unless you use merge: true
//        db.collection("rooms").document(roomToUpdate.id).setData(["color": newRoomColorHex], merge: true) { error in
//            //check for errors
//            if error == nil {
//                //get the new data
//                //self.getData()
//            }
////        }
//        
//    }
}//rooomsettingsview

struct MemberView: View{
    @EnvironmentObject var user: User
    //@EnvironmentObject var memberArray: MemberArray
    var member: UserProgress
    @ObservedObject var room: Room
    
    var body: some View{
        
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color("FFDBCD89"))
               // .frame(width: UIScreen.screenWidth * 0.80, height: UIScreen.screenHeight * 0.05, alignment: .top)
            
          //  HStack{
                HStack{
                    
                    Circle()
                        .fill()
                        .foregroundColor(Color(member.color))
                        .frame(width:  UIScreen.screenWidth * 0.80 * 0.15, height: UIScreen.screenHeight * 0.05 * 0.7)
                    
                    if room.isOwner(username: member.username){
                        Text("\(member.username) (Owner)")
                            .foregroundColor(Color(UIColor(named: "black")!))
                    }
                    else{
                        
                        Text(member.username)
                            .foregroundColor(Color(UIColor(named: "black")!))
                        
                    }
                    Spacer()
                    if (room.isOwner(username: user.username) && member.username != room.owner)
                    {
                        Button{
                            Task {
                                await room.removeUser(username: member.username, removeSelf: false)
                                //memberArray.reload(room: room)
                            }
                        }label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("FF000056"))
                                Text("Remove")
                                    .foregroundColor(.black)
                                    .scaledToFit()
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                            }.frame(width: UIScreen.screenWidth * 0.22, height: UIScreen.screenHeight * 0.04)
                            
                        }
                    }
                    Spacer()
                        .frame(width: UIScreen.screenWidth * 0.80 * 0.02)
                    
                }//.frame(width: UIScreen.screenWidth * 0.75, alignment: .leading).border(Color.red)//hstack
                
              //  Spacer()
           // }.frame(width: UIScreen.screenWidth * 0.85).border(Color.yellow)
           
        }.frame(width: UIScreen.screenWidth * 0.80, height: UIScreen.screenHeight * 0.07, alignment: .top)//.border(Color.green)//zstack
    }
}

class MemberArray: ObservableObject {
    @Published var members = Array<UserProgress>()
    
//    func reload (room: Room) {
//        room.getLeaderboard() { users in
//            self.members = users
//        }
//    }
}




