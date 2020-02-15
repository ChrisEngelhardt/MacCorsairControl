//
//  AppDelegate.swift
//  CorsairUI
//
//  Created by Chris Engelhardt on 23.10.19.
//  Copyright © 2019 Chris Engelhardt. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine
import Sparkle
import LaunchAtLogin

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    private var corsair = Corsair(refreshInterval: 2, debug: false)
    private let donationURL = URL(string: "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MYA6VUBHAJ43W&source=url")
    private var subscriptions = Set<AnyCancellable>()
    private let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    private let popover = NSPopover()
    private var eventMonitor: EventMonitor?
    private let checkForUpdatesAuto = NSMenuItem(title: "Automatically check for updates", action: #selector(autoCheckForUpdateButton), keyEquivalent: "")
    private let update = NSMenuItem(title: "Check for updates now", action: #selector(checkForUpdateButton), keyEquivalent: "")
    private let donate = NSMenuItem(title: "Donate", action: #selector(donateButton), keyEquivalent: "d")
    private let close = NSMenuItem(title: "Quit", action: #selector(quitButton), keyEquivalent: "q")
    private let autoStart = NSMenuItem(title: "Autostart", action: #selector(autostart), keyEquivalent: "")
    //private let showInfo = NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "")
    private lazy var menu: NSMenu = {
        let menu = NSMenu()
        checkForUpdatesAuto.state = SUUpdater.shared()?.automaticallyChecksForUpdates ?? true ? NSControl.StateValue.on : NSControl.StateValue.off
        //menu.addItem(showInfo)
        //menu.addItem(NSMenuItem.separator())
        menu.addItem(update)
        menu.addItem(checkForUpdatesAuto)
        autoStart.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(autoStart)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(donate)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(close)
        return menu
    }()
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Set up status bar icon
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(corsair))
            let mode = NSAppearance.current
            let appearence = mode?.bestMatch(from: [.darkAqua, .aqua])
            popover.appearance = NSAppearance(named: appearence ?? .darkAqua)
        }
        
        //handle mouse click outside
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
        //Show current temperature
        corsair.$temperature.sink { (values) in
            if let button = self.statusItem.button {
                if let tmp = self.corsair.temperature.first{
                    button.title = "\(tmp) °C"
                }else{
                    button.title = "-"
                }
                
                
            }
        }.store(in: &subscriptions)
        
        SUUpdater.shared()?.checkForUpdatesInBackground()
        #if !DEBUG
            PFMoveToApplicationsFolderIfNecessary()
        #endif
    }
    

    
    @objc private func togglePopover(_ sender: Any?) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            handleRightClick()
        } else {
            handleLeftClick(sender)
        }
    }
    
    
    private func handleRightClick() {
        statusItem.popUpMenu(menu)
        statusItem.menu = nil   //Strange but necessary
    }
    
    private func handleLeftClick(_ sender: Any?) {
        if let sender = sender as? NSButton{
            if popover.isShown {
                closePopover(sender: sender)
            } else {
                showPopover(sender: sender)
            }
        }
    }
    
    private func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    private func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    @objc private func autoCheckForUpdateButton(){
        SUUpdater.shared()?.automaticallyChecksForUpdates.toggle()
        checkForUpdatesAuto.state = SUUpdater.shared()?.automaticallyChecksForUpdates ?? true ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    @objc private func checkForUpdateButton(){
        SUUpdater.shared()?.checkForUpdates(statusItem.button)
    }
    
    @objc private func donateButton(){
        NSWorkspace.shared.open(donationURL!)
    }
    
    @objc private func quitButton(){
        NSApplication.shared.terminate(self)
    }
    
    @objc private func autostart(){
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        autoStart.state = LaunchAtLogin.isEnabled ? .on : .off
    }
    
    @objc private func showAbout(){
       
    }
}




