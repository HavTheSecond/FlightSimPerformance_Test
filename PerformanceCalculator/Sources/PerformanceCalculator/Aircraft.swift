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
    
    let lowestFlexName: String
    let maxTempPlusISA: UInt
    
    let derates: [(name: String, minusPercent: UInt)]
    let bump: (name: String, plusPercent: UInt)?
    
    let runwayLimitFirstFlaps: (warning: String, lengthInFeet: UInt)?
    let minRWLenghtWarning: String
    
    let maxApproachSpeedAddition: UInt
    let headwindDivisionSpeedAddition: UInt
    
    let autobrakes: [String]
    
    let engines: Engines
    
    // MARK: Weights
    let oew: UInt
    let maxZFW: UInt
    let maxTOW: UInt
    let maxLandingWT: UInt
    var maxRampWT: UInt {
        maxTOW + 301
    }
    
    let maxNoseupTrim: (cg: Double, trimTenths: UInt)
    let zeroTrimCG: Double
    let maxNosedownTrim: (cg: Double, trimTenths: UInt)
    
    // MARK: Passenger numbers
    let firstClass: UInt
    var firstClassWT: UInt {
        UInt(Double(firstClass) * DefaultData.passengerWeight)
    }
    
    let business: UInt
    var busClassWT: UInt {
        UInt(Double(business) * DefaultData.passengerWeight)
    }
    
    let economy: UInt
    var econWT: UInt {
        UInt(Double(economy) * DefaultData.passengerWeight)
    }
    
    let allEconomyPaxLoad: UInt
    
    // MARK: Cargo
    let frontCargo: UInt
    let rearCargo: UInt
    var maximumPayload: UInt {
        maxZFW - oew
    }
    var mainDeck: UInt {
        maximumPayload - frontCargo - rearCargo
    }
    
    // MARK: Fuel
    let tanks: [(name: String, weight: UInt)]
    var maxFuelWeight: UInt {
        tanks.reduce(0, {$0+$1.weight})
    }
    
    let minContingencyFuelFor15Min: UInt
    let minFinalReserve: UInt
    func calcTrueMinContingency(blockFuel: UInt) -> UInt {
        let fivePercent = Double(blockFuel) * 0.05
        return max(minContingencyFuelFor15Min, UInt(fivePercent))
    }
    
    // MARK: OperatingLimits
    let maxWindTOLand: UInt
    
    let maxCrosswind: UInt
    let maxTailWindTO: UInt
    let maxTailWindLand: UInt
    let maxGlidepath: Double
    
    let maxCrosswindAutoland: UInt
    let maxTailwindAutoland: UInt
    let maxHeadwindAutoland: UInt
    let maxGlidepathAutoland: Double
    
    let maxOperatingAltitude: UInt
    let standardMaximumAirfieldAltitude: UInt
    
    let maxTailwindSteepApproach: UInt
    
    let minStandardLandingFlapsIndex: UInt
}

struct MeasuredPerformance {
    let weight: UInt
    let distSea: UInt
    let dist2000: UInt?
    let dist4000: UInt?
    let dist6000: UInt?
    let dist8000: UInt?
    let dist10000: UInt?
}

struct Engines {
    let name: String
    let tRefSLEngineIce: (on: UInt, off: UInt)
    let tRef5000EngineIce: (on: UInt, off: UInt)
    let tMaxFlexSLEngineIce: (on: UInt, off: UInt)
    let tMaxFlex5000EngineIce: (on: UInt, off: UInt)
    
    let altName: String
    let altEnginePerfPercent: UInt?
    let altEngineAltCorrPercent: UInt?
    let altEngineISARateIncrease: UInt
    let altEngineOEW: UInt
    let tRefSLAltEngineIceAlterna: (on: UInt, off: UInt)
    let tRef5000AltEngineIce: (on: UInt, off: UInt)
    let tMaxFlexSLAltEngineIce: (on: UInt, off: UInt)
    let tMaxFlex5000AltEngineIce: (on: UInt, off: UInt)
    let toAltPercADJWT2: (below: UInt, above: UInt)
    let landingWeight: (weight: UInt, percADJ: UInt)
}
