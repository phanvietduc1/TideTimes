import Foundation

struct StationResponse: Codable {
    let context: String
    let meta: Meta
    let items: [Station]

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case meta, items
    }
    // MARK: - Meta
    struct Meta: Codable {
        let publisher: String
        let licence: String
        let documentation: String
        let version: String
        let comment: String
        let hasFormat: [String]
    }
}

// MARK: - Station
struct Station: Codable, Identifiable {
    var id: String
    var rloiid: String? = nil
    var catchmentName: String? = nil
    var dateOpened: String? = nil
    var easting: Int? = nil
    var gridReference: String? = nil
    var label: String? = nil
    var lat: Double? = nil
    var long: Double? = nil
    var measures: [Measure]? = nil
    var northing: Int? = nil
    var notation: String? = nil
    var riverName: String? = nil
    var stageScale: String? = nil
    var stationReference: String? = nil
    var status: String? = nil
    var town: String? = nil

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case rloiid = "RLOIid"
        case catchmentName, dateOpened, easting, gridReference, label, lat, long, measures, northing, notation, riverName, stageScale, stationReference, status, town
    }
}

// MARK: - Measure
struct Measure: Codable {
    let id: String? = nil
    let parameter: String? = nil
    let parameterName: String? = nil
    let period: Int? = nil
    let qualifier: String? = nil
    let unitName: String? = nil

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case parameter, parameterName, period, qualifier, unitName
    }
}

struct IndividualStationResponse: Codable {
    let context: String
    let meta: Meta
    let items: StationData

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case meta, items
    }
    
    // MARK: - Meta
    struct Meta: Codable {
        let publisher: String
        let licence: String
        let documentation: String
        let version: String
        let comment: String
        let hasFormat: [String]
    }

    // MARK: - StationData
    struct StationData: Codable {
        var id: String
        var rloiID: String? = nil
        var catchmentName: String? = nil
        var dateOpened: String? = nil
        var eaAreaName: String? = nil
        var eaRegionName: String? = nil
        var easting: Int? = nil
        var gridReference: String? = nil
        var label: String? = nil
        var lat: Double? = nil
        var long: Double? = nil
        var measures: Measures? = nil
        var northing: Int? = nil
        var notation: String? = nil
        var riverName: String? = nil
        var stageScale: StageScale? = nil
        var stationReference: String? = nil
        var status: String? = nil
        var statusDate: String? = nil
        var town: String? = nil
        var type: [String]? = nil
        var wiskiID: String? = nil

        enum CodingKeys: String, CodingKey {
            case id = "@id"
            case rloiID = "RLOIid"
            case catchmentName, dateOpened, eaAreaName, eaRegionName, easting, gridReference, label, lat, long, measures, northing, notation, riverName, stageScale, stationReference, status, statusDate, town, type, wiskiID
        }
    }

    // MARK: - Measures
    struct Measures: Codable {
        let id: String
        let datumType: String
        let label: String
        let latestReading: LatestReading
        let localDatumMeasure: String
        let notation: String
        let parameter: String
        let parameterName: String
        let period: Int
        let qualifier: String
        let station: String
        let stationReference: String
        let type: [String]
        let unit: String
        let unitName: String
        let valueType: String

        enum CodingKeys: String, CodingKey {
            case id = "@id"
            case datumType, label, latestReading, localDatumMeasure, notation, parameter, parameterName, period, qualifier, station, stationReference, type, unit, unitName, valueType
        }
    }

    // MARK: - LatestReading
    struct LatestReading: Codable {
        let id: String
        let date: String
        let dateTime: String
        let measure: String
        let value: Double

        enum CodingKeys: String, CodingKey {
            case id = "@id"
            case date, dateTime, measure, value
        }
    }

    // MARK: - StageScale
    struct StageScale: Codable {
        let id: String
        let datum: Int
        let maxOnRecord: MaxOnRecord
        let scaleMax: Int

        enum CodingKeys: String, CodingKey {
            case id = "@id"
            case datum, maxOnRecord, scaleMax
        }
    }

    // MARK: - MaxOnRecord
    struct MaxOnRecord: Codable {
        let id: String
        let dateTime: String
        let value: Double

        enum CodingKeys: String, CodingKey {
            case id = "@id"
            case dateTime, value
        }
    }

}

struct OneDayData: Codable {
    let context: String
    let meta: Meta
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case meta, items
    }
}

// MARK: - Item
struct Item: Codable {
    let id: String
    let dateTime: String
    let measure: String
    let value: Double

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case dateTime, measure, value
    }
}

struct Meta: Codable {
    let publisher: String
    let licence, documentation: String
    let version, comment: String
    let hasFormat: [String]
    let limit: Int
}
