//
//  InfoView.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 27.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import SwiftUI

struct BoxHeader: View{
    @State var header:String
    @State var image:String
    
    var body: some View{
        HStack{
//            Image(image)
//                .resizable()
//                .aspectRatio(1, contentMode: .fit)
//                .frame(width:32,height:32)
//                .padding(.trailing)
            Text(header)
                .font(.headline)
        }
    }
}

struct InfoView: View{
    @EnvironmentObject var corsair: Corsair
    var body: some View{
        GroupBox(label: BoxHeader(header: "System Information", image: "info")){
            VStack (alignment: .center){
                HStack(alignment: .center){
                    Text(corsair.vendor)
                        .font(.title)
                    Text(corsair.device)
                        .font(.title)
                }.padding(.top)
                Spacer()
                HStack(alignment: .center){
                    Text("Temperature: \(corsair.temperature.reduce("", { (s, t) in s + String(t)}))")
                        .font(.subheadline)
                    Spacer()
                    Text("Firmware: \(corsair.firmware)")
                        .font(.subheadline)
                }.padding()
            }
        }
        .padding(.horizontal, 10)
    }
}
