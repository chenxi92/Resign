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
            
            Text(tag + ": ")
                .font(.headline)
            
            Text(message)
            
            Button {
                let pasteBoard = NSPasteboard.general
                pasteBoard.declareTypes([.string], owner: nil)
                isShowAlert = pasteBoard.setString(message, forType: .string)
            } label: {
                Image(systemName: "doc.on.doc")
            }
        }
        .sheet(isPresented: $isShowAlert, content: {
            ZStack {
                Text("Success!")
                    .font(.title3)
                    .padding()
                    .foregroundColor(Color.red)
            }
            .background(.white)
            .onTapGesture {
                isShowAlert.toggle()
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                    isShowAlert.toggle()
                }
            }
        })
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
                        .font(.headline.bold())
                        .scaleEffect(1.5)
                }
                .clipShape(Circle())
                .background(.clear)
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
                
                deviceList
            }
            .textSelection(.enabled)
        }
        .padding()
    }
    
    @ViewBuilder
    var deviceList: some View {
        if let devices = profile.provisionedDevices {
            VStack {
                HStack {
                    Text("Contain \(devices.count) Device")
                        .font(.headline)
                        .bold()
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
}
