//
//  CityView.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/1/26.
//

import SwiftUI
import MapKit
import Charts

struct CityView: View {
    @EnvironmentObject var settings: AppSettings
    
    let cityName: String
    
    @State private var searchedCity = "Search for a city"
    
    @State private var weather: WeatherResponse?
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    @State private var exchangeRate = "--"
    @State private var fromCurrency = "USD"
    @State private var toCurrency = "USD"

    
    
    let currencyService = CurrencyService()
    
    let weatherService = WeatherService()
    
    var body: some View {
        ZStack {
            settings.theme.color.opacity(0.15)
                .ignoresSafeArea()
            
            
            
            if isLoading {
                ProgressView("Loading weather...")
            } else if let weather = weather {
                ScrollView {
                    VStack(spacing: 22) {
                        Text(weather.location.name)
                            .font(.largeTitle)
                            .bold()
                        
                        Text(temp(weather.current.temp_f, weather.current.temp_c))
                            .font(.system(size:50))
                        
                        Text(weather.current.condition.text)
                            .font(.title3)
                        
                        if let today = weather.forecast.forecastday.first {
                            HStack {
                                Text("High: \(temp(today.day.maxtemp_f, today.day.maxtemp_c))")
                                    .fontWeight(.semibold)
                                Text("Low: \(temp(today.day.mintemp_f, today.day.mintemp_c))")
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        if let today = weather.forecast.forecastday.first {
                            horizontalForecast(today.hour)
                        }
                        
                        weeklyForecastBox(weather.forecast.forecastday)
                        
                        if let today = weather.forecast.forecastday.first {
                            TemperatureChartView(hours: today.hour)
                        }
                        
                        
                        
                        detailsGrid(weather)
                        
                        seasonalOutlookCard()
                        
                    }
                    .padding()
                }
            } else {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .padding()
            }
            
            
        }
        .task {
            await loadWeather()
        }
    }
    
    
    func horizontalForecast(_ hours: [HourData]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(Array(hours.prefix(24)), id: \.id) { hour in
                    VStack(spacing: 6) {
                        Text(shortTime(hour.time))
                            .font(.caption)

                        AsyncImage(url: URL(string: "https:\(hour.condition.icon)")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 28, height: 28)

                        Text(temp(hour.temp_f, hour.temp_c))
                            .font(.caption)
                            .bold()
                    }
                    .frame(width: 70, height: 100)
                    .background(settings.theme.color.opacity(0.15))
                    .cornerRadius(15)
                }
            }
        }
    }
    
    func weeklyForecastBox(_ days: [ForecastDay]) -> some View {
        VStack(spacing: 15) {
            ForEach(days, id: \.date) { day in
                
                HStack {
                    Text(dayOfWeek(from: day.date, short: false))
                        .frame(width: 100, alignment: .leading)
                    
                    
                    AsyncImage(url: URL(string: "https:\(day.day.condition.icon)")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 35, height: 35)
                    
                    Text(day.day.condition.text)
                    
                    Spacer()
                    
                    Text("H: \(temp(day.day.maxtemp_f, day.day.maxtemp_c))")
                    Text("L: \(temp(day.day.mintemp_f, day.day.mintemp_c))")
                    
                    
                }
                Divider()
            }
        }
        .padding()
        .background(settings.theme.color.opacity(0.15))
        .cornerRadius(20)
    }
    
    func detailsGrid(_ weather: WeatherResponse) -> some View {
        VStack(spacing: 15) {
            if let today = weather.forecast.forecastday.first {
                HStack {
                    detailBox(title: "Sunrise", value: today.astro.sunrise)
                    detailBox(title: "Sunset", value: today.astro.sunset)
                }
            }
            
            HStack {
                uvDetailBox(uvIndex: weather.current.uv)
                detailBox(title: "Feels like", value: "\(weather.current.feelslike_f)°")
                //detailBox(title: "Precipitation", value: "\(weather.current.precipitation)")
            }
            
            HStack {
                detailBox(title: "Wind", value: "\(weather.current.wind_mph)")
                detailBox(title: "Humidity", value: "\(weather.current.humidity)%")
            }
            
            HStack {
                VStack {
                    NavigationLink {
                        PackingView(weather: weather)
                    } label: {
                        VStack {
                            Text("Packing & Planning ☂️🕶️🧥")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Text("Tap for outfit ideas →")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .foregroundColor(.black)
                            
                        }
                    }
                    
                }.padding()
                    .frame(maxWidth: .infinity, minHeight: 105, alignment: .leading)
                    .background(settings.theme.color.opacity(0.15))
                    .cornerRadius(18)
                
                VStack {
                    currencyCard()
                    
                }
                
            }
            
        }
    }
    
    func seasonalOutlookCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seasonal Outlook")
                .font(.headline)

            seasonalRow(monthsAhead: 1)
            seasonalRow(monthsAhead: 3)
            seasonalRow(monthsAhead: 6)

            Text("Based on typical seasonal patterns, not a live long-range forecast.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(settings.theme.color.opacity(0.15))
        .cornerRadius(18)
    }
    
    func seasonalRow(monthsAhead: Int) -> some View {
        let date = Calendar.current.date(byAdding: .month, value: monthsAhead, to: Date()) ?? Date()
        let month = Calendar.current.component(.month, from: date)

        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(monthsAhead) Month\(monthsAhead == 1 ? "" : "s") Ahead")
                    .bold()

                Spacer()

                Text(monthName(from: date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("\(seasonIcon(for: month)) \(seasonName(for: month))")
                .font(.callout)

            Text(seasonAdvice(for: month))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    func seasonName(for month: Int) -> String {
        switch month {
        case 12, 1, 2:
            return "Cooler weather"
        case 3, 4, 5:
            return "Mild spring weather"
        case 6, 7, 8:
            return "Warm summer weather"
        case 9, 10, 11:
            return "Mild fall weather"
        default:
            return "Seasonal weather"
        }
    }

    func seasonIcon(for month: Int) -> String {
        switch month {
        case 12, 1, 2:
            return "❄️"
        case 3, 4, 5:
            return "🌷"
        case 6, 7, 8:
            return "☀️"
        case 9, 10, 11:
            return "🍂"
        default:
            return "🌤️"
        }
    }
    
    func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }

    func seasonAdvice(for month: Int) -> String {
        switch month {
        case 12, 1, 2:
            return "Expect colder temperatures. Pack layers, a coat, and warm shoes."
        case 3, 4, 5:
            return "Weather may be mild but changeable. Bring light layers and rain gear."
        case 6, 7, 8:
            return "Likely warmer weather. Pack breathable clothes, sunscreen, and water."
        case 9, 10, 11:
            return "Expect cooler mornings and evenings. Bring a jacket or sweater."
        default:
            return "Check closer to your trip for more accurate conditions."
        }
    }
    
    func shortTime(_ timeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "ha"

        if let date = inputFormatter.date(from: timeString) {
            return outputFormatter.string(from: date)
        }

        return timeString
    }
    
    func uvDetailBox(uvIndex: Double) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("UV Index")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(uvIndex.formatted(.number.precision(.fractionLength(1))))")
                .font(.title3)
                .bold()

            Text(uvRiskLabel(uvIndex))
                .font(.caption2)
                .bold()
                .foregroundColor(uvRiskColor(uvIndex))

            ProgressView(value: min(uvIndex, 11), total: 11)
                .tint(uvRiskColor(uvIndex))
        }
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .padding()
        .background(settings.theme.color.opacity(0.15))
        .cornerRadius(18)
    }
    
    func uvRiskLabel(_ uvIndex: Double) -> String {
        switch uvIndex {
        case 0..<3:
            return "Low Risk"
        case 3..<6:
            return "Moderate Risk"
        case 6..<8:
            return "High Risk"
        case 8..<11:
            return "Very High Risk"
        default:
            return "Extreme Risk"
        }
    }

    func uvRiskColor(_ uvIndex: Double) -> Color {
        switch uvIndex {
        case 0..<3:
            return .green
        case 3..<6:
            return .yellow
        case 6..<8:
            return .orange
        case 8..<11:
            return .red
        default:
            return .purple
        }
    }
    
    func detailBox(title: String, value: String) -> some View {
        VStack(alignment: .leading){
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title3)
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(settings.theme.color.opacity(0.15))
        .cornerRadius(18)
    }
    
    func currencyCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exchange Rate")
                .font(.caption)
                .fontWeight(.semibold)

            Text("1 \(fromCurrency) = \(exchangeRate) \(toCurrency)")
                .font(.caption)
                .bold()

            Text("Based on the viewed city's country")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        .padding()
        .background(settings.theme.color.opacity(0.15))
        .cornerRadius(18)
    }
    
    func currencyCode(for country: String) -> String {
        switch country {
        case "United States":
            return "USD"
        case "United Kingdom":
            return "GBP"
        case "France", "Germany", "Italy", "Spain", "Netherlands", "Greece":
            return "EUR"
        case "Canada":
            return "CAD"
        case "Mexico":
            return "MXN"
        case "Japan":
            return "JPY"
        case "China":
            return "CNY"
        case "Australia":
            return "AUD"
        default:
            return "USD"
        }
    }
    
    func loadWeather() async {
        do {
            isLoading = true
            weather = try await weatherService.getWeather(for: cityName, days: settings.forecastDays)
            
            if let weather = weather {
                fromCurrency = "USD"
                toCurrency = currencyCode(for: weather.location.country)

                let rate = try await currencyService.getExchangeRate(
                    from: fromCurrency,
                    to: toCurrency
                )

                exchangeRate = String(format: "%.2f", rate.conversion_rate)
                
                print(weather.location.country)
            }
            
            isLoading = false
            
            
        } catch {
            errorMessage = "Could not load weather for \(cityName)"
            isLoading = false
            print(error)
        }
    }
    
    func dayOfWeek(from dateString: String, short: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = short ? "E" : "EEEE"
        return formatter.string(from: date)
    }
    
    func temp(_ fahrenheit: Double, _ celsius: Double) -> String {
        if settings.temperatureUnit == .fahrenheit {
            return "\(Int(fahrenheit))°"
        } else {
            return "\(Int(celsius))°"
        }
    }
    
    func videoName(for condition: String) -> String {
        let lower = condition.lowercased()

        if lower.contains("sunny") || lower.contains("clear") {
            return "sunny"
        } else if lower.contains("cloud") || lower.contains("overcast") {
            return "cloudy"
        } else if lower.contains("rain") || lower.contains("drizzle") {
            return "rain"
        } else if lower.contains("snow") || lower.contains("sleet") {
            return "snow"
        } else if lower.contains("thunder") || lower.contains("storm") {
            return "storm"
        } else {
            return "defaultWeather"
        }
    }
}

struct TemperatureChartView: View {
    @EnvironmentObject var settings: AppSettings

    let hours: [HourData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hourly Temperature")
                .font(.headline)

            Chart(hours.prefix(12)) { hour in
                LineMark(
                    x: .value("Time", shortTime(hour.time)),
                    y: .value("Temperature", temperatureValue(hour))
                )

                PointMark(
                    x: .value("Time", shortTime(hour.time)),
                    y: .value("Temperature", temperatureValue(hour))
                )
            }
            .frame(height: 180)
        }
        .padding()
        .background(settings.theme.color.opacity(0.15))
        .cornerRadius(20)
    }

    func temperatureValue(_ hour: HourData) -> Double {
        if settings.temperatureUnit == .fahrenheit {
            return hour.temp_f
        } else {
            return hour.temp_c
        }
    }

    func shortTime(_ timeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "ha"

        if let date = inputFormatter.date(from: timeString) {
            return outputFormatter.string(from: date)
        }

        return timeString
    }
    
    
    
    
}



struct UVRiskMeterView: View {
    let uvIndex: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("UV Risk")
                .font(.headline)

            Text(riskLabel)
                .font(.title2)
                .bold()

            ProgressView(value: min(uvIndex, 11), total: 11)
                .tint(riskColor)

            Text("UV Index: \(uvIndex.formatted(.number.precision(.fractionLength(1))))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
    }

    var riskLabel: String {
        switch uvIndex {
        case 0..<3:
            return "Low"
        case 3..<6:
            return "Moderate"
        case 6..<8:
            return "High"
        case 8..<11:
            return "Very High"
        default:
            return "Extreme"
        }
    }

    var riskColor: Color {
        switch uvIndex {
        case 0..<3:
            return .green
        case 3..<6:
            return .yellow
        case 6..<8:
            return .orange
        case 8..<11:
            return .red
        default:
            return .purple
        }
    }
}

#Preview {
        CityView(cityName: "New York")
        .environmentObject(AppSettings())
}


