import Foundation

class Calculator {
    var aircraft: Aircraft
    var useStandardEO = true
    var cabinType = CabinType.mixed
    
    var departureAirport: Airport
    var departureRunwayIndex: UInt = 0
    var departureRunwayCondition: RunwayCondition = RunwayCondition.conditions.first!
    var departureRunwayRCC: UInt {
        let necessarySubtraction = (departureRunwayCondition.description == "SNOW COMPACTED" && departureTemp > Measurement(value: -15, unit: .celsius)) ? UInt(1) : 0
        return departureRunwayCondition.rcc - necessarySubtraction
    }
    var departureRunway: (name: String, length: Measurement<UnitLength>) {
        guard departureAirport.runways.count > departureRunwayIndex else {
            return (name: "N/A", length: ft(0))
        }
        
        return departureAirport.runways[Int(departureRunwayIndex)]
    }
    var departureDensityAltitude: Measurement<UnitLength> {
        departureAirport.elevation + ft((hps(1013) -  departureQNH).hpVal * 27)
        + (ft((departureTemp - celsius(15)).celsiusVal) + departureAirport.elevation / 500) * 120
    }
    
    var paxTotal: UInt = 0
    
    var paxFirstClass: UInt {
        guard maxPaxFirstClass != 0 else {return 0}
        
        let ratio = Double(paxTotal) / Double(maxPaxTotal)
        return UInt((ratio * Double(maxPaxFirstClass)).rounded())
    }
    
    var paxBusiness: UInt {
        guard maxPaxBusiness != 0 else {return 0}
        
        let ratio = Double(paxTotal) / Double(maxPaxTotal)
        return UInt((ratio * Double(maxPaxBusiness)).rounded())
    }
    
    var paxEconomy: UInt {
        paxTotal - paxFirstClass - paxBusiness
    }
    
    var maxPaxTotal: UInt {
        maxPaxFirstClass + maxPaxBusiness + maxPaxEconomy
    }
    
    var maxPaxFirstClass: UInt {
        if cabinType == .mixed {
            aircraft.firstClass
        } else {
            0
        }
    }
    
    var maxPaxBusiness: UInt {
        if cabinType == .mixed {
            aircraft.business
        } else {
            0
        }
    }
    
    var maxPaxEconomy: UInt {
        switch cabinType {
            case .mixed:
                aircraft.economy
            case .economyOnly:
                aircraft.allEconomyPaxNo
            case .cargo:
                0
        }
    }
    
    var paxWeightFirstClass: Measurement<UnitMass> {
        Double(paxFirstClass) * DefaultData.passengerWeight
    }
    
    var paxWeightBusiness: Measurement<UnitMass> {
        Double(paxBusiness) * DefaultData.passengerWeight
    }
    
    var paxWeightEconomy: Measurement<UnitMass> {
        paxWeightTotal - paxWeightFirstClass - paxWeightBusiness
    }
    
    var paxWeightTotal: Measurement<UnitMass> {
        Double(paxTotal) * DefaultData.passengerWeight
    }
    
    var cargoWeight = kgs(0)
    var blockFuel = kgs(0)
    var tripFuel = kgs(0)
    var taxiOut = kgs(0)
    var alternate = kgs(0)
    var finalReserve = kgs(0)
    
    var minimumTOFuel: Measurement<UnitMass> {
        blockFuel - taxiOut
    }
    
    var maxFuelWeight: Measurement<UnitMass> {
        aircraft.maxFuelWeight
    }
    
    var fuelTanks: [(name: String, fillPercentage: Double, weight: Measurement<UnitMass>, capacity: Measurement<UnitMass>)] {
        var result = [(name: String, fillPercentage: Double, weight: Measurement<UnitMass>, capacity: Measurement<UnitMass>)]()
        var distributedFuel = kgs(0)
        for (name, weight) in aircraft.tanks {
            let fillWith = min(weight, blockFuel - distributedFuel)
            distributedFuel = distributedFuel + fillWith
            let fillPercentage = fillWith.kgsVal / weight.kgsVal * 100
            result.append((name: name, fillPercentage: fillPercentage, weight: fillWith, capacity: weight))
        }
        let totalCapacity = aircraft.maxFuelWeight
        result.insert((name: "TOTAL", fillPercentage: blockFuel.kgsVal / totalCapacity.kgsVal * 100, weight: blockFuel, capacity: totalCapacity), at: 0)
        
        return result
    }
    
    var revisedOEW = nil as Measurement<UnitMass>?
    
    var actualOEW: Measurement<UnitMass> {
        revisedOEW ?? savedOEW
    }
    
    var savedOEW: Measurement<UnitMass> {
        if useStandardEO {
            aircraft.oew
        } else {
            aircraft.engines.altEngineOEW
        }
    }
    
    var payloadWeight: Measurement<UnitMass> {
        Double(paxTotal) * DefaultData.totalPassengerWeight + cargoWeight
    }
    
    var payloadLoadPercentage: Double {
        payloadWeight.kgsVal / maxPayloadWeight.kgsVal * 100
    }
    
    var maxPayloadWeight: Measurement<UnitMass> {
        if cabinType == .cargo {
            return aircraft.maximumPayload
        } else {
            return aircraft.maxZFW - actualOEW
        }
    }
    
    var baggageWeightTotal: Measurement<UnitMass> {
        Double(paxTotal) * DefaultData.baggageWeight
    }
    
    var totalMainDeckCargoWeight: Measurement<UnitMass>? {
        guard cabinType == .cargo else {return nil}
        return cargoWeight - totalFrontCargoWeight - totalRearCargoWeight
    }
    
    var maxMainDeckCargoWeight: Measurement<UnitMass>? {
        guard cabinType == .cargo else {return nil}
        return aircraft.mainDeck
    }
    
    var totalBaggageAndCargoWeight: Measurement<UnitMass> {
        cargoWeight + baggageWeightTotal
    }
    
    var maxBaggageAndCargoWeight: Measurement<UnitMass> {
        min(maxPayloadWeight, maxFrontCargoWeight + maxRearCargoWeight + (maxMainDeckCargoWeight ?? kgs(0)))
    }
    
    var totalFrontCargoWeight: Measurement<UnitMass> {
        if cabinType == .cargo {
            cargoWeight * (maxFrontCargoWeight.kgsVal / maxPayloadWeight.kgsVal)
        } else {
            cargoWeight * (maxFrontCargoWeight.kgsVal / (maxFrontCargoWeight + maxRearCargoWeight).kgsVal) + baggageWeightFront
        }
    }
    
    var maxFrontCargoWeight: Measurement<UnitMass> {
        aircraft.frontCargo
    }
    
    var baggageWeightFront: Measurement<UnitMass> {
        baggageWeightTotal * (maxFrontCargoWeight.kgsVal / (maxFrontCargoWeight + maxRearCargoWeight + (maxMainDeckCargoWeight ?? kgs(0))).kgsVal)
    }
    
    var totalRearCargoWeight: Measurement<UnitMass> {
        if cabinType == .cargo {
            cargoWeight * (maxFrontCargoWeight.kgsVal / maxPayloadWeight.kgsVal)
        } else {
            totalBaggageAndCargoWeight - totalFrontCargoWeight
        }
    }
    
    var maxRearCargoWeight: Measurement<UnitMass> {
        aircraft.rearCargo
    }
    
    var baggageWeightRear: Measurement<UnitMass> {
        baggageWeightTotal - baggageWeightFront
    }
    
    var zeroFuelWeight: Measurement<UnitMass> {
        actualOEW + payloadWeight
    }
    
    var maxZFW: Measurement<UnitMass> {
        aircraft.maxZFW
    }
    
    var rampWeight: Measurement<UnitMass> {
        zeroFuelWeight + blockFuel
    }
    
    var maxRampWeight: Measurement<UnitMass> {
        aircraft.maxRampWT
    }
    
    var tow: Measurement<UnitMass> {
        rampWeight - taxiOut
    }
    
    var maxTOW: Measurement<UnitMass> {
        aircraft.maxTOW
    }
    
    var destinationLandingWeight: Measurement<UnitMass> {
        tow - tripFuel
    }
    
    var alternateLandingWeight: Measurement<UnitMass> {
        destinationLandingWeight - alternate
    }
    
    var maxLandingWT: Measurement<UnitMass> {
        aircraft.maxLandingWT
    }
    
    var zfwCG = 25.0
    
    /// - Returns negative Value if nose down trim
    var toTrim: Double? {
        guard let noseUp = aircraft.maxNoseUpTrim,
              let zeroTrimCG = aircraft.zeroTrimCG,
              let noseDown = aircraft.maxNoseDownTrim else {return nil}
        
        let maxNoseUpTrim = Double(noseUp.trimTenths) / 10.0
        let forwardCGDifference = zfwCG < zeroTrimCG ? zeroTrimCG - zfwCG : 0
        let noseUpTrim = noseUp.trimTenths == 0 ? 0 : maxNoseUpTrim / (zeroTrimCG - noseUp.cg) * forwardCGDifference
        
        
        let maxNoseDownTrim = Double(noseDown.trimTenths) / 10.0
        let aftCGDifference = zfwCG > zeroTrimCG ? zeroTrimCG - zfwCG : 0
        let noseDownTrim = noseDown.trimTenths == 0 ? 0 : maxNoseDownTrim / (noseDown.cg - zeroTrimCG) * aftCGDifference
        
        return noseDownTrim + noseUpTrim
    }
    
    var departureWindDir = degs(0)
    var departureWindSpd = knts(0)
    
    var departureHeadOrTailWind: Measurement<UnitSpeed> {
        let trueWind = cos((departureWindDir - rwyDir(name: departureRunway.name)).radiansVal)
        return departureWindSpd * trueWind
    }
    var departureCrossWind: Measurement<UnitSpeed> {
        let trueXWind = abs(sin((rwyDir(name: departureRunway.name) - departureWindDir).radiansVal))
        return departureWindSpd * trueXWind
    }
    
    private func rwyDir(name: String) -> Measurement<UnitAngle> {
        guard name.count > 1 else {return degs(0)}
        let index0 = name.startIndex
        let index1 = name.index(after: index0)
        let number = Double(name[index0 ... index1]) ?? 0
        
        return degs(number * 10)
    }
    
    var departureTemp = celsius(15)
    var departureQNH = hps(1013)
    
    init() {
        aircraft = DefaultData.a20n
        departureAirport = DefaultData.eddf
    }
}

struct RunwayCondition {
    let description: String
    let rcc: UInt
    
    static let conditions: [RunwayCondition] = [
        .init(description: "DRY", rcc: 6),
        .init(description: "WET / FROST / SLUSH / SNOW  < 3MM", rcc: 5),
        .init(description: "SNOW COMPACTED", rcc: 4),
        .init(description: "WET 'SLIPPERY WET' RUNWAY", rcc: 3),
        .init(description: "SNOW - WET OR DRY > 3MM", rcc: 3),
        .init(description: "STANDING WATER / SLUSH > 3MM", rcc: 2),
        .init(description: "ICE", rcc: 1),
        .init(description: "WATER OR SNOW ON ICE", rcc: 0)
    ]
}

enum CabinType {
    case mixed, economyOnly, cargo
}
