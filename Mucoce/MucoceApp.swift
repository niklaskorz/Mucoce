//
//  MucoceApp.swift
//  Mucoce
//
//  Created by Niklas Korz on 21.04.23.
//

import SwiftUI
import ScriptingBridge

@main
struct MucoceApp: App {
    var body: some Scene {
        MenuBarExtra("Mucoce", systemImage: "music.note") {
            ContentView()
        }.menuBarExtraStyle(.window)
    }
}
