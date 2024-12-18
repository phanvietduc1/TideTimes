//
//  ContentView.swift
//  TideTimes
//
//  Created by Geminisoft on 17/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @AppStorage("selectedLocation") private var savedLocation: Data?
    
    var body: some View {
        NavigationView {
            VStack {
                // Location search
                SearchBar(text: $searchText)
                    .onChange(of: searchText) { _ in
                        locationManager.searchLocations(query: searchText)
                    }
                
                if !searchText.isEmpty {
                    List(locationManager.searchResults) { location in
                        NavigationLink {
                            StationListView(location: location)
                        } label: {
                            Text(location.name)
                        }
                    }
                    
                    if let savedLocation = savedLocation, let location = try? JSONDecoder().decode(Location.self, from: savedLocation){
                        NavigationLink {
                            TideDetailView(location: location)
                        } label: {
                            Text(location.name)
                                .font(.headline)
                        }
                        .padding()
                    }    
                }
                
                Spacer()
            }
            .navigationTitle("Tide Times")
        }
    }
}

#Preview {
    ContentView()
}
