import Foundation
struct TidePoint: Codable, Identifiable {
    let id: UUID
    let time: Date
    let height: Double
    let isHighTide: Bool
    
    init(time: Date, height: Double, isHighTide: Bool) {
        self.id = UUID()
        self.time = time
        self.height = height
        self.isHighTide = isHighTide
    }
} 
