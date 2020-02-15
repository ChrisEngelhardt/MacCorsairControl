//
//  AutostartHelper.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 02.11.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import LaunchAtLogin
import Combine

class AutostartHelper: ObservableObject{
    private var subscriptions = Set<AnyCancellable>()
    @Published var isEnabled  = LaunchAtLogin.isEnabled
    
    init() {
        $isEnabled
            .sink { state in
                LaunchAtLogin.isEnabled = state
        }
        .store(in: &subscriptions)
    }
}
