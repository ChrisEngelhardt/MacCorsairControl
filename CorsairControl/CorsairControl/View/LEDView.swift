//
//  LEDView.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 27.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import SwiftUI


struct LEDView: View {
    @EnvironmentObject var corsair: Corsair
    
    var body: some View {
        GroupBox(label:BoxHeader(header: "LED", image: "light")){
            HStack(alignment: .center){
                VStack(alignment: .center){
                    HStack{
                        Spacer()
                        ListView(options: Corsair.LightMode.getOptions(), selectedOption: $corsair.selectedLedMode, title: "Mode")
                        Spacer()
                    }
                    if(corsair.selectedLedMode == 0){
                        ColorPicker(color: $corsair.staticColor, strokeWidth: 10)
                        .padding(10)
                    }else if (corsair.selectedLedMode == 1){
                        NColorView(colors: $corsair.blinkColor)
                    }else if (corsair.selectedLedMode == 2){
                        NColorView(colors: $corsair.pulseColor)
                    }else if (corsair.selectedLedMode == 3){
                        NColorView(colors: $corsair.shiftColor)
                    }else if (corsair.selectedLedMode == 4){
                        NColorView(colors: $corsair.rainbowColor)
                    }else if (corsair.selectedLedMode == 5){
                        HStack{
                            Spacer()
                            ColorSelectForTemperature(tColor: $corsair.colorGardient[0])
                            Spacer()
                            ColorSelectForTemperature(tColor: $corsair.colorGardient[1])
                            Spacer()
                            ColorSelectForTemperature(tColor: $corsair.colorGardient[2])
                            Spacer()
                        }.padding(.bottom, 20)
                    }
                }
            }}
            .padding(.horizontal, 10)
            .frame(height: 250)
    }
}


struct NColorView: View{
    @Binding var colors: [NSColor]
    var body: some View{
        HStack{
            ForEach(0...colors.count-1, id:\.self){ i in
                ColorPicker(color: self.$colors[i], strokeWidth: 6)
            }
        }
    }
}

struct ColorSelectForTemperature: View {
    @Binding var tColor: Corsair.LightMode.TColor
    var body: some View {
        VStack{
            ColorPicker(color: $tColor.color, strokeWidth: 10)
            HStack(alignment: .center){
                Text("°C")
                TextField(String(tColor.temperature), value: $tColor.temperature, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
            }
            .padding(.top)
            
        }
        
    }
}
