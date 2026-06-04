//
//  SettingsView.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/2/26.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        ZStack {
            settings.theme.color.opacity(0.12)
                .ignoresSafeArea()
            
            Form {
                Section("Notifications") {
                    Toggle("Severe Weather Alerts", isOn: $settings.severeAlerts)
                        .onChange(of: settings.severeAlerts) {
                            if settings.severeAlerts {
                                requestNotifications()
                            }
                        }

                    Toggle("Daily Weather Notification", isOn: $settings.dailyWeatherNotifications)
                        .onChange(of: settings.dailyWeatherNotifications) {
                            if settings.dailyWeatherNotifications {
                                requestNotifications()
                            }
                        }
                }
                .listRowBackground(Color.white.opacity(0.70))
                

                Section("Forecast") {
                    Stepper("Forecast Days: \(settings.forecastDays)", value: $settings.forecastDays, in: 1...10)
                }
                .listRowBackground(Color.white.opacity(0.70))

                Section("Temperature Unit") {
                    Picker("Unit", selection: $settings.temperatureUnit) {
                            ForEach(TemperatureUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.white.opacity(0.70))

                Section("Color Theme") {
                    Picker("Theme", selection: $settings.theme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                    }
                }
                .listRowBackground(Color.white.opacity(0.70))

                Section("Language") {
                    Picker("Language", selection: $settings.language) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.rawValue).tag(language)
                            }
                    }
                }
                .listRowBackground(Color.white.opacity(0.70))
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
        }
        
    }
    
        
    func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Notifications granted: \(granted)")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
