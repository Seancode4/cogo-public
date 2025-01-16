//
//  BarChartRow.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/1/22.
//

import Foundation
import SwiftUI

public struct BarChartRow : View {
    @ObservedObject var chartData: ChartData
    var data: [Double]
    var accentColor: Color
    var gradient: GradientColor?
  
    
    
    init (chartData: ChartData, accentColor: Color, gradient: GradientColor?, touchLocation: Binding<CGFloat>) {
        self.chartData = chartData
        self.data = chartData.points.map{$0.1}
        self.accentColor = accentColor
        self.gradient = gradient
        self._touchLocation = touchLocation
        
    }
    
    var maxValue: Double {
        guard let max = data.max() else {
            return 1
        }
        return max != 0 ? max : 1
    }
    @Binding var touchLocation: CGFloat
    public var body: some View {
        GeometryReader { geometry in
            /*
            Rectangle()
                .fill(.white)
                .frame( width: 2)
                .edgesIgnoringSafeArea(.vertical) */
            HStack{
                Spacer()
                
                HStack(alignment: .bottom, spacing: (geometry.frame(in: .local).width-22)/CGFloat(self.data.count * 3)){
                    
                Spacer()
                   /* Text("Completions")
                        .rotationEffect(.degrees(-90))
                    
                        Divider()
                            .font(.system(size: 40))
                            .background(Color.white) */
                    
                    ForEach(0..<self.data.count, id: \.self) { i in
                        BarChartCell(/*chartData: chartData,*/ value: self.normalizedValue(index: i),
                                     index: i,
                                     width: Float(geometry.frame(in: .local).width - 22),
                                     numberOfDataPoints: self.data.count,
                                     accentColor: self.accentColor,
                                                               gradient: self.gradient, touchLocation: self.$touchLocation)
                            .scaleEffect(self.touchLocation > CGFloat(i)/CGFloat(self.data.count) && self.touchLocation < CGFloat(i+1)/CGFloat(self.data.count) ? CGSize(width: 1.4, height: 1.1) : CGSize(width: 1, height: 1), anchor: .bottom)
                            .animation(.spring())
                        
                        
                    }
                    
                    Spacer()
                }
                .frame(width: UIScreen.screenWidth * 0.6, height: 80, alignment: .center)
                .padding([.top, .leading, .trailing], 10)
               // .frame(width: 180, height: 90, alignment: .center)
                
                
                Spacer()
            }.frame(width: UIScreen.screenWidth * 0.7)//.border(Color.red)
            
            
            
        }
    }
    
    func normalizedValue(index: Int) -> Double {
        return Double(self.chartData.points.map{$0.1}[index])/Double(self.maxValue)
    }
}

//#if DEBUG
//struct ChartRow_Previews : PreviewProvider {
//    static var previews: some View {
//        Group {
//            BarChartRow(data: [0], accentColor: Colors.OrangeStart, touchLocation: .constant(-1))
//            BarChartRow(data: [8,23,54,32,12,37,7], accentColor: Colors.OrangeStart, touchLocation: .constant(-1))
//        }
//    }
//}
//#endif
