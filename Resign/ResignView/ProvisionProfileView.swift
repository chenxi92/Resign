//
//  ProvisionProfileView.swift
//  Resign
//
//  Created by 陈希 on 2021/12/14.
//

import SwiftUI

struct PasteText: View {
    let tag: String
    let message: String
    @State private var isShowAlert = false
    
    var body: some View {
        HStack {
            Text(tag + ": " + message)
            Button {
                let pasteBoard = NSPasteboard.general
                pasteBoard.declareTypes([.string], owner: nil)
                isShowAlert = pasteBoard.setString(message, forType: .string)
            } label: {
                Image(systemName: "doc.on.doc")
            }
        }
        .alert("Success", isPresented: $isShowAlert) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                Text("past successr")
            }
        }
    }
}

struct ProvisionProfileView: View {
    var profile: ProvisioningProfile
    @Binding var isDismiss: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Provision Profile Detail")
                    .font(.headline)
                Spacer()
                Button {
                    isDismiss.toggle()
                } label: {
                    Image(systemName: "xmark")
                }

            }
            Form {
                PasteText(tag: "Name", message: profile.name)
                PasteText(tag: "UUID", message: profile.uuid)
                PasteText(tag: "BundleID", message: profile.bundleIdentifier)
                PasteText(tag: "Team", message: profile.teamName)
                let teamId = profile.teamIdentifiers.joined(separator: "")
                PasteText(tag: "TeamID", message: teamId)
                PasteText(tag: "Expiration", message: profile.expirationDateString)
                
                if let certificate = profile.developerCertificates.first?.certificate {
                    PasteText(tag: "Sign", message: certificate.commmonName ?? "")
                }
                if let devices = profile.provisionedDevices {
                    VStack(spacing: 2) {
                        HStack {
                            Text("Device List:")
                            Spacer()
                        }
                        ScrollView {
                            ForEach(devices, id: \.self) { id in
                                HStack {
                                    Text(id)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
    
            }
            .textSelection(.enabled)
        }
        .padding()
    }
}
