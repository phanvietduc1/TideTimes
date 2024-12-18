import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var searchResults: [Location] = []
    private let searchCompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        manager.delegate = self
        searchCompleter.delegate = self
        
        // Configure search completer
        searchCompleter.resultTypes = .address
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func searchLocations(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchCompleter.queryFragment = query
    }
    
    private func performLocationSearch(for result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { [weak self] (response, error) in
            guard let item = response?.mapItems.first else { return }
            
            DispatchQueue.main.async {
                let location = Location(
                    name: result.title,
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
                if !(self?.searchResults.contains(where: { $0.name == location.name }) ?? false) {
                    self?.searchResults.append(location)
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

extension LocationManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Clear previous results
        searchResults = []
        
        // Convert and perform search for each completion
        for completion in completer.results.prefix(5) { // Limit to 5 results
            performLocationSearch(for: completion)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search error: \(error.localizedDescription)")
    }
} 
