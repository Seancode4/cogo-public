//
//  SideMenuView.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/15/22.
//

/*
import Foundation
import SwiftUI


struct SideMenuView: View {
    
    let width: CGFloat
    let menuOpened: Bool
    let toggleMenu: () -> Void
    
    var body: some View{
        ZStack{
            //dimmed background
            GeometryReader{ _ in
                EmptyView()
            }
           .background(Color.gray.opacity(0.25))
           .opacity(self.menuOpened ? 1: 0)
           .animation(Animation.easeIn.delay(0.15))
            .onTapGesture {
                self.toggleMenu()
            }
            
            //menu content
            
            HStack{
                Spacer()
                
                MenuContent()
                    .frame(width: width)
                    .offset(x: menuOpened ? 0 : UIScreen.screenWidth)
                    .animation(.easeInOut(duration: 0.5), value: menuOpened)
                    //.transition(.move(edge: .trailing))
                
            }
            
            
        }
    }
}

struct MenuContent: View{
    
    let items: [MenuItems] = [
      //  MenuItems(text: "Home", imageName: "house.fill", tapped: 0, isClicked: false),
        MenuItems(text: "Join Room", imageName: "plus.circle", tapped: 1, isClicked: false),
        MenuItems(text: "Create Room", imageName: "person.fill.badge.plus", tapped: 2, isClicked: false),
        MenuItems(text: "Settings", imageName: "gearshape", tapped: 3, isClicked: false)
    ]
    
    @State var isTapped: Bool = false
    @State var tappedView: Int = 3
    @State var tappedSettings = false
      
    var body: some View{
        ZStack{
            Color("FFDBCD")
                    .ignoresSafeArea()
            VStack(alignment: .trailing, spacing: 0){
                ForEach(items) { item in
                    
                   Button{
                       // isTapped = item.isClicked
                       // isTapped.toggle()
                        tappedView = item.tapped
                        tappedSettings.toggle()
                       print("tapped")
                       print(item.text)
                       print("tappedView: \(tappedView)")
                      
                    }label: {
                        HStack{
                            Image(systemName: item.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color("F97878"))
                                .frame(width: 32, height: 32, alignment: .center)
                            
                            Text(item.text)
                                .bold()
                                .foregroundColor(Color("F97878"))
                                .font(.system(size: 22))
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding()
                    }.fullScreenCover(isPresented: $tappedSettings){
                      /*  if tappedView == 3{
                            HomeSettingsView(isClicked: $tappedSettings)
                        }
                        if tappedView == 2{
                            CreateRoomView(isClicked: $tappedSettings)
                        }
                        if tappedView == 1{
                            JoinRoomView(isClicked: $tappedSettings)
                        }
                        if tappedView == 0{
                            //HomeSettingsView(isClicked: $tappedSettings)
                           // MainScreenView()
                        } */
                   } 
                   
                    //Divider()
                }//.animation(.easeInOut(duration: 0.5))
                
                Spacer()
            }.padding(.top, 30)//vstack
            
            /*
            if tappedView == 0 && isTapped{
                MainScreenView()
            }
            if tappedView == 1 && isTapped{
                
            }
            if tappedView == 2 && isTapped{
                
            }
            if tappedView == 3 && isTapped{
                HomeSettingsView( isClicked: $tappedSettings)
            }*/
            
        }//zstack
    }
}//MENU CONTENT

struct MenuItems: Identifiable{
    
    var id = UUID()
    let text: String
    let imageName: String
    var tapped: Int
    var isClicked: Bool
    
}

*/
