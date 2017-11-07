//
//  AppDelegate.swift
//  TinyServer
//
//  Created by Luigi Pizzolito on 7/11/2017.
//  Copyright © 2017 Luigi Pizzolito. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSUserNotificationCenter.default.delegate = self as NSUserNotificationCenterDelegate//add this in the applicationDidFinishLaunching call

        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
    }

    extension AppDelegate:NSUserNotificationCenterDelegate{
        func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
            return true
        }
}



