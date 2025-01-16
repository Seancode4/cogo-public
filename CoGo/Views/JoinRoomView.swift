//
//  JoinRoomView.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/15/22.
//

import Foundation
import SwiftUI

struct JoinRoomView: View{
    
    @EnvironmentObject var user: User
    @State var roomCode = ""
    @State var roomId = ""
    @State var isLoading   = false
    @StateObject var model = RoomCreationModel()

    @State var success = false
    @State var clicked = false
    //@ObservedObject var chartData: ChartData = ChartData(values: [("", 0)])
    @State var tappedArrow: Bool = true
    @Binding var tabSelection: Int
    @State var textSwitch = false
    
    
    var body: some View{
        ZStack{
            Color(UIColor(named: "bgColor")!)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
            
           // ScrollView{
                 
                 VStack{
                     
                     Spacer()
                         .frame(height: UIScreen.screenHeight * 0.2)
                         
                     ZStack{
                         Circle()
                             .foregroundColor(Color("F97878"))
                             //.frame(width: UIScreen.screenWidth * 0.5, height: UIScreen.screenHeight * 0.3, alignment: .center)
                         HStack{
                             
                             Text("cogo")
                                 .foregroundColor(.white)
                                 .font(Font.custom("Futura-Medium", size: 60))
                                 .scaledToFit()
                                 .minimumScaleFactor(0.01)
                                 .lineLimit(1)
                             
                         }.frame(width: UIScreen.screenWidth * 0.30, height: UIScreen.screenHeight * 0.2, alignment: .center)
                         
                     }.frame(width: UIScreen.screenWidth * 0.35, height: UIScreen.screenHeight * 0.2, alignment: .center)
                     
                     Spacer()
                         .frame(height: UIScreen.screenHeight * 0.03)
                    
                     TextField("Room Code", text: $roomCode)
                         .textFieldStyle(MyTextFieldStyle())
                         .frame(width: UIScreen.screenWidth * 0.55, alignment: .center)
                         .autocapitalization(.none)
                         .disableAutocorrection(true)
                    
                     
                     Spacer()
                         .frame(height: UIScreen.screenHeight * 0.03)
                     
                     Button{
                         
                         //do something
                         
                         if roomCode != ""{
                             Task {
                                 if await model.joinRoom(user: user, code: roomCode){
                                     roomId = roomCode
                                     
                                     withoutAnimation {
                                         clicked = false
                                         roomCode = ""
                                         success = true
                                     }
                                     
                                 }else{
                                     
                                     roomCode = ""
                                     clicked = true
                                 }
                                 
                                 //clear textfield
                                   
                             }
                         }
                         
                     } label:{
                         ZStack{
                             RoundedRectangle(cornerRadius: 20)
                                 .foregroundColor(.green.opacity(0.25))
                             Text("Join Room")
                                 .foregroundColor(.black)
                                 .scaledToFit()
                                 .minimumScaleFactor(0.01)
                                 .lineLimit(1)
                         }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                     }.fullScreenCover(isPresented: $success) {
                         //RoomScreenView(room: Room(roomId: roomId), tappedArrow: $success, chartData: RoomCard(roomCard: Room(roomId: roomId), user: user).chartData).environmentObject(user)
                         RoomScreenView(room: model.newRoom!, tappedArrow: $success, chartData: RoomCard(roomCard: model.newRoom!, user: user).chartData).environmentObject(user)
                     }
                     
                     
                     
                     if clicked{
                         HStack{
                             Text("Error Joining Room")
                                 .foregroundColor(Color.red)
                                 .font(.system(size: 14))
                                 .scaledToFit()
                                 .minimumScaleFactor(0.01)
                                 .lineLimit(1)
                         }
                         //JoinRoomMessageView(show: $clicked)
                     }
                     
                     
                     
                     Spacer()
                     
                 }.frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)//vstack
                
            //}//scrollview
            
            //blue
            Circle()
                .foregroundColor(Color("006B9349"))
                .frame(width: UIScreen.screenWidth * 0.7, height: UIScreen.screenHeight * 0.5, alignment: .center)
                .position(x: UIScreen.screenWidth * 0.8, y: UIScreen.screenHeight * 0.9)
            
            //purple
            Circle()
                .foregroundColor(Color("7E34C933"))
                .frame(width: UIScreen.screenWidth * 0.5, height: UIScreen.screenHeight * 0.3, alignment: .center)
                .position(x: UIScreen.screenWidth * 0.9, y: UIScreen.screenHeight * 0.7)
            
           /* if isLoading{
                LoadingView()
            } */
            
        }.onAppear {
            clicked = false
        }
        .onTapGesture {
            
            dismissKeyboard()
            
        }
        //.onAppear{ startFakeNetowrkingCall() }//zstack
        
        
    }
    
  /*  func startFakeNetowrkingCall(){
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2){
            isLoading = false
        }
    } */
    
    struct MyTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(20)
                
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(.white)
                    .addBorder(Color.gray.opacity(0.5), cornerRadius: 20)
                    //.frame(height: UIScreen.screenHeight * 0.07)
                    //.stroke(Color.gray, lineWidth: 1)
                    
                    
            )
            
        }
    }
    
  /*  struct JoinRoomMessageView: View{
        
        //@State var success: Bool
        @Binding var show: Bool
        @State var textSwitch = false
        
        var body: some View{
            
           HStack{
                        
             /*  if success{
                   Text((textSwitch ? "" : "successfully joined room!"))
                       .foregroundColor(Color.black)
                       .font(.system(size: 14))
                       .scaledToFit()
                       .minimumScaleFactor(0.01)
                       .lineLimit(1)
                       .onAppear {
                           DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                               self.textSwitch.toggle()
                           }
                       } */

              // }else{
                   Text((textSwitch ?  ""  : "Error Joining Room"))
                       .foregroundColor(Color.red)
                       .font(.system(size: 14))
                       .scaledToFit()
                       .minimumScaleFactor(0.01)
                       .lineLimit(1)
                       .onAppear {
                           DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                               self.textSwitch.toggle()
                           }
                       }

              // }
                      
           }
            
        }
 } */
}


