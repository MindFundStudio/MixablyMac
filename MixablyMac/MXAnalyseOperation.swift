//
//  MXAnalyseOperation.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 15/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import PSOperations
import Regex
import SwiftyJSON

/*  
=====================================
Sample Usage:
=====================================
// Create an strong reference to an OperationQueue
let operationQueue = OperationQueue()

// Optionally set the max concurrent operation count
operationQueue.maxConcurrentOperationCount = 4

// Create the operation
let operation = MXAnalyseOperation(fileURL: fileURL) { features, error in
    // Do something with features and error
}

// Make sure to add to an OperationQueue
operationQueue.addOperation(operation)
*/

typealias MXAnalyseCompletion = (MXFeatures?, NSError?) -> Void

final class MXAnalyseOperation: Operation {
    
    // =============
    // MARK: - Enums
    // =============
    
    enum JSONKey:String {
        case MusicPath = "musicPath"
        case Tonality = "tonality"
        case Intensity = "intensity"
        case Bins = "bins"
        case RhythmStrength = "rhythmStrength"
        case RMSEnergy = "rmsEnergy"
        case Tempo = "tempo"
        
        var key:String {
            return self.rawValue
        }
    }
    
    // ==================
    // MARK: - Properties
    // ==================
    
    static let regex = Regex("\\{.*\\}")
    
    let fileURL:NSURL
    let completion:MXAnalyseCompletion?
    let task: NSTask
    // ============
    // MARK: - Init
    // ============
    
    init(fileURL:NSURL, completion:MXAnalyseCompletion?) {
        self.fileURL = fileURL
        self.completion = completion
        self.task = NSTask()
    }
    
    // ===========================
    // MARK: - Operation Execution
    // ===========================
    
    override func execute() {
        
        if cancelled {
            return
        }
        
        if let resourcePath = NSBundle.mainBundle().resourcePath, path = fileURL.path {
            
            let execPath = NSString(string: resourcePath).stringByAppendingPathComponent("blackbox")
            
            let pipe = NSPipe()
            let error = NSPipe()
            
            task.launchPath = execPath
            task.currentDirectoryPath = resourcePath
            task.arguments = [path, "-s"]
            task.standardOutput = pipe
            task.standardError = error
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            // Note: jsonString uses regex to grab only the info in between braces { }
            // as blackbox also outputs other stuff such as error messages and other
            // print statements which would render the pipe capture invalid JSON
            
            if let output = String(data: data, encoding: NSUTF8StringEncoding),
                jsonString = MXAnalyseOperation.regex.match(output)?.matchedString
            {
                let json = JSON.parse(jsonString)
                let musicPath = json[JSONKey.MusicPath.key].stringValue
                let tonality = json[JSONKey.Tonality.key].stringValue
                let intensity = json[JSONKey.Intensity.key].doubleValue
                let rhythmStrength = json[JSONKey.RhythmStrength.key].doubleValue
                let rmsEnergy = json[JSONKey.RMSEnergy.key].doubleValue
                let tempo = json[JSONKey.Tempo.key].doubleValue
                
                let binsJson = json[JSONKey.Bins.key].arrayValue
                let bins = binsJson.map {bin in bin.doubleValue }
                
                let features = MXFeatures(path: musicPath,
                    tonality: tonality,
                    intensity: intensity,
                    rhythmStrength: rhythmStrength,
                    rmsEnergy: rmsEnergy,
                    tempo: tempo,
                    bins: bins)
                
                completion?(features, nil)
                finish()
            }
            else {
                let error = NSError(domain: "MXErrorDomain", code: 1, userInfo: ["location": self.fileURL])
                completion?(nil, error)
                finishWithError(error)
            }
            
            task.waitUntilExit()
            
        } else {
            // This really should not happen
            assertionFailure("Fatal: MXAnalyzeOperation Error, cannot find bundle resource path")
        }
    }
    
    override func cancel() {
        if task.running {
            task.terminate()
        }
        
        super.cancel()
    }
}
