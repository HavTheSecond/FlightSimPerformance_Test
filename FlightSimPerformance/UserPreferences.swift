import Foundation
import SwiftUI
import PerformanceCalculator

@Observable
class UserPreferences {
    private let userDefaults = UserDefaults.standard
    
    public var weightUnitIndex: Int {
        didSet {
            if weightUnitIndex >= allowedWeightUnits.count {
                weightUnitIndex = oldValue
            } else {
                userDefaults.setValue(weightUnitIndex, forKey: "weight_unit")
            }
        }
    }
    public let allowedWeightUnits = [UnitMass.kilograms, UnitMass.metricTons, UnitMass.pounds]
    public var overWeightPrevention = true
    
    public var weightUnit: UnitMass {
        allowedWeightUnits[weightUnitIndex]
    }
    
    func fromWeight(_ weight: Measurement<UnitMass>) -> Int {
        Int(weight.converted(to: weightUnit).value.rounded())
    }
    
    func fromWeight(_ weight: Measurement<UnitMass>, rule: FloatingPointRoundingRule) -> Int {
        Int(weight.converted(to: weightUnit).value.rounded(rule))
    }
    
    func stringFromWeight(_ weight: Measurement<UnitMass>) -> String {
        "\(fromWeight(weight).formatted()) \(weightUnit.symbol)"
    }
    
    func stringFromWeight(_ weight: Measurement<UnitMass>, rule: FloatingPointRoundingRule) -> String {
        "\(fromWeight(weight, rule: rule).formatted()) \(weightUnit.symbol)"
    }
    
    func toWeight(_ weight: Int) -> Measurement<UnitMass> {
        Measurement(value: Double(weight), unit: weightUnit)
    }
    
    public var volumeUnitIndex: Int {
        didSet {
            if volumeUnitIndex >= allowedVolumeUnits.count {
                volumeUnitIndex = oldValue
            } else {
                userDefaults.setValue(volumeUnitIndex, forKey: "volume_unit")
            }
        }
    }
    public let allowedVolumeUnits = [UnitVolume.liters, UnitVolume.gallons]
    
    public var volumeUnit: UnitVolume {
        allowedVolumeUnits[volumeUnitIndex]
    }
    
    public var elevationUnitIndex: Int {
        didSet {
            if elevationUnitIndex >= allowedElevationUnits.count {
                elevationUnitIndex = oldValue
            } else {
                userDefaults.setValue(elevationUnitIndex, forKey: "elevation_unit")
            }
        }
    }
    public let allowedElevationUnits = [UnitLength.feet, UnitLength.meters, UnitLength.kilometers, UnitLength.miles]
    
    public var elevationUnit: UnitLength {
        allowedElevationUnits[elevationUnitIndex]
    }
    
    func fromElevation(_ elevation: Measurement<UnitLength>) -> Int {
        Int(elevation.converted(to: elevationUnit).value.rounded())
    }
    
    func fromElevation(_ elevation: Measurement<UnitLength>, rule: FloatingPointRoundingRule) -> Int {
        Int(elevation.converted(to: elevationUnit).value.rounded(rule))
    }
    
    func stringFromElevation(_ elevation: Measurement<UnitLength>) -> String {
        "\(fromElevation(elevation).formatted()) \(elevationUnit.symbol)"
    }
    
    func stringFromElevation(_ elevation: Measurement<UnitLength>, rule: FloatingPointRoundingRule) -> String {
        "\(fromElevation(elevation, rule: rule).formatted()) \(elevationUnit.symbol)"
    }
    
    func toElevation(_ elevation: Int) -> Measurement<UnitLength> {
        Measurement(value: Double(elevation), unit: elevationUnit)
    }
    
    public var rwLengthUnitIndex: Int {
        didSet {
            if rwLengthUnitIndex >= allowedRWLengthUnits.count {
                rwLengthUnitIndex = oldValue
            } else {
                userDefaults.setValue(rwLengthUnitIndex, forKey: "rw_length_unit")
            }
        }
    }
    public let allowedRWLengthUnits = [UnitLength.meters, UnitLength.kilometers, UnitLength.feet, UnitLength.miles]
    
    public var rwLengthUnit: UnitLength {
        allowedRWLengthUnits[rwLengthUnitIndex]
    }
    
    func fromRWLength(_ rwLength: Measurement<UnitLength>) -> Int {
        Int(rwLength.converted(to: rwLengthUnit).value.rounded())
    }
    
    func fromRWLength(_ rwLength: Measurement<UnitLength>, rule: FloatingPointRoundingRule) -> Int {
        Int(rwLength.converted(to: rwLengthUnit).value.rounded(rule))
    }
    
    func stringFromRWLength(_ rwLength: Measurement<UnitLength>) -> String {
        "\(fromRWLength(rwLength).formatted()) \(rwLengthUnit.symbol)"
    }
    
    func stringFromRWLength(_ rwLength: Measurement<UnitLength>, rule: FloatingPointRoundingRule) -> String {
        "\(fromRWLength(rwLength, rule: rule).formatted()) \(rwLengthUnit.symbol)"
    }
    
    func toRWLength(_ rwLength: Int) -> Measurement<UnitLength> {
        Measurement(value: Double(rwLength), unit: elevationUnit)
    }
    
    public var pressureUnitIndex: Int {
        didSet {
            if pressureUnitIndex >= allowedPressureUnits.count {
                pressureUnitIndex = oldValue
            } else {
                userDefaults.setValue(pressureUnitIndex, forKey: "pressure_unit")
            }
        }
    }
    public let allowedPressureUnits = [UnitPressure.hectopascals, UnitPressure.inchesOfMercury, UnitPressure.bars, UnitPressure.millimetersOfMercury]
    
    public var pressureUnit: UnitPressure {
        allowedPressureUnits[pressureUnitIndex]
    }
    
    public var speedUnitIndex: Int {
        didSet {
            if speedUnitIndex >= allowedSpeedUnits.count {
                speedUnitIndex = oldValue
            } else {
                userDefaults.setValue(speedUnitIndex, forKey: "speed_unit")
            }
        }
    }
    public let allowedSpeedUnits = [UnitSpeed.knots, UnitSpeed.kilometersPerHour, UnitSpeed.milesPerHour, UnitSpeed.metersPerSecond]
    
    public var speedUnit: UnitSpeed {
        allowedSpeedUnits[speedUnitIndex]
    }
    
    public var tempUnitIndex: Int {
        didSet {
            if tempUnitIndex >= allowedTempUnits.count {
                tempUnitIndex = oldValue
            } else {
                userDefaults.setValue(tempUnitIndex, forKey: "temp_unit")
            }
        }
    }
    public let allowedTempUnits = [UnitTemperature.celsius, UnitTemperature.fahrenheit]
    
    public var tempUnit: UnitTemperature {
        allowedTempUnits[tempUnitIndex]
    }

    
    public var resetCount = 0
    
    func savePassengerWeights(passenger: Measurement<UnitMass>, baggage: Measurement<UnitMass>) {
        guard let passengerJSON = try? JSONEncoder().encode(passenger),
              let baggageJSON = try? JSONEncoder().encode(baggage) else {return}
        userDefaults.setValue(passengerJSON, forKey: "passenger_weight")
        userDefaults.setValue(baggageJSON, forKey: "baggage_weight")
    }
    
    public func loadPassengerWeights() -> (passenger: Measurement<UnitMass>, baggage: Measurement<UnitMass>)? {
        let type = Measurement<UnitMass>.self
        guard let passengerJSON = userDefaults.value(forKey: "passenger_weight") as? Data,
              let baggageJSON = userDefaults.value(forKey: "baggage_weight") as? Data,
              let passenger = try? JSONDecoder().decode(type, from: passengerJSON),
              let baggage = try? JSONDecoder().decode(type, from: baggageJSON) else {return nil}
        return (passenger, baggage)
    }
    
    init() {
        weightUnitIndex = userDefaults.object(forKey: "weight_unit") as? Int ?? 0
        volumeUnitIndex = userDefaults.object(forKey: "volume_unit") as? Int ?? 0
        elevationUnitIndex = userDefaults.object(forKey: "elevation_unit") as? Int ?? 0
        rwLengthUnitIndex = userDefaults.object(forKey: "rw_length_unit") as? Int ?? 0
        speedUnitIndex = userDefaults.object(forKey: "speed_unit") as? Int ?? 0
        tempUnitIndex = userDefaults.object(forKey: "temp_unit") as? Int ?? 0
        pressureUnitIndex = userDefaults.object(forKey: "pressure_unit") as? Int ?? 0
    }
}
