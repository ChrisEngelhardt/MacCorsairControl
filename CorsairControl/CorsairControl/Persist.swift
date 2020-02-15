//
//  UserDefault.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 01.11.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation

//At the moment unused :/
@propertyWrapper
struct Persist<Value: Codable> {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get {
            return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
