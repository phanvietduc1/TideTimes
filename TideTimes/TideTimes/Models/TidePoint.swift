import Foundation
struct TidePoint: Codable, Identifiable, Hashable {
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
    
    // Add hash function to identify duplicates
    func hash(into hasher: inout Hasher) {
        hasher.combine(time)
        hasher.combine(height)
    }
    
    // Add equality check
    static func == (lhs: TidePoint, rhs: TidePoint) -> Bool {
        lhs.time == rhs.time && lhs.height == rhs.height
    }
} 
