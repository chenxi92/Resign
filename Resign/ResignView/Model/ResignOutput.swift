//
//  ResignOutput.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import Foundation

public struct ResignOutput {
    let workDir: String
    let unzipfolder: String
    let outputIpaFilePath: String
    let payloadPath: String
    let entitlementsPath: String
    
    init(from inputURL: URL) {
        self.workDir =  inputURL.deletingLastPathComponent().path + "/" + "\(UUID().uuidString)"
        self.unzipfolder = self.workDir + "/origin"
        self.payloadPath = self.unzipfolder + "/Payload"
        self.entitlementsPath = workDir + "/entitlements.plist"
        let fileName = inputURL.lastPathComponent.split(separator: ".").first!
        self.outputIpaFilePath = workDir + "/\(fileName)-resign" + ".ipa"
        if !FileManager.default.fileExists(atPath: self.unzipfolder) {
            try? FileManager.default.createDirectory(atPath: self.unzipfolder, withIntermediateDirectories: true)
        }
    }
}
