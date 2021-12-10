//
//  InfoPlist.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import Foundation

public struct InfoPlist: Codable {
    
    enum CodingKeys: String, CodingKey {
        case bundleName                   = "CFBundleName"
        case displayName                  = "CFBundleDisplayName"
        case bundleVersionShort           = "CFBundleShortVersionString"
        case bundleVersion                = "CFBundleVersion"
        case bundleIdentifier             = "CFBundleIdentifier"
        case minOSVersion                 = "MinimumOSVersion"
        case xcodeVersion                 = "DTXcode"
        case xcodeBuild                   = "DTXcodeBuild"
        case sdkName                      = "DTSDKName"
        case buildSDK                     = "DTSDKBuild"
        case buildMachineOSBuild          = "BuildMachineOSBuild"
        case platformVersion              = "DTPlatformVersion"
        case supportedPlatforms           = "CFBundleSupportedPlatforms"
        case bundleExecutable             = "CFBundleExecutable"
        case bundleResourceSpecification  = "CFBundleResourceSpecification"
        case companionAppBundleIdentifier = "WKCompanionAppBundleIdentifier"
    }
    
    public var bundleName:                     String
    public var displayName:                    String
    public var bundleVersionShort:             String
    public var bundleVersion:                  String
    public var bundleIdentifier:               String
    public var minOSVersion:                   String
    public var xcodeVersion:                   String
    public var xcodeBuild:                     String
    public var sdkName:                        String
    public var buildSDK:                       String
    public var buildMachineOSBuild:            String
    public var platformVersion:                String
    public var supportedPlatforms:             [String]
    public var bundleExecutable:               String
    public var bundleResourceSpecification:    String?
    public var companionAppBundleIdentifier:   String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bundleName                   = try container.decode(String.self, forKey: .bundleName)
        displayName                  = try container.decode(String.self, forKey: .displayName)
        bundleVersionShort           = try container.decode(String.self, forKey: .bundleVersionShort)
        bundleVersion                = try container.decode(String.self, forKey: .bundleVersion)
        bundleIdentifier             = try container.decode(String.self, forKey: .bundleIdentifier)
        minOSVersion                 = try container.decode(String.self, forKey: .minOSVersion)
        xcodeVersion                 = try container.decode(String.self, forKey: .xcodeVersion)
        xcodeBuild                   = try container.decode(String.self, forKey: .xcodeBuild)
        sdkName                      = try container.decode(String.self, forKey: .sdkName)
        buildSDK                     = try container.decode(String.self, forKey: .buildSDK)
        buildMachineOSBuild          = try container.decode(String.self, forKey: .buildMachineOSBuild)
        platformVersion              = try container.decode(String.self, forKey: .platformVersion)
        supportedPlatforms           = try container.decode([String].self, forKey: .supportedPlatforms)
        bundleExecutable             = try container.decode(String.self, forKey: .bundleExecutable)
        bundleResourceSpecification  = try container.decodeIfPresent(String.self, forKey: .bundleResourceSpecification)
        companionAppBundleIdentifier = try container.decodeIfPresent(String.self, forKey: .companionAppBundleIdentifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bundleName, forKey: .bundleName)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(bundleVersionShort, forKey: .bundleVersionShort)
        try container.encode(bundleVersion, forKey: .bundleVersion)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(minOSVersion, forKey: .minOSVersion)
        try container.encode(xcodeVersion, forKey: .xcodeVersion)
        try container.encode(xcodeBuild, forKey: .xcodeBuild)
        try container.encode(sdkName, forKey: .sdkName)
        try container.encode(buildSDK, forKey: .buildSDK)
        try container.encode(buildMachineOSBuild, forKey: .buildMachineOSBuild)
        try container.encode(platformVersion, forKey: .platformVersion)
        try container.encode(supportedPlatforms, forKey: .supportedPlatforms)
        try container.encode(bundleExecutable, forKey: .bundleExecutable)
        try container.encodeIfPresent(bundleResourceSpecification, forKey: .bundleResourceSpecification)
        try container.encodeIfPresent(companionAppBundleIdentifier, forKey: .companionAppBundleIdentifier)
    }
}
