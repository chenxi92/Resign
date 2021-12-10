//
//  CertificateWrapper.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import Foundation

public struct CertificateWrapper: Codable, Equatable {
    let data: Data
    let certificate: Certificate?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        data = try container.decode(Data.self)
        certificate = try Certificate.parse(from: data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
    
    public var base64Encoding: String {
        data.base64EncodedString()
    }
}

public struct Certificate: Encodable, Equatable {
    
    public enum InitError: Error, Equatable {
        case failedToFindValue(key: String)
        case failedToCastValue(expected: String, actual: String)
        case failedToFindLabel(label: String)
    }
    
    enum ParseError: Error {
        case failedToCreateCertificate
        case failedToCreateTrust
        case failedToExtractValues
    }
    
    public let notValidBefore: Date
    public let notValidAfter: Date
    
    public let issuerCommonName: String
    public let issuerCountryName: String
    public let issuerOrgName: String
    public let issuerOrgUnit: String
    
    public let serialNumber: String
    public let fingerprints: [String: String]
    
    public let commmonName: String?
    public let countryName: String
    public let orgName: String?
    public let orgUnit: String
    
    static func parse(from data: Data) throws -> Certificate {
        let certificate = try getSecCertificate(data: data)
        return try parse(from: certificate)
    }
    
    private static func parse(from certificate: SecCertificate) throws -> Certificate {
        var error: Unmanaged<CFError>? = nil
        let values = SecCertificateCopyValues(certificate, nil, &error)
        if let e = error {
            throw e.takeRetainedValue() as Error
        }
        
        guard let valuesDict = values as? [CFString: Any] else {
            throw ParseError.failedToExtractValues
        }
        
        var commonName: CFString?
        SecCertificateCopyCommonName(certificate, &commonName)
        
        return try Certificate(results: valuesDict, commonName: commonName as String?)
    }
    
    public init(results: [CFString: Any], commonName: String?) throws {
        self.commmonName = commonName
        
        notValidBefore = try Certificate.getValue(for: kSecOIDX509V1ValidityNotBefore, from: results)
        notValidAfter = try Certificate.getValue(for: kSecOIDX509V1ValidityNotAfter, from: results)
        
        let issuerName: [[CFString: Any]] = try Certificate.getValue(for: kSecOIDX509V1IssuerName, from: results)
        
        issuerCommonName = try Certificate.getValue(for: kSecOIDCommonName, fromDict: issuerName)
        issuerCountryName = try Certificate.getValue(for: kSecOIDCountryName, fromDict: issuerName)
        issuerOrgName = try Certificate.getValue(for: kSecOIDOrganizationName, fromDict: issuerName)
        issuerOrgUnit = try Certificate.getValue(for: kSecOIDOrganizationalUnitName, fromDict: issuerName)
        
        serialNumber = try Certificate.getValue(for: kSecOIDX509V1SerialNumber, from: results)
     
        let shaFingerprints: [[CFString: Any]] = try Certificate.getValue(for: "Fingerprints" as CFString, from: results)
        let sha1Fingerprint: Data   = try Certificate.getValue(for: "SHA-1" as CFString, fromDict: shaFingerprints)
        let sha256Fingerprint: Data = try Certificate.getValue(for: "SHA-256" as CFString, fromDict: shaFingerprints)
        
        let sha1   = sha1Fingerprint.map { String(format: "%02x", $0) }.joined()
        let sha256 = sha256Fingerprint.map { String(format: "%02x", $0) }.joined()
        
        self.fingerprints = ["SHA-1":   sha1.uppercased(),
                             "SHA-256": sha256.uppercased()]
        
        let subjectName: [[CFString: Any]] = try Certificate.getValue(for: kSecOIDX509V1SubjectName, from: results)
        
        countryName = try Certificate.getValue(for: kSecOIDCountryName, fromDict: subjectName)
        orgName = try? Certificate.getValue(for: kSecOIDOrganizationName, fromDict: subjectName)
        orgUnit = try Certificate.getValue(for: kSecOIDOrganizationalUnitName, fromDict: subjectName)
    }
    
    private static func getSecCertificate(data: Data) throws -> SecCertificate {
        guard let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData) else {
            throw ParseError.failedToCreateCertificate
        }
        return certificate
    }
    
    private static func validate(certificate: SecCertificate) -> Bool {
        let oids: [CFString] = [
            kSecOIDX509V1ValidityNotAfter,
            kSecOIDX509V1ValidityNotBefore,
            kSecOIDCommonName
        ]
        let values = SecCertificateCopyValues(certificate, oids as CFArray?, nil) as? [String: [String: AnyObject]]
        
        return relativeTime(froOID: kSecOIDX509V1ValidityNotAfter, values: values) >= 0.0
            && relativeTime(froOID: kSecOIDX509V1ValidityNotBefore, values: values) <= 0.0
    }
    
    private static func relativeTime(froOID oid: CFString, values: [String: [String: AnyObject]]?) -> Double {
        guard let dateNumber = values?[oid as String]?[kSecPropertyKeyValue as String] as? NSNumber else {
            return 0.0
        }
        return dateNumber.doubleValue - CFAbsoluteTimeGetCurrent()
    }
    
    static func getValue<T>(for key: CFString, from values: [CFString: Any]) throws -> T {
        let node = values[key] as? [CFString: Any]
        
        guard let rawValue = node?[kSecPropertyKeyValue] else {
            throw InitError.failedToFindValue(key: key as String)
        }
        
        if T.self is Date.Type {
            if let value = rawValue as? TimeInterval {
                // Force unwrap here is fine as we've validated the type above
                return Date(timeIntervalSinceReferenceDate: value) as! T
            }
        }
        
        guard let value = rawValue as? T else {
            let type = (node?[kSecPropertyKeyType] as? String) ?? String(describing: rawValue)
            throw InitError.failedToCastValue(expected: String(describing: T.self), actual: type)
        }
        
        return value
    }
    
    static func getValue<T>(for key: CFString, fromDict values: [[CFString: Any]]) throws -> T {
        guard let results = values.first(where: { ($0[kSecPropertyKeyLabel] as? String) == (key as String) }) else {
            throw InitError.failedToFindLabel(label: key as String)
        }
        
        guard let rawValue = results[kSecPropertyKeyValue] else {
            throw InitError.failedToFindValue(key: key as String)
        }
        
        guard let value = rawValue as? T else {
            let type = (results[kSecPropertyKeyType] as? String) ?? String(describing: rawValue)
            throw InitError.failedToCastValue(expected: String(describing: T.self), actual: type)
        }
        
        return value
    }
}
