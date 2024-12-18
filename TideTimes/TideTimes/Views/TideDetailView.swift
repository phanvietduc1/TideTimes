import SwiftUI
import Charts

struct TideDetailView: View {
    let notation: String
    @StateObject private var tideService = TideService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if tideService.isLoading {
//                    loadingView
                    EmptyView()
                } else if let error = tideService.error {
//                    errorView(error)
                    EmptyView()
                } else if !tideService.data.isEmpty {
                    waterLevelCard
                    tideChartCard
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
    
    private var waterLevelCard: some View {
        VStack(spacing: 8) {
            Text("Current Water Level")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let currentLevel = tideService.data.last {
                Text(String(format: "%.2f m", currentLevel.value))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private var tideChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Water Levels")
                .font(.headline)
            
            // Chart container
            VStack(spacing: 24) {
                Chart {
                    ForEach(getMedianValues(tideService.data), id: \.id) { item in
                        LineMark(
                            x: .value("Time", formatDate(item.dateTime)),
                            y: .value("Level", item.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.blue.gradient)
                        
                        PointMark(
                            x: .value("Time", formatDate(item.dateTime)),
                            y: .value("Level", item.value)
                        )
                        .foregroundStyle(Color.blue)
                        .annotation(position: .top) {
                            Text(formatTime(formatDate(item.dateTime)))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                        }
                    }
                    
                    if let avgLevel = tideService.data.map(\.value).average {
                        RuleMark(y: .value("Average", avgLevel))
                            .foregroundStyle(.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .annotation(position: .leading) {
                                Text("Avg")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(formatTime(date))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            Text("\(value.as(Double.self)?.formatted(.number.precision(.fractionLength(1))) ?? "")m")
                                .font(.caption)
                        }
                    }
                }
                
                // High/Low summary
                VStack(spacing: 16) {
                    HStack(spacing: 24) {
                        // Highest reading
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Highest", systemImage: "arrow.up.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            
                            if let highest = tideService.data.max(by: { $0.value < $1.value }) {
                                Text(String(format: "%.2f m", highest.value))
                                    .font(.title3.bold())
                                Text(formatTime(formatDate(highest.dateTime)))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Lowest reading
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Lowest", systemImage: "arrow.down.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            
                            if let lowest = tideService.data.min(by: { $0.value < $1.value }) {
                                Text(String(format: "%.2f m", lowest.value))
                                    .font(.title3.bold())
                                Text(formatTime(formatDate(lowest.dateTime)))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private func getMedianValues(_ data: [Item], count: Int = 5) -> [Item] {
        let sortedData = data.sorted { $0.value < $1.value }
        let step = max(1, sortedData.count / count)
        var medianValues: [Item] = []
        
        // Get median values
        for i in 0..<min(count, sortedData.count) {
            let index = min(i * step, sortedData.count - 1)
            medianValues.append(sortedData[index])
        }
        
        // Sort by time
        medianValues.sort { $0.dateTime < $1.dateTime }
        
        // Add the last data point if it's not already included
        if let lastPoint = data.sorted(by: { $0.dateTime < $1.dateTime }).last,
           !medianValues.contains(where: { $0.id == lastPoint.id }) {
            medianValues.append(lastPoint)
        }
        
        // Final sort by time to ensure proper order
        return medianValues.sorted { $0.dateTime < $1.dateTime }
    }
    
    private func formatDate(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Helper extension to calculate average
extension Collection where Element == Double {
    var average: Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
} 
