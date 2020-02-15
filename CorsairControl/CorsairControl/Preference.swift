//
//  Preference.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 01.11.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//
import Foundation
import Cocoa

let Preferences = UserDefaults.standard

class Defaults {
    fileprivate init() {}
}

class DefaultsKey<ValueType>: Defaults {
    let key: String
    
    init(_ key: String) {
        self.key = key
    }
}

extension UserDefaults {
    subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return bool(forKey: key.key) }
        set { set(newValue, forKey: key.key) }
    }
    subscript(key: DefaultsKey<Int>) -> Int {
        get { return integer(forKey: key.key) }
        set { set(newValue, forKey: key.key) }
    }
    subscript(key: DefaultsKey<Float>) -> Float {
        get { return float(forKey: key.key) }
        set { set(newValue, forKey: key.key) }
    }
    subscript(key: DefaultsKey<NSColor>) -> NSColor {
        get { return color(forKey: key.key)  ?? .red}
        set { set(newValue, forKey: key.key) }
    }
    subscript(key: DefaultsKey<[NSColor]>) -> [NSColor] {
        get { return colors(forKey: key.key)  ?? [.red, .green, .yellow, .orange, .magenta, .blue, .cyan]}
        set { set(newValue, forKey: key.key) }
      }
}
