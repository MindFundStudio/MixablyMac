//
//  MXSidebarMoodlistViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 11/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXSidebarMoodlistViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

    @IBOutlet var moodlistController: NSTreeController!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let m1 = Mood()
        m1.name = "M1"
        let m2 = Mood()
        m2.name = "M2"
        
        let original = [
            "name": "MOODS",
            "isLeaf": false,
            "children": [m1, m2]
        ]
        let root: NSMutableDictionary = NSMutableDictionary(dictionary: original)
        moodlistController.addObject(root)
        
        outlineView.expandItem(nil, expandChildren: true)
        outlineView.deselectRow(0)
        
        outlineView.registerForDraggedTypes([dragType])
    }
    
    // MARK: - Helpers
    
    func isHeader(item: AnyObject) -> Bool {
        if let item = item as? NSTreeNode {
            return !(item.representedObject is Mood)
        } else {
            return !(item is Mood)
        }
    }
    
    // MARK: - NSOutlineView DataSource
    // MARK: - Drag & Drop
    
    func outlineView(outlineView: NSOutlineView, pasteboardWriterForItem item: AnyObject) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        
        if let mood = ((item as? NSTreeNode)?.representedObject) as? Mood {
            pbItem.setString(mood.name, forType: dragType)
            return pbItem
        }
        
        return nil
    }

    func outlineView(outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: AnyObject?, proposedChildIndex index: Int) -> NSDragOperation {
        let canDrag = index >= 0 && item != nil
        
        if canDrag {
            return .Move
        } else {
            return .None
        }
    }
    
    func outlineView(outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: AnyObject?, childIndex index: Int) -> Bool {
        let pb = info.draggingPasteboard()
        let name = pb.stringForType(dragType)
        
        var sourceNode: NSTreeNode?
        
        if let item = item as? NSTreeNode where item.childNodes != nil {
            
            for node in item.childNodes! {
                if let mood = node.representedObject as? Mood {
                    if mood.name == name {
                        sourceNode = node
                    }
                }
            }
        }
        if sourceNode == nil {
            return false
        }
        
        let indexArr: [Int] = [0, index]
        let toIndexPath = NSIndexPath(indexes: indexArr, length: 2)
        moodlistController.moveNode(sourceNode!, toIndexPath: toIndexPath)
        
        return true
    }
    
    // MARK: - NSOutlineView Delegate
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if isHeader(item) {
            return outlineView.makeViewWithIdentifier("HeaderCell", owner: self)
        } else {
            return outlineView.makeViewWithIdentifier("DataCell", owner: self)
        }
    }
    
    func outlineView(outlineView: NSOutlineView, shouldShowOutlineCellForItem item: AnyObject) -> Bool {
        return !isHeader(item)
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        return !isHeader(item)
    }

    func outlineViewSelectionDidChange(notification: NSNotification) {
        print("moodlist: \(outlineView.selectedRow)")
    }
    
}