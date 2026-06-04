//
//  Weather_AppApp.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/1/26.
//

import SwiftUI

@main
struct Weather_AppApp: App {
    @StateObject private var settings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
