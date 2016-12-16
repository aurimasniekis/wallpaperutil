//
//  main.swift
//  WallpaperUtil
//
//  Created by Aurimas Niekis on 12/12/16.
//  Copyright © 2016 Aurimas Niekis. All rights reserved.
//

import Foundation
import AppKit

let version = "1.0.0"
var sw = NSWorkspace.shared()
var args = ProcessInfo.processInfo.arguments

let helpText = "Wallpaper util provides a way to change and get information about each monitors wallpapers.\n\n" +

"Usage: wallpaperutil [options]\n" +
"   -l, --list            Displays all screen information.\n\n" +
"   -g, --get [ID]        Returns current wallpaper path of all monitors or specific monitor id.\n" +
"   -s, --set [ID] FILE   Set wallpaper for all monitors or specific monitor id.\n\n" +
"   -v, --version         Displays version number.\n" +
"   -h, --help            Shows this help prompt.\n\n" +

"Created by Aurimas Niekis"


if args.count < 2 {
    puts(helpText)
    
    exit(1)
}

if args[1] == "--version" || args[1] == "-v" {
    puts(version)
    
    exit(0)
}

if args[1] == "--help" || args[1] == "-h" {
    puts(helpText)
    
    exit(0)
}

if args[1] == "--list" || args[1] == "-l" {
    for screen: NSScreenType in NSScreen.screens()! {
        let deviceId = screen.deviceId
        let deviceName = screen.displayName
        let deviceWallpaper = (sw.desktopImageURL(for: screen as! NSScreen)?.path)! as String
        
        
        let info = "\(deviceName) (\(deviceId)): \(deviceWallpaper)"
        puts(info)
    }
}

if args[1] == "--get" || args[1] == "-g" {
    if args.count == 2 {
        print((sw.desktopImageURL(for: NSScreen.main()!)?.path)! as String)
    } else {
        var f = NumberFormatter()
        f.numberStyle = .decimal
        let deviceId = f.number(from: args[2])

        for screen: NSScreenType in NSScreen.screens()! {
            if screen.deviceId == deviceId {
                print((sw.desktopImageURL(for: screen as! NSScreen)?.path)! as String)
                exit(0)
            }
        }
        
        puts("Device id \"\((deviceId?.stringValue)! as String)\" not found!")
    }
}

if (args[1] == "--set" || args[1] == "-s") && args.count >= 3 {
    let fileManager = FileManager.default
    
    if args.count == 4 {
        var f = NumberFormatter()
        f.numberStyle = .decimal
        let deviceId = f.number(from: args[2])
        let imagePath = URL(fileURLWithPath: args[3])
        
        if !fileManager.fileExists(atPath: args[3]) {
            puts("File \(args[3]) does not exist!")
            
            exit(1)
        }
        
        
        for screen: NSScreenType in NSScreen.screens()! {
            if screen.deviceId == deviceId {
                var opt = sw.desktopImageOptions(for: screen as! NSScreen)
                var err: Error!
                
                do {
                    try sw.setDesktopImageURL(imagePath, for: screen as! NSScreen, options: opt!)
                } catch {
                    puts(err.localizedDescription as String)
                    
                    exit(1)
                }
            }
        }
    } else {
        let imagePath = URL(fileURLWithPath: args[2])
        
        if !fileManager.fileExists(atPath: args[2]) {
            puts("File \(args[2]) does not exist!")
            
            exit(1)
        }
        
        for screen: NSScreenType in NSScreen.screens()! {
            var opt = sw.desktopImageOptions(for: screen as! NSScreen)
            var err: Error!
            
            do {
                try sw.setDesktopImageURL(imagePath, for: screen as! NSScreen, options: opt!)
            } catch {
                puts(err.localizedDescription as String)
                
                exit(1)
            }
        }
    }
}
