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
                    .onChange(of: searchText) { _,_ in
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
