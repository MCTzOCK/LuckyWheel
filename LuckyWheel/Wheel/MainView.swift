//
//  MainView.swift
//  LuckyWheel
//
//  Created by Ben Siebert on 28.03.26.
//

import SwiftUI

struct MainView: View {
    
    @State private var items: [String] = []
    @State private var selection: Int = 0
    
    var body: some View {
        VStack {
            if selection == 0 {
                PremiumWheelConfigView(items: $items)
            } else if selection == 1 {
                FortuneWheelView(items: $items, onResult: {result in })
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $selection) {
                    Text("List").tag(0)
                    Text("Fortune Wheel").tag(1)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    MainView()
}
