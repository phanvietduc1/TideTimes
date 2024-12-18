import SwiftUI

struct TideGraphView: View {
    let tidePoints: [TidePoint]
    let currentTime: Date
    
    // Constants for graph appearance
    private let dotSize: CGFloat = 8
    private let lineWidth: CGFloat = 2
    private let padding: CGFloat = 20
    
    private var relevantPoints: [TidePoint] {
        // Filter points to show current + one high/low on either side
        let sortedPoints = tidePoints.sorted { $0.time < $1.time }
        guard let currentIndex = sortedPoints.firstIndex(where: { $0.time > currentTime }) else {
            return Array(sortedPoints.prefix(4))
        }
        
        let startIndex = max(0, currentIndex - 2)
        let endIndex = min(sortedPoints.count, currentIndex + 2)
        return Array(sortedPoints[startIndex..<endIndex])
    }
    
    private var graphPoints: [CGPoint] {
        guard !relevantPoints.isEmpty else { return [] }
        
        // Find time and height ranges for scaling
        let timeRange = relevantPoints.last!.time.timeIntervalSince(relevantPoints.first!.time)
        let heights = relevantPoints.map(\.height)
        let minHeight = heights.min()!
        let heightRange = heights.max()! - minHeight
        
        return relevantPoints.enumerated().map { index, point in
            let timeInterval = point.time.timeIntervalSince(relevantPoints.first!.time)
            let x = timeInterval / timeRange
            let y = (point.height - minHeight) / heightRange
            return CGPoint(x: x, y: 1 - y) // Invert y because SwiftUI draws from top-down
        }
    }
    
    private var currentPoint: CGPoint? {
        guard !graphPoints.isEmpty else { return nil }
        let currentTimeInterval = currentTime.timeIntervalSince(relevantPoints.first!.time)
        let timeRange = relevantPoints.last!.time.timeIntervalSince(relevantPoints.first!.time)
        let progress = currentTimeInterval / timeRange
        
        // Find surrounding points for interpolation
        guard let nextPointIndex = relevantPoints.firstIndex(where: { $0.time > currentTime }),
              nextPointIndex > 0 else { return nil }
        
        let prevPoint = graphPoints[nextPointIndex - 1]
        let nextPoint = graphPoints[nextPointIndex]
        
        // Linear interpolation between points
        let t = CGFloat(progress)
        return CGPoint(
            x: prevPoint.x + (nextPoint.x - prevPoint.x) * t,
            y: prevPoint.y + (nextPoint.y - prevPoint.y) * t
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width - padding * 2
            let height = geometry.size.height - padding * 2
            
            ZStack {
                // Draw the curve
                Path { path in
                    guard let firstPoint = graphPoints.first else { return }
                    
                    path.move(to: CGPoint(
                        x: firstPoint.x * width + padding,
                        y: firstPoint.y * height + padding
                    ))
                    
                    for index in 1..<graphPoints.count {
                        let point = graphPoints[index]
                        let prevPoint = graphPoints[index - 1]
                        
                        // Calculate control points for smooth curve
                        let control1 = CGPoint(
                            x: prevPoint.x * width + (point.x - prevPoint.x) * width * 0.5 + padding,
                            y: prevPoint.y * height + padding
                        )
                        let control2 = CGPoint(
                            x: prevPoint.x * width + (point.x - prevPoint.x) * width * 0.5 + padding,
                            y: point.y * height + padding
                        )
                        
                        path.addCurve(
                            to: CGPoint(x: point.x * width + padding, y: point.y * height + padding),
                            control1: control1,
                            control2: control2
                        )
                    }
                }
                .stroke(Color.blue, lineWidth: lineWidth)
                
                // Draw high/low tide points
                ForEach(relevantPoints.indices, id: \.self) { index in
                    let point = relevantPoints[index]
                    let graphPoint = graphPoints[index]
                    
                    Image(systemName: point.isHighTide ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                        .position(
                            x: graphPoint.x * width + padding,
                            y: graphPoint.y * height + padding
                        )
                }
                
                // Draw current time indicator
                if let currentPoint = currentPoint {
                    Circle()
                        .fill(Color.red)
                        .frame(width: dotSize, height: dotSize)
                        .position(
                            x: currentPoint.x * width + padding,
                            y: currentPoint.y * height + padding
                        )
                }
            }
        }
        .frame(height: 200)
    }
}

// Preview provider
#Preview {
    TideGraphView(
        tidePoints: [
            TidePoint(time: Date().addingTimeInterval(-3600 * 6), height: 1.2, isHighTide: true),
            TidePoint(time: Date(), height: 0.5, isHighTide: false),
            TidePoint(time: Date().addingTimeInterval(3600 * 6), height: 1.8, isHighTide: true)
        ],
        currentTime: Date()
    )
    .padding()
} 
