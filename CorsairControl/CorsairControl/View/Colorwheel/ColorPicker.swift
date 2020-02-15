//
//  ColorPicker.swift
//  ColorPicker
//
//  Created by Hendrik Ulbrich on 15.07.19.
// 

import SwiftUI
import Combine

public struct ColorPicker : View {
    
    @Binding var color: NSColor
    var strokeWidth: CGFloat = 30
    
    public var body: some View {
        GeometryReader { geometry -> ColorWheel in
            
            return ColorWheel(color: self.$color, frame: geometry.frame(in: CoordinateSpace.local),  angle: self.color.toAngle(), strokeWidth: self.strokeWidth)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}



public struct ColorWheel: View {
    
    @Binding var color:NSColor
    @State var frame: CGRect
    @State private var position: CGPoint = CGPoint.zero
    @State var angle: Angle
    @State var strokeWidth: CGFloat
    
    public var body: some View {
        let conic = AngularGradient(gradient: Gradient.colorWheelSpectrum, center: .center, angle: .degrees(-90))
        let indicatorOffset = CGSize(width: cos(angle.radians) * Double(frame.midX - strokeWidth / 2), height: -sin(angle.radians) * Double(frame.midY - strokeWidth / 2))
        
        return ZStack(alignment: .center) {
            Circle()
                .strokeBorder(conic, lineWidth: strokeWidth)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged(self.update(value:))
            )
            
            Circle()
                .frame(width: strokeWidth, height: strokeWidth, alignment: .center)
                .fixedSize()
                .offset(indicatorOffset)
                .allowsHitTesting(false)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .offset(indicatorOffset)
                        .allowsHitTesting(false)
            )
        }
    }
    


    internal func update(value: DragGesture.Value) {
        self.position = value.location
        self.angle = Angle(radians: radCenterPoint(value.location, frame: self.frame))
        self.$color.wrappedValue = NSColor.fromAngle(angle: self.angle)
    }
    
    internal func radCenterPoint(_ point: CGPoint, frame: CGRect) -> Double {
        let adjustedAngle = atan2f(Float(frame.midX - point.x), Float(frame.midY - point.y)) + .pi / 2
        return Double(adjustedAngle < 0 ? adjustedAngle + .pi * 2 : adjustedAngle)
    }

}

