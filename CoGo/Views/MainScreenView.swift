//
//  RoomView.swift
//  CoGo
//
//  Created by Abigail Joseph and Sean Noh on 1/7/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MainScreenView: View {
    
    @EnvironmentObject var user: User
    @EnvironmentObject var userSettings: UserSettings
    
    @State var name = ""
    @State var owner = ""
    @State var color = ""
    @State var target: Int? = nil
    @State var id = "" 
    
   // @State var dummyRooms = [Room(roomId: "ItA1U2gEIjZCSoUgkx6l"),Room(roomId: "ItA1U2gEIjZCSoUgkx6l"), Room(roomId: "ItA1U2gEIjZCSoUgkx6l"), Room(roomId: "ItA1U2gEIjZCSoUgkx6l") ]
    
    @State var showingRoom = false
    @State var tappedSettings = false
    
    @State var menuOpened = false
    @State var pressed = false
    
    @State var count = 0
    @State var isOdd = false
   // let backgroundColor = Color("FFDBCD")
    
    
  //  @EnvironmentObject var room: Room
    

    init() {
       UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Avenir-Oblique", size: 30)!]
        
        if #available(iOS 13.0, *) {
                  UIWindow.appearance().overrideUserInterfaceStyle = .dark
         }
    }

    var body: some View {
        
        ZStack{
            Color(UIColor(named: "bgColor")!)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
            ScrollView{
                
               
                    
                    VStack(){
                        
                       // ZStack{
                              
                        HStack{
                            //Spacer()
                            //    .frame(width: UIScreen.screenWidth * 0.02)
                            Text("cogo")
                                .foregroundColor(Color("F97878"))
                                .font(Font.custom("Futura-Medium", size: 60))
                                .frame(alignment: .center)
                            
                        }//hstack
                        
                     
                        
                        if user.rooms.isEmpty{
                            VStack{
                               // HStack{
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill()
                                        .foregroundColor(.white.opacity(0))
                                        .frame(width: UIScreen.screenWidth * 0.40, height: UIScreen.screenHeight * 0.30)
                                //}
                                HStack{
                                    Text("Your rooms will be displayed here once you join or create a room.")
                                          .foregroundColor(.gray)
                                          .multilineTextAlignment(.center)
                                          .fixedSize(horizontal: false, vertical: true)
                                          .frame(alignment: .center)
                                }.frame(width: UIScreen.screenWidth * 0.80, alignment: .center)
                            }
                            
                        }
                            
                   
                        
                            LazyVGrid (columns: [GridItem(), GridItem()]){
                                ForEach(user.rooms) { room in
                                      
                                    RoomCard(roomCard: room, user: user).getCard()
                                    
                                }
    //                            ForEach(user.getRoom()[0..<user.getRoom().count]){ room in
    //                                let card = RoomCard(roomCard: room, user: user)
    //                                card.getCard()
    //                            } //foreach
                            }//lazyvgrid
                        
                        
                    }.frame(maxWidth: .infinity)//vstack
                    
                    
               // }//zstack
                
                
                
            }//scrollview
            
            
          /*  if pressed{
                withAnimation {
                    SideMenuView(width: UIScreen.screenWidth * 0.5, menuOpened: menuOpened, toggleMenu: toggleMenu)
                }
                
            } */
            
            
        }//zstack
        
       /* TabView{
            MainScreenView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            JoinRoomView(isClicked: $tappedSettings)
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Join Room")
                }
            CreateRoomView(isClicked: $tappedSettings)
                .tabItem {
                    Image(systemName: "person.fill.badge.plus")
                    Text("Create Room")
                }
            HomeSettingsView(isClicked: $tappedSettings)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        } */

    } //some view
    
    func toggleMenu(){
        menuOpened.toggle()
    }
    
       
} //mainscreenview struct
                 

class ChartInfo: ObservableObject {
    @Published var info: [(String, Int)]
    
    init () {
        info = []
    }
    func size() -> Int {
        return info.capacity
    }
    func setInfo (_ values: [(String, Int)]) {
        info = values
    }
}

class RoomCard {
    @ObservedObject var room: Room
    var user: User
    //@ObservedObject var chartData: ChartInfo = ChartInfo()
    @ObservedObject var chartData: ChartData = ChartData(values: [("", 0)])
    
    init (roomCard: Room, user: User)
    {
        self.room = roomCard
        self.user = user
        let userProgress = self.room.getUser(user.username)
        SavedProgress.shared.addData(username: user.username, roomId: room.id, chartData: chartData)
        //self.room.getUser(user.username, caller: "makeroomcard") { userProgress in
            self.chartData.set(values: self.room.lastWeek(history: userProgress.history))
        //}
    }
    
    public func getCard() -> some View {
        //return RoomCardView(roomCard: room).environmentObject(chartData)
        return RoomCardView(roomCard: room, chartData: self.chartData)
    }
}


struct RoomCardView: View {

      @ObservedObject var roomCard: Room
      @EnvironmentObject var user: User
      //@EnvironmentObject var chartData: ChartInfo
    //@EnvironmentObject var chartData: ChartData
    @StateObject var chartData: ChartData
    
    
      @State private var userDailyCount = 0
      @State private var userTotalCount = 0
      @State private var userStreak = 0
    
     // @State private var tapped = false
     // @State var userProgress: UserProgress
     
     //@ObservedObject var model = RoomModel()
     @State var rectangleWidth = UIScreen.screenWidth * 0.40
     @State var rectangleHeight = UIScreen.screenHeight * 0.20
    //@State var isLoading   = false
    
    @State private var tapped: Bool = false
     
     var body: some View{
         
         if UIScreen.nativeScreenHeight <= 1334{ //for iphones 8 and below
             
             Button (action: {
                 
                 if (chartData.size() > 0)
                 {
                     print(roomCard.name)
                     
                     withoutAnimation {
                         tapped.toggle()
                     }
                     
                 }
                 
             }, label: {
                 
                   // Spacer()
                 HStack{
                     Spacer().frame(width: UIScreen.screenWidth * 0.05)
                     ZStack{
                         RoundedRectangle(cornerRadius: 20)
                             .fill()
                             .foregroundColor(Color(roomCard.color))
                             .frame(width: UIScreen.screenWidth * 0.43, height: UIScreen.screenHeight * 0.23)
                         
                         VStack(spacing: 5){
                             //Spacer()
                             
                             HStack{
                                  Text(roomCard.name)
                                     .foregroundColor(roomCard.contrastColor)
                                      .font(Font.custom("Futura-Medium", size: 30))
                                      .scaledToFit()
                                      .minimumScaleFactor(0.1)
                                      .lineLimit(1)
                                     
                             }.frame(width:UIScreen.screenWidth * 0.40, height: rectangleHeight * 0.17)//.border(Color.red)//h
                             
                            // Spacer()
                             
                             ZStack{
                                 Circle()
                                      .fill(roomCard.contrastColor)
                                      //.border(Color.pink)
                                     .frame(width: rectangleWidth * 0.65, height: rectangleHeight * 0.65)
                                
                                  
                                  HStack{
                                      Text("\(roomCard.getUser(user.username).dailyCount)/\(roomCard.target)")
                                          .foregroundColor(Color(roomCard.color))
                                          .font(Font.custom("Futura-Medium", size: 40))
                                           .scaledToFit()
                                           .minimumScaleFactor(0.01)
                                           .lineLimit(1)
                                       
                                  }.frame(width: rectangleWidth * 0.50)//.border(Color.blue)
                             }//.frame(width: rectangleWidth * 0.60, height:  rectangleHeight * 0.60, alignment: .center).border(Color.purple)//z
                             
                            // Spacer()
                             
                             if containsThreeDigit() {
                                 
                                 HStack{
                                     Image(systemName: "star.fill")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(.system(size: 13))
                                         .imageScale(.medium)
                                         //.scaledToFit()
                                         
                                        // .font(Font.custom("Futura-Medium", size: 40))
                                        //  .scaledToFit()
                                        //  .minimumScaleFactor(0.01)
                                        //  .lineLimit(1)
                                     Text(roomCard.groupCompletion > 99 ? "99+": "\(roomCard.groupCompletion)")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                              .scaledToFit()
                                              //.minimumScaleFactor(0.5)
                                              .lineLimit(1)
                                        // .foregroundColor(roomCard.contrastColor)
                                         //.font(Font.custom("Futura-Medium", size: 15))
                                         //.scaledToFit()
                                     
                                     Spacer()
                                     
                                     Image(systemName: "checkmark.circle")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(.system(size: 13))
                                         .imageScale(.medium)
                                         //.scaledToFit()
                                     /*
                                         .font(Font.custom("Futura-Medium", size: 40))
                                          .scaledToFit()
                                          .minimumScaleFactor(0.01)
                                          .lineLimit(1)*/
                                     Text(roomCard.getUser(user.username).totalCount > 99 ? "99+" : "\(roomCard.getUser(user.username).totalCount)")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                              //.scaledToFit()
                                              //.minimumScaleFactor(0.5)
                                              .lineLimit(1)
                                       //  .foregroundColor(roomCard.contrastColor)
                                       //  .font(Font.custom("Futura-Medium", size: 15))
                                       //  .scaledToFit()
                                     
                                     Spacer()
                                     
                                     Image(systemName: "flame.fill")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(.system(size: 13))
                                         .imageScale(.medium)
                                         //.scaledToFit()
                                         /*.font(Font.custom("Futura-Medium", size: 40))
                                          .scaledToFit()
                                          .minimumScaleFactor(0.01)
                                          .lineLimit(1) */
                                     Text(roomCard.getUser(user.username).streak > 99 ? "99+" : "\(roomCard.getUser(user.username).streak)")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                              //.scaledToFit()
                                              //.minimumScaleFactor(0.5)
                                              .lineLimit(1)
                                       //  .scaledToFit()
                                       //  .font(Font.custom("Futura-Medium", size: 15))
                                      //   .foregroundColor(roomCard.contrastColor)
                                     
                                 }
                                 .frame(width: UIScreen.screenWidth * 0.43 * 0.9, height: rectangleHeight * 0.15)
                                //.border(Color.blue)//h
                                 
                             }//if
                             else{
                                 
                                 HStack{
                                     
                                     Image(systemName: "star.fill")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(.system(size: numOfTwoDigits() <= 1 ? 14 : 12))
                                         .imageScale(.medium)
                                         //.scaledToFit()
                                         
                                        // .font(Font.custom("Futura-Medium", size: 40))
                                        //  .scaledToFit()
                                        //  .minimumScaleFactor(0.01)
                                        //  .lineLimit(1)
                                     Text(roomCard.groupCompletion > 99 ? "99+": "\(roomCard.groupCompletion)")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 14 : 12))
                                              .scaledToFit()
                                              //.minimumScaleFactor(0.5)
                                              .lineLimit(1)
                                        // .foregroundColor(roomCard.contrastColor)
                                         //.font(Font.custom("Futura-Medium", size: 15))
                                         //.scaledToFit()
                                     
                                     Spacer()
                                     
                                     Image(systemName: "checkmark.circle")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(.system(size: numOfTwoDigits() <= 1 ? 14 : 12))
                                         .imageScale(.medium)
                                         //.scaledToFit()
                                     /*
                                         .font(Font.custom("Futura-Medium", size: 40))
                                          .scaledToFit()
                                          .minimumScaleFactor(0.01)
                                          .lineLimit(1)*/
                                     Text(roomCard.getUser(user.username).totalCount > 99 ? "99+" : "\(roomCard.getUser(user.username).totalCount)")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 14 : 12))
                                              //.scaledToFit()
                                              //.minimumScaleFactor(0.5)
                                              .lineLimit(1)
                                       //  .foregroundColor(roomCard.contrastColor)
                                       //  .font(Font.custom("Futura-Medium", size: 15))
                                       //  .scaledToFit()
                                     
                                     Spacer()
                                     
                                     Image(systemName: "flame.fill")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(.system(size: numOfTwoDigits() <= 1 ? 14 : 12))
                                         .imageScale(.medium)
                                         //.scaledToFit()
                                         /*.font(Font.custom("Futura-Medium", size: 40))
                                          .scaledToFit()
                                          .minimumScaleFactor(0.01)
                                          .lineLimit(1) */
                                     Text(roomCard.getUser(user.username).streak > 99 ? "99+" : "\(roomCard.getUser(user.username).streak)")
                                         .foregroundColor(roomCard.contrastColor)
                                         .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 14 : 12))
                                              //.scaledToFit()
                                              //.minimumScaleFactor(0.5)
                                              .lineLimit(1)
                                       //  .scaledToFit()
                                       //  .font(Font.custom("Futura-Medium", size: 15))
                                      //   .foregroundColor(roomCard.contrastColor)
                                     
                                 }
                                 .frame(width: UIScreen.screenWidth * 0.43 * 0.9, height: rectangleHeight * 0.15)
                                //.border(Color.blue)//h
                                 
                             }//else
                             
                             
                           // Spacer()
                         
                         }.frame(width: UIScreen.screenWidth * 0.43, height: UIScreen.screenHeight * 0.23)//.border(Color.green)//v
                        
                         
                     }.frame(width: UIScreen.screenWidth * 0.43, height: UIScreen.screenHeight * 0.23)//.border(Color.yellow)//z
                     
                     Spacer().frame(width: UIScreen.screenWidth * 0.05, height: UIScreen.screenHeight * 0.035)
                     
                     
                 }.frame(minWidth: UIScreen.screenWidth * 0.5, minHeight: rectangleHeight + UIScreen.screenHeight * 0.035)//.border(Color.blue)//h
                      
                 
                 
             }).fullScreenCover(isPresented: $tapped) {
                 //RoomScreenView(room: roomCard, isTapped: $tapped).environmentObject(chartData)
                 
                 RoomScreenView(room: roomCard, tappedArrow: $tapped, chartData: chartData)
                     //.statusBarStyle(.darkContent, ignoreDarkMode: true)
                   //  .onAppear{startFakeNetowrkingCall()}
             }
             
         }//if
         else{ //for iphones above 8
             
             if UIScreen.nativeScreenHeight == 1920{ //iphone 8+
                 
                 Button (action: {
                     
                     if (chartData.size() > 0)
                     {
                         print(roomCard.name)
                         
                         withoutAnimation {
                             tapped.toggle()
                         }
                         
                     }
                     
                 }, label: {
                     
                       // Spacer()
                     HStack{
                         Spacer().frame(width: UIScreen.screenWidth * 0.05)
                         ZStack{
                             RoundedRectangle(cornerRadius: 25)
                                 .fill()
                                 .foregroundColor(Color(roomCard.color))
                                 .frame(width: rectangleWidth, height: UIScreen.screenHeight * 0.3)
                             
                             VStack(spacing: 2.5){
                                 //Spacer()
                                 
                                 HStack{
                                      Text(roomCard.name)
                                         .foregroundColor(roomCard.contrastColor)
                                          .font(Font.custom("Futura-Medium", size: 30))
                                          .scaledToFit()
                                          .minimumScaleFactor(0.1)
                                          .lineLimit(1)
                                         
                                 }.frame(width: rectangleWidth * 0.85, height: UIScreen.screenHeight * 0.3 * 0.15)//.border(Color.red)
                                 
                                // Spacer()
                                 
                                 ZStack{
                                     Circle()
                                          .fill(roomCard.contrastColor)
                                          //.border(Color.pink)
                                         //.frame(width: rectangleWidth * 0.60, height: rectangleHeight * 0.60)
                                    
                                      
                                      HStack{
                                          Text("\(roomCard.getUser(user.username).dailyCount)/\(roomCard.target)")
                                              .foregroundColor(Color(roomCard.color))
                                              .font(Font.custom("Futura-Medium", size: 40))
                                               .scaledToFit()
                                               .minimumScaleFactor(0.5)
                                               .lineLimit(1)
                                           
                                      }.frame(width: rectangleWidth * 0.55, height:  UIScreen.screenHeight * 0.3 * 0.60, alignment: .center)//.border(Color.blue)
                                 }.frame(width: rectangleWidth * 0.60, height:  UIScreen.screenHeight * 0.3 * 0.60, alignment: .center)//.border(Color.purple)
                                 
                                // Spacer()
                                 
                                 if containsThreeDigit(){
                                     
                                     HStack{
                                         Image(systemName: "star.fill")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                             
                                            // .font(Font.custom("Futura-Medium", size: 40))
                                            //  .scaledToFit()
                                            //  .minimumScaleFactor(0.01)
                                            //  .lineLimit(1)
                                         Text(roomCard.groupCompletion > 99 ? "99+": "\(roomCard.groupCompletion)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                                  .scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                            // .foregroundColor(roomCard.contrastColor)
                                             //.font(Font.custom("Futura-Medium", size: 15))
                                             //.scaledToFit()
                                         
                                         Spacer()
                                         
                                         Image(systemName: "checkmark.circle")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                         /*
                                             .font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1)*/
                                         Text(roomCard.getUser(user.username).totalCount > 99 ? "99+" : "\(roomCard.getUser(user.username).totalCount)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                                  //.scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                           //  .foregroundColor(roomCard.contrastColor)
                                           //  .font(Font.custom("Futura-Medium", size: 15))
                                           //  .scaledToFit()
                                         
                                         Spacer()
                                         
                                         Image(systemName: "flame.fill")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                             /*.font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1) */
                                         Text(roomCard.getUser(user.username).streak > 99 ? "99+" : "\(roomCard.getUser(user.username).streak)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                                  //.scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                           //  .scaledToFit()
                                           //  .font(Font.custom("Futura-Medium", size: 15))
                                          //   .foregroundColor(roomCard.contrastColor)
                                         
                                     }
                                     .frame(width: rectangleWidth * 0.9, height: UIScreen.screenHeight * 0.3 * 0.15)
                                         //.border(Color.blue)
                                     
                                 }//if
                                 else{
                                     
                                     HStack{
                                         Image(systemName: "star.fill")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: numOfTwoDigits() <= 1 ? 15 : 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                             
                                            // .font(Font.custom("Futura-Medium", size: 40))
                                            //  .scaledToFit()
                                            //  .minimumScaleFactor(0.01)
                                            //  .lineLimit(1)
                                         Text(roomCard.groupCompletion > 99 ? "99+": "\(roomCard.groupCompletion)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 15 : 14))
                                                  .scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                            // .foregroundColor(roomCard.contrastColor)
                                             //.font(Font.custom("Futura-Medium", size: 15))
                                             //.scaledToFit()
                                         
                                         Spacer()
                                         
                                         Image(systemName: "checkmark.circle")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: numOfTwoDigits() <= 1 ? 15 : 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                         /*
                                             .font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1)*/
                                         Text(roomCard.getUser(user.username).totalCount > 99 ? "99+" : "\(roomCard.getUser(user.username).totalCount)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 15 : 14))
                                                  //.scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                           //  .foregroundColor(roomCard.contrastColor)
                                           //  .font(Font.custom("Futura-Medium", size: 15))
                                           //  .scaledToFit()
                                         
                                         Spacer()
                                         
                                         Image(systemName: "flame.fill")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: numOfTwoDigits() <= 1 ? 15 : 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                             /*.font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1) */
                                         Text(roomCard.getUser(user.username).streak > 99 ? "99+" : "\(roomCard.getUser(user.username).streak)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 15 : 14))
                                                  //.scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                           //  .scaledToFit()
                                           //  .font(Font.custom("Futura-Medium", size: 15))
                                          //   .foregroundColor(roomCard.contrastColor)
                                         
                                     }
                                     .frame(width: rectangleWidth * 0.9, height: UIScreen.screenHeight * 0.3 * 0.15)
                                         //.border(Color.blue)
                                     
                                 }//else
                                 
                                // Spacer()
                             
                             }.frame(width: rectangleWidth, height: UIScreen.screenHeight * 0.3)//.border(Color.green)
                            
                             
                         }.frame(width: rectangleWidth, height: UIScreen.screenHeight * 0.3)//.border(Color.yellow)//z
                         
                         Spacer().frame(width: UIScreen.screenWidth * 0.05, height: UIScreen.screenHeight * 0.035)
                         
                         
                     }.frame(minWidth: UIScreen.screenWidth * 0.5, minHeight: UIScreen.screenHeight * 0.3 + UIScreen.screenHeight * 0.035)//.border(Color.blue)//h
                          
                     
                     
                 }).fullScreenCover(isPresented: $tapped) {
                     //RoomScreenView(room: roomCard, isTapped: $tapped).environmentObject(chartData)
                     
                     RoomScreenView(room: roomCard, tappedArrow: $tapped, chartData: chartData)
                         //.statusBarStyle(.darkContent, ignoreDarkMode: true)
                       //  .onAppear{startFakeNetowrkingCall()}
                 }
                 
             }
             else{ //iphones above 8+
                 
                 Button (action: {
                     
                     if (chartData.size() > 0)
                     {
                         print(roomCard.name)
                         
                         withoutAnimation {
                             tapped.toggle()
                         }
                         
                     }
                     
                 }, label: {
                     
                       // Spacer()
                     HStack{
                         Spacer().frame(width: UIScreen.screenWidth * 0.05)
                         ZStack{
                             RoundedRectangle(cornerRadius: 25)
                                 .fill()
                                 .foregroundColor(Color(roomCard.color))
                                 .frame(width: rectangleWidth, height: rectangleHeight)
                             
                             VStack(spacing: 2.5){
                                 //Spacer()
                                 
                                 HStack{
                                      Text(roomCard.name)
                                         .foregroundColor(roomCard.contrastColor)
                                          .font(Font.custom("Futura-Medium", size: 30))
                                          .scaledToFit()
                                          .minimumScaleFactor(0.1)
                                          .lineLimit(1)
                                         
                                 }.frame(width: rectangleWidth * 0.85, height: rectangleHeight * 0.15)//.border(Color.red)
                                 
                                 //Spacer()
                                 
                                 ZStack{
                                     Circle()
                                          .fill(roomCard.contrastColor)
                                          //.border(Color.pink)
                                          .frame(width: UIScreen.screenWidth * 0.40 * 0.60, height:  UIScreen.screenHeight * 0.20 * 0.60, alignment: .center)//.border(Color.purple)
                                    
                                      
                                      HStack{
                                          Text("\(roomCard.getUser(user.username).dailyCount)/\(roomCard.target)")
                                              .foregroundColor(Color(roomCard.color))
                                              .font(Font.custom("Futura-Medium", size: 40))
                                               .scaledToFit()
                                               .minimumScaleFactor(0.5)
                                               .lineLimit(1)
                                           
                                      }.frame(width: UIScreen.screenWidth * 0.40 * 0.55, alignment: .center)//.border(Color.blue)
                                 }
                                 
                                 //Spacer()
                                 
                                 if containsThreeDigit(){
                                     
                                     HStack{
                                         Image(systemName: "star.fill")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                             
                                            // .font(Font.custom("Futura-Medium", size: 40))
                                            //  .scaledToFit()
                                            //  .minimumScaleFactor(0.01)
                                            //  .lineLimit(1)
                                         Text(roomCard.groupCompletion > 99 ? "99+": "\(roomCard.groupCompletion)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                                  .scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                            // .foregroundColor(roomCard.contrastColor)
                                             //.font(Font.custom("Futura-Medium", size: 15))
                                             //.scaledToFit()
                                         
                                         Spacer()
                                         
                                         Image(systemName: "checkmark.circle")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                         /*
                                             .font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1)*/
                                         Text(roomCard.getUser(user.username).totalCount > 99 ? "99+" : "\(roomCard.getUser(user.username).totalCount)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                                  //.scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                           //  .foregroundColor(roomCard.contrastColor)
                                           //  .font(Font.custom("Futura-Medium", size: 15))
                                           //  .scaledToFit()
                                         
                                         Spacer()
                                         
                                         Image(systemName: "flame.fill")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                             /*.font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1) */
                                         Text(roomCard.getUser(user.username).streak > 99 ? "99+" : "\(roomCard.getUser(user.username).streak)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfThreeDigits() == 3 ? 8 : 10))
                                                  //.scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                           //  .scaledToFit()
                                           //  .font(Font.custom("Futura-Medium", size: 15))
                                          //   .foregroundColor(roomCard.contrastColor)
                                         
                                     }
                                     .frame(width: rectangleWidth * 0.9, height: rectangleHeight * 0.15)
                                         //.border(Color.blue)
                                     
                                 }//if
                                 else{
                                     
                                     HStack{
                                         Image(systemName: "star.fill")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: numOfTwoDigits() <= 1 ? 15 : 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                             
                                            // .font(Font.custom("Futura-Medium", size: 40))
                                            //  .scaledToFit()
                                            //  .minimumScaleFactor(0.01)
                                            //  .lineLimit(1)
                                         Text(roomCard.groupCompletion > 99 ? "99+": "\(roomCard.groupCompletion)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 15 : 14))
                                                  .scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                            // .foregroundColor(roomCard.contrastColor)
                                             //.font(Font.custom("Futura-Medium", size: 15))
                                             //.scaledToFit()
                                         
                                         Spacer()
                                         
                                         Image(systemName: "checkmark.circle")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: numOfTwoDigits() <= 1 ? 15 : 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                         /*
                                             .font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1)*/
                                         Text(roomCard.getUser(user.username).totalCount > 99 ? "99+" : "\(roomCard.getUser(user.username).totalCount)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 15 : 14))
                                                  //.scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                           //  .foregroundColor(roomCard.contrastColor)
                                           //  .font(Font.custom("Futura-Medium", size: 15))
                                           //  .scaledToFit()
                                         
                                         Spacer()
                                         
                                         Image(systemName: "flame.fill")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(.system(size: numOfTwoDigits() <= 1 ? 15 : 13))
                                             .imageScale(.medium)
                                             //.scaledToFit()
                                             /*.font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1) */
                                         Text(roomCard.getUser(user.username).streak > 99 ? "99+" : "\(roomCard.getUser(user.username).streak)")
                                             .foregroundColor(roomCard.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: numOfTwoDigits() <= 1 ? 15 : 14))
                                                  //.scaledToFit()
                                                  //.minimumScaleFactor(0.5)
                                                  .lineLimit(1)
                                           //  .scaledToFit()
                                           //  .font(Font.custom("Futura-Medium", size: 15))
                                          //   .foregroundColor(roomCard.contrastColor)
                                         
                                     }
                                     .frame(width: rectangleWidth * 0.9, height: rectangleHeight * 0.15)
                                         //.border(Color.blue)
                                     
                                 }//else
                                 
                                 //Spacer()
                             
                             }.frame(width: rectangleWidth, height: rectangleHeight)//.border(Color.green)//v
                            
                             
                         }.frame(width: rectangleWidth, height: rectangleHeight)//.border(Color.yellow)//z
                         
                         Spacer().frame(width: UIScreen.screenWidth * 0.05, height: UIScreen.screenHeight * 0.035)
                         
                         
                     }.frame(minWidth: UIScreen.screenWidth * 0.5, minHeight: rectangleHeight + UIScreen.screenHeight * 0.035)//.border(Color.blue)//h
                          
                     
                     
                 }).fullScreenCover(isPresented: $tapped) {
                     //RoomScreenView(room: roomCard, isTapped: $tapped).environmentObject(chartData)
                     
                     RoomScreenView(room: roomCard, tappedArrow: $tapped, chartData: chartData)
                         //.statusBarStyle(.darkContent, ignoreDarkMode: true)
                       //  .onAppear{startFakeNetowrkingCall()}
                 }
                 
             }
            
             
         }//else
         
         
     }
    
    private func scaledText(_ content: String) -> some View  {
            Text(content)
                .font(Font.custom("Futura-Medium", size: 20))
                .minimumScaleFactor(0.01)
                .lineLimit(1)
    }
    
    func countNumbers(n: Int)->Int{
       var count = 0
       var num = n
       if (num == 0){
          return 1
       }
       while (num > 0){
          num = num / 10
         count += 1
       }
       return count
    }

    func containsThreeDigit()-> Bool{
        
        var threeDigit = false
        
        if roomCard.groupCompletion > 99 || roomCard.getUser(user.username).totalCount > 99{
            threeDigit = true
        }
        if roomCard.getUser(user.username).streak > 99{
            threeDigit = true
        }
        
        return threeDigit
    }
    
    func numOfThreeDigits() -> Int{
        var count = 0
        
        if countNumbers(n: roomCard.groupCompletion) >= 3 {
            count += 1
        }
        if countNumbers(n: roomCard.getUser(user.username).totalCount) >= 3 {
            count += 1
        }
        if countNumbers(n: roomCard.getUser(user.username).streak) >= 3 {
            count += 1
        }
        
        return count
    }
    
    func numOfTwoDigits() -> Int{
        var count = 0
        
        if countNumbers(n: roomCard.groupCompletion) == 2 {
            count += 1
        }
        if countNumbers(n: roomCard.getUser(user.username).totalCount) == 2 {
            count += 1
        }
        if countNumbers(n: roomCard.getUser(user.username).streak) == 2 {
            count += 1
        }
        
        return count
    }
    
//    func getUserDailyCount() -> Int{
//        // var userProgress: UserProgress
//        roomCard.getUser(user.username, caller: "getuserdisplaystats") { (user) in
//            userDailyCount = user.dailyCount
//         }
//         return userDailyCount
//     }
//
//    func getUserTotalCount() -> Int{
//
//        roomCard.getUser(user.username, caller: "getuserdisplaystats") { (user) in
//          userTotalCount = user.totalCount
//       }
//       return userTotalCount
//    }
//    func getUserStreak() -> Int{
//
//        roomCard.getUser(user.username, caller: "getuserdisplaystats") { (user) in
//          userStreak = user.streak
//       }
//       return userStreak
//   }

    

}

struct FrameAdjustingContainer<Content: View>: View {
    @Binding var frameWidth: CGFloat
    @Binding var frameHeight: CGFloat
    let content: () -> Content
    
    var body: some View  {
        ZStack {
            content()
                .frame(width: frameWidth, height: frameHeight)
                .border(Color.red, width: 1)
            
            VStack {
                Spacer()
                Slider(value: $frameWidth, in: 50...300)
                Slider(value: $frameHeight, in: 50...600)
            }
            .padding()
        }
    }
}

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
         //.environment(\.colorScheme, .dark)
       //RoomScreenView(openRoom: null)
    }
}



