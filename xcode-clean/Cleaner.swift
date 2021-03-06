//
//  Cleaner.swift
//  xcode-clean
//
//  Created by Niklas Berglund on 2017-11-04.
//  Copyright © 2017 Niklas Berglund. All rights reserved.
//

import Foundation

enum DirectoryPath: String {
    case archives = "~/Library/Developer/Xcode/Archives"
    case derivedData = "~/Library/Developer/Xcode/DerivedData"
    case simulatorDevices = "~/Library/Developer/CoreSimulator/Devices"
    case deviceSupport = "~/Library/Developer/Xcode/iOS DeviceSupport"
    
    static let allValues = [
        DirectoryPath.archives,
        DirectoryPath.derivedData,
        DirectoryPath.simulatorDevices,
        DirectoryPath.deviceSupport
    ]
}

class Cleaner {
    public func diskSpace(path: DirectoryPath) -> Int {
        let expandedPath = Cleaner.expandTilde(path.rawValue)
        var totalSize: Int = 0
        
        if let files = FileManager.default.subpaths(atPath: expandedPath) {
            for filePath in files {
                let filePathFull = "\(expandedPath)/\(filePath)"
                
                if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: filePathFull) {
                    totalSize += fileAttributes[FileAttributeKey.size] as! Int
                }
            }
        }
        
        return totalSize
    }
    
    public func humanReadableDiskSpace(path: DirectoryPath) -> String {
        let totalSize: Double = Double(self.diskSpace(path: path))
        
        let roundFactor = 100
        
        let kbSize = totalSize/1024
        let mbSize = kbSize/1024
        let gbSize = mbSize/1024
        
        if kbSize < 1024 {
            let roundedSize = Double(round(kbSize * Double(roundFactor))/Double(roundFactor))
            return "\(roundedSize)K"
        }
        else if mbSize < 1024 {
            let roundedSize = Double(round(mbSize * Double(roundFactor))/Double(roundFactor))
            return "\(roundedSize)M"
        }
        else {
            let roundedSize = Double(round(gbSize * Double(roundFactor))/Double(roundFactor))
            return "\(roundedSize)G"
        }
    }
    
    /// Removes all files and directories under the specified directory.
    ///
    /// - Parameter path: Path of the directory to remove files and directories under.
    public func deleteContents(path: DirectoryPath) {
        let expandedPath = Cleaner.expandTilde(path.rawValue)
        
        if let files = try? FileManager.default.contentsOfDirectory(atPath: expandedPath) {
            for subPath in files {
                let subPathFull = "\(expandedPath)/\(subPath)"
                
                do {
                    try FileManager.default.removeItem(atPath: subPathFull)
                }
                catch let error {
                    debugPrint("\(error.localizedDescription)")
                }
            }
        }
    }
    
    private static func expandTilde(_ path: String) -> String {
        return NSString(string: path).expandingTildeInPath
    }
}
