import SwiftUI

struct TideDetailView: View {
    let location: Location
    @StateObject private var tideService = TideService()
    
    var body: some View {
        VStack(spacing: 16) {
            if tideService.isLoading {
                ProgressView()
                Text("Loading tide data...")
            } else if let error = tideService.error {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error loading tide data")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Button("Retry") {
                        Task {
                            try? await tideService.fetchTideData(for: location)
                        }
                    }
                    .padding()
                }
            } else if tideService.tidePoints.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "water.waves")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Text("No tide data available")
                        .font(.headline)
                    Button("Retry") {
                        Task {
                            try? await tideService.fetchTideData(for: location)
                        }
                    }
                    .padding()
                }
            } else {
                // Tide graph
                TideGraphView(
                    tidePoints: tideService.tidePoints,
                    currentTime: Date()
                )
                .frame(height: 300)
                .padding()
                
                // Current tide info
                if let currentTide = getCurrentTideInfo() {
                    VStack(spacing: 8) {
                        Text("Current Tide")
                            .font(.headline)
                        Text(String(format: "%.1f meters", currentTide.height))
                            .font(.title2)
                    }
                }
                
                // Next events
                if let nextHigh = getNextHighTide(),
                   let nextLow = getNextLowTide() {
                    HStack(spacing: 32) {
                        VStack {
                            Text("Next High")
                                .font(.subheadline)
                            Text(timeFormatter.string(from: nextHigh.time))
                            Text(String(format: "%.1f m", nextHigh.height))
                        }
                        
                        VStack {
                            Text("Next Low")
                                .font(.subheadline)
                            Text(timeFormatter.string(from: nextLow.time))
                            Text(String(format: "%.1f m", nextLow.height))
                        }
                    }
                }
            }
        }
        .navigationTitle(location.name)
        .task {
            try? await tideService.fetchTideData(for: location)
        }
    }
    
    private func getCurrentTideInfo() -> TidePoint? {
        let now = Date()
        let sortedPoints = tideService.tidePoints.sorted { $0.time < $1.time }
        
        guard let nextIndex = sortedPoints.firstIndex(where: { $0.time > now }),
              nextIndex > 0 else { return nil }
        
        let prev = sortedPoints[nextIndex - 1]
        let next = sortedPoints[nextIndex]
        
        // Linear interpolation for current height
        let totalTime = next.time.timeIntervalSince(prev.time)
        let currentTime = now.timeIntervalSince(prev.time)
        let progress = currentTime / totalTime
        
        let height = prev.height + (next.height - prev.height) * progress
        return TidePoint(time: now, height: height, isHighTide: false)
    }
    
    private func getNextHighTide() -> TidePoint? {
        let now = Date()
        return tideService.tidePoints
            .filter { $0.isHighTide && $0.time > now }
            .min { $0.time < $1.time }
    }
    
    private func getNextLowTide() -> TidePoint? {
        let now = Date()
        return tideService.tidePoints
            .filter { !$0.isHighTide && $0.time > now }
            .min { $0.time < $1.time }
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
} 