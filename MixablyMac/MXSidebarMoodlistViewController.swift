//
//  MXSidebarMoodlistViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 11/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

final class MXSidebarMoodlistViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

    @IBOutlet var moodlistController: NSTreeController!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    let newMood = Mood.create()
    let realm = try! Realm()
    var moods: [Mood]! {
        didSet {
            moods.append(newMood)
            dict.setObject(moods, forKey: "children")
        }
    }
    
    var dict: NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let root = [
            "name": "Moods",
            "isLeaf": false
        ]
        
        dict = NSMutableDictionary(dictionary: root)
        moodlistController.addObject(dict)
        
        loadAllMoods()
        
        outlineView.expandItem(nil, expandChildren: true)
        outlineView.deselectRow(0)
        
        outlineView.registerForDraggedTypes([NSPasteboardTypeString])
        
        outlineView.selectionHighlightStyle = .Regular
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadAllMoods", name: MXNotifications.ReloadSidebarMood.rawValue, object: nil)
    }
    
    // MARK: - Helpers
    
    func loadAllMoods() {
        moods = realm.objects(Mood).filter("isInternal == false").map { (x) in return x }
    }
    
    func isHeader(item: AnyObject) -> Bool {
        if let item = item as? NSTreeNode {
            return !(item.representedObject is Mood)
        } else {
            return !(item is Mood)
        }
    }
    
    func isNew(item: AnyObject) -> Bool {
        if let item = item as? NSTreeNode {
            if let mood = item.representedObject as? Mood {
                return mood.isNew
            } else {
                return false
            }
        } else {
            return (item as! Mood).isNew
        }
    }
    
    // MARK: - NSOutlineView DataSource
    // MARK: - Drag & Drop
    
    func outlineView(outlineView: NSOutlineView, pasteboardWriterForItem item: AnyObject) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        
        if let mood = ((item as? NSTreeNode)?.representedObject) as? Mood {
            pbItem.setString(mood.name, forType: NSPasteboardTypeString)
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
        let name = pb.stringForType(NSPasteboardTypeString)
        
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
        } else if isNew(item) {
            return outlineView.makeViewWithIdentifier("AddCell", owner: self)
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

    func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        return 27
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        print("moodlist: \(outlineView.selectedRow)")
        let item = outlineView.itemAtRow(outlineView.selectedRow)
        
        if let item = item where isNew(item) {
            outlineView.deselectRow(outlineView.selectedRow)
            return
        }
        
        if let mood = ((item as? NSTreeNode)?.representedObject) as? Mood {
            NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.SelectMood.rawValue, object: self, userInfo: [MXNotificationUserInfo.Mood.rawValue: mood])
        }

    }
    
    func outlineView(outlineView: NSOutlineView, rowViewForItem item: AnyObject) -> NSTableRowView? {
        return MXTableRowView()
    }
    
    // MARK: - IBAction
    
    @IBAction func showPopover(sender: NSButton) {
        // Popover
        
        let vc = MXPopoverViewController.loadFromNib()
        vc.popover.delegate = self
        vc.showPopover(outlineView)
    }
    
}

extension MXSidebarMoodlistViewController: NSPopoverDelegate {
    func popoverDidClose(notification: NSNotification) {
        loadAllMoods()
    }
}
