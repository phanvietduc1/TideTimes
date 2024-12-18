import SwiftUI

struct StationListView: View {
    let location: Location
    @StateObject private var tideService = TideService()
    @State private var stations: [Station] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                Text("Loading nearby stations...")
            } else if let error = error {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error loading stations")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Button("Retry") {
                        Task {
                            await loadStations()
                        }
                    }
                    .padding()
                }
            } else if stations.isEmpty {
                Text("No stations found nearby")
                    .font(.headline)
            } else {
                List(stations) { station in
                    NavigationLink {
                        TideDetailView(notation: station.notation ?? "")
                    } label: {
                        VStack(alignment: .leading) {
                            Text(station.notation ?? "")
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .navigationTitle("Nearby Stations")
        .task {
            await loadStations()
        }
    }
    
    private func loadStations() async {
        isLoading = true
        error = nil
        
        do {
            stations = try await tideService.fetchNearbyStations(
                lat: location.latitude,
                lon: location.longitude
            )
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
} 
