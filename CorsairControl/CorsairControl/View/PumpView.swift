//
//  PumpView.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 27.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import SwiftUI

struct PumpView: View {
    @EnvironmentObject var corsair: Corsair
    
    var body: some View {
        GroupBox(label:BoxHeader(header: "Pump", image: "pump")){
            HStack{
                HStack{
                    Spacer()
                    ListView(options: Corsair.PumpMode.getOptions(), selectedOption: $corsair.selectedPumpMode, title: "Mode")
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 10)
    }
}
