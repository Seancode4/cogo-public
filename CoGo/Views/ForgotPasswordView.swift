//
//  ForgotPasswordView.swift
//  CoGo
//
//  Created by Abigail Joseph on 6/22/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

struct ForgotPasswordView: View{
    
    @State var email = ""
    @Binding var clicked: Bool
    @State var loginStatusMessage = " "
    
    var body: some View{
        
        ZStack{
            Color(UIColor(named: "bgColor")!)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
            
            VStack{
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.03)
                    
                ZStack{
                    Circle()
                        .foregroundColor(Color("F97878"))
                        .frame(width: UIScreen.screenWidth * 0.35, height: UIScreen.screenHeight * 0.2, alignment: .center)
                    
                    Text("cogo")
                        .foregroundColor(.white)
                        .font(Font.custom("Futura-Medium", size: 60))
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .frame(width: UIScreen.screenWidth * 0.30, height: UIScreen.screenHeight * 0.2, alignment: .center)
                      
                }//z
                
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.10)
                   
               
               
                TextField("Email Address", text: $email)
                    .textFieldStyle(MyTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.03)
                
                Button{
                    forgotPassword()
                    
                }label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.green.opacity(0.25))
                        Text("Send Password Reset Email")
                            .foregroundColor(.black)
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                    }.frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.05, alignment: .center)
                }//label
                
                Text(loginStatusMessage)
                    .foregroundColor(.red)
                    .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)

                
                Spacer()
                
                Button{
                    clicked.toggle()
                    
                }label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.red.opacity(0.25))
                        Text("Close Window")
                            .foregroundColor(.black)
                            .scaledToFit()
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                    }.frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.05, alignment: .center)
                }//label
                
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.03)
                
            }//v
            
        }//z
    }
    
    private func forgotPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            //clicked = true
            if let error = error
            {
                self.loginStatusMessage = "Failed to reset password: \(error.localizedDescription)"
            }
            else
            {
                self.loginStatusMessage = "Password Reset Sent to Your Email!"
            }
        }
    }
    
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
    
}

