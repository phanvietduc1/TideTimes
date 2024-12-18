import Foundation
import Combine
import Alamofire

class TideService: ObservableObject {
    @Published var tidePoints: [TidePoint] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiKey = "c2dc8bee-7786-4bd1-8c8b-c0e402fc071c"
    private let baseURL = "https://www.worldtides.info/api/v3"
    
    // MARK: - API Endpoints
    
    /// Get tidal heights for a specific date
    private func fetchHeights(lat: Double, lon: Double, date: String) async throws -> HeightsResponse {
        let urlString = "\(baseURL)?heights&date=\(date)&lat=\(lat)&lon=\(lon)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw TideError.apiError("Invalid URL")
        }
        
        print("Heights URL: \(urlString)")
        return try await AF.request(url).serializingDecodable(HeightsResponse.self).value
    }
    
    /// Get extreme tides (highs and lows)
    private func fetchExtremes(lat: Double, lon: Double, date: String) async throws -> ExtremesResponse {
        let urlString = "\(baseURL)?extremes&date=\(date)&lat=\(lat)&lon=\(lon)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw TideError.apiError("Invalid URL")
        }
        
        print("Extremes URL: \(urlString)")
        return try await AF.request(url).serializingDecodable(ExtremesResponse.self).value
    }
    
    // MARK: - Public Methods
    
    func fetchTideData(for location: Location) async throws {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
            self.tidePoints = []
        }
        
        do {
            print("Fetching tide data for: \(location.name) (\(location.latitude), \(location.longitude))")
            
            // Get current date in required format (YYYY-MM-DD)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentDate = dateFormatter.string(from: Date())
            
            // Fetch both heights and extremes concurrently
            async let heightsResponse = fetchHeights(
                lat: location.latitude,
                lon: location.longitude,
                date: currentDate
            )
            
            async let extremesResponse = fetchExtremes(
                lat: location.latitude,
                lon: location.longitude,
                date: currentDate
            )
            
            // Wait for both responses
            let (heights, extremes) = try await (heightsResponse, extremesResponse)
            
            print("Received tide data from station: \(heights.station)")
            print("Heights count: \(heights.heights.count), Extremes count: \(extremes.extremes.count)")
            
            var points: [TidePoint] = []
            
            // Add height points
            points += heights.heights.map { height in
                TidePoint(
                    time: Date(timeIntervalSince1970: TimeInterval(height.dt)),
                    height: height.height,
                    isHighTide: false
                )
            }
            
            // Add extreme points
            points += extremes.extremes.map { extreme in
                TidePoint(
                    time: Date(timeIntervalSince1970: TimeInterval(extreme.dt)),
                    height: extreme.height,
                    isHighTide: extreme.type == "High"
                )
            }
            
            // Sort points by time
            let sortedPoints = points.sorted { $0.time < $1.time }
            
            DispatchQueue.main.async {
                self.tidePoints = sortedPoints
                self.isLoading = false
                print("Updated tidePoints count: \(self.tidePoints.count)")
            }
            
        } catch {
            print("Error fetching tide data: \(error.localizedDescription)")
            let apiError = TideError.apiError(error.localizedDescription)
            DispatchQueue.main.async {
                self.error = apiError
                self.isLoading = false
            }
            throw apiError
        }
    }
    
    func fetchNearbyStations(lat: Double, lon: Double) async throws -> [Station] {
        let urlString = "\(baseURL)?stations&lat=\(lat)&lon=\(lon)&stationDistance=50&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw TideError.apiError("Invalid URL")
        }
        
        print("Stations URL: \(urlString)")
        let response = try await AF.request(url).serializingDecodable(StationsResponse.self).value
        return response.stations
    }
}

// MARK: - API Response Models

struct HeightsResponse: Decodable {
    let status: Int
    let callCount: Int
    let copyright: String
    let requestLat: Double
    let requestLon: Double
    let responseLat: Double
    let responseLon: Double
    let atlas: String
    let station: String
    let heights: [Height]
    
    struct Height: Decodable {
        let dt: Int
        let date: String
        let height: Double
    }
}

struct ExtremesResponse: Decodable {
    let status: Int
    let callCount: Int
    let copyright: String
    let requestLat: Double
    let requestLon: Double
    let responseLat: Double
    let responseLon: Double
    let atlas: String
    let station: String
    let extremes: [Extreme]
    
    struct Extreme: Decodable {
        let dt: Int
        let date: String
        let height: Double
        let type: String
    }
}

enum TideError: LocalizedError {
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        }
    }
} 
