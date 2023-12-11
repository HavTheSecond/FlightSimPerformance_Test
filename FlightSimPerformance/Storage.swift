import Foundation
import SwiftCSV
import PerformanceCalculator
import OSLog

@Observable
class Storage {
    var aircraft = [Aircraft]()
    var airports = [Airport]()
    
    static let logger = Logger(subsystem: "de.paulschuetz.FlightSimPerformance", category: "Importer")
    
    func importAircraft() {
        do {
            guard let csv = try CSV<Named>(name: "Aircraft.csv", delimiter: .semicolon) else {
                loadDefaultAircraft()
                return
            }
            try csv.enumerateAsArray(startAt: 1, rowLimit: nil) { [self] values in
                guard let newAircraft = loadAircraft(values) else {return}
                aircraft.append(newAircraft)
            }
        } catch {
            if let e = error as? CSVParseError {
                Storage.logger.warning("Invalid CSV: \(e.localizedDescription)")
            } else {
                Storage.logger.warning("Couldn't load file: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadAircraft(_ values: [String]) -> Aircraft? {
        guard values.count >= 155 else {return nil}
        
        let tanks = loadTanks(values)
        let toPerformances = loadTOPerfomances(values)
        let landPerformances = loadLandPerfomances(values)
        let flaps = loadFlaps(values)
        let autobrakes = loadAutobrakes(values)
        let engines = loadEngines(values)
        
        let name = values[0]
        let approachDetails = values[1]
        let performanceSummary = values[2]
        let typeCheck = values[155]
        let vrISA = Double(values[17]) ?? 150
        let isaIncrease_ISAPlusRate = splitDoubleNums(values[46])
        let lowestFlexName = values[69]
        let maxTempPlusISA = UInt(values[70]) ?? 0
        let (derates, bump) = loadDeratesAndBump(values)
        let runwayLimitFirstFlaps = loadRunwayLimitFirstFlaps(values)
        let maxApproachSpeedAddition = UInt(values[127]) ?? 0
        let headwindDivisionSpeedAddition = UInt(values[128]) ?? 1
        let oew = Double(values[3]) ?? 0
        let maxZFW = Double(values[4]) ?? 0
        let maxTOW = Double(values[35]) ?? 0
        let maxLandingWT = Double(values[36]) ?? 0
        let standardTaxiFuel = calcStdTaxiFuel(oew: kgs(oew))
        let (maxNoseUpTrim, zeroTrimZG, maxNoseDownTrim) = loadTrims(values)
        let firstClass = UInt(values[6]) ?? 0
        let business = UInt(values[8]) ?? 0
        let economy = UInt(values[10]) ?? 0
        let allEconomyPaxNo = UInt(values[12]) ?? 0
        let frontCargo = Double(values[13]) ?? 0
        let rearCargo = Double(values[14]) ?? 0
        let maxPayload = Double(values[16]) ?? 0
        let minContingency = Double(values[104]) ?? 0
        let minFinalReserve = Double(values[105]) ?? 0
        let maxWindTOLand = Double(values[80]) ?? 0
        let maxCrosswind = Double(values[81]) ?? 0
        let maxTailWindTO = -(Double(values[82]) ?? 0)
        let maxTailWindLand = -(Double(values[83]) ?? 0)
        let maxGlidepath = Double(values[90]) ?? 0
        let maxCrosswindAutoland = Double(values[88]) ?? 0
        let maxTailwindAutoland = -(Double(values[86]) ?? 0)
        let maxHeadwindAutoland = Double(values[87]) ?? 0
        let maxGlidepathAutoland = Double(values[89]) ?? 0
        let maxOperatingAltitude = Double(values[84]) ?? 0
        let standardMaximumAirfieldAltitude = Double(values[85]) ?? 0
        let maxTailwindSteepApproach = Double(values[91])
        let minStandardLandingFlapsIndex = flaps.firstIndex { flap in
            flap.name == values[126]
        } ?? 0
        let rccFlexLimit = UInt(values[92]) ?? 6
        
        var maxTailwindSteepApproachTF = nil as Measurement<UnitSpeed>?
        
        if let maxTailwindSteepApproach {
            maxTailwindSteepApproachTF = knts(-maxTailwindSteepApproach)
        }
        
        return Aircraft(name: name,
                        approachDetails: approachDetails,
                        performanceSummary: performanceSummary,
                        typeCheck: typeCheck,
                        vrISA: knts(vrISA),
                        toPerformances: toPerformances,
                        landPerformances: landPerformances,
                        flaps: flaps,
                        isaIncrease_ISAPlusRate: ISAIncrease_ISAPlusRate(increase: celsius(isaIncrease_ISAPlusRate.0), rate: UInt(isaIncrease_ISAPlusRate.1)),
                        lowestFlexName: lowestFlexName,
                        maxTempPlusISA: maxTempPlusISA,
                        derates: derates,
                        bump: bump,
                        runwayLimitFirstFlaps: runwayLimitFirstFlaps,
                        maxApproachSpeedAddition: maxApproachSpeedAddition,
                        headwindDivisionSpeedAddition: headwindDivisionSpeedAddition,
                        autobrakes: autobrakes,
                        engines: engines,
                        oew: kgs(oew),
                        maxZFW: kgs(maxZFW),
                        maxTOW: kgs(maxTOW),
                        maxLandingWT: kgs(maxLandingWT),
                        standardTaxiFuel: standardTaxiFuel,
                        maxNoseUpTrim: maxNoseUpTrim,
                        zeroTrimCG: zeroTrimZG,
                        maxNoseDownTrim: maxNoseDownTrim,
                        firstClass: firstClass,
                        business: business,
                        economy: economy,
                        allEconomyPaxNo: allEconomyPaxNo,
                        frontCargo: kgs(frontCargo),
                        rearCargo: kgs(rearCargo),
                        selectedMaxPayload: kgs(maxPayload),
                        tanks: tanks,
                        minContingencyFuelFor15Min: kgs(minContingency),
                        minFinalReserve: kgs(minFinalReserve),
                        maxWindTOLand: knts(maxWindTOLand),
                        maxCrosswind: knts(maxCrosswind),
                        maxTailWindTO: knts(maxTailWindTO),
                        maxTailWindLand: knts(maxTailWindLand),
                        maxGlidepath: degs(maxGlidepath),
                        maxCrosswindAutoland: knts(maxCrosswindAutoland),
                        maxTailwindAutoland: knts(maxTailwindAutoland),
                        maxHeadwindAutoland: knts(maxHeadwindAutoland),
                        maxGlidepathAutoland: degs(maxGlidepathAutoland),
                        maxOperatingAltitude: ft(maxOperatingAltitude),
                        standardMaximumAirfieldAltitude: ft(standardMaximumAirfieldAltitude),
                        maxTailwindSteepApproach: maxTailwindSteepApproachTF,
                        minStandardLandingFlapsIndex: UInt(minStandardLandingFlapsIndex),
                        rccFlexLimit: rccFlexLimit)
    }
    
    private func loadTanks(_ values: [String]) -> [Tank] {
        var tanks = [Tank]()
        let startIndex = 18
        for i in 0..<8 {
            let currentStart = startIndex + 2 * i
            let name = values[currentStart]
            guard let weight = Int(values[currentStart + 1]) else {continue}
            let tank = Tank(name: name, weight: kgs(Double(weight)))
            tanks.append(tank)
        }
        
        return tanks
    }
    
    private func loadTOPerfomances(_ values: [String]) -> [MeasuredPerformance] {
        var performances = [MeasuredPerformance]()
        
        let startIndex = 37
        
        for i in 0..<3 {
            let currentStart = startIndex + i * 3
            guard let weight = Double(values[currentStart]),
                  let dist = Double(values[currentStart + 1]),
                  let wt_isa_dist = Double(values[currentStart + 2]) else {continue}
            
            let dist2000: Double?, dist4000: Double?, dist6000: Double?, dist8000: Double?
            
            if i == 1 {
                dist2000 = Double(values[47])
                dist4000 = Double(values[48])
                dist6000 = Double(values[49])
                dist8000 = Double(values[50])
            } else {
                dist2000 = nil
                dist4000 = nil
                dist6000 = nil
                dist8000 = nil
            }
            
            let measuredPerf = MeasuredPerformance(weight: kgs(weight), distSea: meters(dist), dist2000: metersOpt(dist2000), dist4000: metersOpt(dist4000), dist6000: metersOpt(dist6000), dist8000: metersOpt(dist8000), dist10000: nil, WT_ISA_DIST: meters(wt_isa_dist))
            
            performances.append(measuredPerf)
        }
        
        return performances
    }
    
    private func loadLandPerfomances(_ values: [String]) -> [MeasuredPerformance] {
        var performances = [MeasuredPerformance]()
        
        let startIndex = 93
        
        for i in 0..<3 {
            let currentStart = startIndex + i * 2
            guard let weight = Double(values[currentStart]),
                  let dist = Double(values[currentStart + 1]) else {continue}
            
            let dist2000: Double?, dist4000: Double?, dist6000: Double?, dist8000: Double?, dist10000: Double?
            
            if i == 1 {
                dist2000 = Double(values[99])
                dist4000 = Double(values[100])
                dist6000 = Double(values[101])
                dist8000 = Double(values[102])
                dist10000 = Double(values[103])
            } else {
                dist2000 = nil
                dist4000 = nil
                dist6000 = nil
                dist8000 = nil
                dist10000 = nil
            }
            
            let measuredPerf = MeasuredPerformance(weight: kgs(weight), distSea: meters(dist), dist2000: metersOpt(dist2000), dist4000: metersOpt(dist4000), dist6000: metersOpt(dist6000), dist8000: metersOpt(dist8000), dist10000: metersOpt(dist10000), WT_ISA_DIST: nil)
            
            performances.append(measuredPerf)
        }
        
        return performances
    }
    
    private func loadFlaps(_ values: [String]) -> [Flap] {
        var flaps = [Flap]()
        
        let startIndexTO = 51
        let startIndexLand = 106
        
        if let landPerfImpactPercent = Double(values[startIndexLand + 1]) {
            flaps.append(Flap(name: "UP", toPerfImpactPercent: nil, landPerfImpactPercent: landPerfImpactPercent))
        }
        
        for i in 1..<10 {
            var name = values[startIndexTO + 2*(i-1)]
            if name == "" {
                name = values[startIndexLand + 2*i]
            }
            if name == "" {
                break
            }
            
            let toPerfImpactPercent = Double(values[startIndexTO + 2*(i-1) + 1])
            guard let landPerfImpactPercent = Double(values[startIndexLand + 2*i + 1]) else {break}
            
            flaps.append(Flap(name: name, toPerfImpactPercent: toPerfImpactPercent, landPerfImpactPercent: landPerfImpactPercent))
        }
        
        return flaps
    }
    
    private func loadAutobrakes(_ values: [String]) -> [String] {
        var brakes = [String]()
        
        let startIndex = 129
        
        for i in 0..<6 {
            let name = values[startIndex + i]
            if name != "" {
                brakes.append(name)
            } else {
                break
            }
        }
        
        return brakes
    }
    
    private func loadEngines(_ values: [String]) -> Engines {
        let startIndex = 138
        
        let name = values[startIndex]
        let tRefSLEngineIce = splitDoubleNums(values[startIndex + 1])
        let tRef5000EngineIce = splitDoubleNums(values[startIndex + 2])
        let tMaxFlexSLEngineIce = splitDoubleNums(values[startIndex + 4])
        let tMaxFlex5000EngineIce = splitDoubleNums(values[startIndex + 5])
        
        let altName = values[startIndex + 7]
        let altEnginePerfPercent = UInt(values[startIndex + 3])
        let altEngineCorrPercent = UInt(values[startIndex + 6])
        let altEngineISARateIncrease = UInt(values[startIndex + 8]) ?? 0
        let altEngineOEW = Double(values[startIndex + 9]) ?? 0
        
        let tRefSLAltEngineIce = splitDoubleNums(values[startIndex + 10])
        let tRef5000AltEngineIce = splitDoubleNums(values[startIndex + 11])
        let tMaxFlexSLAltEngineIce = splitDoubleNums(values[startIndex + 13])
        let tMaxFlex5000AltEngineIce = splitDoubleNums(values[startIndex + 14])
        let toAltPercADJWT2 = splitDoubleNums(values[startIndex + 15])
        let landingWeight = splitDoubleNums(values[startIndex + 16])
        
        return Engines(name: name,
                       tRefSLEngineIce: ReferenceTemperatures(on: celsius(tRefSLEngineIce.0), off: celsius(tRefSLEngineIce.1)),
                       tRef5000EngineIce: ReferenceTemperatures(on: celsius(tRef5000EngineIce.0), off: celsius(tRef5000EngineIce.1)),
                       tMaxFlexSLEngineIce: ReferenceTemperatures(on: celsius(tMaxFlexSLEngineIce.0), off: celsius(tMaxFlexSLEngineIce.1)),
                       tMaxFlex5000EngineIce: ReferenceTemperatures(on: celsius(tMaxFlex5000EngineIce.0), off: celsius(tMaxFlex5000EngineIce.1)),
                       altName: altName,
                       altEnginePerfPercent: altEnginePerfPercent,
                       altEngineAltCorrPercent: altEngineCorrPercent,
                       altEngineISARateIncrease: altEngineISARateIncrease,
                       altEngineOEW: kgs(altEngineOEW),
                       tRefSLAltEngineIce: ReferenceTemperatures(on: celsius(tRefSLAltEngineIce.0), off: celsius(tRefSLAltEngineIce.1)),
                       tRef5000AltEngineIce: ReferenceTemperatures(on: celsius(tRef5000AltEngineIce.0), off: celsius(tRef5000AltEngineIce.1)),
                       tMaxFlexSLAltEngineIce: ReferenceTemperatures(on: celsius(tMaxFlexSLAltEngineIce.0), off: celsius(tMaxFlexSLAltEngineIce.1)),
                       tMaxFlex5000AltEngineIce: ReferenceTemperatures(on: celsius(tMaxFlex5000AltEngineIce.0), off: celsius(tMaxFlex5000AltEngineIce.1)),
                       toAltPercADJWT2: TOAltitudeOffsets(below: Int(toAltPercADJWT2.0), above: Int(toAltPercADJWT2.1)),
                       landingWeight: LandingWeights(weight: kgs(landingWeight.0), percADJ: Int(landingWeight.1)))
    }
    
    func loadDeratesAndBump(_ values: [String]) -> ([Derate]?, Bump?) {
        var derates = nil as [Derate]?
        var bump = nil as Bump?
        
        let startIndex = 71
        
        for i in 0..<2 {
            let derateName = values[startIndex + 2*i]
            let deratePerc = Int(values[startIndex + 2*i + 1]) ?? 0
            
            if derateName == "" || deratePerc == 0 {
                break
            } else {
                if derates == nil {
                    derates = [Derate]()
                }
                
                derates?.append(Derate(name: derateName, minusPercent: UInt(-deratePerc)))
            }
        }
        
        let bumpName = values[startIndex + 4]
        let bumpPerc = UInt(values[startIndex + 5]) ?? 0
        
        if bumpName != "" && bumpPerc != 0 {
            bump = Bump(name: bumpName, plusPercent: bumpPerc)
        }
        
        return (derates, bump)
    }
    
    func loadRunwayLimitFirstFlaps(_ values: [String]) -> RunwayLimit? {
        let warning = values[77] + ", " + values[79]
        let limit = Double(values[78]) ?? 0
        
        guard warning != "" && limit > 0 else {return nil}
        
        return RunwayLimit(warning: warning, length: ft(limit))
    }
    
    private func calcStdTaxiFuel(oew: Measurement<UnitMass>) -> Measurement<UnitMass> {
        let kgsVal = oew.kgsVal
        if kgsVal < 100000 {
            return kgs(300)
        } else if kgsVal < 150000 {
            return kgs(500)
        } else {
            return kgs(1000)
        }
    }
    
    private func loadTrims(_ values: [String]) -> (Trim?, Double?, Trim?) {
        let nUpT = splitDoubleNums(values[135])
        let cg = Double(values[136])
        let nDnT = splitDoubleNums(values[137])
        
        var nUpTrim = nil as Trim?
        var nDnTrim = nil as Trim?
        
        if nUpT.1 != 0 {
            nUpTrim = Trim(cg: nUpT.0, trimTenths: UInt(nUpT.1))
        }
        
        if nDnT.1 != 0 {
            nDnTrim = Trim(cg: nDnT.0, trimTenths: UInt(nDnT.1))
        }
        
        return (nUpTrim, cg, nDnTrim)
    }
    
    private func splitDoubleNums(_ str: String) -> (Double, Double) {
        let nums = str.split { char in
            char == "/" || char == "_"
        }
        if nums.count > 1 {
            return (Double(nums[0]) ?? 0.0, Double(nums[1]) ?? 0.0)
        } else if nums.count == 1 {
            return (Double(nums[0]) ?? 0.0, 0.0)
        } else {
            return (0.0, 0.0)
        }
    }
    
    private func metersOpt(_ meterVal: Double?) -> Measurement<UnitLength>? {
        if let meterVal {
            return meters(meterVal)
        } else {
            return nil
        }
    }
    
    private func loadDefaultAircraft() {
        aircraft.append(DefaultData.a20n)
    }
    
    func importAirports() {
        do {
            guard let csv = try CSV<Named>(name: "Airports.csv", delimiter: .semicolon) else {
                loadDefaultAirport()
                return
            }
            try csv.enumerateAsArray(startAt: 1, rowLimit: nil) { [self] values in
                guard let newAirport = loadAirport(values) else {return}
                airports.append(newAirport)
            }
        } catch {
            if let e = error as? CSVParseError {
                Storage.logger.warning("Invalid CSV: \(e.localizedDescription)")
            } else {
                Storage.logger.warning("Couldn't load file: \(error.localizedDescription)")
            }
        }
    }
    
    func loadAirport(_ values: [String]) -> Airport? {
        guard values.count > 18,
              values[0] != "" else {return nil}
        
        let icao = values[0]
        let name = values[1]
        
        guard let elevation = Double(values[2]) else {return nil}
        
        var runways = [Runway]()
        
        let startIndex = 3
        for i in 0..<8 {
            let addition = i * 2
            let name = values[startIndex + addition]
            let length = Double(values[startIndex + addition + 1]) ?? 0
            
            guard name != "" && length != 0 else { continue }
            
            runways.append(Runway(name: name, length: ft(length)))
        }
        
        return Airport(icao: icao, name: name, elevation: ft(elevation), runways: runways)
    }
    
    private func loadDefaultAirport() {
        airports.append(DefaultData.eddf)
    }
}
