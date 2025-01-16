//
//  BarChartCell.swift
//  CoGo
//
//  Created by Abigail Joseph and Sean Noh on 5/1/22.
//

import Foundation
import SwiftUI

public struct BarChartCell : View {
    var value: Double
    @State var widthChanged: Bool = false
    var index: Int = 0
    var width: Float
    var numberOfDataPoints: Int
    var cellWidth: Double {
        return Double(width)/(Double(numberOfDataPoints) * 1.5)
    }
    var accentColor: Color
    var gradient: GradientColor?
    
    @State var scaleValue: Double = 0
    @Binding var touchLocation: CGFloat
    
    public var body: some View {
        VStack{
            
            
            
            ZStack {
                RoundedRectangle(cornerRadius: barCornerRadius(self.value) ? 20 : 4)
                    .fill(LinearGradient(gradient: gradient?.getGradient() ?? GradientColor(start: accentColor, end: accentColor).getGradient(), startPoint: .bottom, endPoint: .top))
                }
                .frame(width: CGFloat(self.cellWidth))
                .scaleEffect(CGSize(width: 1, height: heightWithMin(self.value)), anchor: .bottom)
                
            
            
            
            if widthChanged{
                Text("hello")
                    
            }
        }
        
        
//            .onAppear(){
//                self.scaleValue = self.value
//                if (self.scaleValue == 0)
//                {
//                    self.scaleValue = 0.05
//                }
//            }
        .animation(Animation.spring().delay(self.touchLocation < 0 ?  Double(self.index) * 0.04 : 0))
    }
    
    
    private func heightWithMin (_ value: Double) -> Double
    {
        if value == 0
        {
            return 0.05
        }
        else
        {
            return value
        }
    }
    
    private func barCornerRadius(_ value: Double) -> Bool{
        if value == 0
        {
            return true
        }
        else
        {
            return false
        }
        
    }
}

#if DEBUG
/*struct ChartCell_Previews : PreviewProvider {
    static var previews: some View {
        BarChartCell(value: Double(0.75), width: 320, numberOfDataPoints: 12, accentColor: Colors.OrangeStart, gradient: nil, touchLocation: .constant(-1))
    }
} */
#endif
