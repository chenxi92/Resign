//
//  ContentView.swift
//  Resign
//
//  Created by peak on 2021/12/10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ResignView()
        }
        .frame(minWidth: 700, minHeight: 500)
        .toolbar {
            ToolbarItem {
                Link("Contact Me", destination:URL(string: "https://github.com/chenxi92")!)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
