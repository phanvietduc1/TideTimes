import Foundation
import Combine
import Alamofire

class TideService: ObservableObject {
    @Published var data: [Item] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func getISOStartOfDay() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Lấy 0 giờ 0 phút ngày hôm nay
        let startOfDay = calendar.startOfDay(for: now)
        
        // Định dạng theo ISO 8601
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC timezone
        
        return isoFormatter.string(from: startOfDay)
    }
    // MARK: - API Endpoints
    private func fetchTideData(notation: String) async throws -> OneDayData {
        // https://environment.data.gov.uk/flood-monitoring/id/measures/E72639-level-tidal_level-Mean-15_min-mAOD/readings?since=2024-12-17T10:00:00Z&_sorted&_limit=50
        
        let urlString = "https://environment.data.gov.uk/flood-monitoring/id/measures/E72639-level-tidal_level-Mean-15_min-mAOD/readings?since=\(getISOStartOfDay())&_sorted&_limit=50"
        print("Fetching tide data from Storm Glass API: \(urlString)")
        return try await AF.request(
            urlString
        ).serializingDecodable(OneDayData.self).value
    }
    
    // MARK: - Public Methods
    func fetchTideData(for notation: String) async throws {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
            self.data = []
        }
        
        do {
            let response = try await fetchTideData(
                notation: notation
            )

            DispatchQueue.main.async {
                self.data = response.items
                self.isLoading = false
            }
            
        } catch {
            print("Error fetching tide data: \(error.localizedDescription)")
        }
    }
    
    func fetchNearbyStations(lat: Double, lon: Double) async throws -> [Station] {
        let urlString = "https://environment.data.gov.uk/flood-monitoring/id/stations?type=TideGauge&lat=\(lat)&long=\(lon)&dist=50"
        let response = try await AF.request(
            urlString
        ).serializingDecodable(StationResponse.self).value
        
        return response.items
    }
}
