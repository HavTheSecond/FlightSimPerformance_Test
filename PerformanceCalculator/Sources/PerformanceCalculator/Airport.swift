import Foundation

public struct Airport: Identifiable {
    public let icao: String
    public let name: String
    public let elevation: Measurement<UnitLength>
    
    public let runways: [(name: String, length: Measurement<UnitLength>)]
    
    public var id: String {
        icao
    }
}
