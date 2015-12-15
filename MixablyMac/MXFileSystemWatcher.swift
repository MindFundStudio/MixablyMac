//
//  MXFileSystemWatcher.swift
//  MixablyMac
//
//  Created by Joseph Cheung on 14/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation
public class MXFileSystemWatcher {
    private let pathsToWatch: [String]
    private var started = false
    private var streamRef: FSEventStreamRef!
    public private(set) var lastEventId: FSEventStreamEventId
    
    public init(pathsToWatch: [String], sinceWhen: FSEventStreamEventId) {
        self.lastEventId = sinceWhen
        self.pathsToWatch = pathsToWatch
    }
    
    convenience public init(pathsToWatch: [String]) {
        self.init(pathsToWatch: pathsToWatch, sinceWhen: FSEventStreamEventId(kFSEventStreamEventIdSinceNow))
    }
    
    deinit {
        stop()
    }
    
    private let eventCallback: FSEventStreamCallback = {(stream: ConstFSEventStreamRef, contextInfo: UnsafeMutablePointer<Void>, numEvents: Int, eventPaths: UnsafeMutablePointer<Void>, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIds: UnsafePointer<FSEventStreamEventId>) in
        print("*** FSEventCallback Fired ***")
        
        let fileSystemWatcher: MXFileSystemWatcher = unsafeBitCast(contextInfo, MXFileSystemWatcher.self)
        let paths = unsafeBitCast(eventPaths, NSArray.self) as! [String]
        
        for index in 0..<numEvents {
            fileSystemWatcher.processEvent(eventIds[index], eventPath: paths[index], eventFlags: eventFlags[index])
        }
        fileSystemWatcher.lastEventId = eventIds[numEvents - 1]
    }
    
    private func processEvent(eventId: FSEventStreamEventId, eventPath: String, eventFlags: FSEventStreamEventFlags) {
        print("\t\(eventId) - \(String(format: "%2X", eventFlags)) - \(eventPath)")
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagNone)) != 0 {
            print("kFSEventStreamEventFlagNone - There was some change in the directory at the specific path supplied in this event.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagMustScanSubDirs)) != 0 {
            print("kFSEventStreamEventFlagMustScanSubDirs - Your application must rescan not just the directory given in the event, but all its children, recursively.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagUserDropped)) != 0 {
            print("kFSEventStreamEventFlagUserDropped - The kFSEventStreamEventFlagUserDropped or kFSEventStreamEventFlagKernelDropped flags may be set in addition to the kFSEventStreamEventFlagMustScanSubDirs flag to indicate that a problem occurred in buffering the events (the particular flag set indicates where the problem occurred) and that the client must do a full scan of any directories (and their subdirectories, recursively) being monitored by this stream.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagKernelDropped)) != 0 {
            print("kFSEventStreamEventFlagKernelDropped - The kFSEventStreamEventFlagUserDropped or kFSEventStreamEventFlagKernelDropped flags may be set in addition to the kFSEventStreamEventFlagMustScanSubDirs flag to indicate that a problem occurred in buffering the events (the particular flag set indicates where the problem occurred) and that the client must do a full scan of any directories (and their subdirectories, recursively) being monitored by this stream.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagEventIdsWrapped)) != 0 {
            print("kFSEventStreamEventFlagEventIdsWrapped - If kFSEventStreamEventFlagEventIdsWrapped is set, it means the 64-bit event ID counter wrapped around.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagHistoryDone)) != 0 {
            print("kFSEventStreamEventFlagHistoryDone - Denotes a sentinel event sent to mark the end of the \"historical\" events sent as a result of specifying a sinceWhen value in the FSEventStreamCreate...() call that created this event stream.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagRootChanged)) != 0 {
            print("kFSEventStreamEventFlagRootChanged - Denotes a special event sent when there is a change to one of the directories along the path to one of the directories you asked to watch.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagMount)) != 0 {
            print("kFSEventStreamEventFlagMount - Denotes a special event sent when a volume is mounted underneath one of the paths being monitored.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagUnmount)) != 0 {
            print("kFSEventStreamEventFlagUnmount - Denotes a special event sent when a volume is unmounted underneath one of the paths being monitored.")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated)) != 0 {
            print("kFSEventStreamEventFlagItemCreated - A file system object was created at the specific path supplied in this event. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved)) != 0 {
            print("kFSEventStreamEventFlagItemRemoved - A file system object was removed at the specific path supplied in this event. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemInodeMetaMod)) != 0 {
            print("kFSEventStreamEventFlagItemInodeMetaMod - A file system object at the specific path supplied in this event had its metadata modified. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
        if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed)) != 0 {
            print("kFSEventStreamEventFlagItemRenamed - A file system object was renamed at the specific path supplied in this event. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
         if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified)) != 0 {
            print("kFSEventStreamEventFlagItemModified - A file system object at the specific path supplied in this event had its data modified. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
         if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemFinderInfoMod)) != 0 {
            print("kFSEventStreamEventFlagItemFinderInfoMod - A file system object at the specific path supplied in this event had its FinderInfo data modified. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
         if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemChangeOwner)) != 0 {
            print("kFSEventStreamEventFlagItemChangeOwner - A file system object at the specific path supplied in this event had its ownership changed. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
         if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemXattrMod)) != 0 {
            print("kFSEventStreamEventFlagItemXattrMod - A file system object at the specific path supplied in this event had its extended attributes modified. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
         if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsFile)) != 0 {
            print("kFSEventStreamEventFlagItemIsFile - The file system object at the specific path supplied in this event is a regular file. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
         if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsDir)) != 0 {
            print("kFSEventStreamEventFlagItemIsDir - The file system object at the specific path supplied in this event is a directory. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
         if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsSymlink)) != 0 {
            print("kFSEventStreamEventFlagItemIsSymlink - The file system object at the specific path supplied in this event is a symbolic link. (This flag is only ever set if you specified the FileEvents flag when creating the stream.)")
        }
        
   }
    
    public func start() {
        guard started == false else { return }
        
        var context = FSEventStreamContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutablePointer<Void>(unsafeAddressOf(self))
        let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        streamRef = FSEventStreamCreate(kCFAllocatorDefault, eventCallback, &context, pathsToWatch, lastEventId, 0, flags)
        
        FSEventStreamScheduleWithRunLoop(streamRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode)
        FSEventStreamStart(streamRef)
        
        started = true
    }
    
    public func stop() {
        guard started == true else { return }
        
        FSEventStreamStop(streamRef)
        FSEventStreamInvalidate(streamRef)
        FSEventStreamRelease(streamRef)
        streamRef = nil
        
        started = false
    }
}
