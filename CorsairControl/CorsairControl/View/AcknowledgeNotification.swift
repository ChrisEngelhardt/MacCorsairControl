//
//  AcknowledgeNotification.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 02.11.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import SwiftUI


struct AcknowledgeNotification: View{
    @Binding var presented: Bool
    var body: some View{
        HStack{
            if(presented){
                Image("success")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width:20, height:20)
                    .animation(.interactiveSpring())
                    .transition(.offset(x: 50, y: 0))
                    .position(x: 440, y: 20)
            }
        }
        
    }
}
