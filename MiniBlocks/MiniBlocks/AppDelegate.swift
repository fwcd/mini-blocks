//
//  AppDelegate.swift
//  MiniBlocks
//
//  Created by Fredrik on 06.01.22.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up menu
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q")
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        let menu = NSMenu()
        menu.addItem(appMenuItem)
        NSApp.menu = menu
        
        // Set up window
        let width = 800
        let height = 600
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.miniaturizable, .closable, .titled, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "MiniBlocks"
        window.contentViewController = MiniBlocksViewController(
            sceneFrame: CGRect(x: 0, y: 0, width: width, height: height),
            worldGenerator: .nature(seed: "default"),
            gameMode: .survival,
            renderDistance: 12,
            debugStatsShown: true
        )
        window.makeKeyAndOrderFront(nil)
    }
}
