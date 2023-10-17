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
    }
}
