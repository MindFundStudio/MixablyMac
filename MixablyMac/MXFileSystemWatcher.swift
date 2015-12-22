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
    public var onFileChange: ((eventId: FSEventStreamEventId, eventPath: String, eventFlags: FSEventStreamEventFlags) -> Void)?
    
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
            fileSystemWatcher.onFileChange?(eventId: eventIds[index], eventPath: paths[index], eventFlags: eventFlags[index])
        }
        fileSystemWatcher.lastEventId = eventIds[numEvents - 1]
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
