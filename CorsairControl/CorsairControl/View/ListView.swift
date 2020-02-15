//
//  ListView.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 27.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import SwiftUI

struct ListView: View {
    @State var options: [String]
    @Binding var selectedOption:Int
    @State var title:String
    
    var body: some View {
        VStack {
            Picker(selection: $selectedOption, label: Text(title).font(.subheadline).padding()) {
                ForEach(0 ..< options.count) {
                    Text(self.options[$0])
                }
            }.pickerStyle(DefaultPickerStyle())
            
        }
    }
}
