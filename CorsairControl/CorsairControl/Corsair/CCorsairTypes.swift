//
//  CCorsairTypes.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 25.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import Combine
import Cocoa


extension Corsair{

    
    enum CorsairError: Error{
        case failedToSetup
        case wrongDeviceNumber
        case deviceNotSet
        case noOldState
        case unableToGetData
    }

    enum LightMode {
        struct TColor: Codable{
            var color: NSColor
            var temperature: Int
            enum CodingKeys: String, CodingKey {
                case color = "color"
                case temperature = "temperature"
            }
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                temperature = try values.decode(Int.self, forKey: .temperature)
                let colorHex = try values.decode(String.self, forKey: .temperature)
                color = NSColor(hex: colorHex) ?? .red
            }
            
            func encode(to encoder: Encoder) throws {
                var values = encoder.container(keyedBy: CodingKeys.self)
                try values.encode(temperature, forKey: .temperature)
                let colorHex = color.toHex
                try values.encode(colorHex, forKey: .color)
            }
            
            init(color:NSColor, temperature:Int) {
                self.color = color
                self.temperature = temperature
            }
        }
        
        
        case blink(channel:Int, colors: [NSColor])
        case pulse(channel:Int, colors: [NSColor])
        case shift(channel:Int, colors: [NSColor])
        case rainbow(channel:Int, colors: [NSColor])
        case temperature(channel:Int, colorTemperature:[TColor])
        case staticColor(channel:Int, color: NSColor)
        
        var generate:String{
            var cmd = "--device=0 --led channel="
            switch self {
            case .blink(let channel, let colors):
                cmd.append("\(channel),mode=1,colors=\(colors.compactMap{$0}.toHex)")
            case .staticColor(let channel, let color):
                cmd.append("\(channel),mode=0,colors=\(color.toHex)")
            case .pulse(let channel, let colors):
                cmd.append("\(channel),mode=2,colors=\(colors.compactMap{$0}.toHex)")
            case .shift(let channel, let colors):
                cmd.append("\(channel),mode=3,colors=\(colors.compactMap{$0}.toHex)")
            case .rainbow(let channel, let colors):
                cmd.append("\(channel),mode=4,colors=\(colors.compactMap{$0}.toHex)")
            case .temperature(let channel, let ct):
                cmd.append("\(channel),mode=5,colors=\(ct.compactMap{$0.color}.toHex),temps=\(ct.compactMap{$0.temperature}.toList)")
            }
            return cmd
        }
        
        
        
        static func getOptions() -> [String]{
            return ["Static", "Blink", "Pulse", "Shift", "Rainbow", "Temperature dependend"]
        }
        
    }
    
   
    enum FanMode{
        struct TRpm: Codable {
            var temperature: Int
            var rpm: Int
        }
        
        case fixedPWM(channel:Int, pwm: Int)
        case fixedRPM(channel:Int, rpm: Int)
        case vendorDefault(channel:Int)
        case quiet(channel:Int)
        case balanced(channel:Int)
        case performance(channel:Int)
        case customCurve(channel:Int, tRpms: [TRpm])
        
        var generate:String{
            var cmd = "--device=0 --fan channel="
            switch self {
            case .fixedPWM(let channel, let pwm):
                cmd.append("\(channel),mode=0,pwm=\(pwm)")
            case .fixedRPM(let channel, let rpm):
                cmd.append("\(channel),mode=0,rpm=\(rpm)")
            case .vendorDefault(let channel):
                cmd.append("\(channel),mode=2")
            case .quiet(let channel):
                cmd.append("\(channel),mode=3")
            case .balanced(let channel):
                cmd.append("\(channel),mode=4")
            case .performance(let channel):
                cmd.append("\(channel),mode=5")
            case .customCurve(let channel, let tRpms):
                cmd.append("\(channel),mode=6,temps=\(tRpms.compactMap{$0.temperature}.toList),speeds=\(tRpms.compactMap{$0.rpm}.toList)")
            }
            return cmd
        }
        static func getOptions() -> [String]{
            return ["Quiet", "Balanced", "Performance", "Fixed RPM", "Fixed PWM", "Curve"]
        }
    }
    
    
    
    enum PumpMode{
        case quiet, performance, balanced
        
        var generate:String{
            var cmd = "--device=0 --pump mode="
            switch self {
            case .quiet:
                cmd.append("3")
            case .balanced:
                cmd.append("4")
            case .performance:
                cmd.append("5")
            }
            return cmd
        }
        
        static func getOptions() -> [String]{
            return ["Quiet", "Balanced", "Performance"]
        }
        
    }
    
}
