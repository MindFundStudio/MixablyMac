//
//  AppDelegate.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift
import iTunesLibrary
import SwiftyUserDefaults

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    let popover = NSPopover()
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var eventMonitor: EventMonitor?
    var songManger: MXSongManager?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        print(Realm.Configuration.defaultConfiguration.path)
        
        MXAnalyticsManager.setup()
        MXAnalyticsManager.startApp()
        
        songManger = MXSongManager()
        songManger?.trackSongDirectory()
        
        statusItem.title = ""

        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = Selector("togglePopover:")
        }

        // Popover

        popover.contentViewController = MXMainViewController.loadFromNib()

        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask], handler: { (event) -> () in
            if self.popover.shown {
                self.closePopover(event)
            }
        })

        // Seed Data
//        Defaults[.appInitLaunch] = false
        do {
            MXDataManager.importSeedData()
            try songManger?.importSongs()
            try songManger?.processUnanalysedSongs()
            Defaults[.appInitLaunch] = true
        } catch let error as NSError {
            print("Error: \(error)")
            NSAlert(error: error).runModal()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        MXAnalyticsManager.terminateApp()
        songManger = nil
    }

    // Helpers

    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
        }
        eventMonitor?.start()
    }

    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

