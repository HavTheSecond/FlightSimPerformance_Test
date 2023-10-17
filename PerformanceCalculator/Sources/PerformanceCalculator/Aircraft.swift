import Foundation

public struct Aircraft: Codable, Equatable {
    
    // MARK: User information
    public let name: String
    public let approachDetails: String
    public let performanceSummary: String
    public let typeCheck: String
    
    // MARK: Performance
    public let vrISA: UInt
    
    public let toPerformances: [MeasuredPerformance]
    public let landPerformances: [MeasuredPerformance]
    public let flaps: [Flap]
    public let isaIncrease_ISAPlusRate: ISAIncrease_ISAPlusRate
    
    public let lowestFlexName: String
    public let maxTempPlusISA: UInt
    
    public let derates: [Derate]?
    public let bump: Bump?
    
    public let runwayLimitFirstFlaps: RunwayLimit?
    
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
    
    public let maxNoseUpTrim: Trim?
    public let zeroTrimCG: Double?
    public let maxNoseDownTrim: Trim?
    
    // MARK: Passenger numbers
    public let firstClass: UInt
    
    public let business: UInt
    
    public let economy: UInt
    
    public let allEconomyPaxNo: UInt
    
    // MARK: Cargo
    public let frontCargo: Measurement<UnitMass>
    public let rearCargo: Measurement<UnitMass>
    public let selectedMaxPayload: Measurement<UnitMass>?
    public var maximumPayload: Measurement<UnitMass> {
        selectedMaxPayload ?? (maxZFW - oew)
    }
    public var mainDeck: Measurement<UnitMass> {
        maximumPayload - frontCargo - rearCargo
    }
    
    // MARK: Fuel
    public let tanks: [Tank]
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

public struct MeasuredPerformance: Codable, Equatable {
    public let weight: Measurement<UnitMass>
    public let distSea: Measurement<UnitLength>
    public let dist2000: Measurement<UnitLength>?
    public let dist4000: Measurement<UnitLength>?
    public let dist6000: Measurement<UnitLength>?
    public let dist8000: Measurement<UnitLength>?
    public let dist10000: Measurement<UnitLength>?
    public let WT_ISA_DIST: Measurement<UnitLength>?
}

public struct Engines: Codable, Equatable {
    public let name: String
    public let tRefSLEngineIce: ReferenceTemperatures
    public let tRef5000EngineIce: ReferenceTemperatures
    public let tMaxFlexSLEngineIce: ReferenceTemperatures
    public let tMaxFlex5000EngineIce: ReferenceTemperatures
    
    public let altName: String
    public let altEnginePerfPercent: UInt?
    public let altEngineAltCorrPercent: UInt?
    public let altEngineISARateIncrease: UInt
    public let altEngineOEW: Measurement<UnitMass>
    public let tRefSLAltEngineIce: ReferenceTemperatures
    public let tRef5000AltEngineIce: ReferenceTemperatures
    public let tMaxFlexSLAltEngineIce: ReferenceTemperatures
    public let tMaxFlex5000AltEngineIce: ReferenceTemperatures
    public let toAltPercADJWT2: TOAltitudeOffsets
    public let landingWeight: LandingWeights
}

public struct ISAIncrease_ISAPlusRate: Codable, Equatable {
    let increase: Measurement<UnitTemperature>
    let rate: UInt
}

public struct Flap: Codable, Equatable {
    let name: String
    let toPerfImpactPercent: Double?
    let landPerfImpactPercent: Double
}

public struct Derate: Codable, Equatable {
    let name: String
    let minusPercent: UInt
}

public struct Bump: Codable, Equatable {
    let name: String
    let plusPercent: UInt
}

public struct RunwayLimit: Codable, Equatable {
    let warning: String
    let lengthInFeet: UInt
}

public struct Trim: Codable, Equatable {
    let cg: Double
    let trimTenths: UInt
}

public struct Tank: Codable, Equatable {
    let name: String
    let weight: Measurement<UnitMass>
}

public struct ReferenceTemperatures: Codable, Equatable {
    let on: Measurement<UnitTemperature>
    let off: Measurement<UnitTemperature>
}

public struct TOAltitudeOffsets: Codable, Equatable {
    let below: Int
    let above: Int
}

public struct LandingWeights: Codable, Equatable {
    let weight: Measurement<UnitMass>
    let percADJ: Int
}
