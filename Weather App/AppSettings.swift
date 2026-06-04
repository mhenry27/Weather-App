//
//  AppSettings.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/3/26.
//

import Foundation
import SwiftUI
import Combine

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case fahrenheit = "Fahrenheit"
    case celsius = "Celsius"

    var id: String { rawValue }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case purple = "Purple"
    case green = "Green"
    case pink = "Pink"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .green: return .green
        case .pink: return .pink
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case spanish = "Spanish"
    case french = "French"
    
    var id: String { rawValue }
}

class AppSettings: ObservableObject {
        @Published var severeAlerts = false
        @Published var dailyWeatherNotifications = false
        @Published var forecastDays = 5
        @Published var temperatureUnit: TemperatureUnit = .fahrenheit
        @Published var theme: AppTheme = .blue
        @Published var language: AppLanguage = .english
}

