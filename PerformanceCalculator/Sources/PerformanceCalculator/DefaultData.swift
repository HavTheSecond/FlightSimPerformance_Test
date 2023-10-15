import Foundation

public struct DefaultData {
    static public var passengerWeight = Measurement(value: 175, unit: UnitMass.pounds)
    static public var baggageWeight = Measurement(value: 55, unit: UnitMass.pounds)
    
    static public var totalPassengerWeight: Measurement<UnitMass> {
        passengerWeight + baggageWeight
    }
    
    private init() {}
    
    
    static public var a20n: Aircraft {
        let tanks: [(name: String, weight: Measurement<UnitMass>)] = [
            (name: "OUTER WINGS", weight: kgs(1386)),
            (name: "INNER WINGS", weight: kgs(11038)),
            (name: "CENTRE", weight: kgs(6622))
        ]
        
        let toPerformances: [MeasuredPerformance] = [
            .init(weight: kgs(50000), distSea: meters(1000), dist2000: nil, dist4000: nil, dist6000: nil, dist8000: nil, dist10000: nil, WT_ISA_DIST: meters(1050)),
            .init(weight: kgs(75000), distSea: meters(1690), dist2000: meters(1770), dist4000: meters(1920), dist6000: meters(2050), dist8000: meters(2330), dist10000: nil, WT_ISA_DIST: meters(1750)),
            .init(weight: kgs(85000), distSea: meters(2300), dist2000: nil, dist4000: nil, dist6000: nil, dist8000: nil, dist10000: nil, WT_ISA_DIST: meters(2390))
        ]
        
        let landPerformances: [MeasuredPerformance] = [
            .init(weight: kgs(50000), distSea: meters(1143), dist2000: nil, dist4000: nil, dist6000: nil, dist8000: nil, dist10000: nil, WT_ISA_DIST: nil),
            .init(weight: kgs(60000), distSea: meters(1341), dist2000: meters(1402), dist4000: meters(1463), dist6000: meters(1554), dist8000: meters(1722), dist10000: meters(1900), WT_ISA_DIST: nil),
            .init(weight: kgs(70000), distSea: meters(1621), dist2000: nil, dist4000: nil, dist6000: nil, dist8000: nil, dist10000: nil, WT_ISA_DIST: nil)
        ]
        
        let flaps: [(name: String, toPerfImpactPercent: Double?, landPerfImpactPercent: Double)] = [
            (name: "UP", toPerfImpactPercent: nil, landPerfImpactPercent: 1.8),
            (name: "1+F", toPerfImpactPercent: 10, landPerfImpactPercent: 1.2),
            (name: "2", toPerfImpactPercent: 0.0000001, landPerfImpactPercent: 1.15),
            (name: "3", toPerfImpactPercent: -5, landPerfImpactPercent: 1.1),
            (name: "FULL", toPerfImpactPercent: -5, landPerfImpactPercent: 0.0000001)
        ]
        
        let autobrakes = ["LOW", "MED", "MAX MAN"]
        
        let engines = Engines(name: "CFM LEAP-1A", tRefSLEngineIce: (on: celsius(30), off: celsius(30)), tRef5000EngineIce: (on: celsius(30), off: celsius(30)), tMaxFlexSLEngineIce: (on: celsius(60), off: celsius(60)), tMaxFlex5000EngineIce: (on: celsius(60), off: celsius(60)), altName: "CFM LEAP-1A", altEnginePerfPercent: 100, altEngineAltCorrPercent: 100, altEngineISARateIncrease: 10031, altEngineOEW: kgs(42500), tRefSLAltEngineIce: (on: celsius(30), off: celsius(30)), tRef5000AltEngineIce: (on: celsius(30), off: celsius(30)), tMaxFlexSLAltEngineIce: (on: celsius(60), off: celsius(60)), tMaxFlex5000AltEngineIce: (on: celsius(60), off: celsius(60)), toAltPercADJWT2: (below: 100, above: 100), landingWeight: (weight: kgs(067400), percADJ: 001))
        
        return Aircraft(name: "A320neo", approachDetails: "Approach Cat C /  Weight Cat Medium / Max 4.2 deg Approach ", performanceSummary: "Range – 3500nm / Cruise M0.78 515kts / Max FL390", typeCheck: "A20N", vrISA: 142, toPerformances: toPerformances, landPerformances: landPerformances, flaps: flaps, isaIncrease_ISAPlusRate: (increase: celsius(15), rate: 10031), lowestFlexName: "OAT TO", maxTempPlusISA: 40, derates: nil, bump: nil, runwayLimitFirstFlaps: (warning: "MUST USE FLAP 2 OR 3, MIN RWY FOR FLAP 1+F T/O", lengthInFeet: 2000), maxApproachSpeedAddition: 15, headwindDivisionSpeedAddition: 3, autobrakes: autobrakes, engines: engines, oew: kgs(42500), maxZFW: kgs(62500), maxTOW: kgs(79000), maxLandingWT: kgs(67400), standardTaxiFuel: kgs(300), maxNoseUpTrim: (cg: 17, trimTenths: 25), zeroTrimCG: 28.5, maxNoseDownTrim: (cg: 40, trimTenths: 25), firstClass: 0, business: 12, economy: 162, allEconomyPaxNo: 186, frontCargo: kgs(3402), rearCargo: kgs(6033), tanks: tanks, minContingencyFuelFor15Min: kgs(550), minFinalReserve: kgs(898), maxWindTOLand: knts(50), maxCrosswind: knts(38), maxTailWindTO: knts(10), maxTailWindLand: knts(15), maxGlidepath: degs(4.2), maxCrosswindAutoland: knts(20), maxTailwindAutoland: knts(10), maxHeadwindAutoland: knts(30), maxGlidepathAutoland: degs(3.15), maxOperatingAltitude: ft(39000), standardMaximumAirfieldAltitude: ft(9000), maxTailwindSteepApproach: nil, minStandardLandingFlapsIndex: 3, rccFlexLimit: 4)
    }
    
    static public var eddf: Airport {
        let runways: [(name: String, length: Measurement<UnitLength>)] = [
            (name: "07C", length: ft(13123)),
            (name: "07L", length: ft(9186)),
            (name: "07R", length: ft(13123)),
            (name: "18", length: ft(13018)),
            (name: "25C", length: ft(13123)),
            (name: "25R", length: ft(9186)),
            (name: "25L", length: ft(13123)),
            (name: "36", length: ft(13018))
        ]
        
        return Airport(icao: "EDDF", name: "FRANKFURT/MAIN", elevation: ft(364), runways: runways)
    }
}

public func kgs(_ kgs: Double) -> Measurement<UnitMass> {
    Measurement(value: kgs, unit: .kilograms)
}

public func ft(_ ft: Double) -> Measurement<UnitLength> {
    Measurement(value: ft, unit: .feet)
}

public func meters(_ meters: Double) -> Measurement<UnitLength> {
    Measurement(value: meters, unit: .meters)
}

public func knts(_ knts: Double) -> Measurement<UnitSpeed> {
    Measurement(value: knts, unit: .knots)
}

public func degs(_ degs: Double) -> Measurement<UnitAngle> {
    Measurement(value: degs, unit: .degrees)
}

public func hps(_ hps: Double) -> Measurement<UnitPressure> {
    Measurement(value: hps, unit: .hectopascals)
}

public func celsius(_ celsius: Double) -> Measurement<UnitTemperature> {
    Measurement(value: celsius, unit: .celsius)
}

extension Measurement<UnitTemperature> {
    public var celsiusVal: Double {
        converted(to: .celsius).value
    }
}

extension Measurement<UnitPressure> {
    public var hpVal: Double {
        converted(to: .hectopascals).value
    }
}

extension Measurement<UnitAngle> {
    public var radiansVal: Double {
        converted(to: .radians).value
    }
}

extension Measurement<UnitMass> {
    public var kgsVal: Double {
        converted(to: .kilograms).value
    }
}

extension Measurement<UnitLength> {
    public var ftVal: Double {
        converted(to: .feet).value
    }
    
    public var meterVal: Double {
        converted(to: .meters).value
    }
}

extension Measurement<UnitSpeed> {
    public var kntValue: Double {
        converted(to: .knots).value
    }
}

extension Double {
    public func roundedToTenths() -> Double {
        let tenTimes = self * 10
        let tenTimesRounded = tenTimes.rounded()
        return tenTimesRounded / 10
    }
    
    public func roundedToHundreths() -> Double {
        let hundredTimes = self * 100
        let hundredTimesRounded = hundredTimes.rounded()
        return hundredTimesRounded / 100
    }
}
