import Foundation

struct Aircraft {
    
    // MARK: User information
    let name: String
    let approachDetails: String
    let performanceSummary: String
    let typeCheck: String
    
    // MARK: Performance
    let vrISA: UInt
    
    let toPerformances: [MeasuredPerformance]
    let landPerformances: [MeasuredPerformance]
    let flaps: [(name: String, toPerfImpactPercent: Double?, landPerfImpactPercent: Double)]
    let isaIncrease_ISAPlusRate: (increase: UInt, rate: UInt)
    
    let lowestFlexName: String
    let maxTempPlusISA: UInt
    
    let derates: [(name: String, minusPercent: UInt)]?
    let bump: (name: String, plusPercent: UInt)?
    
    let runwayLimitFirstFlaps: (warning: String, lengthInFeet: UInt)?
    
    let maxApproachSpeedAddition: UInt
    let headwindDivisionSpeedAddition: UInt
    
    let autobrakes: [String]
    
    let engines: Engines
    
    // MARK: Weights
    let oew: Measurement<UnitMass>
    let maxZFW: Measurement<UnitMass>
    let maxTOW: Measurement<UnitMass>
    let maxLandingWT: Measurement<UnitMass>
    var maxRampWT: Measurement<UnitMass> {
        maxTOW + Measurement(value: 301, unit: .kilograms)
    }
    
    let maxNoseUpTrim: (cg: Double, trimTenths: UInt)?
    let zeroTrimCG: Double?
    let maxNoseDownTrim: (cg: Double, trimTenths: UInt)?
    
    // MARK: Passenger numbers
    let firstClass: UInt
    var firstClassWT: Measurement<UnitMass> {
        DefaultData.passengerWeight * Double(firstClass)
    }
    
    let business: UInt
    var busClassWT: Measurement<UnitMass> {
        DefaultData.passengerWeight * Double(business)
    }
    
    let economy: UInt
    var econWT: Measurement<UnitMass> {
        DefaultData.passengerWeight * Double(economy)
    }
    
    let allEconomyPaxNo: UInt
    
    // MARK: Cargo
    let frontCargo: Measurement<UnitMass>
    let rearCargo: Measurement<UnitMass>
    var maximumPayload: Measurement<UnitMass> {
        maxZFW - oew
    }
    var mainDeck: Measurement<UnitMass> {
        maximumPayload - frontCargo - rearCargo
    }
    
    // MARK: Fuel
    let tanks: [(name: String, weight: Measurement<UnitMass>)]
    var maxFuelWeight: Measurement<UnitMass> {
        tanks.reduce(.init(value: 0, unit: .kilograms), {$0+$1.weight})
    }
    
    let minContingencyFuelFor15Min: Measurement<UnitMass>
    let minFinalReserve: Measurement<UnitMass>
    func calcTrueMinContingency(blockFuel: Measurement<UnitMass>) -> Measurement<UnitMass> {
        let fivePercent = blockFuel * 0.05
        return max(minContingencyFuelFor15Min, fivePercent)
    }
    
    // MARK: OperatingLimits
    let maxWindTOLand: Measurement<UnitSpeed>
    
    let maxCrosswind: Measurement<UnitSpeed>
    let maxTailWindTO: Measurement<UnitSpeed>
    let maxTailWindLand: Measurement<UnitSpeed>
    let maxGlidepath: Measurement<UnitAngle>
    
    let maxCrosswindAutoland: Measurement<UnitSpeed>
    let maxTailwindAutoland: Measurement<UnitSpeed>
    let maxHeadwindAutoland: Measurement<UnitSpeed>
    let maxGlidepathAutoland: Measurement<UnitAngle>
    
    let maxOperatingAltitude: Measurement<UnitLength>
    let standardMaximumAirfieldAltitude: Measurement<UnitLength>
    
    let maxTailwindSteepApproach: Measurement<UnitSpeed>?
    
    let minStandardLandingFlapsIndex: UInt
    
    let rccFlexLimit: UInt
}

struct MeasuredPerformance {
    let weight: Measurement<UnitMass>
    let distSea: Measurement<UnitLength>
    let dist2000: Measurement<UnitLength>?
    let dist4000: Measurement<UnitLength>?
    let dist6000: Measurement<UnitLength>?
    let dist8000: Measurement<UnitLength>?
    let dist10000: Measurement<UnitLength>?
    let WT_ISA_DIST: Measurement<UnitLength>?
}

struct Engines {
    let name: String
    let tRefSLEngineIce: (on: Int, off: Int)
    let tRef5000EngineIce: (on: Int, off: Int)
    let tMaxFlexSLEngineIce: (on: Int, off: Int)
    let tMaxFlex5000EngineIce: (on: Int, off: Int)
    
    let altName: String
    let altEnginePerfPercent: UInt?
    let altEngineAltCorrPercent: UInt?
    let altEngineISARateIncrease: UInt
    let altEngineOEW: Measurement<UnitMass>
    let tRefSLAltEngineIceAlterna: (on: Int, off: Int)
    let tRef5000AltEngineIce: (on: Int, off: Int)
    let tMaxFlexSLAltEngineIce: (on: Int, off: Int)
    let tMaxFlex5000AltEngineIce: (on: Int, off: Int)
    let toAltPercADJWT2: (below: Int, above: Int)
    let landingWeight: (weight: Measurement<UnitMass>, percADJ: Int)
}
