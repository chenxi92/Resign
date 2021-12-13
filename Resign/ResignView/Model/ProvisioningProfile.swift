//
//  ProvisioningProfile.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import Foundation

public struct ProvisioningProfile: Equatable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case appIdName = "AppIDName"
        case applicationIdentifierPrefixs = "ApplicationIdentifierPrefix"
        case creationDate = "CreationDate"
        case platforms = "Platform"
        case developerCertificates = "DeveloperCertificates"
        case entitlements = "Entitlements"
        case expirationDate = "ExpirationDate"
        case name = "Name"
        case provisionedDevices = "ProvisionedDevices"
        case teamIdentifiers = "TeamIdentifier"
        case teamName = "TeamName"
        case timeToLive = "TimeToLive"
        case uuid = "UUID"
        case version = "Version"
    }
    
    public var url: URL?
    
    public var appIdName: String
    
    /// The App ID prefix (or Bundle Seed ID) generated when you create a new App ID
    public var applicationIdentifierPrefixs: [String]
    
    public var creationDate: Date
    
    public var platforms: [String]
    
    public var developerCertificates: [CertificateWrapper]
    
    public var entitlements: [String: PropertyListDictionaryValue]
    
    /// The date in which this profile will expire
    public var expirationDate: Date
    
    public var name: String
    
    /// An array of device UUIDs that are provisioned on this profile
    public var provisionedDevices: [String]?
    
    public var teamIdentifiers: [String]
    
    /// The name of the team in which this profile belongs to
    public var teamName: String
    
    public var timeToLive: Int
    
    /// The profile's unique identifier, usually used to reference the profile from within Xcode
    public var uuid: String
    
    public var version: Int
}

extension ProvisioningProfile {
    public var isExpired: Bool {
        let now = Date()
        return expirationDate <= now
    }
    
    public var bundleIdentifier: String {
        switch entitlements["application-identifier"] {
        case .string(let value):
            let prefixIndex = value.index(value.startIndex, offsetBy: teamIdentifiers.first!.count + 1)
            return String(value[prefixIndex...])
        default:
            return ""
        }
    }
    
    var displayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expiry = "\(dateFormatter.string(from: expirationDate))"
        return "\(name) (Expired: \(expiry))"
    }
    
    var expirationDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: expirationDate)
    }
}

extension ProvisioningProfile: Identifiable {
    public var id: String {
        uuid
    }
}

//extension ProvisioningProfile {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        appIdName = try container.decode(String.self, forKey: .appIdName)
//        applicationIdentifierPrefix = try container.decode([String].self, forKey: .applicationIdentifierPrefixs)
//        creationDate = try container.decode(Date.self, forKey: .creationDate)
//        platforms = try container.decode([String].self, forKey: .platforms)
//        developerCertificates = try container.decode([CertificateWrapper].self, forKey: .developerCertificates)
//        entitlements = try container.decode([String: PropertyListDictionaryValue].self, forKey: .entitlements)
//        expirationDate = try container.decode(Date.self, forKey: .expirationDate)
//        name = try container.decode(String.self, forKey: .name)
//        provisionedDevices = try container.decodeIfPresent([String].self, forKey: .provisionedDevices)
//        teamIdentifier = try container.decode([String].self, forKey: .teamIdentifiers)
//        teamName = try container.decode(String.self, forKey: .teamName)
//        timeToLive = try container.decode(Int.self, forKey: .timeToLive)
//        uuid = try container.decode(String.self, forKey: .uuid)
//        version = try container.decode(Int.self, forKey: .version)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encode(appIdName, forKey: .appIdName)
//        try container.encode(applicationIdentifierPrefix, forKey: .applicationIdentifierPrefixs)
//        try container.encode(creationDate, forKey: .creationDate)
//        try container.encode(platforms, forKey: .platforms)
//        try container.encode(developerCertificates, forKey: .developerCertificates)
//        try container.encode(entitlements, forKey: .entitlements)
//        try container.encode(expirationDate, forKey: .expirationDate)
//        try container.encode(name, forKey: .name)
//        try container.encodeIfPresent(provisionedDevices, forKey: .provisionedDevices)
//        try container.encode(teamIdentifier, forKey: .teamIdentifiers)
//        try container.encode(teamName, forKey: .teamName)
//        try container.encode(timeToLive, forKey: .timeToLive)
//        try container.encode(uuid, forKey: .uuid)
//        try container.encode(version, forKey: .version)
//    }
//}
