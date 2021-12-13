//
//  FileManager+ProvisionProfile.swift
//  Resign
//
//  Created by peak on 2021/12/13.
//

import Foundation


extension FileManager {
    func availableProvisionProfile() -> [URL] {
        var availableFiles = [URL]()
        /// Delete App Sandbox in Singing & Capabilities to access the perimision
        let profilesDirectoryURL = self.homeDirectoryForCurrentUser.appendingPathComponent("Library/MobileDevice/Provisioning Profiles")
        let enumerator = self.enumerator(at: profilesDirectoryURL,
                                                includingPropertiesForKeys: [.nameKey],
                                                options: .skipsHiddenFiles,
                                                errorHandler: nil)
        while let url = enumerator?.nextObject() as? URL {
            if url.pathExtension == "mobileprovision" {
                availableFiles.append(url)
            }
        }
        return availableFiles
    }
}
