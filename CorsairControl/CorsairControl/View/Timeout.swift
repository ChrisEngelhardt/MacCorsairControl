//
//  Timeout.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 30.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import SwiftUI
import Combine

class Timeout: ObservableObject{
    @Published var visible: Bool = false
    private var subscriptions = Set<AnyCancellable>()
    
    init(timeToWait: Double) {
        $visible
            .filter({ v -> Bool in
                v
            })
            .delay(for: .seconds(timeToWait), scheduler: DispatchQueue.main)
            .sink { _ in
                self.visible = false
            }
            .store(in: &subscriptions)
    }
}
