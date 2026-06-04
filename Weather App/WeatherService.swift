//
//  WeatherService.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/2/26.
//

import Foundation

struct WeatherResponse: Codable {
    let location: LocationData
    let current: CurrentWeatherData
    let forecast: ForecastData
}

struct LocationData: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}

struct CurrentWeatherData: Codable {
    let temp_f: Double
    let feelslike_f: Double
    let humidity: Int
    //let precipitation: Double
    let wind_mph: Double
    let uv: Double
    let condition: ConditionData
    let temp_c: Double
    let feelslike_c: Double
}

struct ConditionData: Codable {
    let text: String
    let icon: String
}

struct ForecastData: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: DayData
    let astro: AstroData
    let hour: [HourData]
}

struct DayData: Codable {
    let maxtemp_f: Double
    let mintemp_f: Double
    let condition: ConditionData
    let maxtemp_c: Double
    let mintemp_c: Double
}

struct AstroData: Codable {
    let sunrise: String
    let sunset: String
}

struct HourData: Codable, Identifiable {
    var id: String { time }
    
    let time: String
    let temp_f: Double
    let temp_c: Double
    let condition: ConditionData
}

struct ExchangeRateResponse: Codable {
    let result: String
    let base_code: String
    let target_code: String
    let conversion_rate: Double
}



class CurrencyService {
    func getExchangeRate(from: String, to: String) async throws -> ExchangeRateResponse {
        let urlString = "https://open.er-api.com/v6/latest/\(from)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let decoded = try JSONDecoder().decode(ExchangeRateAllResponse.self, from: data)

        guard let rate = decoded.rates[to] else {
            throw URLError(.cannotParseResponse)
        }

        return ExchangeRateResponse(
            result: "success",
            base_code: from,
            target_code: to,
            conversion_rate: rate
        )
    }
}

struct ExchangeRateAllResponse: Codable {
    let result: String
    let base_code: String
    let rates: [String: Double]
}

class WeatherService {
    let apiKey = "b5eb920ac0a64a8e91323710260306"
    
    func getWeather(for city: String, days: Int) async throws -> WeatherResponse {
        let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(cityEncoded)&days=\(days)&aqi=no&alerts=no"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
