import Foundation
import Combine
import Alamofire

class TideService: ObservableObject {
    @Published var data: IndividualStationResponse.StationData = IndividualStationResponse.StationData(id: "0")
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - API Endpoints
    private func fetchTideData(notation: String) async throws -> IndividualStationResponse {
        let urlString = "https://environment.data.gov.uk/flood-monitoring/id/stations/\(notation).json"
        print("Fetching tide data from Storm Glass API: \(urlString)")
        return try await AF.request(
            urlString
        ).serializingDecodable(IndividualStationResponse.self).value
    }
    
    // MARK: - Public Methods
    func fetchTideData(for notation: String) async throws {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
            self.data = IndividualStationResponse.StationData(id: "0")
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
        let urlString = "https://environment.data.gov.uk/flood-monitoring/id/stations?type=TideGauge"
        let response = try await AF.request(
            urlString
        ).serializingDecodable(StationResponse.self).value
        
        return response.items
    }
}
