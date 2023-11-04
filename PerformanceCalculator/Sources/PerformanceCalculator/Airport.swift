import Foundation

public struct Airport: Identifiable, Codable, Equatable {
    public let icao: String
    public let name: String
    public let elevation: Measurement<UnitLength>
    
    public let runways: [Runway]
    
    public var id: String {
        icao
    }
}

public struct Runway: Codable, Equatable, Hashable {
    public let name: String
    public let length: Measurement<UnitLength>
    
    public init(name: String, length: Measurement<UnitLength>) {
        self.name = name
        self.length = length
    }
}
