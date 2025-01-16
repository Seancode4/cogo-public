//
//  RoomScreenView.swift
//  CoGo
//
//  Created by Sean Noh and Abigail Joseph on 2/16/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
//import SwiftUICharts

struct RoomScreenView: View{
    @ObservedObject var room: Room
    @EnvironmentObject var user: User
    
    @ObservedObject var sharedProgress = SavedProgress.shared
    @Binding var tappedArrow: Bool
    
    @State var tappedSettings = false
    //@State var userProgress: UserProgress
    //@State private var tapped = false
    
    //@EnvironmentObject var chartData: ChartData
    @ObservedObject var chartData: ChartData
    @State var starStat = false
    @State var checkmarkStat = false
    @State var flameStat = false
    @State private var isCrown = false
    
    @State var canIncrement = true
    
   /* init() {
       UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Avenir-Oblique", size: 30)!]
        
        if #available(iOS 13.0, *) {
                  UIWindow.appearance().overrideUserInterfaceStyle = .dark
         }
    } */
    var body: some View{
            ZStack{
                Color(!room.lightMode ? UIColor(named: "bgColor")! : UIColor(named: "darkBg")!)
                    .ignoresSafeArea()
                    .preferredColorScheme(.light)
                   // .statusBarStyle(.darkContent, ignoreDarkMode: true)
                
                ScrollView{
                    
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: UIScreen.screenHeight * 0.03)
                        HStack{
                            Spacer()
                                .frame(width: UIScreen.screenWidth * 0.03)
                            Button (action: {
                                
                                withoutAnimation {
                                    tappedArrow = false
                                    SavedProgress.shared.currentRoom = nil
                                }
                                
                            }, label: {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(Color("F97878"))
                                    .font(Font.title.weight(.semibold))
                            })
                            
                            Spacer()
                            
                            Button (action: {
                                tappedSettings.toggle()
                            }, label: {
                                Image(systemName: "gearshape")
                                    .foregroundColor(Color("F97878"))
                                    .font(Font.title.weight(.semibold))
                            }).fullScreenCover(isPresented: $tappedSettings){
                                RoomSettingsView(room: room, isClicked: $tappedSettings, inRoom: $tappedArrow).environmentObject(user)
                            }
                            
                            Spacer()
                                .frame(width: UIScreen.screenWidth * 0.03)
                        }
                        Spacer()
                          .frame(height: UIScreen.screenHeight * 0.02)
                       
                       
                        if sharedProgress.getUser(username: user.username, roomId: room.id).completedToday{
                            
                    
                            Image(systemName: "crown")
                                .foregroundColor(Color(room.color))
                                .font(.system(size: 30))
                                
                                
                            
                            Spacer()
                              .frame(height: UIScreen.screenHeight * 0.02)
                            
                            
                        }else{
                            Image(systemName: "person.3")
                                .foregroundColor(Color(room.color))
                                .font(.system(size: 30))
                            
                            Spacer()
                              .frame(height: UIScreen.screenHeight * 0.02)
                        }
                                     
                            //room title
                            ZStack{
                                RoundedRectangle(cornerRadius: 35)
                                    .fill()
                                    .foregroundColor(room.lightMode ? Color(room.color) : room.contrastColor)
                                    .shadow(color: Color(UIColor(named: "grey")!), radius: 3, x: 0, y: 5)
                                    .frame(width: UIScreen.screenWidth * 0.70, height: UIScreen.screenHeight * 0.07)
                               
                                Text("\(room.name)")
                                    .foregroundColor(room.lightMode ? room.contrastColor : Color(room.color))
                                    .font(Font.custom("Futura-Medium", size: 30))
                                     .scaledToFit()
                                     .minimumScaleFactor(0.01)
                                     .lineLimit(1)
                                     .frame(width: UIScreen.screenWidth * 0.55)
                                 
                            }.frame(width: UIScreen.screenWidth * 0.60, height: UIScreen.screenHeight * 0.07)
                           
                        Spacer()
                               .frame(height: UIScreen.screenHeight * 0.03)
                            
                            //daily total
                        HStack(){
                                Spacer()
                                //decrement circle
                                Button {
                                    //decrement code
                                    if canIncrement
                                    {
                                        withAnimation {
                                            room.increment(username: user.username, value: -1, chartData: chartData)
                                        }
                                        canIncrement = false
                                        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: false) { timer in
                                            canIncrement = true
                                        }
                                    }
                                    
    //
                                } label: {
                                    ZStack{
                                        Circle()
                                            .fill()
                                            .foregroundColor(Color(room.color))
                                            .frame(width: UIScreen.screenWidth * 0.08, height: UIScreen.screenHeight * 0.08)
                                        Image(systemName: "minus")
                                            .foregroundColor(room.contrastColor)
                                    }
                                }
                
                                Spacer()
                                //daily count
                                ZStack{
                                    Circle()
                                        .fill()
                                        .foregroundColor(Color(room.color))
                                        .frame(width: UIScreen.screenWidth * 0.30, height: UIScreen.screenHeight * 0.15)
                                    VStack{
                                        Text("\(sharedProgress.getUser(username: user.username, roomId: room.id).dailyCount)/\(room.target)")
                                             .foregroundColor(room.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: 40))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1)
                                              .frame(width: UIScreen.screenWidth * 0.30 * 0.75)
                                              //.border(Color.blue)
                                            // .frame(width: 90, height: 90, alignment: .center)
                                        Text("today")
                                             .foregroundColor(room.contrastColor)
                                             .font(Font.custom("Futura-Medium", size: 15))
                                              .scaledToFit()
                                              .minimumScaleFactor(0.01)
                                              .lineLimit(1)
                                              //.border(Color.purple)
                                        
                                    }.frame(width: UIScreen.screenWidth * 0.30, height: UIScreen.screenHeight * 0.15, alignment: .center)//.border(Color.green)
                                } //zstack
                                Spacer()
                                
                                //increment circle
                                Button {
                                    
                                    if canIncrement
                                    {
                                        withAnimation {
                                            room.increment(username: user.username, value: 1, chartData: chartData)

                                        }
                                        canIncrement = false
                                        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: false) { timer in
                                            canIncrement = true
                                        }
                                    }
                                    
                                    
                                } label: {
                                    ZStack{
                                        Circle()
                                            .fill()
                                            .foregroundColor(Color(room.color))
                                            .frame(width: UIScreen.screenWidth * 0.08, height: UIScreen.screenHeight * 0.08)
                                        Image(systemName: "plus")
                                            .foregroundColor(room.contrastColor)
                                    }
                                }//end of button
                                Spacer()
                            }//hstack
                        
                        Spacer()
                           .frame(height: UIScreen.screenHeight * 0.03)
                        Group{
                            
                        //stats
                        ZStack{
                            HStack{
                                Spacer()
                                    //.frame(width: UIScreen.screenWidth * 0.15)
                                //star
                                Button{
                                    withAnimation {
                                        starStat.toggle()
                                    }
                                    
                                } label: {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(Color(room.color))
                                        .scaledToFit()
                                        .minimumScaleFactor(0.01)
                                        .lineLimit(1)
                                }
                                Text("\(room.groupCompletion)")
                                    .foregroundColor(Color(room.color))
                                    .font(Font.custom("Futura-Medium", size: 15))
                                     .scaledToFit()
                                     .minimumScaleFactor(0.01)
                                     .lineLimit(1)
                                Spacer()
                                
                                //checkmark
                                Button{
                                    withAnimation {
                                        checkmarkStat.toggle()
                                    }
                                    
                                } label: {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(Color(room.color))
                                        .font(.system(size: 22))
                                        
                                }
                                Text("\(sharedProgress.getUser(username: user.username, roomId: room.id).totalCount)")
                                    .foregroundColor(Color(room.color))
                                    .font(Font.custom("Futura-Medium", size: 15))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                Spacer()
                                
                                //flame
                                Button{
                                    withAnimation {
                                        flameStat.toggle()
                                    }
                                    
                                } label: {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Color(room.color))
                                        .font(.system(size: 22))
                                        
                                }
                                Text("\(sharedProgress.getUser(username: user.username, roomId: room.id).streak)")
                                    .foregroundColor(Color(room.color))
                                    .font(Font.custom("Futura-Medium", size: 15))
                                    .scaledToFit()
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                
                                Spacer()
                               //     .frame(width: UIScreen.screenWidth * 0.15)
                                
                            }//.border(Color.yellow)//hstack
                            
                            if starStat{
                                StatInfoView(message: "total number of group completions throughout history", statImage: "star.fill", show: $starStat)
                            }
                            if checkmarkStat{
                                StatInfoView(message: "your total number of completions throughout history", statImage: "checkmark.circle", show: $checkmarkStat)
                            }
                            if flameStat{
                                StatInfoView(message: "your streak of successfully completed days", statImage: "flame.fill", show: $flameStat)
                            }
                        }.edgesIgnoringSafeArea(.all)//z
                        
                        Spacer()
                            .frame(height: UIScreen.screenHeight * 0.03)
                        
                        
                        //leaderboard: show user rank based on streak
                           /* if crown(){
                                LeaderBoardView(room: room, hasCrown: true)
                            }else{
                                LeaderBoardView(room: room, hasCrown: false)
                            } */
                            
                            LeaderBoardView(room: room)
                            
                                    
                        //history:
                            //HistoryView(room: room).environmentObject(chartData)
                            HistoryView(room: room, chartData: chartData)
                        }//group
                        
                    }.frame(maxWidth: .infinity) //vstack
                    
                }//scrollview
                
            }.onAppear {
                SavedProgress.shared.currentRoom = self
            }//zstack
    }//some view
    func delete() {
        tappedSettings = false
        SavedProgress.shared.currentRoom = nil
        tappedArrow = false
    }
//     func getUserDailyCount() -> Int{
//       // var userProgress: UserProgress
//         room.getUser(user.username, caller: "getuserdisplaystats") { (user) in
//           userDailyCount = user.dailyCount
//        }
//        return userDailyCount
//    }
//
//    func getUserTotalCount() -> Int{
//
//        room.getUser(user.username, caller: "getuserdisplaystats") { (user) in
//          userTotalCount = user.totalCount
//       }
//       return userTotalCount
//   }
//
//    func getUserStreak() -> Int{
//
//        room.getUser(user.username, caller: "getuserdisplaystats") { (user) in
//          userStreak = user.streak
//       }
//       return userStreak
////
////   }
//
//    func crown() -> Bool{
//        if getUserDailyCount() >= room.target{
//            return true
//        }
//        else{
//            return false
//        }
//
//    }
    
    
    
    
}//roomscreenview

struct LeaderBoardView: View{
    
    //@State var tempLeaderboard: [UserProgress] = []
    @ObservedObject var room: Room
    @State var nUsers: Int = 0
   // @State var hasCrown: Bool
    
    
    var body: some View{
        
        ZStack{
            
            RoundedRectangle(cornerRadius: 25)//increase in size as members increase
                .frame(width: UIScreen.screenWidth * 0.7, height: UIScreen.screenHeight * 0.08 * CGFloat(room.ordered.count /*leaderboard().count*/ + 1))
                .foregroundColor(Color(room.color))
                .shadow(color: Color(UIColor(named: "grey")!), radius: 3, x: 0, y: 5)
            
            

            VStack{
                Spacer()
                    .frame(height: 20)
                
                ForEach(room.ordered/*leaderboard()*/, id: \.self) { users in
                    LeaderboardRankView(user: users, room: room)
                     Spacer()
                        .frame(height: UIScreen.screenHeight * 0.02)
                    
                }//foreach
            }//vstack
            
            
           
        }.onTapGesture {
            print(room.ordered.first?.username)
        } //zstack
    }//someview
    
    
    /*func leaderboard() -> Array<UserProgress>{
      room.getLeaderboard() { users in
          tempLeaderboard = users
      }
        return tempLeaderboard.sorted(by: { $0.streak > $1.streak })
        
   }*/
    

    
  
    
}//leaderboardView

struct LeaderboardRankView: View {
    @ObservedObject var user: UserProgress
    @ObservedObject var room: Room
    @State var userDailyCount = 0
    //@Binding var hasCrown: Bool
    
    
    var body: some View{
        
            ZStack{
                RoundedRectangle(cornerRadius: 35)
                    .fill()
                    .foregroundColor(room.contrastColor)
                    //.opacity(0.75)
                    .frame(width: UIScreen.screenWidth * 0.60, height: UIScreen.screenHeight * 0.07, alignment: .top)
                HStack{
                    ZStack{
                        
                        Circle()
                            .fill()
                            .foregroundColor(Color(user.color))
                            .frame(width: UIScreen.screenWidth * 0.60 * 0.15, height: UIScreen.screenHeight * 0.75 * 0.70)
                        
                        if user.completedToday {
                            Image(systemName: "crown")
                                .foregroundColor(crownColor())
                               //.font(.system(size: 30))
                            
                        }
                        
                    }
                   
                    
                   Text(user.username)
                        .foregroundColor(Color(room.color))
                        .font(Font.custom("Futura-Medium", size: 18))
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                    
                    
                   Spacer()
                    
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color(room.color))
                        .font(.system(size: 22))
                    Text("\(user.streak)")
                        .font(Font.custom("Futura-Medium", size: 14))
                        .foregroundColor(Color(room.color))
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                    Spacer()
                        .frame(width: 5)
                }.frame(width: UIScreen.screenWidth * 0.55, height: UIScreen.screenHeight * 0.07)
            }
    }
        
    private func crownColor () -> Color
    {
        let red = Color(user.color)?.cgColor?.components?[0] ?? 1
        let green = Color(user.color)?.cgColor?.components?[1] ?? 1
        let blue = Color(user.color)?.cgColor?.components?[2] ?? 1
        if (red + green + blue > 2)
        {
             return .black
           
        }
        else
        {
            return .white
        }
        
        
    }
}//leaderboardRankView

struct HistoryView: View{
    
    @ObservedObject var room: Room
    @EnvironmentObject var user: User
    //@EnvironmentObject var chartData: ChartData
    @ObservedObject var chartData: ChartData
    // @State var roomColor: String
    //@State var userHistory: Dictionary<String, Int> = [:]
    
    var body: some View{
        
        VStack{
            Spacer()
                .frame(height: 20)
          /*  ZStack{
                 RoundedRectangle(cornerRadius: 25)//increase in size as members increase
                    .frame(width: UIScreen.screenWidth * 0.70, height: UIScreen.screenHeight * 0.30)
                     .foregroundColor(Color(room.color))
                     .shadow(color: .gray, radius: 3, x: 0, y: 5)
              */

            BarChartView(data: chartData/*ChartData(values: chartData.info)*/, title: "History", style: ChartStyle(backgroundColor: Color(room.color), accentColor: room.contrastColor/*.opacity(0.75)*/, secondGradientColor: room.contrastColor/*.opacity(0.75)*/, textColor: room.contrastColor, legendTextColor: Color.black, dropShadowColor: Color(UIColor(named: "grey")!)), form: ChartForm.extraLarge, backgroundHex: room.color, room: room)
                
            // }zstack
            Spacer()
                .frame(height: 20)
       }
        
        
 }//some view
    
    
//    func getUserHistory() -> Dictionary<String, Int> {
//        var userHistory: Dictionary<String, Int> = [:]
//      room.getUser(user.username) { (user) in
//        userHistory = user.history
//       }
//
//        print("History: ")
//        userHistory.forEach { day in
//           print(day)
//        }
//
//        print("historyyyy: \(userHistory)")
//       return userHistory
//   }

}//history view


struct StatInfoView: View{
    
    @State var message: String
    @State var statImage: String
    @Binding var show: Bool
    
    var body: some View{
        
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)){
            VStack(){
                HStack{
                    Text("Symbol:")
                        .font(.system(size: 28, weight: .bold))
                    Image(systemName: statImage)
                        .font(.system(size: 22))
                    //Text(")")
                   //   .font(.system(size: 28, weight: .bold))
                    
                    Spacer()
                  
                }.frame(alignment: .leading)
                
                Spacer().frame(height: UIScreen.screenHeight * 0.02)
   
                HStack{
                    Text("represents: ")
                        //.font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                        .frame(alignment: .leading)
                    
                    Spacer()
                }
                
                HStack{
                    Text(message)
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                        
                    
                    
                    Spacer()
                }
                
                
                
     
                
            } .padding(.vertical, 25)
             .padding(.horizontal, 30)
            
            Button{
                withAnimation {
                    show.toggle()
                }
            }label: {
               Image(systemName: "xmark.circle")
                   // .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
            }.padding()
            
        }.frame(maxWidth: UIScreen.screenWidth * 0.75, maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: Color(UIColor(named: "grey")!), radius: 3, x: 0, y: 5)
        
    }//some view
    
    
}//statinfo view



