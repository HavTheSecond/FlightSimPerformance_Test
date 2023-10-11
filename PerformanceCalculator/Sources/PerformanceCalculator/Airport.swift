import Foundation

struct Airport: Identifiable {
    let icao: String
    let name: String
    let elevation: Measurement<UnitLength>
    
    let runways: [(name: String, length: Measurement<UnitLength>)]
    
    var id: String {
        icao
    }
}
