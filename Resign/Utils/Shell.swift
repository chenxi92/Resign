//
//  Shell.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import Foundation

@discardableResult
func runShell(_ executable: String, args: [String], currentDirectory: String? = nil) throws -> Data? {
    let process = Process()
    if #available(macOS 10.13, *) {
        process.executableURL = URL(fileURLWithPath: executable)
        if currentDirectory != nil {
            process.currentDirectoryURL = URL(fileURLWithPath: currentDirectory!)
        }
    } else {
        process.launchPath = executable
        if currentDirectory != nil {
            process.currentDirectoryPath = currentDirectory!
        }
    }
    process.arguments = args
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
        if #available(OSX 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
        
        process.waitUntilExit()
        if process.terminationStatus == 0 {
            return try pipe.fileHandleForReading.readToEnd()
        }
    } catch {
        print(error)
    }
    return nil
}
