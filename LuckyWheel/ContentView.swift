//
//  ContentView.swift
//  LuckyWheel
//
//  Created by Ben Siebert on 28.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var items: [String] = []
    var body: some View {
        TabView {
            Tab {
                NavigationStack {
                    MainView()
                }
            } label: {
                Label("Fortune Wheel", systemImage: "wand.and.stars")
            }
            Tab {
                UAUICommonInfoView(title: "LuckyWheel", logoName: "Logo", version: "1.0", libraries: [], content: {
                })
            } label: {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    ContentView()
}
