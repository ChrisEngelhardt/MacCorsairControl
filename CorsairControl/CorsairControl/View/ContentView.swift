//
//  ContentView.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 23.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import SwiftUI
import Combine
struct ContentView: View {
    @EnvironmentObject var corsair:Corsair
    @ObservedObject var presented:Timeout = Timeout(timeToWait: 1)
    
    private var subscriptions = Set<AnyCancellable>()
    var body: some View {
        ZStack{
            AcknowledgeNotification(presented: $presented.visible)
            VStack(alignment: .center, spacing: 30) {
                InfoView().padding(.top, 20)
                FanView()
                PumpView()
                LEDView()
                    .padding(.bottom, 20)
                //BottomBar()
            }
            .onReceive(corsair.acknowledge) { _ in
                self.presented.visible = true
            }
            .foregroundColor(.primary)
            .frame(minWidth: 460, alignment: .center)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Corsair(refreshInterval: 2, debug: true))
    }
}
