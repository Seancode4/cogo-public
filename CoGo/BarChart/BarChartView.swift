//
//  barCharView.swift
//  CoGo
//
//  Created by Abigail Joseph on 5/1/22.
//

import SwiftUI

public struct BarChartView : View {
    @ObservedObject var room: Room
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject private var data: ChartData
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var formSize:CGSize
    public var dropShadow: Bool
    //public var cornerImage: Image?
    public var valueSpecifier:String
    public var animatedToBack: Bool
    public var backgroundColor: Color
    
    @State private var touchLocation: CGFloat = -1.0
    @State private var showValue: Bool = false
    @State private var showLabelValue: Bool = false  
    @State private var currentValue: Double = 0 {
        didSet{
            if(oldValue != self.currentValue && self.showValue) {
                HapticFeedback.playSelection()
            }
        }
    }
    var isFullWidth:Bool {
        return self.formSize == ChartForm.large
    }
     init(data:ChartData, title: String, legend: String? = nil, style: ChartStyle = Styles.barChartStyleOrangeLight, form: CGSize? = ChartForm.medium, dropShadow: Bool? = true, /*cornerImage:Image? = Image(systemName: "waveform.path.ecg"),*/ valueSpecifier: String? = "%.0f", animatedToBack: Bool = false, backgroundHex: String, room: Room){
        self.data = data
        self.title = title
        self.legend = legend
        self.style = style
        self.darkModeStyle = style //style.darkModeStyle != nil ? style.darkModeStyle! : Styles.barChartStyleOrangeDark
        self.formSize = form!
        self.dropShadow = dropShadow!
        //self.cornerImage = cornerImage
        self.valueSpecifier = valueSpecifier!
        self.animatedToBack = animatedToBack
        self.backgroundColor = Color(hex: backgroundHex)
        self.room = room
    }
    
    public var body: some View {
        ZStack{
            Rectangle()
                .fill(backgroundColor)
                //.fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                .cornerRadius(20)
               // .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)
                .shadow(color: self.style.dropShadowColor, radius: 3, x: 0, y: 5)
            VStack(alignment: .leading){
                HStack(alignment: .center){
                    if(!showValue){
                        Text(self.title)
                            .font(.headline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }else{
                        
                        Text("Daily Count: \(self.currentValue, specifier: self.valueSpecifier)")
                            .font(.headline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    if(self.formSize == ChartForm.large && self.legend != nil && !showValue) {
                        Text(self.legend!)
                            .font(.callout)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor)
                            .transition(.opacity)
                            .animation(.easeOut)
                    }
                    Spacer()
                   /* self.cornerImage
                        .imageScale(.large)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor) */
                }.padding()
            
                BarChartRow(/*data: data.points.map{$0.1},*/
                    chartData: self.data,
                            accentColor: self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor,
                            gradient: self.colorScheme == .dark ? self.darkModeStyle.gradientColor : self.style.gradientColor,
                    touchLocation: self.$touchLocation)
                if self.legend != nil  && self.formSize == ChartForm.medium && !self.showLabelValue{
                    Text(self.legend!)
                        .font(.headline)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                        .padding()
                }else if (self.data.valuesGiven && self.getCurrentValue() != nil) {
                   // Divider()
                     //   .frame(width: UIScreen.screenWidth * 0.3, alignment: .center)
                       // .font(.system(size: 40))
                        //.background(Color.white)
                   /* Rectangle()
                        .fill(.white)
                        .frame( height: 5)
                        .edgesIgnoringSafeArea(.horizontal) */
                    //Spacer()
                      //  .frame(height: UIScreen.screenHeight * 0.03)
                    LabelView(arrowOffset: self.getArrowOffset(touchLocation: self.touchLocation),
                              title: .constant(self.getCurrentValue()!.0), room: room)
                        .offset(x: self.getLabelViewOffset(touchLocation: self.touchLocation), y: -6)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                }
                
            }
        }.frame(minWidth:self.formSize.width,
                maxWidth: self.isFullWidth ? .infinity : self.formSize.width,
                minHeight:self.formSize.height,
                maxHeight:self.formSize.height)
            .gesture(DragGesture()
                .onChanged({ value in
                    self.touchLocation = value.location.x/self.formSize.width
                    self.showValue = true
                    self.currentValue = self.getCurrentValue()?.1 ?? 0
                    if(self.data.valuesGiven && self.formSize == ChartForm.medium) {
                        self.showLabelValue = true
                    }
                    //print("current value \(currentValue)")
                })
                .onEnded({ value in
                    if animatedToBack {
                        self.touchLocation = value.location.x/self.formSize.width
                        self.showValue = true
                        self.currentValue = self.getCurrentValue()?.1 ?? 0
                        if(self.data.valuesGiven && self.formSize == ChartForm.medium) {
                            self.showLabelValue = true
                        }
                        
                        /* ORIGINAL
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(Animation.easeOut(duration: 1)) {
                                self.showValue = false
                                self.showLabelValue = false
                                self.touchLocation = -1
                            }
                        } */
                    } else {
                        self.touchLocation = value.location.x/self.formSize.width
                        self.showValue = true
                        self.currentValue = self.getCurrentValue()?.1 ?? 0
                        if(self.data.valuesGiven && self.formSize == ChartForm.medium) {
                            self.showLabelValue = true
                        }
                        
                        /* ORIGNIAL
                        self.showValue = false
                        self.showLabelValue = false
                        self.touchLocation = -1
                         
                         */
                    }
                })
        )
            .gesture(TapGesture()
        )
    }
    
    func getArrowOffset(touchLocation:CGFloat) -> Binding<CGFloat> {
        let realLoc = (self.touchLocation * self.formSize.width) - 50
        if realLoc < 10 {
            return .constant(realLoc - 10)
        }else if realLoc > self.formSize.width-110 {
            return .constant((self.formSize.width-110 - realLoc) * -1)
        } else {
            return .constant(0)
        }
    }
    
    func getLabelViewOffset(touchLocation:CGFloat) -> CGFloat {
        return min(self.formSize.width-110,max(10,(self.touchLocation * self.formSize.width) - 50))
    }
    
    func getCurrentValue() -> (String,Double)? {
        guard self.data.points.count > 0 else { return nil}
        let index = max(0,min(self.data.points.count-1,Int(floor((self.touchLocation*self.formSize.width)/(self.formSize.width/CGFloat(self.data.points.count))))))
        return self.data.points[index]
    }
}

#if DEBUG
/*struct ChartView_Previews : PreviewProvider {
    static var previews: some View {
        BarChartView(data: TestData.values ,
                     title: "Model 3 sales",
                     legend: "Quarterly",
                     valueSpecifier: "%.0f", backgroundHex: "000000")
    }
} */
#endif
