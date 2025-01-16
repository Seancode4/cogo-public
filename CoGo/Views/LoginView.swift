//
//  LoginView.swift
//  CoGo
//
//  Created by Sean Noh and Abigail Joseph on 1/8/22.
//

import SwiftUI
import Firebase
import FirebaseAuth   //ran without this line
import FirebaseStorage //ran without this line
//additional package we need to import when using authentication ^
//and also storage




//IF NO IMAGE IS SELECTED, DOES NOT SAVE TO DATABASE





/*
class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    override init () {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
 
        super.init()
    }
}
 
 if using that, replace Auth.auth() with FirebaseManager.shared.auth
 
 if using that, replace Storage.storage() with FirebaseManager.shared.storage
 */



struct LoginView: View {
    
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var user: User
    @State var isLoginMode = false
    @State var clicked = false
    @State var email = ""
    @State var password = ""
    @State var username = ""
    //@State var color = Color.white
    @State var roomColor = Color(hex: "F97878")//Color.white
    @State var forgotPswd = false
    @State var cpTapped = false
        
    @State var shouldShowImagePicker = false
    @State var loginStatusMessage = " "
            
    var body: some View {
        
        ZStack{
            Color(UIColor(named: "bgColor")!)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
            
            //ScrollView{
                 
                VStack(){
                    
                    if !isLoginMode{
                        Spacer()
                            .frame(height: UIScreen.nativeScreenHeight > 1334 ? UIScreen.screenHeight * 0.08 : UIScreen.screenHeight * 0.04)
                    }
                    
                    
                                
                    VStack{//v1
                        
                        
                        ZStack{
                            Circle()
                                .foregroundColor(Color("F97878"))
                                
                            HStack{
                                
                                Text("cogo")
                                    .foregroundColor(.white)
                                    .font(Font.custom("Futura-Medium", size: 60))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                
                                
                            }.frame(width: UIScreen.screenWidth * 0.30, height: UIScreen.screenHeight * 0.2, alignment: .center)//h
                            
                        }.frame(width: UIScreen.screenWidth * 0.35, height: UIScreen.screenHeight * 0.2, alignment: .center)//z
                        
                        Spacer()
                        
                        if !isLoginMode{
                            
                            HStack{
                                ColorPicker("Choose Your Color:", selection: $roomColor, supportsOpacity: false)
                                    .foregroundColor(.gray)
                                   /* .onTapGesture {
                                        cpTapped = true
                                    }.onChange(of: roomColor) { _ in
                                        cpTapped = false
                                    } */
                            }.frame(width: UIScreen.screenWidth * 0.65, alignment: .center)
                            Spacer()
                        }
                        
                    }.frame(width: UIScreen.screenWidth, height: isLoginMode ? UIScreen.screenHeight * 0.20 : UIScreen.screenHeight * 0.24)//.border(Color.red)//v1
                   
                   // ZStack{//z1.5
                   
                    if UIScreen.nativeScreenHeight >= 2532{//if1
                        VStack{ //v2
                            //Spacer()
                             
                             TextField("Email", text: $email)
                                 .textFieldStyle(MyTextFieldStyle())
                                 .keyboardType(.emailAddress)
                                 .accentColor(Color(hex: "F97878"))
                                 .autocapitalization(.none)
                                 .disableAutocorrection(true)
                                 .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                        
                            if !isLoginMode{
                                Spacer()
                                
                                TextField("Username", text: $username)
                                    .textFieldStyle(MyTextFieldStyle())
                                    .accentColor(Color(hex: "F97878"))
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                            }
                            Spacer()
                             
                             SecureField("Password", text: $password)
                                 .textFieldStyle(MyTextFieldStyle())
                                 .accentColor(Color(hex: "F97878"))
                                 .autocapitalization(.none)
                                 .disableAutocorrection(true)
                                 .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                            
                        
                       // Spacer()
                        }.frame(width: UIScreen.screenWidth, height: isLoginMode ? UIScreen.screenHeight * 0.16 : UIScreen.screenHeight * 0.27)
                            .contentShape(Rectangle())
                            .clipShape(Rectangle())
                            .onTapGesture {
                                   dismissKeyboard()
                            }//v2
                       
                        Text(clicked ? "\(loginStatusMessage)" : " ")
                            .foregroundColor(Color.red)
                            .font(.system(size: 14))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                         
                       VStack{ //v3
                            Group{
                                
                               // Spacer()
                                
                                Button{
                                    handleAction()
                                    
                                    withAnimation {
                                        clicked = true
                                    }
                                    
                                } label: {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(.green.opacity(0.25))
                                        Text(isLoginMode ? "Log In"
                                             : "Create Account")
                                            .foregroundColor(.black)
                                    }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                }
                                
                                Spacer()
                                
                                Button{
                                    print("native bounds height: \(UIScreen.nativeScreenHeight)")
                                    
                                    if isLoginMode{
                                        loginStatusMessage = " "
                                        clicked = false
                                        isLoginMode = false
                                    }else{
                                        loginStatusMessage = " "
                                        clicked = false
                                        isLoginMode = true
                                    }
                                   
                                    
                                } label: {
                                    ZStack{
                                       // RoundedRectangle(cornerRadius: 20)
                                           // .foregroundColor(.green.opacity(0.25))
                                        Text(!isLoginMode ? "Log In"
                                             : "Create Account")
                                            .foregroundColor(.black)
                                    }//.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                }
                                
                               // Spacer()
                                
                                if isLoginMode{
                                    Spacer()
                                    Button{
                                        //forgotPassword()
                                        forgotPswd.toggle()
                                    } label: {
                                        ZStack{
                                           // RoundedRectangle(cornerRadius: 20)
                                               // .foregroundColor(.green.opacity(0.25))
                                            Text("Forgot Password")
                                                .foregroundColor(.black)
                                        }//.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                    }.fullScreenCover(isPresented: $forgotPswd){
                                        ForgotPasswordView(clicked: $forgotPswd)
                                    }
                                }
                                
                                
                            }//group
                        }.frame(width: UIScreen.screenWidth, height: isLoginMode ? UIScreen.screenHeight * 0.16 : UIScreen.screenHeight * 0.10)
                            //.border(Color.blue)
                            .contentShape(Rectangle())
                            .clipShape(Rectangle())
                            .onTapGesture {
                                   dismissKeyboard()
                            }//v3
                            
                        
                        if !isLoginMode{
                            Spacer()
                               
                        }
                    }//if1
                    
                    if UIScreen.nativeScreenHeight < 2532 && UIScreen.nativeScreenHeight > 1334{//if2
                        
                        VStack{ //v2
                            //Spacer()
                             
                             TextField("Email", text: $email)
                                 .textFieldStyle(MyTextFieldStyle())
                                 .keyboardType(.emailAddress)
                                 .accentColor(Color(hex: "F97878"))
                                 .autocapitalization(.none)
                                 .disableAutocorrection(true)
                                 .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                        
                            if !isLoginMode{
                                Spacer()
                                
                                TextField("Username", text: $username)
                                    .textFieldStyle(MyTextFieldStyle())
                                    .accentColor(Color(hex: "F97878"))
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                            }
                            Spacer()
                             
                             SecureField("Password", text: $password)
                                 .textFieldStyle(MyTextFieldStyle())
                                 .accentColor(Color(hex: "F97878"))
                                 .autocapitalization(.none)
                                 .disableAutocorrection(true)
                                 .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                             
                           
                            
                        
                       // Spacer()
                        }.frame(width: UIScreen.screenWidth, height: isLoginMode ? UIScreen.screenHeight * 0.20 : UIScreen.screenHeight * 0.30)
                            .contentShape(Rectangle())
                            .clipShape(Rectangle())
                            .onTapGesture {
                                   dismissKeyboard()
                            }//v2
                        
                        
                        Text(clicked ? "\(loginStatusMessage)" : " \(" ")")
                            .foregroundColor(Color.red)
                            .font(.system(size: 14))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                         
                       VStack{ //v3
                            Group{
                                
                               // Spacer()
                                
                                Button{
                                    handleAction()
                                    
                                    withAnimation {
                                        clicked = true
                                    }
                                    
                                } label: {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(.green.opacity(0.25))
                                        Text(isLoginMode ? "Log In"
                                             : "Create Account")
                                            .foregroundColor(.black)
                                    }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                }
                                
                                Spacer()
                                
                                Button{
                                    print("native bounds height: \(UIScreen.nativeScreenHeight)")
                                    if isLoginMode{
                                        loginStatusMessage = " "
                                        clicked = false
                                        isLoginMode = false
                                    }else{
                                        loginStatusMessage = " "
                                        clicked = false
                                        isLoginMode = true
                                    }
                                   
                                    
                                } label: {
                                    ZStack{
                                       // RoundedRectangle(cornerRadius: 20)
                                           // .foregroundColor(.green.opacity(0.25))
                                        Text(!isLoginMode ? "Log In"
                                             : "Create Account")
                                            .foregroundColor(.black)
                                    }//.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                }
                                
                               // Spacer()
                                
                                if isLoginMode{
                                    Spacer()
                                    Button{
                                        //forgotPassword()
                                        forgotPswd.toggle()
                                    } label: {
                                        ZStack{
                                           // RoundedRectangle(cornerRadius: 20)
                                               // .foregroundColor(.green.opacity(0.25))
                                            Text("Forgot Password")
                                                .foregroundColor(.black)
                                        }//.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                    }.fullScreenCover(isPresented: $forgotPswd){
                                        ForgotPasswordView(clicked: $forgotPswd)
                                    }
                                }
                                
                                
                            }//group
                        }.frame(width: UIScreen.screenWidth, height: isLoginMode ? UIScreen.screenHeight * 0.16 : UIScreen.screenHeight * 0.10)
                            //.border(Color.blue)
                            .contentShape(Rectangle())
                            .clipShape(Rectangle())
                            .onTapGesture {
                                   dismissKeyboard()
                            }//v3
                            
                        
                        if !isLoginMode{
                            Spacer()
                               
                        }
                        
                    }//if2
                    
                    if UIScreen.nativeScreenHeight <= 1334{//if3
                        
                        VStack{ //v2
                            //Spacer()
                             
                             TextField("Email", text: $email)
                                 .textFieldStyle(MyTextFieldStyle())
                                 .keyboardType(.emailAddress)
                                 .accentColor(Color(hex: "F97878"))
                                 .autocapitalization(.none)
                                 .disableAutocorrection(true)
                                 .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                        
                            if !isLoginMode{
                                Spacer()
                                
                                TextField("Username", text: $username)
                                    .textFieldStyle(MyTextFieldStyle())
                                    .accentColor(Color(hex: "F97878"))
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                            }
                            Spacer()
                             
                             SecureField("Password", text: $password)
                                 .textFieldStyle(MyTextFieldStyle())
                                 .accentColor(Color(hex: "F97878"))
                                 .autocapitalization(.none)
                                 .disableAutocorrection(true)
                                 .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                             
                        
                       // Spacer()
                        }.frame(width: UIScreen.screenWidth, height: isLoginMode ? UIScreen.screenHeight * 0.25 : UIScreen.screenHeight * 0.38)
                        .contentShape(Rectangle())
                        .clipShape(Rectangle())
                        .onTapGesture {
                            dismissKeyboard()
                        }
                        //.border(Color.blue)//v2
                        
                        Text(clicked ? "\(loginStatusMessage)" : " \(" ")")
                            .foregroundColor(Color.red)
                            .font(.system(size: 14))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: UIScreen.screenWidth * 0.7, alignment: .center)
                         
                       VStack{ //v3
                            Group{
                                
                               // Spacer()
                                
                                Button{
                                    handleAction()
                                    
                                    withAnimation {
                                        clicked = true
                                    }
                                    
                                } label: {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(.green.opacity(0.25))
                                        Text(isLoginMode ? "Log In"
                                             : "Create Account")
                                            .foregroundColor(.black)
                                    }.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                }
                                
                                Spacer()
                                
                                Button{
                                    print("native bounds height: \(UIScreen.nativeScreenHeight)")
                                    if isLoginMode{
                                        loginStatusMessage = " "
                                        clicked = false
                                        isLoginMode = false
                                    }else{
                                        loginStatusMessage = " "
                                        clicked = false
                                        isLoginMode = true
                                    }
                                   
                                    
                                } label: {
                                    ZStack{
                                       // RoundedRectangle(cornerRadius: 20)
                                           // .foregroundColor(.green.opacity(0.25))
                                        Text(!isLoginMode ? "Log In"
                                             : "Create Account")
                                            .foregroundColor(.black)
                                    }//.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                }
                                
                               // Spacer()
                                
                                if isLoginMode{
                                    Spacer()
                                    Button{
                                        //forgotPassword()
                                        forgotPswd.toggle()
                                    } label: {
                                        ZStack{
                                           // RoundedRectangle(cornerRadius: 20)
                                               // .foregroundColor(.green.opacity(0.25))
                                            Text("Forgot Password")
                                                .foregroundColor(.black)
                                        }//.frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.05, alignment: .center)
                                    }.fullScreenCover(isPresented: $forgotPswd){
                                        ForgotPasswordView(clicked: $forgotPswd)
                                    }
                                }
                                
                                
                            }//group
                        }.frame(width: UIScreen.screenWidth, height: isLoginMode ? UIScreen.screenHeight * 0.20 : UIScreen.screenHeight * 0.13)
                            //.border(Color.blue)
                            .contentShape(Rectangle())
                            .clipShape(Rectangle())
                            .onTapGesture {
                                   dismissKeyboard()
                            }//v3
                            
                        
                        if !isLoginMode{
                            Spacer()
                               
                        }
                        
                    }//if3
                    
                   //  Spacer()
                     
                }.frame(maxWidth: .infinity, alignment: .center )//vstack
                
            //}//scrollview
            
            
            Circle()
                .foregroundColor(Color("006B9349")) //blue
                .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.4, alignment: .center)
                .position(x: UIScreen.screenWidth * 0.8, y: UIScreen.screenHeight * 0.85)
            
            Circle() //purple
                .foregroundColor(Color("7E34C933"))
                .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.2, alignment: .center)
                .position(x: UIScreen.screenWidth * 0.9, y: UIScreen.screenHeight * 0.7)
            
        }//zstack//.onTapGesture {
            
            //if !isLoginMode{
           //     dismissKeyboard()
            //}
    
      //  }
        
    }//some view
    
    @State var image: UIImage?
    
    /*
    private func getUser () {
        if Auth.auth().currentUser != nil {
          // User is signed in.
          // ...
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            userSettings.isLoggedIn = true
        } else {
          // No user is signed in.
          // ...
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            userSettings.isLoggedIn = false
        }

    }*/
    
    
    func updateStoredPassword(_ password: String) {
      let kcw = KeychainWrapper()
      do {
        try kcw.storeGenericPasswordFor(
            account: userSettings.storedEmail!,
          service: "unlockPassword",
          password: password)
      } catch _ as KeychainWrapperError {
        print("Exception setting password")
      } catch {
        print("An error occurred setting the password.")
      }
    }
    private func handleAction(){
        if isLoginMode{
            //log into firebase with existing credentials
            loginUser()
        }
        else{
            //register a new account inside firebase
            attemptToCreateAccount()
        }
        //getUser()
    }
    
  
    
    private func attemptToCreateAccount() {
        if (username.contains("/")) {
            loginStatusMessage = "Do not use '/'"
            return
        }
        Firestore.firestore().collection("users").whereField("username", isEqualTo: username).limit(to: 1).getDocuments(completion: { (querySnapshot, err) in
            if let err = err {
                print("Error (in attempt to create): \(err)")
                return
            }
            else {
                ReadTracker.shared.read(label: "Check if username exists")
                if querySnapshot!.isEmpty
                {
                    createNewAccount()
                }
                else
                {
                    loginStatusMessage = "Username taken"
                }
            }
        })
    }
    
    private func createNewAccount() {
        //make sure 6+ character password
        if username == "" {
            self.loginStatusMessage = "No username provided"
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "\(err.localizedDescription)"
                
                email = ""
                password = ""
                username = ""
                
                return
            }
            print ("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user"
            self.storeUserInformation()
            //self.persistImageToStorage()
            loginUser()
        }
    }
    private func forgotPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            clicked = true
            if let error = error
            {
                self.loginStatusMessage = "\(error.localizedDescription)"
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
                    //.stroke(Color.gray, lineWidth: 1)
                    
                    
            )
        }
    }
        
//    private func persistImageToStorage(){
//        //let filename = UUID().uuidString
//
//        guard let uid = Auth.auth().currentUser?.uid
//            else{ return}
//
//
//        let ref = Storage.storage().reference(withPath: uid)
//        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
//        ref.putData(imageData, metadata: nil){  metadata, err in
//            if let err = err {
//                self.loginStatusMessage = "Failed to push image to storage: \(err)"
//                return
//            }
//            ref.downloadURL{ url, err in
//                if let err = err {
//                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
//                    return
//                }
//                self.loginStatusMessage = "sucessfully stored image with url: \(url?.absoluteString ?? "")"
//
//                guard let url = url else {return}
//                self.storeUserInformation(imageProfileUrl: url)
//            }
//        }
//    }
    
    private func storeUserInformation(/*imageProfileUrl: URL*/)
    {
        guard let uid = Auth.auth().currentUser?.uid else {
            return }
        
        //password not stored in database
        //should put dummy roomid for testing purposes
        //need to link room id withroom object
        let userData = ["email": self.email, "id": uid, "username": username, "color": roomColor.toHex() ?? "000000", /*"rooms": ["room1", "room2"],*/ "lastAccessed": Date().formatted(date: .abbreviated, time: .omitted) /*"profileImageUrl": imageProfileUrl.absoluteString*/ ] as [String : Any]
        Firestore.firestore().collection("users").document(uid).setData(userData) { err in
            if let err = err {
                self.loginStatusMessage = "\(err)"
                return
            }
        }
        Firestore.firestore().collection("users").document(uid).collection("deletes").document("deleteInfo").setData(["actionNeeded": false]) { err in
            if let err = err {
                print(err.localizedDescription)
            }
        }
        
    }
    
    private func loginUser () {
        
        
        Auth.auth().signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "\(err.localizedDescription)"
                
                email = ""
                password = ""
                
                return
            }
            print ("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in"
            userSettings.logIn()
            userSettings.storeEmail(email: email)
            updateStoredPassword(password)
            user.configure()
            
        }
        
        
        
        
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
