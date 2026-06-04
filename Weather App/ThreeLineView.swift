//
//  ThreeLineView.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/3/26.
//

import SwiftUI

struct ThreeLineView: View {
    @EnvironmentObject var settings: AppSettings
    var body: some View {
        ZStack {
            settings.theme.color.opacity(0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                    Text("Extras")
                        .font(.title)
                        .bold()
                
                List {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            
        }
    }
}

#Preview {
    ThreeLineView()
        .environmentObject(AppSettings())
}
