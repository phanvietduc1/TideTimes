import SwiftUI

struct TideDetailView: View {
    let notation: String
    @StateObject private var tideService = TideService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if tideService.isLoading {
                    loadingView
                } else if let error = tideService.error {
                    errorView(error)
                } else {
                    // Current tide card
                    if let currentTide = getCurrentTideInfo() {
                        currentTideCard(currentTide)
                    }
                    
                    // Tide graph
                    tideGraphCard
                    
                    // Next 24h events
                    nextEventsCard
                }
            }
            .padding()
        }
        .navigationTitle(notation)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            try? await tideService.fetchTideData(for: notation)
        }
    }
    
    private func currentTideCard(_ tide: TidePoint) -> some View {
        VStack(spacing: 8) {
            Text("Current Tide")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.1f m", tide.height))
                .font(.system(size: 42, weight: .bold, design: .rounded))
            
            Text(timeFormatter.string(from: tide.time))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading tide data...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "water.waves")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            Text("No tide data available")
                .font(.headline)
            Button("Retry") {
                Task {
                    try? await tideService.fetchTideData(for: notation)
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error loading tide data")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                Task {
                    try? await tideService.fetchTideData(for: notation)
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
} 
