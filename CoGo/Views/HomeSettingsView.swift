//
//  HomeSettingsView.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/7/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

struct HomeSettingsView: View{
    @EnvironmentObject var user: User
    @EnvironmentObject var userSettings: UserSettings

    //@ObservedObject var room = Room(roomId: <#String#>)
    @State var newUserColor: Color = Color.white
    //@State var newRoomColorHex = ""
    @State var rectangleWidth = UIScreen.screenWidth * 0.90
    @State var firstRectangleHeight = UIScreen.screenWidth * 0.30
    @State var passwordText = " "
    @State var deleteAcc = false

   // @Binding var isClicked: Bool
    
   /* init(){
        //self.user = user
        self.newRoomColor = Color(hex: user.color)
    } */
    
    var body: some View{
        
        ZStack{
            Color(UIColor(named: "bgColor")!)
                .ignoresSafeArea()
            ScrollView{
                
                VStack{
                    
                    //page title and x button & color circle
                    VStack{
                        HStack{
                            
                            Text("Settings")
                                .foregroundColor(.black)
                                .font(Font.custom("Futura-Medium", size: 40))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                            
                            
                            
                        }.frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.05, alignment: .leading)//.border(Color.blue)//hstack
                        
                        
                    }//.frame(height: UIScreen.screenHeight * 0.3)//v
                    
                    //user color
                    Circle()
                        .foregroundColor(Color(user.color))
                        .frame(width: UIScreen.screenWidth * 0.30, height: UIScreen.screenHeight * 0.13, alignment: .center)
                    
                    HStack{
                        
                        ColorPicker("Change Your Profile Color:", selection: $newUserColor, supportsOpacity: false)
                            .foregroundColor(Color(UIColor(named: "black")!))
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                            .onAppear(perform: {
                                self.newUserColor = Color(hex: user.color)
                            })
                            .onChange(of: newUserColor) { newValue in
                                
                                if newUserColor != Color(hex: user.color){
                                    user.changeColor(newColor: newUserColor)
                                    print("user color in loop: \(newUserColor)")
                                }
                            }
                            
                         //   changeRoomColor(newColor: newRoomColor)
                        
                    }.frame(width: UIScreen.screenWidth * 0.50)
                    
                    //info rectangle
                    ZStack{
                        
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white.opacity(0.5))
                            .addBorder(Color.gray, cornerRadius: 20)
                            
                        
                        VStack{
                            
                           // Spacer()
                            
                           // VStack{
                                
                                HStack{
                                    Text("My Account:")
                                        .foregroundColor(Color(UIColor(named: "black")!))
                                            .font(Font.custom("Futura-Medium", size: 40))
                                             .scaledToFit()
                                             .minimumScaleFactor(0.05)
                                             .lineLimit(1)
                                        //.font(Font.custom("Futura-Medium", size: 30))
                                    Spacer()
                                }
                            
                                Spacer()
                            
                                HStack{
                                    Text("My Username: \(user.username)")
                                        .foregroundColor(Color(UIColor(named: "black")!))
                                        .font(Font.custom("Futura-Medium", size: 15))
                                        .scaledToFit()
                                        .minimumScaleFactor(0.01)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                
                                HStack{
                                    Text("My Email: \(user.email)")
                                        .foregroundColor(Color(UIColor(named: "black")!))
                                        .font(Font.custom("Futura-Medium", size: 15))
                                        .scaledToFit()
                                        .minimumScaleFactor(0.01)
                                        .lineLimit(1)
                                    Spacer()
                                }
                          /*  Text("  ")
                                .font(.system(size: 15)) */
                                
                           // }//.frame(width: UIScreen.screenWidth * 0.80, height:  UIScreen.screenHeight * 0.1)
                            
                            Spacer()
                            
                            Button{
                                //change password
                                Auth.auth().sendPasswordReset(withEmail: user.email) { error in
                                    if let error = error
                                    {
                                        self.passwordText = "Failed to reset password: \(error.localizedDescription)"
                                    }
                                    else
                                    {
                                        self.passwordText = "Password Reset Sent to Your Email!"
                                    }
                                }
                                
                            }label:{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(.green.opacity(0.25))
                                    HStack{
                                        Text("Change Password")
                                            .foregroundColor(Color.black)
                                            .scaledToFit()
                                            .minimumScaleFactor(0.01)
                                            .lineLimit(1)
                                    }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                    
                                }.frame(width: UIScreen.screenWidth * 0.50, height: UIScreen.screenHeight * 0.05, alignment: .center)
                            }
                            Button{
                              //logout
                                user.reset()
                                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                                    SavedProgress.shared.clear()
                                    userSettings.logOut()
                                }
                            }label:{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color("FF000056"))
                                    HStack{
                                        Text("Log Out")
                                            .foregroundColor(.black)
                                            .scaledToFit()
                                            .minimumScaleFactor(0.01)
                                            .lineLimit(1)
                                    }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                    
                                }.frame(width: UIScreen.screenWidth * 0.50, height: UIScreen.screenHeight * 0.05, alignment: .center)
                            }
                            
                            Button{
                              //delete account
                                deleteAcc.toggle()
                            }label:{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color("FF000086"))
                                    HStack{
                                        Text("Delete Account")
                                            .foregroundColor(.black)
                                            .scaledToFit()
                                            .minimumScaleFactor(0.01)
                                            .lineLimit(1)
                                    }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                    
                                }.frame(width: UIScreen.screenWidth * 0.50, height: UIScreen.screenHeight * 0.05, alignment: .center)
                            }
                            
                            Text(passwordText)
                                .foregroundColor(Color.red)
                                .font(.system(size: 14))
                            
                         //   Spacer()
                            
                        }.frame(width: UIScreen.screenWidth * 0.85, height:  UIScreen.screenHeight * 0.32)//.border(Color.blue)//vstack
                        
                        
                        
                    }.frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.35, alignment: .center)//zstack
                    
                    //info rectangle 2
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white.opacity(0.5))
                            .addBorder(Color.gray, cornerRadius: 20)
                            
                        
                        VStack{
                            HStack{
                                Text("Meet the Developers:")
                                    .foregroundColor(Color(UIColor(named: "black")!))
                                    .font(Font.custom("Futura-Medium", size: 30))
                                     .scaledToFit()
                                     .minimumScaleFactor(0.01)
                                     .lineLimit(1)
                                Spacer()
                            }.frame(width: UIScreen.screenWidth * 0.80)
                            
                            Spacer()
                           
                            Text("Sean Noh & Abigail Joseph")
                                .foregroundColor(Color(UIColor(named: "black")!))
                                .frame(alignment: .center)
                                .font(Font.custom("Futura-Medium", size: 15))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                            
                            Text("Co-Developers")
                                .frame(alignment: .center)
                                .font(Font.custom("Futura-Medium", size: 15))
                                .foregroundColor(Color("1D00D0"))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                            
                            Spacer()
                            
                           /* Text("Contact Us: thecogoapp@gmail.com")
                                .foregroundColor(Color(UIColor(named: "black")!))
                                .accentColor(Color("1D00D0"))
                                .frame(alignment: .center)
                                .font(Font.custom("Futura-Medium", size: 15))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)*/
                            
                            Text("Contact Us")
                                  .foregroundColor(Color(UIColor(named: "black")!))
                                  .accentColor(Color("1D00D0"))
                                  .frame(alignment: .center)
                                  .font(Font.custom("Futura-Medium", size: 15))
                                  .scaledToFit()
                                  .minimumScaleFactor(0.01)
                                  .lineLimit(1)
                            
                            Text("thecogoapp@gmail.com")
                                .font(Font.custom("Futura-Medium", size: 15))
                                .frame(alignment: .center)
                                .accentColor(Color("1D00D0"))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                            
                            
                           /* Spacer()
                            
                            Text("Abigail Joseph")
                                .foregroundColor(Color(UIColor(named: "black")!))
                                .frame(alignment: .center)
                                .font(Font.custom("Futura-Medium", size: 15))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                            
                            Text("Lead UI/UX Developer")
                                .font(Font.custom("Futura-Medium", size: 15))
                                .frame(alignment: .center)
                                .foregroundColor(Color("1D00D0"))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1) */
                        }.frame(width: UIScreen.screenWidth * 0.80, height: UIScreen.screenHeight * 0.15, alignment: .center)
                        
                    }.frame(width: UIScreen.screenWidth * 0.90, height: UIScreen.screenHeight * 0.2, alignment: .center)
                
                }.frame(width: UIScreen.screenWidth)//vstack
                
            }//.offset(x: 0, y: -20)//scrollview
            
            
            if deleteAcc{
                GeometryReader{g in
                    
                    VStack{
                        Spacer()
                        
                        HStack{
                            Spacer()
                            DeleteAccountView(show: $deleteAcc).environmentObject(user).environmentObject(userSettings)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                }.background(
                    Color.black.opacity(0.25)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            deleteAcc.toggle()
                        }
                )
            }//if
            
        }.onAppear {
            passwordText = " "
        }//zstack
    }
    
    
    struct DeleteAccountView: View{
        
        @EnvironmentObject var user: User
        @EnvironmentObject var userSettings: UserSettings
        @Binding var show: Bool
        @State var error: String = " "
        
        var body: some View{
            VStack(spacing: 10){
                
                Text("Are you sure you want to delete your account? This action can not be undone.")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                    .multilineTextAlignment(.center)
                
                
                 
                 Button{
                     //delete
                     Task
                     {
                         for room in user.rooms
                         {
                             user.removeRoom(room)
                             await room.removeUser(username: user.username, removeSelf: true)
                         }
                         print("removed rooms")
                         try? await Firestore.firestore().collection("users").document(user.id).collection("deletes").document("deleteInfo").delete()
                         try? await Firestore.firestore().collection("users").document(user.id).delete()
                         print("deleted user")
                         user.reset()
                         try? await Task.sleep(nanoseconds: UInt64(0.2) * 1_000_000_000)
                         SavedProgress.shared.clear()
                         userSettings.logOut()
                         print("gettinguser")
                         let userAuth = Auth.auth().currentUser
                         do
                         {
                             try await userAuth?.delete()
                             print("deleted auth")
                         }
                         catch
                         {
                             print("delete account failed")
                             self.error = "Delete account failed. Log out and try again."
                         }
                         do
                         {
                             try Auth.auth().signOut()
                         }
                         catch
                         {
                         }
                     }

                 }label:{
                     ZStack{
                         RoundedRectangle(cornerRadius: 20)
                             .foregroundColor(Color("FF0000"))
                         HStack{
                             Text("Delete")
                                 .foregroundColor(.black)
                                 .scaledToFit()
                                 .minimumScaleFactor(0.01)
                                 .lineLimit(1)
                         }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                         
                     }.frame(width: UIScreen.screenWidth * 0.50, height: UIScreen.screenHeight * 0.05, alignment: .center)
                 }.padding([.leading, .trailing])
                
               
                Button{
                    show.toggle()
                    
                }label:{
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(Color("c2c2c2"))
                        HStack{
                            Text("Cancel")
                                .foregroundColor(.black)
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                        }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                        
                    }.frame(width: UIScreen.screenWidth * 0.50, height: UIScreen.screenHeight * 0.05, alignment: .center)
                
                }.padding([.leading, .trailing])
                
                
               Text(error)
                    .foregroundColor(.red)
                    .padding([.bottom, .leading, .trailing])
                
                
            }.background(Color.white)
                .cornerRadius(15)
            
        }
    }
   
}


