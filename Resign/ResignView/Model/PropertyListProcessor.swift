//
//  PropertyListProcessor.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import Foundation

public final class PropertyListProcessor {
    public var content: InfoPlist
    public var plistFilePath: String
    public var dictionaryContent: NSMutableDictionary
    
    init(with path: String) {
        dictionaryContent = NSMutableDictionary(contentsOfFile: path) ?? NSMutableDictionary()
        plistFilePath = path
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = PropertyListDecoder()
        self.content = try! decoder.decode(InfoPlist.self, from: data)
    }
    
    func modifyBundleIdentifier(with new: String?) {
        guard let new = new, !new.isEmpty else {
            return
        }
        content.bundleIdentifier = new
        dictionaryContent.setObject(new, forKey: InfoPlist.CodingKeys.bundleIdentifier.rawValue as NSCopying)
        if let _ = content.companionAppBundleIdentifier {
            dictionaryContent.setObject(new, forKey: InfoPlist.CodingKeys.companionAppBundleIdentifier.rawValue as NSCopying)
        }
        dictionaryContent.write(toFile: plistFilePath, atomically: true)
    }
    
    func modifyBundleVersionShort(with new: String?) {
        guard let new = new, !new.isEmpty else {
            return
        }
        content.bundleVersionShort = new
        dictionaryContent.setObject(new, forKey: InfoPlist.CodingKeys.bundleVersionShort.rawValue as NSCopying)
        dictionaryContent.write(toFile: plistFilePath, atomically: true)
    }
    
    func modifyBundleVersion(with new: String?) {
        guard let new = new, !new.isEmpty else {
            return
        }
        content.bundleVersion = new
        dictionaryContent.setObject(new, forKey: InfoPlist.CodingKeys.bundleVersion.rawValue as NSCopying)
        dictionaryContent.write(toFile: plistFilePath, atomically: true)
    }
    
    func modifyDisplayName(with new: String?) {
        guard let new = new, !new.isEmpty else {
            return
        }
        content.displayName = new
        dictionaryContent.setObject(new, forKey: InfoPlist.CodingKeys.displayName.rawValue as NSCopying)
        dictionaryContent.write(toFile: plistFilePath, atomically: true)
    }
}
