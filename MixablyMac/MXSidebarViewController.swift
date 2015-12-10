//
//  MXOutlinePlaylistViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 9/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXSidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {

    @IBOutlet weak var sourceListView: NSOutlineView!
    var topLevelItems = ["Library", "Playlist"]
    var childrenDictionary: [String: [Playlist]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let playlist1 = Playlist()
        playlist1.name = "All Songs"
        let playlist2 = Playlist()
        playlist2.name = "P1"
        let playlist3 = Playlist()
        playlist3.name = "P2"
        childrenDictionary = [
            "Library": [playlist1],
            "Playlist": [playlist2, playlist3]
        ]
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 0
        sourceListView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
    }
    
    // MARK: - Helpers
    
    func isHeader(item: AnyObject) -> Bool {
        if let item = item as? String {
            return item == "Library" || item == "Playlist"
        } else {
            return false
        }
    }
    
    // MARK: - NSOutlineView DataSource
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let item = item {
            switch item {
            case let item as String where topLevelItems.contains(item):
                return childrenDictionary[item]!.count
            default:
                return 0
            }
        } else {
            return topLevelItems.count
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return outlineView.parentForItem(item) == nil
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let item = item {
            switch item {
            case let item as String where topLevelItems.contains(item):
                let result = childrenDictionary[item]![index]
                return result
            default:
                return self
            }
        } else {
            return topLevelItems[index]
        }
    }
    
    // MARK: - Delegate
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        switch item {
        case let item as String where topLevelItems.contains(item):
            let view = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            view.textField?.stringValue = item
            return view
        case let item as Playlist:
            let view = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
            view.textField?.stringValue = item.name
            return view
        default:
            return nil
        }
        
    }
    
    func outlineView(outlineView: NSOutlineView, shouldShowOutlineCellForItem item: AnyObject) -> Bool {
        return !isHeader(item)
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        return !isHeader(item)
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        print("notification: \(sourceListView.selectedRow)")
    }
    
}
