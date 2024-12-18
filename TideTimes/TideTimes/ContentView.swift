//
//  ContentView.swift
//  TideTimes
//
//  Created by Geminisoft on 17/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tideService = TideService()
    @State private var provinceStations: [String: Bool] = [:]
    private let englishProvinces = [
        Province(name: "Greater London", latitude: 51.5074, longitude: -0.1278),
        Province(name: "Greater Manchester", latitude: 53.4808, longitude: -2.2426),
        Province(name: "West Midlands", latitude: 52.4862, longitude: -1.8904),
        Province(name: "West Yorkshire", latitude: 53.8008, longitude: -1.5491),
        Province(name: "Merseyside", latitude: 53.4084, longitude: -2.9916),
        Province(name: "South Yorkshire", latitude: 53.3811, longitude: -1.4701),
        Province(name: "Tyne and Wear", latitude: 54.9783, longitude: -1.6178),
        Province(name: "Kent", latitude: 51.2787, longitude: 0.5217),
        Province(name: "Essex", latitude: 51.7343, longitude: 0.4697),
        Province(name: "Hampshire", latitude: 51.0577, longitude: -1.3080),
        Province(name: "Lancashire", latitude: 53.7632, longitude: -2.7044),
        Province(name: "Surrey", latitude: 51.3148, longitude: -0.5600),
        Province(name: "Hertfordshire", latitude: 51.8126, longitude: -0.2248),
        Province(name: "Norfolk", latitude: 52.6140, longitude: 0.8864),
        Province(name: "Suffolk", latitude: 52.1872, longitude: 0.9708)
    ]
    
    var body: some View {
        NavigationView {
            List(englishProvinces) { province in
                NavigationLink {
                    StationListView(location: Location(
                        name: province.name,
                        latitude: province.latitude,
                        longitude: province.longitude
                    ))
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(province.name)
                                .font(.headline)
                        }
                        Spacer()
                        if let hasStations = provinceStations[province.name] {
                            Text(hasStations ? "" : "No stations")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Provinces")
            .task {
                await checkStationsAvailability()
            }
        }
    }
    
    private func checkStationsAvailability() async {
        for province in englishProvinces {
            do {
                let stations = try await tideService.fetchNearbyStations(
                    lat: province.latitude,
                    lon: province.longitude
                )
                await MainActor.run {
                    provinceStations[province.name] = !stations.isEmpty
                }
            } catch {
                print("Error checking stations for \(province.name): \(error.localizedDescription)")
                await MainActor.run {
                    provinceStations[province.name] = false
                }
            }
        }
    }
}

// Add this struct for provinces
struct Province: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

#Preview {
    ContentView()
}
