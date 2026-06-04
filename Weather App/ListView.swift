//
//  ListView.swift
//  Weather App
//
//  Created by Mackinley Henry on 6/1/26.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var settings: AppSettings
    
    @AppStorage("savedCities") private var savedCitiesData = ""
    @State private var cities: [String] = []
    @State private var searchText = ""
    var body: some View {
        return NavigationStack{
            ZStack {
                settings.theme.color.opacity(0.12)
                    .ignoresSafeArea()
                
                VStack {
                    HStack(spacing: 10) {
                        Text("Weather")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        EditButton()
                            .foregroundColor(.black)
                            .font(.footnote)
                        
                        Text(" ")
                        
                        NavigationLink {
                            ThreeLineView()
                        }label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        
                    } 
                    .padding()
                    
                    
                    
                    List {
                        ForEach(cities, id:\.self) { city in
                            NavigationLink {
                                CityView(cityName: city)
                            } label : {
                                cityCard(city: city)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteCity(city)
                                } label: {
                                    Label(" ", systemImage: "trash")
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: -10))
                        }
                        .onMove(perform: moveCity)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    
                    
                    HStack {
                        TextField("Search city", text: $searchText)
                            .textFieldStyle(.plain)
                            .padding(.horizontal)
                        
                        Button {
                            addCity()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                        }
                        .padding(.trailing)
                    }
                    .frame(height: 50)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(25)
                    .padding()
                    
                }
            }.onAppear {
                loadCities()
            }
            
            
        }
        
        func loadCities() {
            if savedCitiesData.isEmpty {
                cities = ["Los Angeles", "New York", "Dallas"]
            } else {
                cities = savedCitiesData.components(separatedBy: "|")
            }
        }
        
        func saveCities() {
            savedCitiesData = cities.joined(separator: "|")
        }
        
        func cityCard(city: String) -> some View {
            CityCardView(cityName: city)
        }
        
        func addCity() {
            let city = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !city.isEmpty else { return }
            
            cities.append(city)
            searchText = ""
            saveCities()
        }
        
        func deleteCity(_ city: String) {
            cities.removeAll { $0 == city }
            saveCities()
        }
        
        func moveCity(from source: IndexSet, to destination: Int) {
            cities.move(fromOffsets: source, toOffset: destination)
            saveCities()
        }
    }
    

}

struct CityCardView: View {
    @EnvironmentObject var settings: AppSettings
    
    let cityName: String
    
    @State private var temp = "--"
    @State private var high = "--"
    @State private var low = "--"
    @State private var condition = "--"
    
    let weatherService = WeatherService()
    
    var body: some View {
        HStack {
            Text(cityName)
                .font(.title2)
                .bold()
            
            Spacer()
            
            Text(condition == "--" ? "--" : "\(condition)")
                .font(.body)
                
                
            
            Spacer()
            VStack {
                Text(temp == "--°" ? "--°" : "\(temp)")
                    .font(.title2)
                    .bold()
                
                HStack{
                    Text(high == "--°" ? "--°" : "H: \(high)")
                        .font(.caption)
                        .bold()
                    
                    Text(low == "--°" ? "--°" : "L: \(low)")
                        .font(.caption)
                        .bold()
                }
            }
            
        }
        .padding()
        .frame(height: 75)
        .background(Color.white.opacity(0.75))
        .cornerRadius(18)
        .task {
            await loadTemp()
        }
    }
    
    func loadTemp() async {
        do {
            let weather = try await weatherService.getWeather(for: cityName, days: settings.forecastDays)

            if settings.temperatureUnit == .fahrenheit {
                temp = "\(Int(weather.current.temp_f))°"
                high = "\(Int(weather.forecast.forecastday.first?.day.maxtemp_f ?? 0))°"
                low = "\(Int(weather.forecast.forecastday.first?.day.mintemp_f ?? 0))°"
            } else {
                temp = "\(Int(weather.current.temp_c))°"
                high = "\(Int(weather.forecast.forecastday.first?.day.maxtemp_c ?? 0))°"
                low = "\(Int(weather.forecast.forecastday.first?.day.mintemp_c ?? 0))°"
            }

            condition = weather.current.condition.text

        } catch {
            temp = "--"
        }
    }
    
    
}

#Preview {
    ListView()
        .environmentObject(AppSettings())
}
