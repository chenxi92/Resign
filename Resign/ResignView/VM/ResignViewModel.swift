//
//  ResignViewModel.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import SwiftUI

public class ResignViewModel: ObservableObject {
    
    @Published private(set) var provisioningProfiles: [ProvisioningProfile] = []
    @Published private(set) var certificateNames: [String] = []
    @Published private(set) var logs: [String] = []
    @Published var displayName: String = ""
    @Published var buildVersion: String = ""
    @Published var buildVersionShort: String = ""
    
    @AppStorage("resign.certifile.name")
    var selectedCertificateName = ""
    
    @AppStorage("resign.provision.file.uuid")
    var selectedProvisionFileUUID: String = ""
    
    public func selectedProvisionFile() -> ProvisioningProfile? {
        provisioningProfiles.first { $0.uuid == selectedProvisionFileUUID }
    }
    
    public func loadCertificates() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.loadCertificateAsync()
        }
    }
    
    private func loadCertificateAsync() {
        do {
            let data = try runShell("/usr/bin/security", args: ["find-identity", "-v", "-p", "codesigning"])!
            DispatchQueue.main.async {
                let buffer = String(data: data, encoding: .utf8)!
                buffer.enumerateLines { line, _ in
                    let components = line.components(separatedBy: "\"")
                    if components.count > 2 {
                        let name = components[components.count - 2]
                        if !self.certificateNames.contains(name) {
                            self.certificateNames.append(name)
                        }
                    }
                }
                self.addLog("load \(self.certificateNames.count) certificate name")
            }
        } catch {
            addLog("load certificate error: \(error)")
        }
    }
    
    public func loadProvisioningFiles() {
        DispatchQueue.global(qos: .userInitiated).async {
            var availableProfiles: [ProvisioningProfile] = []
            for url in  FileManager.default.availableProvisionProfile() {
                if let profile = self.parseProvisioningFile(at: url) {
                    availableProfiles.append(profile)
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.provisioningProfiles += availableProfiles
                self?.provisioningProfiles.sort { $0.expirationDate > $1.expirationDate }
                self?.addLog("load \(availableProfiles.count) provision profile.")
            }
        }
    }
    
    public func sign(at filePath: String, output: ResignOutput) {
        do {
            guard let profile = selectedProvisionFile() else {
                addLog("no provision file selected.")
                return
            }
            
            // 1. unzip file
            addLog("begin zip file")
            try runShell("/usr/bin/unzip", args: ["-q", filePath, "-d", output.unzipfolder])
            if !FileManager.default.fileExists(atPath: output.payloadPath) {
                addLog("unzip failed.")
                return
            }
            
            
            // 2. extract emtitlements content
            addLog("begin write entitlements")
            writeEntitlementsPlist(to: profile, filePath: output.entitlementsPath)
            
            // 3. change Info.plist
            let appFiles = findsubfolders(at: output.payloadPath, withExtension: ["app"])
            if appFiles.count != 1 {
                addLog("app file path not found in: \(appFiles)")
                return
            }
            
            let appFilePath = appFiles.first!
            let infoPlistFilePath = appFilePath + "/Info.plist"
            if !FileManager.default.fileExists(atPath: infoPlistFilePath) {
                addLog("Info.plist file not exist: \(appFilePath)")
            }
            
            let bundleID = profile.bundleIdentifier
            let plistProcessor = PropertyListProcessor(with: infoPlistFilePath)
            plistProcessor.modifyBundleIdentifier(with: bundleID)
            addLog("modify bundleIdentifier to: \(bundleID)")
            
            if !displayName.isEmpty {
                addLog("change displayName to: \(displayName)")
                plistProcessor.modifyDisplayName(with: displayName)
            }
            if !buildVersion.isEmpty {
                addLog("change buildVersion to: \(buildVersion)")
                plistProcessor.modifyBundleVersion(with: buildVersion)
            }
            if !buildVersionShort.isEmpty {
                addLog("change buildVersionShort to: \(buildVersionShort)")
                plistProcessor.modifyBundleVersion(with: buildVersionShort)
            }
            
            // 4. sign files
            var signFiles = findsubfolders(at: output.payloadPath, withExtension: ["appex", "framework"])
            signFiles.append(appFilePath)
            for filePath in signFiles {
                addLog("sign file: \(filePath)")
                let arguments = ["-vvv", "-fs" , selectedCertificateName, "--no-strict", "--entitlements=\(output.entitlementsPath)", filePath]
                if let data = try runShell("/usr/bin/codesign", args: arguments) {
                    let buffer = String(data: data, encoding: .utf8)!
                    addLog(buffer)
                }
            }
            
            
            // 5. verify app file
            addLog("begin verify app file")
            try runShell("/usr/bin/codesign", args: ["--verify", appFilePath])
            
            // 7. zip app to ipa
            addLog("begin zip file: \(output.outputIpaFilePath)")
            try runShell("/usr/bin/zip", args: ["-qry", output.outputIpaFilePath, "."], currentDirectory: output.unzipfolder)
            
            // 8. open resign folder
            try runShell("/usr/bin/open", args: [output.workDir])
            
//            addLog("begin clear")
//            try FileManager.default.removeItem(atPath: output.unzipfolder)
//            try FileManager.default.removeItem(atPath: output.entitlementsPath)
//            addLog("clear success")
            
            addLog("sign finished!")
        } catch {
            addLog("sign error: \(error)")
        }
    }
    
    // MARK: - private
    
    private func addLog(_ message: String) {
        print(message)
        logs.append(message)
    }
    
    private func findsubfolders(at folderPath: String, withExtension extensions: [String]) -> [String] {
        var results: [String] = []
        
        let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: folderPath), includingPropertiesForKeys: [.isRegularFileKey], options: .skipsHiddenFiles, errorHandler: nil)
        
        while let url = enumerator?.nextObject() as? URL {
            if extensions.contains(url.pathExtension) {
                results.append(url.path)
            }
        }
        return results
    }
    
    public func writeEntitlementsPlist(to profile: ProvisioningProfile, filePath: String) {
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let data = try encoder.encode(profile.entitlements)
            try data.write(to: URL(fileURLWithPath: filePath))
        } catch {
            print("write entitlement plist error: \(error)")
        }
    }
    
    private func executeShellCommand(launchPath: String, commands: [String]) throws -> Data? {
        let task: Process = Process()
        task.launchPath = launchPath
        task.arguments = commands
        
        let pipe: Pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        let handle = pipe.fileHandleForReading
        task.launch()
        return try handle.readToEnd()
    }
    
    private func parseProvisioningFile(at url: URL) -> ProvisioningProfile? {
        var profile: ProvisioningProfile? = nil
        do {
            let data = try Data(contentsOf: url)
            var decoder: CMSDecoder?
            CMSDecoderCreate(&decoder)
            if let decoder = decoder {
                guard CMSDecoderUpdateMessage(decoder, [UInt8](data), data.count) != errSecUnknownFormat else {
                    print("CMSDecoderUpdateMessage occur error.")
                    return profile
                }
                guard CMSDecoderFinalizeMessage(decoder) != errSecUnknownFormat else {
                    print("CMSDecoderFinalizeMessage occur error.")
                    return profile
                }
                var newData: CFData?
                CMSDecoderCopyContent(decoder, &newData)
                if let data = newData as Data? {
                    profile = try PropertyListDecoder().decode(ProvisioningProfile.self, from: data)
                    profile?.url = url
                }
            }
        } catch {
            print("parse provision file occur error: \(error)")
        }
        return profile
    }
}

