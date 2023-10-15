import Foundation

public struct Aircraft {
    
    // MARK: User information
    public let name: String
    public let approachDetails: String
    public let performanceSummary: String
    public let typeCheck: String
    
    // MARK: Performance
    public let vrISA: UInt
    
    public let toPerformances: [MeasuredPerformance]
    public let landPerformances: [MeasuredPerformance]
    public let flaps: [(name: String, toPerfImpactPercent: Double?, landPerfImpactPercent: Double)]
    public let isaIncrease_ISAPlusRate: (increase: Measurement<UnitTemperature>, rate: UInt)
    
    public let lowestFlexName: String
    public let maxTempPlusISA: UInt
    
    public let derates: [(name: String, minusPercent: UInt)]?
    public let bump: (name: String, plusPercent: UInt)?
    
    public let runwayLimitFirstFlaps: (warning: String, lengthInFeet: UInt)?
    
    public let maxApproachSpeedAddition: UInt
    public let headwindDivisionSpeedAddition: UInt
    
    public let autobrakes: [String]
    
    public let engines: Engines
    
    // MARK: Weights
    public let oew: Measurement<UnitMass>
    public let maxZFW: Measurement<UnitMass>
    public let maxTOW: Measurement<UnitMass>
    public let maxLandingWT: Measurement<UnitMass>
    public var maxRampWT: Measurement<UnitMass> {
        maxTOW + kgs(1) + standardTaxiFuel
    }
    
    public var standardTaxiFuel: Measurement<UnitMass>
    
    public let maxNoseUpTrim: (cg: Double, trimTenths: UInt)?
    public let zeroTrimCG: Double?
    public let maxNoseDownTrim: (cg: Double, trimTenths: UInt)?
    
    // MARK: Passenger numbers
    public let firstClass: UInt
    public var firstClassWT: Measurement<UnitMass> {
        DefaultData.passengerWeight * Double(firstClass)
    }
    
    public let business: UInt
    public var busClassWT: Measurement<UnitMass> {
        DefaultData.passengerWeight * Double(business)
    }
    
    public let economy: UInt
    public var econWT: Measurement<UnitMass> {
        DefaultData.passengerWeight * Double(economy)
    }
    
    public let allEconomyPaxNo: UInt
    
    // MARK: Cargo
    public let frontCargo: Measurement<UnitMass>
    public let rearCargo: Measurement<UnitMass>
    public let selectedMaxPayload = nil as Measurement<UnitMass>?
    public var maximumPayload: Measurement<UnitMass> {
        selectedMaxPayload ?? (maxZFW - oew)
    }
    public var mainDeck: Measurement<UnitMass> {
        maximumPayload - frontCargo - rearCargo
    }
    
    // MARK: Fuel
    public let tanks: [(name: String, weight: Measurement<UnitMass>)]
    public var maxFuelWeight: Measurement<UnitMass> {
        tanks.reduce(kgs(0), {$0+$1.weight})
    }
    
    public let minContingencyFuelFor15Min: Measurement<UnitMass>
    public let minFinalReserve: Measurement<UnitMass>
    public func calcTrueMinContingency(blockFuel: Measurement<UnitMass>) -> Measurement<UnitMass> {
        let fivePercent = blockFuel * 0.05
        return max(minContingencyFuelFor15Min, fivePercent)
    }
    
    // MARK: OperatingLimits
    public let maxWindTOLand: Measurement<UnitSpeed>
    
    public let maxCrosswind: Measurement<UnitSpeed>
    public let maxTailWindTO: Measurement<UnitSpeed>
    public let maxTailWindLand: Measurement<UnitSpeed>
    public let maxGlidepath: Measurement<UnitAngle>
    
    public let maxCrosswindAutoland: Measurement<UnitSpeed>
    public let maxTailwindAutoland: Measurement<UnitSpeed>
    public let maxHeadwindAutoland: Measurement<UnitSpeed>
    public let maxGlidepathAutoland: Measurement<UnitAngle>
    
    public let maxOperatingAltitude: Measurement<UnitLength>
    public let standardMaximumAirfieldAltitude: Measurement<UnitLength>
    
    public let maxTailwindSteepApproach: Measurement<UnitSpeed>?
    
    public let minStandardLandingFlapsIndex: UInt
    
    public let rccFlexLimit: UInt
}

public struct MeasuredPerformance {
    public let weight: Measurement<UnitMass>
    public let distSea: Measurement<UnitLength>
    public let dist2000: Measurement<UnitLength>?
    public let dist4000: Measurement<UnitLength>?
    public let dist6000: Measurement<UnitLength>?
    public let dist8000: Measurement<UnitLength>?
    public let dist10000: Measurement<UnitLength>?
    public let WT_ISA_DIST: Measurement<UnitLength>?
}

public struct Engines {
    public let name: String
    public let tRefSLEngineIce: (on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>)
    public let tRef5000EngineIce: (on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>)
    public let tMaxFlexSLEngineIce: (on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>)
    public let tMaxFlex5000EngineIce: (on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>)
    
    public let altName: String
    public let altEnginePerfPercent: UInt?
    public let altEngineAltCorrPercent: UInt?
    public let altEngineISARateIncrease: UInt
    public let altEngineOEW: Measurement<UnitMass>
    public let tRefSLAltEngineIce: (on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>)
    public let tRef5000AltEngineIce: (on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>)
    public let tMaxFlexSLAltEngineIce: (on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>)
    public let tMaxFlex5000AltEngineIce: (on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>)
    public let toAltPercADJWT2: (below: Int, above: Int)
    public let landingWeight: (weight: Measurement<UnitMass>, percADJ: Int)
}
