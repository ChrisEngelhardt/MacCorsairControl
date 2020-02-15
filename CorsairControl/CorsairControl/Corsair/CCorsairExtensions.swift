//
//  CCorsairExtensions.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 25.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import Combine
import Cocoa





extension UserDefaults{
    
    private static let defaultFanMode = [
        Corsair.FanMode.TRpm(temperature: 45, rpm: 0),
        Corsair.FanMode.TRpm(temperature: 65, rpm: 800),
        Corsair.FanMode.TRpm(temperature: 75, rpm: 2500)
    ]
    private static let defaultLightMode = [
        Corsair.LightMode.TColor(color: .blue, temperature: 37),
        Corsair.LightMode.TColor(color: .yellow, temperature: 55),
        Corsair.LightMode.TColor(color: .red, temperature: 65)
    ]
    
    
    subscript(key: DefaultsKey<[Corsair.FanMode.TRpm]>) -> [Corsair.FanMode.TRpm] {
        get { return trpm(forKey: key.key) ?? UserDefaults.defaultFanMode }
        set { set(newValue, forKey: key.key) }
    }
    
    subscript(key: DefaultsKey<[Corsair.LightMode.TColor]>) -> [Corsair.LightMode.TColor] {
        get { return tColor(forKey: key.key) ?? UserDefaults.defaultLightMode }
        set { set(newValue, forKey: key.key) }
    }
}


extension UserDefaults{
    func set(_ colors: [NSColor], forKey key:String) {
        let data = colors.map { try? JSONEncoder().encode($0.toHex) }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func colors(forKey: String) -> [NSColor]? {
        guard let encodedData = UserDefaults.standard.array(forKey: forKey) as? [Data] else {
            return nil
        }
        do{
            let a:[NSColor] = try encodedData.compactMap {
                let s = try JSONDecoder().decode(String.self, from: $0)
                return NSColor(hex: s)
            }
            if a.count == 0 {
                return nil
            }
            return a
        }catch{
            return nil
        }
    }
}



extension UserDefaults{
    func set(_ trpms: [Corsair.FanMode.TRpm], forKey key:String) {
        let data = trpms.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func trpm(forKey: String) -> [Corsair.FanMode.TRpm]? {
        guard let encodedData = UserDefaults.standard.array(forKey: forKey) as? [Data] else {
            return nil
        }
        do{
            let a = try encodedData.map { try JSONDecoder().decode(Corsair.FanMode.TRpm.self, from: $0) }
            if a.count == 0 {
                return nil
            }
            return a
        }catch{
            return nil
        }
    }
}


extension UserDefaults {
    func set(_ tColors: [Corsair.LightMode.TColor], forKey key:String) {
        let data = tColors.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func tColor(forKey: String) -> [Corsair.LightMode.TColor]? {
        guard let encodedData = UserDefaults.standard.array(forKey: forKey) as? [Data] else {
            return nil
        }
        do{
            let a = try encodedData.map { try JSONDecoder().decode(Corsair.LightMode.TColor.self, from: $0) }
            if a.count == 0 {
                return nil
            }
            return a
        }catch{
            return nil
        }
    }
}


extension UserDefaults {
    func set(_ color: NSColor, forKey: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
            self.set(data, forKey: forKey)
        }
    }
    
    func color(forKey: String) -> NSColor? {
        guard
            let storedData = self.data(forKey: forKey),
            let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: storedData),
            let color = unarchivedData as NSColor?
            else {
                return nil
        }
        return color
    }
}

extension NSColor {
    var toHex: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "FFFFFF"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let hexString = NSString(format: "%02X%02X%02X", red, green, blue)
        return hexString as String
    }
    
    convenience init?(hex str:String){
       var hex = str
        if (hex.hasPrefix("#")) {
            hex.remove(at: hex.startIndex)
        }

        if ((hex.count) != 6) {
            return nil
        }

        var rgbValue:UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let redComponent = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(rgbValue & 0x0000FF) / 255.0
        let alphaComponent = CGFloat(1.0)
        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
    }
    
}

extension String{
    func toCommandLineParam() -> (argc: Int, argv:[String]){
        let argv = self.components(separatedBy: " ")
        let argc = argv.count
        return (argc, argv)
    }
}

extension Array where Array.Element == NSColor{
    var toHex: String{
        let a = self.reduce("") { (p, c) in
            p + ":" + c.toHex
        }
        return String(a.dropLast())
    }
}

extension Array where Array.Element == Int{
    var toList: String{
        let a = self.reduce("") { (p, c) in
            p + String(c) + ":"
        }
        return String(a.dropLast())
    }
}

extension Combineable where Base: UserDefaults{
    func string(forKey name:String) -> Future<String, Corsair.CorsairError>{
        return Future { seal in
            if let v = UserDefaults.standard.string(forKey: name){
                seal(.success(v))
            }else{
                seal(.failure(.noOldState))
            }
        }
    }
    
    func set(value:Float, forKey:String) -> Float{
        UserDefaults.standard.set(value, forKey: forKey)
        return value
    }
}
