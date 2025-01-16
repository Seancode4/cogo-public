//
//  LoadingView.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/23/22.
//

import Foundation
import SwiftUI

struct LoadingView: View{
    
    @State var animate = false
    var animation: Animation {
        Animation.linear(duration: 0.7)
                .repeatForever(autoreverses: false)
    }
    
    var body: some View{
        ZStack{
            Color(UIColor(named: "bgColor")!)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
            
            //V1
           /* VStack{
                Spacer()
                HStack{
                    Text("cogo")
                        .foregroundColor(Color("F97878"))
                        .font(Font.custom("Futura-Medium", size: 60))
                        .frame(alignment: .center)
                    
                }
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color("F97878")))
                    .scaleEffect(3)
                
                Spacer()
            } */
            
            //V2
             VStack{
                 Spacer()
                 HStack{
                     Text("cogo")
                         .foregroundColor(Color("F97878"))
                         .font(Font.custom("Futura-Medium", size: 60))
                         .frame(alignment: .center)
                     
                 }
             Circle()
                 .trim(from: 0, to: 0.8)
                 .stroke(AngularGradient(gradient: .init(colors: [Color(hex: "F97878"), Color(hex: "F97878")]), center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                 .frame(width: 45, height: 45)
                 //.rotationEffect(.init(degrees: self.animate ? 360 : 0))
                 .rotationEffect(Angle(degrees: self.animate ? 360 : 0.0))
                 .animation(self.animate ? animation : .default, value: animate     )
                 //.animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
                 .onAppear {
                     self.animate.toggle()
                 }
                 
                 
                 Spacer()
             }
            
        }
        
    }
}
