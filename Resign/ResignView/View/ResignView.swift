//
//  ResignView.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import SwiftUI
import UniformTypeIdentifiers

struct ResignView: View {
    @ObservedObject private var vm = ResignViewModel()

    @State private var selectedIPAFilePath = ""
    @State private var alertInfo: AlertInfo?
    @State private var output: ResignOutput?
    @State private var isChangeInfoPlist = false
    @State private var isShowProvisionProfileDetail = false
    
    var body: some View {
        VStack {
            inputForm
            
            HStack {
                Text("Log Info")
                    .font(.headline)
                Spacer()
                resignButton
            }
            .padding(.vertical)
            
            logView            
        }
        .padding()
        .alert(item: $alertInfo) { info in
            Alert(title: Text(info.title), message: Text(info.message))
        }
        .sheet(isPresented: $isShowProvisionProfileDetail, content: {
            if let profile = vm.selectedProvisionFile() {
                ProvisionProfileView(profile: profile, isDismiss: $isShowProvisionProfileDetail)
            }
        })
        .task {
            vm.loadProvisioningFiles()
            vm.loadCertificates()
        }
    }
    
    var logView: some View {
        VStack {
            ScrollView {
                ForEach(vm.logs, id: \.self) { message in
                    HStack {
                        Text(message)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var inputForm: some View {
        Form {
            ipaFileSelect
            certificateSelect
            provisionFileSelect
            isChangeInfoPlistUI
        }
    }
    
    @ViewBuilder var isChangeInfoPlistUI: some View {
        Toggle("Change Info.plist", isOn: $isChangeInfoPlist.animation(.spring()))
            .toggleStyle(.switch)
            .onChange(of: isChangeInfoPlist) { newValue in
                if newValue == false {
                    vm.displayName = ""
                    vm.buildVersion = ""
                    vm.buildVersionShort = ""
                }
            }
        
        if isChangeInfoPlist {
            TextField("Display Name", text: $vm.displayName, prompt: Text("Change DisplayName?"))
            TextField("Build Version", text: $vm.buildVersion, prompt: Text("Change BuildVersion?"))
            TextField("Shot Build Version", text: $vm.buildVersionShort, prompt: Text("Change BuildVersionShort?"))
        }
    }
    
    var ipaFileSelect: some View {
        HStack {
            TextField(text: $selectedIPAFilePath, prompt: Text("/path/to/xxx.ipa")) {
                Text("Select File")
            }
            Button {
                selectIpa()
            } label: {
                Text("Browse")
            }
        }
    }
    
    var certificateSelect: some View {
        Picker("Certificate Name", selection: $vm.selectedCertificateName) {
            ForEach(vm.certificateNames, id: \.self) { name in
                Text(name)
            }
        }
    }
    
    var provisionFileSelect: some View {
        HStack(spacing: 0) {
            Picker("Provisioning Profile", selection: $vm.selectedProvisionFileUUID) {
                Section("Valid") {
                    ForEach(vm.provisioningProfiles.filter {$0.expirationDate >= Date() }) { profile in
                        Text(profile.displayName)
                    }
                }
                
                Section("Invalid") {
                    ForEach(vm.provisioningProfiles.filter {$0.expirationDate < Date() }) { profile in
                        Text(profile.displayName)
                            .foregroundColor(.teal)
                    }
                }
            }
            .onChange(of: vm.selectedProvisionFileUUID) { newValue in
                if let profile = vm.selectedProvisionFile() {
                    vm.selectedCertificateName = profile.latestCertificate
                } else {
                    // not found associated certificate
                    vm.selectedCertificateName = ""
                }
            }
            
            if !vm.selectedCertificateName.isEmpty {
                Button {
                    isShowProvisionProfileDetail.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .clipShape(Circle())
            }
        }
    }

    var resignButton: some View {
        Button {
            doResign()
        } label: {
            Text("Resign")
        }
        .buttonStyle(.neumorphic)
    }
    
    func selectIpa() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .cancel {
            return
        }
        if panel.runModal() == .OK, let url = panel.url, url.pathExtension == "ipa" {
            self.selectedIPAFilePath = url.path
            self.output = ResignOutput(from: url)
        } else {
            alertInfo = AlertInfo(title: "File type error", message: "Please select ipa file")
        }
    }
    
    func doResign() {
        guard isValidParameter() else {
            return
        }
        guard let output = output else {
            return
        }
        
        DispatchQueue.main.async {
            vm.sign(at: self.selectedIPAFilePath, output: output)
        }
    }
    
    func isValidParameter() -> Bool {
        if self.selectedIPAFilePath.isEmpty || vm.selectedCertificateName.isEmpty || vm.selectedProvisionFileUUID.isEmpty {
            alertInfo = AlertInfo(title: "Error", message: "Parameter is empty")
            return false
        }
        
        if let certificate = vm.selectedProvisionFile()?.developerCertificates.first?.certificate, certificate.commmonName != vm.selectedCertificateName
        {
            alertInfo = AlertInfo(title: "Mismatch", message: "Certificate not match the provision file \(certificate.commmonName ?? "")")
            return false
        }
        return true
    }
}

struct ResignView_Previews: PreviewProvider {
    static var previews: some View {
        ResignView()
    }
}
