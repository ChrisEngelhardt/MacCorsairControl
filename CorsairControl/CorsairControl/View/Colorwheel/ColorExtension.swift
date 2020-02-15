//
//  ColorExtension.swift
//  ColorPicker
//
//  Created by Hendrik Ulbrich on 16.07.19.
//

import SwiftUI
import Cocoa


extension Color {
    static func fromAngle(angle: Angle) -> Color {
        return Color(hue: angle.radians / (2 * .pi), saturation: 1, brightness: 1)
    }
    
    static func fromAngle(rad: Double) -> Color {
        Color.fromAngle(angle: Angle(radians: rad))
    }

}

extension NSColor{
    static func fromAngle(angle: Angle) -> NSColor {
        return NSColor(hue: CGFloat(angle.radians / (2 * .pi)), saturation: 1, brightness: 1, alpha: 1)
     }
     
     static func fromAngle(rad: Double) -> NSColor {
         NSColor.fromAngle(angle: Angle(radians: rad))
     }
    
    
    func toAngle() -> Angle{
        return Angle(radians: Double(self.hueComponent * 2 * .pi))
    }
}

extension Gradient {
    static let colorWheelSpectrum: Gradient = Gradient(colors: [
        Color.fromAngle(rad: .pi / 2),
        Color.fromAngle(rad: .pi / 4),
        Color.fromAngle(rad: 2 * .pi),
        Color.fromAngle(rad: 7/4 * .pi),
        Color.fromAngle(rad: 3/2 * .pi),
        Color.fromAngle(rad: 5/4 * .pi),
        Color.fromAngle(rad: .pi),
        Color.fromAngle(rad: 3/4 * .pi),
        Color.fromAngle(rad: .pi / 2),
    ])
    
}
