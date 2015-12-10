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
    var childrenDictionary = [
        "Library": ["All Songs"],
        "Playlist": ["P1", "P2"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        sourceListView.sizeLastColumnToFit()
        sourceListView.reloadData()
        sourceListView.floatsGroupRows = false
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 0
        sourceListView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()
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
                print("child: \(result)")
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
        print("item: \(item)")
        switch item {
        case let item as String where topLevelItems.contains(item):
            let view = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            view.textField?.stringValue = item
            return view
        case let item as String:
            let view = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
            view.textField?.stringValue = item
            return view
        default:
            return nil
        }
        
    }
    
    func outlineView(outlineView: NSOutlineView, shouldShowOutlineCellForItem item: AnyObject) -> Bool {
        guard let item = item as? String else { return false }
        
        return item != "Library" && item != "Playlist"
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        print("notification: \(sourceListView.selectedRow)")
    }
    
}
