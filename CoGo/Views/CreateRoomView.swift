//
//  CreateRoomView.swift
//  CoGo
//
//  Created by Abigail Joseph on 2/6/22.
//

import Firebase
import FirebaseAuth
import SwiftUI

struct CreateRoomView: View{
    
  //  @State var openRoom: Room
    @State var name = ""
    @State var owner = ""
    @State var roomColor = Color(hex: "F97878")
    @State var colorHex = ""
    @State var target: Int = 6
    @State var id = ""
    
    //@State var colors: [String] = ["D56A90","A3659A", "0071B2", "006B93", "6E70BE", "0D9801"]
    
    @EnvironmentObject var user: User
    @State var colorClicked = ""
    @State var model = RoomCreationModel()
    @State var show = false
    @State var code: String = ""
   // @Binding var isClicked: Bool
    
    //@ObservedObject var model = RoomModel()
    
    var body: some View{
        ZStack{
            Color(UIColor(named: "bgColor")!)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
            
            //ScrollView{
                VStack{//v0
                    
                   // Spacer()
                    
                    VStack{//v1
                        Spacer()
                        
                        ZStack{
                            Circle()
                                .fill(Color(hex: "F97878"))
                            HStack{
                                
                                Text("cogo")
                                    .foregroundColor(.white)
                                    .font(Font.custom("Futura-Medium", size: 60))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                
                            }.frame(width: UIScreen.screenWidth * 0.30, height: UIScreen.screenHeight * 0.2, alignment: .center)
                            
                        }.frame(width: UIScreen.screenWidth * 0.35, height: UIScreen.screenHeight * 0.2, alignment: .center)//.border(Color.blue)
                       
                        HStack{
                            
                            ColorPicker("Room Color:", selection: $roomColor, supportsOpacity: false)
                                .foregroundColor(.gray)
                                //.preferredColorScheme(.light)
                        }.frame(width: UIScreen.screenWidth * 0.6)
                        
                    }.frame(height: UIScreen.screenHeight * 0.3)//v1
                    
                    VStack{//1.5
                        VStack{//v2
                            
                            TextField("Room Goal", text: $name)
                                .textFieldStyle(MyTextFieldStyle())
                                .foregroundColor(Color(UIColor(named: "grey")!))
                                //.border(Color.purple)
                           
                            HStack{
                                Text("Target Completions Per Day:")
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                            
                           
                            VStack{
                                Picker("Target Completions", selection: $target){
                                    ForEach(1...30, id: \.self){ number in
                                        Text("\(number)").tag(number)
                                            .foregroundColor(Color(UIColor(named: "grey")!))
                                    }
                                }.pickerStyle(.wheel)//.border(Color.green)
                                    
                            }.frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.6 * 0.4)
                                .clipped()//.border(Color.blue)
                            
                            Button{
                                
                                //do something
                               // createRoom(name: name, owner: user.username, color: colorHex, target: target).addUser(newUser: user)
                                if name != "" && target != 0 {
                                    Task {
                                      code =  await model.createRoom(owner: user, name: name, target: target, color: roomColor.toHex() ?? "000000")
                                        //clear textfield
                                        name = ""
                                        colorHex = roomColor.toHex() ?? "000000"
                                       // print("colorHex: \(colorHex)")
                                        withAnimation {
                                            show.toggle()
                                        }
                                        
                                        //print("create room btn: \(model.getCode())")
                                         
                                    }
                                }
                                
                            } label:{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(.green.opacity(0.25))
                                    Text("Create Room")
                                        .foregroundColor(.black)
                                }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                            }//btn
                            
                            Spacer()
                        }.padding([.bottom])
                            .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.5, alignment: .center)
                            //.border(Color.yellow)
                            //v2
                    }.frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.5, alignment: .center)
                    .contentShape(Rectangle())
                    //.clipShape(Rectangle())
                    .onTapGesture {
                           dismissKeyboard()
                    }//1.5
                    
                        
                    }.frame( width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .center)//.border(Color.red)//v0
                    
        
           // }//scroll
            
            if show{
                
                GeometryReader{g in
                    
                    VStack{
                        Spacer()
                        
                        HStack{
                            Spacer()
                            CopyCode(code: code, show: $show)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                 }.background(
                    
                    Color.black.opacity(0.65)
                        .edgesIgnoringSafeArea(.all)
                
                )
            }//if

        }//z
      
    }//someview
    
    struct MyTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(.white)
                    .addBorder(Color.gray.opacity(0.5), cornerRadius: 20)
                    .frame(height: UIScreen.screenHeight * 0.07)
                    //.stroke(Color.gray, lineWidth: 1)
                    
                    
            )
        }
    }
    
    struct CopyCode : View{
        
        @State var code: String
        @State var buttonText = "Copy code to clipboard"
        private let pasteboard = UIPasteboard.general
        @Binding var show: Bool
        
        
        var body: some View{
            VStack(spacing: 10){
                
                HStack{
                    
                    Spacer()
                    
                    Button{
                        
                        withAnimation {
                            show.toggle()
                        }
                        
                    }label:{
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.black)
                            .font(.system(size: 22))
                    }.padding([.trailing, .top])
                    
                }
               
               
                Text("Successfully created room!")
                    .foregroundColor(Color(UIColor(named: "cogoColor")!))
                    .font(Font.custom("Futura-Medium", size: 25))
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    
                            
                Text("Copy the following code to invite users to your room. You can distribute this code by sharing it via any messaging platform. Users can join your room by pasting the following code in the join room page.")
                    .foregroundColor(.black)
                    .font(Font.custom("Futura-Medium", size: 14))
                    .lineLimit(nil)
                    .padding([.leading, .trailing])
                    
                
                Text("Room Code: \(code)")
                    .foregroundColor(.black)
                    .font(Font.custom("Futura-Medium", size: 18))
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .frame(alignment: .leading)

                
                HStack{
                    Button{
                        copyToClipboard()
                        
                    }label:{
                        Label(buttonText, systemImage: "doc.on.doc.fill")
                            .foregroundColor(.black)
                            .font(Font.custom("Futura-Medium", size: 18))
                           
                    }.padding([.bottom])
                    
                }
                
              
                
            }.background(Color.white)
                .cornerRadius(15)
        }
        
        func copyToClipboard(){
            pasteboard.string = self.code
            self.buttonText = "Copied!"
            
            
        }
    }
    
//    private func createRoom(name: String, owner: String, color: String, target: Int?) -> Room{
//        let currentUser = Auth.auth().currentUser
//        if let currentUser = currentUser {
//            id = currentUser.uid
//        }
//
//        let db = Firestore.firestore()
//
//        var ref: DocumentReference? = nil
//
//        //add a document to a collection
//        ref = db.collection("rooms").addDocument(data: ["name":name,"owner":owner,"color":color, "target":target!, "totalProgress": 0, "groupCompletion": 0]) { error in
//
//            //check for errors
//            if error == nil{
//
//                //add the document id of newly created room to roomids and room object to rooms array
//                user.roomIds.append(ref!.documentID)
//                user.rooms.append(Room(roomId: ref!.documentID))
//
//                for ids in user.roomIds{
//                    print("(everything in user.roomids) newly created room id: \(ids)")
//                }
//
//                //adds newly created document id to rooms array in database "users" collection
//                db.collection("users").document(id).updateData(["rooms": FieldValue.arrayUnion([ref!.documentID])])
//            }
//            else{
//                //Handle the error
//            }
//
//        }
//        return Room(roomId: ref!.documentID)
//    }

}
