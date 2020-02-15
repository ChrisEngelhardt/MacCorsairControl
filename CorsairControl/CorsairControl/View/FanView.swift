//
//  FanView.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 27.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import SwiftUI

struct FanView: View {
    @EnvironmentObject var corsair: Corsair
    
    var body: some View {
        GroupBox(label: BoxHeader(header: "Fan", image: "fan")){
            HStack{
                VStack{
                    ListView(options: Corsair.FanMode.getOptions(), selectedOption: $corsair.selectedFanMode, title: "Mode")
                    HStack{
                        Spacer()
                        if(corsair.selectedFanMode == 3){
                            Slider(value: $corsair.rpm, in: 0...3000, label: {Text("RPM:  \(Int(self.corsair.rpm))")})
                                .padding()
                        }else if (corsair.selectedFanMode == 4){
                            Slider(value: $corsair.pwm, in: 0...3000, label: {Text("PWM:  \(Int(self.corsair.pwm))")})
                                .padding()
                        }else if (corsair.selectedFanMode == 5){
                            HStack{
                                TemperatureRPMSet(a: $corsair.curve[0])
                                TemperatureRPMSet(a: $corsair.curve[1])
                                TemperatureRPMSet(a: $corsair.curve[2])
                            }
                        }
                        Spacer()
                    }
                    
                }
                Spacer()
            }
        }
        .padding(.horizontal, 10)
    }
}


struct TemperatureRPMSet: View {
    @Binding var a: Corsair.FanMode.TRpm
    var body: some View {
        VStack(alignment: .trailing){
            HStack(alignment: .center){
                Text("°C")
                TextField(String(a.temperature), value: $a.temperature, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
            }
            HStack(alignment: .center){
                Text("RPM")
                TextField(String(a.rpm), value: $a.rpm, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
            }
        }.padding()
    }
}
