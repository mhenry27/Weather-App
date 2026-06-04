//
//  PackingView.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/2/26.
//

import SwiftUI

struct PackingView: View {
        let weather: WeatherResponse
        
        var body: some View {
            ZStack {
                Color.blue.opacity(0.12)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Packing & Planning")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Outfit Recommendation")
                            .font(.headline)
                        
                        Text(outfitRecommendation())
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(18)
                        
                        Text("Today's Tips")
                            .font(.headline)
                        todayTipsCard()
                        
                        Text("Weekend Planner")
                            .font(.headline)
                        weekendPlannerCard()
                        
                        Text("Packing List")
                            .font(.headline)
                        
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(packingItems(), id: \.self) { item in
                                Label(item, systemImage: "")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(18)
                        
                        if let rainTime = umbrellaTime() {
                            Text("☂️ Bring an umbrella after \(rainTime)")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(18)
                        }
                        
                        
                        
                        
                        Text("Travel Advice")
                            .font(.headline)
                        travelAdviceCard()
                    }
                    .padding()
                }
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
    
    func umbrellaTime() -> String? {
        guard let today = weather.forecast.forecastday.first else {
            return nil
        }

        if let rainyHour = today.hour.first(where: {
            $0.condition.text.lowercased().contains("rain")
        }) {
            return shortTime(rainyHour.time)
        }

        return nil
    }
    
    func outfitRecommendation() -> String {
        

        let temp = weather.current.temp_f

        switch temp {
        case ..<40:
            return "Heavy coat, sweater, boots"
        case 40..<60:
            return "Jacket, jeans, sneakers"
        case 60..<75:
            return "Light layer and pants"
        case 75..<90:
            return "T-shirt and shorts"
        default:
            return "Tank top, shorts, sunglasses"
        }
    }
    
    func packingItems() -> [String] {
        var items: [String] = [
            "👟Comfortable shoes",
            "🔋Phone charger",
            "📸 Camera"
        ]

        let temp = weather.current.temp_f
        let condition = weather.current.condition.text.lowercased()
        let uv = weather.current.uv
        let wind = weather.current.wind_mph

        if temp >= 75 {
            items.append("🕶️ Sunglasses")
            items.append("Water bottle")
            items.append("🧴Sunscreen")
            items.append("👙 Bathingsuit")
        }

        if temp >= 85 {
            items.append("Light clothing")
        }

        if temp < 65 {
            items.append("Light jacket")
        }

        if temp < 50 {
            items.append("Warm sweater")
        }

        if uv >= 5 {
            items.append("🧴Sunscreen")
            items.append("🧢Hat")
        }

        if wind >= 15 {
            items.append("Windbreaker")
        }

        if condition.contains("rain") || condition.contains("drizzle") {
            items.append("Umbrella")
            items.append("Waterproof shoes")
        }

        if condition.contains("snow") {
            items.append("🧤Gloves")
            items.append("🧥Winter coat")
            items.append("🥾Boots")
        }

        return Array(Set(items)).sorted()
    }
    
    func weekendDays() -> [ForecastDay] {
        weather.forecast.forecastday.filter { day in
            let weekday = dayOfWeek(from: day.date)
            return weekday == "Saturday" || weekday == "Sunday"
        }
    }
    
    func dayOfWeek(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: dateString) else {
            return dateString
        }

        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    func weekendPlannerCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(weekendDays(), id: \.date) { day in
                HStack {
                    Text(dayOfWeek(from: day.date))
                        .bold()

                    Spacer()

                    Text(day.day.condition.text)
                        .font(.caption)

                    Text("H: \(Int(day.day.maxtemp_f))°")
                }
            }

            Text(bestWeekendDay())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7))
        .cornerRadius(18)
    }
    
    func bestWeekendDay() -> String {
        let days = weekendDays()

        guard let best = days.max(by: { $0.day.maxtemp_f < $1.day.maxtemp_f }) else {
            return "Weekend forecast is not available yet."
        }

        return "Best day for outdoor activities: \(dayOfWeek(from: best.date))"
    }
    
    func todayTipsCard() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today’s Tips")
                .font(.headline)

            ForEach(todayTips(), id: \.self) { tip in
                Text(tip)
                    .font(.callout)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7))
        .cornerRadius(18)
    }
    
    
    func todayTips() -> [String] {
        var tips: [String] = []

        let condition = weather.current.condition.text.lowercased()
        let temp = weather.current.temp_f
        let uv = weather.current.uv
        let wind = weather.current.wind_mph

        if condition.contains("rain") || condition.contains("drizzle") {
            tips.append("☂️ Umbrella\nBring when heading outside. Rain is expected today.")
        }

        if uv >= 5 {
            tips.append("🕶️ Sunglasses\nBest during midday. UV index reaches \(Int(uv)).")
            tips.append("🧴 Sunscreen\nRecommended when outside for long periods.")
        }

        if temp < 65 {
            tips.append("🧥 Jacket\nRecommended in the morning or evening. Temperatures may feel cool.")
        }

        if wind >= 15 {
            tips.append("🌬️ Windbreaker\nUseful today. Winds are around \(Int(wind)) mph.")
        }

        if tips.isEmpty {
            tips.append("✅ No special items needed\nWeather looks comfortable for normal plans.")
        }

        return tips
    }
    
    func travelAdviceCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Travel Advice")
                .font(.headline)

            Text("Comfort Score: \(comfortScore())/10")
                .font(.title3)
                .bold()

            ForEach(travelAdvice(), id: \.self) { advice in
                Text("• \(advice)")
                    .font(.callout)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7))
        .cornerRadius(18)
    }
    
    func comfortScore() -> Int {
        var score = 10

        let temp = weather.current.temp_f
        let humidity = weather.current.humidity
        let wind = weather.current.wind_mph
        let condition = weather.current.condition.text.lowercased()

        if temp < 45 || temp > 90 { score -= 2 }
        if humidity > 75 { score -= 1 }
        if wind > 18 { score -= 1 }
        if condition.contains("rain") || condition.contains("snow") || condition.contains("storm") {
            score -= 2
        }

        return max(score, 1)
    }
    
    func travelAdvice() -> [String] {
        var advice: [String] = []

        if weather.current.humidity < 60 {
            advice.append("Low humidity")
        } else {
            advice.append("Humidity may feel noticeable")
        }

        if weather.current.temp_f >= 60 && weather.current.temp_f <= 80 {
            advice.append("Mild temperatures")
        }

        if weather.current.wind_mph < 15 {
            advice.append("Light winds")
        }

        if !weather.current.condition.text.lowercased().contains("storm") {
            advice.append("No severe weather expected")
        }

        return advice
    }
    
}

//#Preview {
   // PackingView(weather: weather)
    //    .environmentObject(AppSettings())

//}
