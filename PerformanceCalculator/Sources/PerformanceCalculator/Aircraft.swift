import Foundation

public struct Aircraft: Codable, Equatable {
    // MARK: User information

    public let name: String
    public let approachDetails: String
    public let performanceSummary: String
    public let typeCheck: String

    // MARK: Performance

    public let vrISA: Measurement<UnitSpeed>

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
        tanks.reduce(kgs(0)) { $0 + $1.weight }
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
    
    public init(name: String, approachDetails: String, performanceSummary: String, typeCheck: String, vrISA: Measurement<UnitSpeed>, toPerformances: [MeasuredPerformance], landPerformances: [MeasuredPerformance], flaps: [Flap], isaIncrease_ISAPlusRate: ISAIncrease_ISAPlusRate, lowestFlexName: String, maxTempPlusISA: UInt, derates: [Derate]?, bump: Bump?, runwayLimitFirstFlaps: RunwayLimit?, maxApproachSpeedAddition: UInt, headwindDivisionSpeedAddition: UInt, autobrakes: [String], engines: Engines, oew: Measurement<UnitMass>, maxZFW: Measurement<UnitMass>, maxTOW: Measurement<UnitMass>, maxLandingWT: Measurement<UnitMass>, standardTaxiFuel: Measurement<UnitMass>, maxNoseUpTrim: Trim?, zeroTrimCG: Double?, maxNoseDownTrim: Trim?, firstClass: UInt, business: UInt, economy: UInt, allEconomyPaxNo: UInt, frontCargo: Measurement<UnitMass>, rearCargo: Measurement<UnitMass>, selectedMaxPayload: Measurement<UnitMass>?, tanks: [Tank], minContingencyFuelFor15Min: Measurement<UnitMass>, minFinalReserve: Measurement<UnitMass>, maxWindTOLand: Measurement<UnitSpeed>, maxCrosswind: Measurement<UnitSpeed>, maxTailWindTO: Measurement<UnitSpeed>, maxTailWindLand: Measurement<UnitSpeed>, maxGlidepath: Measurement<UnitAngle>, maxCrosswindAutoland: Measurement<UnitSpeed>, maxTailwindAutoland: Measurement<UnitSpeed>, maxHeadwindAutoland: Measurement<UnitSpeed>, maxGlidepathAutoland: Measurement<UnitAngle>, maxOperatingAltitude: Measurement<UnitLength>, standardMaximumAirfieldAltitude: Measurement<UnitLength>, maxTailwindSteepApproach: Measurement<UnitSpeed>?, minStandardLandingFlapsIndex: UInt, rccFlexLimit: UInt) {
        self.name = name
        self.approachDetails = approachDetails
        self.performanceSummary = performanceSummary
        self.typeCheck = typeCheck
        self.vrISA = vrISA
        self.toPerformances = toPerformances
        self.landPerformances = landPerformances
        self.flaps = flaps
        self.isaIncrease_ISAPlusRate = isaIncrease_ISAPlusRate
        self.lowestFlexName = lowestFlexName
        self.maxTempPlusISA = maxTempPlusISA
        self.derates = derates
        self.bump = bump
        self.runwayLimitFirstFlaps = runwayLimitFirstFlaps
        self.maxApproachSpeedAddition = maxApproachSpeedAddition
        self.headwindDivisionSpeedAddition = headwindDivisionSpeedAddition
        self.autobrakes = autobrakes
        self.engines = engines
        self.oew = oew
        self.maxZFW = maxZFW
        self.maxTOW = maxTOW
        self.maxLandingWT = maxLandingWT
        self.standardTaxiFuel = standardTaxiFuel
        self.maxNoseUpTrim = maxNoseUpTrim
        self.zeroTrimCG = zeroTrimCG
        self.maxNoseDownTrim = maxNoseDownTrim
        self.firstClass = firstClass
        self.business = business
        self.economy = economy
        self.allEconomyPaxNo = allEconomyPaxNo
        self.frontCargo = frontCargo
        self.rearCargo = rearCargo
        self.selectedMaxPayload = selectedMaxPayload
        self.tanks = tanks
        self.minContingencyFuelFor15Min = minContingencyFuelFor15Min
        self.minFinalReserve = minFinalReserve
        self.maxWindTOLand = maxWindTOLand
        self.maxCrosswind = maxCrosswind
        self.maxTailWindTO = maxTailWindTO
        self.maxTailWindLand = maxTailWindLand
        self.maxGlidepath = maxGlidepath
        self.maxCrosswindAutoland = maxCrosswindAutoland
        self.maxTailwindAutoland = maxTailwindAutoland
        self.maxHeadwindAutoland = maxHeadwindAutoland
        self.maxGlidepathAutoland = maxGlidepathAutoland
        self.maxOperatingAltitude = maxOperatingAltitude
        self.standardMaximumAirfieldAltitude = standardMaximumAirfieldAltitude
        self.maxTailwindSteepApproach = maxTailwindSteepApproach
        self.minStandardLandingFlapsIndex = minStandardLandingFlapsIndex
        self.rccFlexLimit = rccFlexLimit
    }
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
    
    public init(weight: Measurement<UnitMass>, distSea: Measurement<UnitLength>, dist2000: Measurement<UnitLength>?, dist4000: Measurement<UnitLength>?, dist6000: Measurement<UnitLength>?, dist8000: Measurement<UnitLength>?, dist10000: Measurement<UnitLength>?, WT_ISA_DIST: Measurement<UnitLength>?) {
        self.weight = weight
        self.distSea = distSea
        self.dist2000 = dist2000
        self.dist4000 = dist4000
        self.dist6000 = dist6000
        self.dist8000 = dist8000
        self.dist10000 = dist10000
        self.WT_ISA_DIST = WT_ISA_DIST
    }
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
    
    public init(name: String, tRefSLEngineIce: ReferenceTemperatures, tRef5000EngineIce: ReferenceTemperatures, tMaxFlexSLEngineIce: ReferenceTemperatures, tMaxFlex5000EngineIce: ReferenceTemperatures, altName: String, altEnginePerfPercent: UInt?, altEngineAltCorrPercent: UInt?, altEngineISARateIncrease: UInt, altEngineOEW: Measurement<UnitMass>, tRefSLAltEngineIce: ReferenceTemperatures, tRef5000AltEngineIce: ReferenceTemperatures, tMaxFlexSLAltEngineIce: ReferenceTemperatures, tMaxFlex5000AltEngineIce: ReferenceTemperatures, toAltPercADJWT2: TOAltitudeOffsets, landingWeight: LandingWeights) {
        self.name = name
        self.tRefSLEngineIce = tRefSLEngineIce
        self.tRef5000EngineIce = tRef5000EngineIce
        self.tMaxFlexSLEngineIce = tMaxFlexSLEngineIce
        self.tMaxFlex5000EngineIce = tMaxFlex5000EngineIce
        self.altName = altName
        self.altEnginePerfPercent = altEnginePerfPercent
        self.altEngineAltCorrPercent = altEngineAltCorrPercent
        self.altEngineISARateIncrease = altEngineISARateIncrease
        self.altEngineOEW = altEngineOEW
        self.tRefSLAltEngineIce = tRefSLAltEngineIce
        self.tRef5000AltEngineIce = tRef5000AltEngineIce
        self.tMaxFlexSLAltEngineIce = tMaxFlexSLAltEngineIce
        self.tMaxFlex5000AltEngineIce = tMaxFlex5000AltEngineIce
        self.toAltPercADJWT2 = toAltPercADJWT2
        self.landingWeight = landingWeight
    }
}

public struct ISAIncrease_ISAPlusRate: Codable, Equatable {
    let increase: Measurement<UnitTemperature>
    let rate: UInt
    
    public init(increase: Measurement<UnitTemperature>, rate: UInt) {
        self.increase = increase
        self.rate = rate
    }
}

public struct Flap: Codable, Equatable, Hashable {
    public let name: String
    public let toPerfImpactPercent: Double?
    public let landPerfImpactPercent: Double
    
    public init(name: String, toPerfImpactPercent: Double?, landPerfImpactPercent: Double) {
        self.name = name
        self.toPerfImpactPercent = toPerfImpactPercent
        self.landPerfImpactPercent = landPerfImpactPercent
    }
}

public struct Derate: Codable, Equatable, Hashable {
    public let name: String
    public let minusPercent: UInt
    
    public init(name: String, minusPercent: UInt) {
        self.name = name
        self.minusPercent = minusPercent
    }
}

public struct Bump: Codable, Equatable, Hashable {
    public let name: String
    public let plusPercent: UInt
    
    public init(name: String, plusPercent: UInt) {
        self.name = name
        self.plusPercent = plusPercent
    }
}

public struct RunwayLimit: Codable, Equatable {
    let warning: String
    let length: Measurement<UnitLength>
    
    public init(warning: String, length: Measurement<UnitLength>) {
        self.warning = warning
        self.length = length
    }
}

public struct Trim: Codable, Equatable {
    public let cg: Double
    public let trimTenths: UInt
    
    public init(cg: Double, trimTenths: UInt) {
        self.cg = cg
        self.trimTenths = trimTenths
    }
}

public struct Tank: Codable, Equatable {
    let name: String
    let weight: Measurement<UnitMass>
    public init(name: String, weight: Measurement<UnitMass>) {
        self.name = name
        self.weight = weight
    }
}

public struct ReferenceTemperatures: Codable, Equatable {
    let on: Measurement<UnitTemperature>
    let off: Measurement<UnitTemperature>
    
    public init(on: Measurement<UnitTemperature>, off: Measurement<UnitTemperature>) {
        self.on = on
        self.off = off
    }
}

public struct TOAltitudeOffsets: Codable, Equatable {
    let below: Int
    let above: Int
    
    public init(below: Int, above: Int) {
        self.below = below
        self.above = above
    }
}

public struct LandingWeights: Codable, Equatable {
    let weight: Measurement<UnitMass>
    let percADJ: Int
    
    public init(weight: Measurement<UnitMass>, percADJ: Int) {
        self.weight = weight
        self.percADJ = percADJ
    }
}
