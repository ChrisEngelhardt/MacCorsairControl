//
//  CCorsair.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 24.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Foundation
import Combine
import Cocoa
import SwiftUI

extension Defaults{
    static let pumpMode = DefaultsKey<Int>("pumpMode")
    static let fanMode = DefaultsKey<Int>("fanMode")
    static let ledMode = DefaultsKey<Int>("ledMode")
    static let rpm = DefaultsKey<Float>("rpm")
    static let pwm = DefaultsKey<Float>("pwm")
    static let staticColor = DefaultsKey<NSColor>("staticColor")
    static let pulseColor = DefaultsKey<[NSColor]>("pulseColor")
    static let shiftColor = DefaultsKey<[NSColor]>("shiftColor")
    static let blinkColor = DefaultsKey<[NSColor]>("blinkColor")
    static let rainbowColor = DefaultsKey<[NSColor]>("rainbowColor")
    static let curve = DefaultsKey<[Corsair.FanMode.TRpm]>("curve")
    static let gradient = DefaultsKey<[Corsair.LightMode.TColor]>("gradient")
}

class Corsair: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
    fileprivate var _acknowledge = PassthroughSubject<Void, Never>()
    
    var connectionState = CurrentValueSubject<Bool, Never>(false)
    lazy var acknowledge = { _acknowledge.eraseToAnyPublisher() }()
    
    // MARK: Published vars
    @Published var temperature:[Double] = []
    @Published var device:String = "Loading"
    @Published var vendor:String = "Loading"
    @Published var firmware:String = "Loading"
    @Published var selectedPumpMode: Int = Preferences[.pumpMode]
    @Published var selectedFanMode: Int = Preferences[.fanMode]
    @Published var selectedLedMode: Int = Preferences[.ledMode]
    @Published var rpm: Float = Preferences[.rpm]
    @Published var pwm: Float = Preferences[.pwm]
    @Published var staticColor: NSColor = Preferences[.staticColor]
    @Published var curve:  [Corsair.FanMode.TRpm] =  Preferences[.curve]
    @Published var colorGardient: [Corsair.LightMode.TColor] = Preferences[.gradient]
    @Published var pulseColor: [NSColor] = Preferences[.pulseColor]
    @Published var shiftColor: [NSColor] = Preferences[.shiftColor]
    @Published var blinkColor: [NSColor] = Preferences[.blinkColor]
    @Published var rainbowColor: [NSColor] = Preferences[.rainbowColor]
    
    // MARK: Inits

    init(refreshInterval:Double = 2, debug: Bool = false) {
        if(!debug){
            setupConnectionChecker(refreshInterval)
            setupConnection()
            gatherInformationsFromDevice()
            gatherVaryingData(refreshInterval)
            setupUIBindings()
        }
    }
    
    // MARK: Setup functions
    private func setupUIBindings() {
        //UI bindings for set
       
        $selectedPumpMode
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (mode) in
            Preferences[.pumpMode] = mode
            self.setPumpMode(mode)
        }
        .store(in: &subscriptions)
        
        
        $selectedLedMode
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (mode) in
                Preferences[.ledMode] = mode
                self.setLightMode(mode)
        }
        .store(in: &subscriptions)
        
        
        $selectedFanMode
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (mode) in
                Preferences[.fanMode] = mode
                self.setFanMode(mode)
        }
        .store(in: &subscriptions)
        
        
        $rpm
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (rpm) in
                Preferences[.rpm] = rpm
                _ = [0,1].map{
                    self.combine.setFanMode(mode: .fixedRPM(channel: $0, rpm: Int(rpm)))
                }
        }
        .store(in: &subscriptions)
        
        $pwm
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (pwm) in
                Preferences[.pwm] = pwm
                _ = [0,1].map{
                    self.combine.setFanMode(mode: .fixedPWM(channel: $0, pwm: Int(pwm)))
                }
        }
        .store(in: &subscriptions)
        
        $curve
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (curve) in
                Preferences[.curve] = curve
                _ = [0,1].map{
                    self.combine.setFanMode(mode: Corsair.FanMode.customCurve(channel: $0, tRpms: curve))
                }
        }
        .store(in: &subscriptions)
        
        $staticColor
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (color) in
                Preferences[.staticColor] = color
                self.combine.setLightMode(mode: .staticColor(channel: 0, color: color))
        }
        .store(in: &subscriptions)
        
        $colorGardient
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (gradient) in
                Preferences[.gradient] = gradient
                self.combine.setLightMode(mode: .temperature(channel: 0, colorTemperature: gradient))
        }
        .store(in: &subscriptions)
        
        $pulseColor
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (pulse) in
                Preferences[.pulseColor] = pulse
                self.combine.setLightMode(mode: .pulse(channel: 0, colors: pulse))
                
        }
        .store(in: &subscriptions)
        
        $rainbowColor
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (rainbowColor) in
                Preferences[.rainbowColor] = rainbowColor
                self.combine.setLightMode(mode: .rainbow(channel: 0, colors: rainbowColor))
        }
        .store(in: &subscriptions)
        
        $shiftColor
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (shiftColor) in
                Preferences[.shiftColor] = shiftColor
                self.combine.setLightMode(mode: .shift(channel: 0, colors: shiftColor))
                
        }
        .store(in: &subscriptions)
        
        $blinkColor
            .combineLatest(connectionState)
            .filter({ $0.1 })
            .map(\.0)
            .dropFirst(1)
            .sink { (blinkColor) in
                Preferences[.blinkColor] = blinkColor
                self.combine.setLightMode(mode: .blink(channel: 0, colors: blinkColor))
        }
        .store(in: &subscriptions)
    }
    

    fileprivate func setupConnectionChecker(_ refreshInterval: Double) {
    
        //Check for device
        Timer.publish(every: refreshInterval * 1.5, on:RunLoop.main, in: .default)
            .autoconnect()
            .combineLatest(connectionState)
            .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: true)
            .filter({!$0.1})
            .sink { _ in
                print("No connection")
                self.setupConnection()
        }
        .store(in: &subscriptions)
        
        //Reset config after reconnect
        connectionState
            .filter({$0})
            .sink { _ in
                self.setFanMode(self.selectedFanMode)
                self.setLightMode(self.selectedLedMode)
                self.setPumpMode(self.selectedPumpMode)
            }
            .store(in: &subscriptions)
    }
    
    
    
    func setupConnection() {
        combine.setup(corsair: CorsairApi.sharedInstance()!)
            .filter({ (api, numberOfValidDevices) -> Bool in
                numberOfValidDevices > 0
            })
            .map({ arg -> (api: CorsairApi, device: Int) in
                return (arg.api, 0)
            })
            .flatMap{self.combine.setDevice(corsair: $0.api, deviceNumber: $0.device)}
            .map({ _ in true })
            .replaceError(with: false)
            .sink(receiveValue: { self.connectionState.send($0) })
            .store(in: &subscriptions)
    }
    
    
    private func gatherVaryingData(_ refreshInterval: Double) {
        Timer.publish(every: refreshInterval, on:RunLoop.main, in: .default)
            .autoconnect()
            .prepend(Date())
            .combineLatest(connectionState)
            .map(\.0)
            .flatMap({_ in
                self.combine.getTemperature()
                    .replaceError(with: [])
            })
            .receive(on: RunLoop.main)
            .assign(to: \.temperature, on: self)
            .store(in: &subscriptions)
    }
    
    
    //Load data once (changes never)
    private func gatherInformationsFromDevice() {
        connectionState
            .filter({ $0 })
            .flatMap({_ in
                self.combine.getFirmware()
                .replaceError(with: "Unable to load")
            })
            .receive(on: RunLoop.main)
            .assign(to: \.firmware, on: self)
            .store(in: &subscriptions)
        
        connectionState
            .filter({ $0 })
            .flatMap({_ in
                self.combine.getVendorName()
                .replaceError(with: "Unable to load")
            })
            .receive(on: RunLoop.main)
            .assign(to: \.vendor, on: self)
            .store(in: &subscriptions)
        
        connectionState
            .filter({ $0 })
            .flatMap({_ in
                self.combine.getDeviceName()
                .replaceError(with: "Unable to load")
            })
            .receive(on: RunLoop.main)
            .assign(to: \.device, on: self)
            .store(in: &subscriptions)
    }
}


// MARK: Combine me :)
extension Combineable where Base: Corsair{
    
    ///Since all those getters are private we pass the corsair api trough for convenience use of comnbine
    // MARK: Getter
    
    //todo: fix error handling
    fileprivate func setup(corsair: CorsairApi = CorsairApi.sharedInstance()!) -> Future<(api: CorsairApi,numberOfValidDevices: Int), Corsair.CorsairError>{
        Future { seal in
            corsair.setup({
                seal(.success((corsair, Int(corsair.numberOfValidDevices))))
            }, failed: { (error) in
                seal(.success((corsair, -1)))
                //seal(.failure(CorsairError.failedToSetup))
            })
        }
    }
    
    
    fileprivate func setDevice(corsair: CorsairApi = CorsairApi.sharedInstance()!, deviceNumber: Int) -> Future<CorsairApi, Corsair.CorsairError>{
        Future { seal in
            corsair.setDevice(Int32(deviceNumber), success: {
                seal(.success(corsair))
            }) { error in
                seal(.failure(.wrongDeviceNumber))
            }
            
        }
    }
    
    
    fileprivate func getTemperature(corsair: CorsairApi = CorsairApi.sharedInstance()!) -> Future<[Double],Corsair.CorsairError>{
        Future{ seal in
            corsair.getDeviceTemperature({ (temperature) in
                DispatchQueue.main.async {
                    if let temps = temperature as? [Double], temps.count > 0{
                        seal(.success(temps))
                        return
                    }
                    self.base.connectionState.send(false)
                    seal(.failure(Corsair.CorsairError.unableToGetData))
                }
            })
        }
    }
    
    
    
    fileprivate func getDeviceName(corsair: CorsairApi = CorsairApi.sharedInstance()!) -> Future<String, Corsair.CorsairError>{
        Future { seal in
            corsair.getDeviceName { name in
                if let name = name{
                    seal(.success(name))
                }else{
                    seal(.failure(.deviceNotSet))
                }
            }
        }
    }
    
    fileprivate func getVendorName(corsair: CorsairApi = CorsairApi.sharedInstance()!) -> Future<String, Corsair.CorsairError>{
        Future { seal in
            corsair.getVendorName { name in
                if let name = name{
                    seal(.success(name))
                }else{
                    seal(.failure(.deviceNotSet))
                }
            }
        }
    }
    
    fileprivate func getFirmware(corsair: CorsairApi = CorsairApi.sharedInstance()!) -> Future<String, Corsair.CorsairError>{
        Future { seal in
            corsair.getFirmwareName { firmware in
                if let firmware = firmware{
                    seal(.success(firmware))
                }else{
                    seal(.failure(.deviceNotSet))
                }
            }
        }
    }
    
    
    // MARK: Setter
    
    @discardableResult
    fileprivate func setLightMode(corsair: CorsairApi = CorsairApi.sharedInstance()!, mode: Corsair.LightMode) -> Future<Int, Corsair.CorsairError>{
        Future{ seal in
            let cmd = mode.generate.toCommandLineParam()
            corsair.setLightMode(Int8(cmd.argc), cmd.argv, success: {
                seal(.success(0))
                DispatchQueue.main.async {
                    self.base._acknowledge.send()
                }            }) {
                    seal(.failure(.deviceNotSet))
            }
        }
    }
    
    
    
    
    @discardableResult
    fileprivate func setFanMode(corsair: CorsairApi = CorsairApi.sharedInstance()!, mode: Corsair.FanMode) -> Future<Int, Corsair.CorsairError>{
        Future{ seal in
            let cmd = mode.generate.toCommandLineParam()
            corsair.setFanMode(Int8(cmd.argc), cmd.argv, success: {
                seal(.success(0))
                DispatchQueue.main.async {
                    self.base._acknowledge.send()
                }
            }) {
                seal(.failure(.deviceNotSet))
            }
        }
    }
    
    @discardableResult
    fileprivate func setPumpMode(corsair: CorsairApi = CorsairApi.sharedInstance()!, mode: Corsair.PumpMode) -> Future<Int, Corsair.CorsairError>{
        Future{ seal in
            let cmd = mode.generate.toCommandLineParam()
            corsair.setPumpMode(Int8(cmd.argc), cmd.argv, success: {
                seal(.success(0))
                DispatchQueue.main.async {
                    self.base._acknowledge.send()
                }            }) {
                    seal(.failure(.deviceNotSet))
            }
        }
    }
}


// MARK: Mapping helper (will be removed)
extension Corsair{
    
    private func setLightMode(_ mode: Int) {
        if (mode == 0){
            combine.setLightMode(mode: .staticColor(channel: 0, color: staticColor))
        }else if (mode == 1){
            combine.setLightMode(mode: .blink(channel: 0, colors: blinkColor))
        }else if(mode == 2){
            combine.setLightMode(mode: .pulse(channel: 0, colors: pulseColor))
        }else if(mode == 3){
            combine.setLightMode(mode: .shift(channel: 0, colors: shiftColor))
        }else if(mode == 4){
            combine.setLightMode(mode: .rainbow(channel: 0, colors: rainbowColor))
        }else if(mode == 5){
            combine.setLightMode(mode: .temperature(channel: 0, colorTemperature: colorGardient))
        }
    }
    
    
    private func setFanMode(_ mode: Int) {
        if(mode == 0){
            _ = [0,1].map{
                combine.setFanMode(mode: .quiet(channel: $0))
            }
        }else if (mode == 1){
            _ = [0,1].map{
                combine.setFanMode(mode: .balanced(channel: $0))
            }
        }else if (mode == 2){
            _ = [0,1].map{
                combine.setFanMode(mode: .performance(channel: $0))
            }
        }
        else if(mode == 3){
            _ = [0,1].map{
                combine.setFanMode(mode: .fixedRPM(channel: $0, rpm: Int(self.rpm)))
            }
        }else if (mode == 4){
            _ = [0,1].map{
                combine.setFanMode(mode: .fixedPWM(channel: $0, pwm: Int(self.pwm)))
            }
        }else if (mode == 5){
            _ = [0,1].map{
                combine.setFanMode(mode: Corsair.FanMode.customCurve(channel: $0, tRpms: self.curve))
            }
        }
    }
    
    private func setPumpMode(_ mode: Int){
         self.combine.setPumpMode(mode: [.quiet, .balanced, .performance][mode])
    }
    
}
