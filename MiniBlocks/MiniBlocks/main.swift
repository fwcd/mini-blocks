//
//  main.swift
//  MiniBlocks
//
//  Created by Fredrik on 06.01.22.
//

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
