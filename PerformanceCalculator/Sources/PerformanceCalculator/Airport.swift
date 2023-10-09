import Foundation

struct Airport: Identifiable {
    let icao: String
    let nama: String
    let elevationInFt: UInt
    
    let runways: [(name: String, lengthInFt: UInt)]
    
    var id: String {
        icao
    }
}
