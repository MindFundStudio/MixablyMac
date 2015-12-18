//
//  MXOutlinePlaylistViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 9/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

final class MXSidebarPlaylistViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {

    @IBOutlet weak var sourceListView: NSOutlineView!
    
    let realm = try! Realm()
    var topLevelItems = ["Library", "Playlist"]
    var childrenDictionary: [String: [Playlist]]!
    var playlist: [Playlist] = []
    var playlistResults: Results<Playlist>? {
        didSet {
            guard playlistResults != nil else { return }
            
            playlist = playlistResults!.map { (x) in return x }
            childrenDictionary["Playlist"] = playlist
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let playlist = Playlist()
        playlist.name = AllSongs
        childrenDictionary = [
            "Library": [playlist]
        ]
        playlistResults = realm.objects(Playlist)
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 0
        sourceListView.expandItem(nil, expandChildren: true)
        NSAnimationContext.endGrouping()

        // Enable Drag & Drop
        sourceListView.registerForDraggedTypes([NSPasteboardTypeString])
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadPlaylist:", name: MXNotifications.ReloadSidebarPlaylist.rawValue, object: nil)
    }
    
    override func viewDidAppear() {
        if MXPlayerManager.sharedManager.selectedPlaylist == nil {
            sourceListView.selectRowIndexes(NSIndexSet(index: 1), byExtendingSelection: false)
        }
    }
    
    // MARK: - Helpers
    
    func reloadOutlineView() {
        let originalSelect = sourceListView.selectedRowIndexes
        
        playlistResults = realm.objects(Playlist)
        sourceListView.reloadData()
        
        sourceListView.selectRowIndexes(originalSelect, byExtendingSelection: true)
    }
    
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
    
    // MARK: - Drag & Drop
    
    func outlineView(outlineView: NSOutlineView, pasteboardWriterForItem item: AnyObject) -> NSPasteboardWriting? {
        guard let playlist = item as? Playlist else { return nil }
        guard let item = item as? Playlist where item.name != AllSongs else { return nil }
        
        let pbItem = NSPasteboardItem()
        pbItem.setString(playlist.name, forType: NSPasteboardTypeString)
        
        return pbItem
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
        var sourceItem: Playlist!
        var sourceIndex: Int!
        
        if let item = item as? String where item == "Playlist" {
            var sourceArray = childrenDictionary[item]!
            
            for (index, p) in sourceArray.enumerate() {
                if p.name == name {
                    sourceItem = p
                    sourceIndex = index
                    break
                }
            }
            if sourceIndex == nil {
                return false
            }
            
            sourceArray.removeAtIndex(sourceIndex)
            if sourceIndex < index {
                sourceArray.insert(sourceItem, atIndex: index - 1)
            } else {
                sourceArray.insert(sourceItem, atIndex: index)
            }
            
            childrenDictionary[item]! = sourceArray
            sourceListView.reloadData()
        } else {
            return false
        }
        
        return true
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
        print("playlist: \(sourceListView.selectedRow)")
        let item = sourceListView.itemAtRow(sourceListView.selectedRow)
        
        if let item = item as? Playlist {
            NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.SelectPlaylist.rawValue, object: self, userInfo: [MXNotificationUserInfo.Playlist.rawValue: item])
        }
    }
    
    // MARK: - Notifications
    
    func reloadPlaylist(notification: NSNotification) {
        reloadOutlineView()
    }
}
