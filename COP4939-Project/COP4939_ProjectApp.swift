//
//  COP4939_ProjectApp.swift
//  COP4939-Project
//
//  Created by Mikhail Plekunov on 11/27/23.
//

import SwiftUI

@main
struct COP4939_ProjectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(dataReceiverViewModel: StateObject(wrappedValue: DataReceiverViewModel(updateFrequency: 0.5)))
        }
    }
}
