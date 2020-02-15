//
//  BottomBar.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 02.11.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import SwiftUI

struct BottomBar: View {
    @ObservedObject var autostart = AutostartHelper()
    
    var body: some View {
        HStack{
            Spacer()
            Toggle(isOn: $autostart.isEnabled) {
                Text("Autostart")
            }.toggleStyle(SwitchToggleStyle()).padding()
            
        }
    }
}
