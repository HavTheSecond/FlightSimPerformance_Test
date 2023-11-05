import Foundation

@Observable
public class Calculator: Codable {
    public var data: InternalData
    
    public var passengerWeight: Measurement<UnitMass> {
        get {
            data.passengerWeight
        }
        set {
            data.passengerWeight = newValue
        }
    }
    public var baggageWeight: Measurement<UnitMass> {
        get {
            data.baggageWeight
        }
        set {
            data.baggageWeight = newValue
        }
    }
    public var totalPassengerWeight: Measurement<UnitMass> {
        passengerWeight + baggageWeight
    }
    
    public func resetData() {
        data = InternalData(aircraft: DefaultData.a20n, departureAirport: DefaultData.eddf)
    }
    
    public var aircraft: Aircraft {
        get {
            data.aircraft
        }
        set {
            data.aircraft = newValue
        }
    }
    public var useStandardEO: Bool {
        get {
            data.useStandardEO
        }
        set {
            data.useStandardEO = newValue
        }
    }
    public var cabinType: CabinType {
        get {
            data.cabinType
        }
        set {
            data.cabinType = newValue
        }
    }
    
    public var packsOn: Bool {
        get {
            data.packsOn
        }
        set {
            data.packsOn = newValue
        }
    }
    public var antiIce: Bool {
        get {
            data.antiIce
        }
        set {
            data.antiIce = newValue
        }
    }
    public var takeoffFlapsIndex: Int {
        get {
            data.takeoffFlapsIndex
        }
        set {
            data.takeoffFlapsIndex = newValue
        }
    }
    
    public var requestedFlexType: RequestedFlexType {
        get {
            data.requestedFlexType
        }
        set {
            data.requestedFlexType = newValue
        }
    }
    public var selectedFlexTemp: Measurement<UnitTemperature> {
        get {
            data.selectedFlexTemp
        }
        set {
            data.selectedFlexTemp = newValue
        }
    }
    public var selectedDeratePerc: Int {
        if case .derate(let percentage) = requestedFlexType {
            return percentage
        } else {
            return 0
        }
    }
    
    public var departureAirport: Airport {
        get {
            data.departureAirport
        }
        set {
            data.departureAirport = newValue
        }
    }
    public var departureRunwayIndex: UInt {
        get {
            data.departureRunwayIndex
        }
        set {
            data.departureRunwayIndex = newValue
        }
    }
    public var departureRunwayCondition: RunwayCondition {
        get {
            data.departureRunwayCondition
        }
        set {
            data.departureRunwayCondition = newValue
        }
    }
    public var departureRunwayLengthSubtraction: Measurement<UnitLength> {
        get {
            data.departureRunwayLengthSubtraction
        }
        set {
            data.departureRunwayLengthSubtraction = newValue
        }
    }
    public var paxTotal: UInt {
        get {
            data.paxTotal
        }
        set {
            data.paxTotal = newValue
        }
    }
    
    public var cargoWeight: Measurement<UnitMass> {
        get {
            data.cargoWeight
        }
        set {
            data.cargoWeight = newValue
        }
    }
    public var blockFuel: Measurement<UnitMass> {
        get {
            data.blockFuel
        }
        set {
            data.blockFuel = newValue
        }
    }
    public var tripFuel: Measurement<UnitMass> {
        get {
            data.tripFuel
        }
        set {
            data.tripFuel = newValue
        }
    }
    public var contingencyFuel: Measurement<UnitMass> {
        get {
            data.contingencyFuel
        }
        set {
            data.contingencyFuel = newValue
        }
    }
    public var taxiOut: Measurement<UnitMass> {
        get {
            data.taxiOut
        }
        set {
            data.taxiOut = newValue
        }
    }
    public var alternate: Measurement<UnitMass> {
        get {
            data.alternate
        }
        set {
            data.alternate = newValue
        }
    }
    public var finalReserve: Measurement<UnitMass> {
        get {
            data.finalReserve
        }
        set {
            data.finalReserve = newValue
        }
    }
    
    public var actualZFW: Measurement<UnitMass>? {
        get {
            data.actualZFW
        }
        set {
            data.actualZFW = newValue
        }
    }
    
    public var revisedOEW: Measurement<UnitMass>? {
        get {
            data.revisedOEW
        }
        set {
            data.revisedOEW = newValue
        }
    }
    
    public var zfwCG: Double {
        get {
            data.zfwCG
        }
        set {
            data.zfwCG = newValue
        }
    }
    
    public var departureWindDir: Measurement<UnitAngle> {
        get {
            data.departureWindDir
        }
        set {
            data.departureWindDir = newValue
        }
    }
    public var departureWindSpd: Measurement<UnitSpeed> {
        get {
            data.departureWindSpd
        }
        set {
            data.departureWindSpd = newValue
        }
    }
    
    public var departureTemp: Measurement<UnitTemperature> {
        get {
            data.departureTemp
        }
        set {
            data.departureTemp = newValue
        }
    }
    public var departureQNH: Measurement<UnitPressure> {
        get {
            data.departureQNH
        }
        set {
            data.departureQNH = newValue
        }
    }
    
    public init() {
        data = InternalData(aircraft: DefaultData.a20n, departureAirport: DefaultData.eddf)
    }
    
    public var calculatedFlexTemp: Measurement<UnitTemperature>? {
        guard flexPermitted,
              requestedFlexType == .autoFlex else {return nil}
        
        return rwyMaxFlex
    }
    
    public var v1DifferenceToVR: Measurement<UnitSpeed> {
        let aw41 = aircraft.landPerformances[2].distSea.meterVal / 2
        let remainingSpace = (departureRunway.length - requiredDistance).meterVal
        let av42 = aw41 - remainingSpace
        let aw42 = knts(av42 / -50)
        
        return min(aw42, knts(0))
    }
    
    public var runwayWetFlexAllowed: Bool {
        departureRunwayRCC > aircraft.rccFlexLimit
    }
    
    public var runwayContaminatedFlexAllowed: Bool {
        departureRunwayRCC >= 4
    }
    
    public var isaDeviation: Measurement<UnitTemperature> {
        departureTemp - celsius(15) + celsius(departureAirport.elevation.ftVal * 1.98 / 1000)
    }
    
    private var growthList: [Measurement<UnitLength>] {
        let toPerformances = aircraft.toPerformances
        let specificPerformance = toPerformances[1]
        var altitudeDifferences = [
            (ft(2000), specificPerformance.dist2000! - specificPerformance.distSea),
            (ft(4000), specificPerformance.dist4000! - specificPerformance.dist2000!),
            (ft(6000), specificPerformance.dist6000! - specificPerformance.dist4000!),
            (ft(8000), specificPerformance.dist8000! - specificPerformance.dist6000!)
        ]
        var altitudeCorrections = altitudeDifferences.map { (altitude, difference) in
            if departureDensityAltitude > altitude {
                return difference
            } else {
                return meters((departureDensityAltitude - (altitude - ft(2000))).ftVal) * difference.meterVal / 2000
            }
        }
        
        let newDifference = altitudeDifferences.last!.1 * 1.53
        altitudeDifferences.append((ft(10000), newDifference))
        if departureDensityAltitude < ft(8000) {
            altitudeCorrections.append(meters(0))
        } else {
            altitudeCorrections.append((meters(departureDensityAltitude.ftVal) - (meters(10000) - meters(2000))) * newDifference.meterVal / 2000)
        }
        
        let correctionSum = altitudeCorrections.reduce(into: meters(0)) { partialResult, correction in
            if correction >= meters(0)  {
                partialResult = partialResult + correction
            }
        }
        
        let beforeOffset = correctionSum - (correctionSum - (correctionSum * (tow.kgsVal / specificPerformance.weight.kgsVal)))
        let offset = aircraft.engines.toAltPercADJWT2
        let altitudeCorrection = beforeOffset * Double(tow < specificPerformance.weight ? offset.below : offset.above) / 100
        
        let measuredDist1 = aircraft.toPerformances[0].distSea
        let measuredDist2 = aircraft.toPerformances[1].distSea
        let measuredDist3 = aircraft.toPerformances[2].distSea
        
        let isaPlusDist1 = aircraft.toPerformances[0].WT_ISA_DIST ?? measuredDist1
        let isaPlusDist2 = aircraft.toPerformances[1].WT_ISA_DIST ?? measuredDist2
        let isaPlusDist3 = aircraft.toPerformances[2].WT_ISA_DIST ?? measuredDist3

        let measuredTOW1 = aircraft.toPerformances[0].weight
        let measuredTOW2 = aircraft.toPerformances[1].weight
        let measuredTOW3 = aircraft.toPerformances[2].weight
        
        let ratio1 = (measuredDist2 - measuredDist1).meterVal / (measuredTOW2 - measuredTOW1).kgsVal
        let ratio2 = (measuredDist3 - measuredDist2).meterVal / (measuredTOW3 - measuredTOW2).kgsVal
        let ratio3 = ratio2 * 1.5
        
        let isaPlusRatio1 = (isaPlusDist2 - isaPlusDist1).meterVal / (measuredTOW2 - measuredTOW1).kgsVal
        let isaPlusRatio2 = (isaPlusDist3 - isaPlusDist2).meterVal / (measuredTOW3 - measuredTOW2).kgsVal
        let isaPlusRatio3 = isaPlusRatio2 * 1.5
        
        let stdComp1 = ratio1 * (min(tow, measuredTOW2) - measuredTOW1).kgsVal
        let stdComp2 = tow < measuredTOW2 ? 0 : ratio2 * (min(tow, measuredTOW3) - measuredTOW2).kgsVal
        let stdComp3 = tow < measuredTOW3 ? 0 : ratio3 * (tow - measuredTOW3).kgsVal
        
        let isaPlusComp1 = isaPlusRatio1 * (min(tow, measuredTOW2) - measuredTOW1).kgsVal
        let isaPlusComp2 = tow < measuredTOW2 ? 0 : isaPlusRatio2 * (min(tow, measuredTOW3) - measuredTOW2).kgsVal
        let isaPlusComp3 = tow < measuredTOW3 ? 0 : isaPlusRatio3 * (tow - measuredTOW3).kgsVal
        
        let stdComps = [meters(stdComp1), meters(stdComp2), meters(stdComp3)]
        let isaPlusComps = [meters(isaPlusComp1), meters(isaPlusComp2), meters(isaPlusComp3)]
        
        var stdDist = stdComps.reduce(into: meters(0)) { partialResult, length in
            if length >= meters(0) {
                partialResult = partialResult + length
            }
        } + measuredDist1
        var isaPlusDist = isaPlusComps.reduce(into: meters(0)) { partialResult, length in
            if length >= meters(0) {
                partialResult = partialResult + length
            }
        } + isaPlusDist1
        
        if !useStandardEO {
            let perc = Double(aircraft.engines.altEnginePerfPercent ?? 100)
            stdDist = stdDist * perc / 100
            isaPlusDist = isaPlusDist * perc / 100
        }
        
        let yValues = [(stdDist + altitudeCorrection).meterVal, (isaPlusDist + altitudeCorrection).meterVal]
        let xValues = [isaZero.celsiusVal, isaPlus.celsiusVal, isaPlus.celsiusVal + 1, minFlex.celsiusVal.rounded(.down), selectedFlexTemp.celsiusVal.rounded(.down), tMaxFlex.celsiusVal.rounded(.down), departureTemp.celsiusVal]
        
        return exponentialRegression(inputX: [Double](xValues[0..<2]), inputY: yValues, newX: xValues).map { length in
            meters(length)
        }
    }
    
    private var tRef: Measurement<UnitTemperature> {
        trefMinDerate - celsius(departureAirport.elevation.ftVal / 500)
    }
    public var minFlex: Measurement<UnitTemperature> {
        max(tRef, departureTemp + celsius(1))
    }
    private var tMaxFlex: Measurement<UnitTemperature> {
        trefMaxFlex + departureTemp - isaDeviation
    }
    private var isaZero: Measurement<UnitTemperature> {
        departureTemp - isaDeviation
    }
    private var isaPlus: Measurement<UnitTemperature> {
        aircraft.isaIncrease_ISAPlusRate.increase + departureTemp - isaDeviation
    }
    
    private var trendList: [Measurement<UnitLength>] {
        let exponent = Double(useStandardEO ? aircraft.isaIncrease_ISAPlusRate.rate : aircraft.engines.altEngineISARateIncrease) / 10000.0
        let growthList = growthList
        let xValues = [isaPlus.celsiusVal, isaPlus.celsiusVal + 1.0, minFlex.celsiusVal.rounded(.down), selectedFlexTemp.celsiusVal, tMaxFlex.celsiusVal.rounded(.down), departureTemp.celsiusVal]
        let trendCalc = RegressionCalculator(xValues: [Double](xValues[0..<2]), yValues: [growthList[1].meterVal, pow(growthList[2].meterVal, exponent)])
        return xValues.map { meters(trendCalc.predictY(whenX: $0)) }
    }
    
    private var trefMinDerate: Measurement<UnitTemperature> {
        let options: [ReferenceTemperatures]
        let engines = aircraft.engines
        if useStandardEO {
            options = [engines.tRefSLEngineIce, engines.tRef5000EngineIce]
        } else {
            options = [engines.tRefSLAltEngineIce, engines.tRef5000AltEngineIce]
        }
        
        let engineValues = options.map { referenceTemp in
            (antiIce ? referenceTemp.on : referenceTemp.off).celsiusVal
        }
        
        let trendCalc = RegressionCalculator(xValues: [0, 5000], yValues: engineValues)
        return celsius(trendCalc.predictY(whenX: departureAirport.elevation.ftVal))
    }
    
    private var trefMaxFlex: Measurement<UnitTemperature> {
        let options: [ReferenceTemperatures]
        let engines = aircraft.engines
        if useStandardEO {
            options = [engines.tMaxFlexSLEngineIce, engines.tMaxFlex5000EngineIce]
        } else {
            options = [engines.tMaxFlexSLAltEngineIce, engines.tMaxFlex5000AltEngineIce]
        }
        
        let engineValues = options.map { refTemp in
            (antiIce ? refTemp.on : refTemp.off).celsiusVal
        }
        
        let trendCalc = RegressionCalculator(xValues: [0, 5000], yValues: engineValues)
        return celsius(trendCalc.predictY(whenX: departureAirport.elevation.ftVal))
    }
    
    private var perfTotal: Measurement<UnitLength> {
        isaDeviation > aircraft.isaIncrease_ISAPlusRate.increase ? trendList.last! : growthList.last!
    }
    
    private var minLength: Measurement<UnitLength> {
        let flapCalc = perfTotal + perfTotal * aircraft.flaps[takeoffFlapsIndex].toPerfImpactPercent! / 100
        let wind = departureHeadOrTailWind
        let vrISA = aircraft.vrISA.kntValue
        
        let windCorrHeadwind = flapCalc - (flapCalc * wind.kntValue / (vrISA * 2))
        let windCorrTailwind = flapCalc - (flapCalc * wind.kntValue * 1.5 / vrISA)
        
        let windCorr = wind.kntValue > 0 ? windCorrHeadwind : windCorrTailwind
        
        let rcamCalc = switch departureRunwayRCC {
        case 6: ft(0)
        case 5: windCorr * 0.02
        case 4: windCorr * 0.15
        case 3: windCorr * 0.2
        case 2: windCorr * 0.4
        case 1: windCorr * 0.67
        default: windCorr
        }
        
        let packsImpact = packsOn ? windCorr * 4 / 100 : ft(0)
        let antiIceImpact = antiIce ? windCorr * 3 / 100 : ft(0)
        
        return windCorr + rcamCalc + packsImpact + antiIceImpact
    }
    
    private var oatPerc: Double {
        minLength.meterVal * 100 / perfTotal.meterVal
    }
    
    private var derateAdditionalDistance: Measurement<UnitLength> {
        if case .derate(let percentage) = requestedFlexType {
            minLength * Double(percentage) / 100
        } else {
            meters(0)
        }
    }
    
    private var oatPercDerate: Double {
        return (minLength + derateAdditionalDistance).meterVal * 100 / perfTotal.meterVal
    }
    
    public var runwayLongEnoughForFlex: Bool {
        let alternativeMin = growthList[3] * oatPerc / 100
        
        return departureRunwayLength >= minLength && departureRunwayLength >= alternativeMin
    }
    
    public var flexPermitted: Bool {
        return runwayWetFlexAllowed && runwayContaminatedFlexAllowed && runwayLongEnoughForFlex && minFlex <= rwyMaxFlex
    }
    
    public var rwyMaxFlex: Measurement<UnitTemperature> {
        min(trendMaxFlexTemps.last!, tMaxFlex)
    }
    
    private var trendFlexRequiredDistances: [Measurement<UnitLength>] {
        let yValues = standardCalculationDistances[2..<5].map { $0.meterVal }
        var newX = trendMaxFlexTemps[2...].map { $0.celsiusVal }
        newX.append(rwyMaxFlex.celsiusVal.rounded(.down))
        let calculator = RegressionCalculator(xValues: [Double](newX[0..<3]), yValues: yValues)
        return newX.map { temp in
            meters(calculator.predictY(whenX: temp))
        }
    }
    
    public var requiredDistance: Measurement<UnitLength> {
        let trend = trendFlexRequiredDistances
        let standardDistance = minLength + derateAdditionalDistance
        let autoFlexDistance = trend[4]
        let thrustFlexDistance = trend[1]
        
        if flexPermitted {
            if requestedFlexType == .autoFlex {
                return autoFlexDistance
            } else if requestedFlexType == .selectedFlex {
                return thrustFlexDistance
            } else {
                return standardDistance
            }
        } else {
            return standardDistance
        }
    }
    
    private var standardCalculationDistances: [Measurement<UnitLength>] {
        let oatPerc = oatPerc
        let oatPercDerate = oatPercDerate
        var index = 0
        return trendList[0..<5].map {
            let factor = index < 3 ? oatPercDerate : oatPerc
            index += 1
            return ($0 * factor / 100)
        }
    }
    
    private var trendMaxFlexTemps: [Measurement<UnitTemperature>] {
        let yValues = [isaPlus.celsiusVal, isaPlus.celsiusVal + 1, minFlex.celsiusVal.rounded(.down), selectedFlexTemp.celsiusVal, tMaxFlex.celsiusVal.rounded(.down)]
        let trendCalc = RegressionCalculator(xValues: standardCalculationDistances.map{$0.meterVal}, yValues: yValues)
        var result = standardCalculationDistances.map { distance in
            trendCalc.predictY(whenX: distance.meterVal)
        }
        result.append(trendCalc.predictY(whenX: departureRunwayLength.meterVal))
        return result.map { temp in
            celsius(temp)
        }
    }
    
    public var maxFlexTemp: Measurement<UnitTemperature> {
        trendMaxFlexTemps.last ?? departureTemp
    }
    
    public var departureRunwayRCC: UInt {
        let necessarySubtraction = (departureRunwayCondition.description == "Snow Compacted" && departureTemp > Measurement(value: -15, unit: .celsius)) ? UInt(1) : 0
        return departureRunwayCondition.rcc - necessarySubtraction
    }
    
    public var departureRunwayBrakingQuality: BrakingQuality {
        calculateBrakingQuality(rcc: departureRunwayRCC)
    }
    
    public var departureRunway: Runway {
        guard departureAirport.runways.count > departureRunwayIndex else {
            return Runway(name: "N/A", length: ft(0))
        }
        
        return departureAirport.runways[Int(departureRunwayIndex)]
    }
    
    public var departureRunwayLength: Measurement<UnitLength> {
        departureRunway.length - departureRunwayLengthSubtraction
    }
    
    public var departureDensityAltitude: Measurement<UnitLength> {
        departureAirport.elevation + ft((hps(1013) -  departureQNH).hpVal * 27)
        + (ft((departureTemp - celsius(15)).celsiusVal) + departureAirport.elevation / 500) * 120
    }
    
    public var paxFirstClass: UInt {
        guard maxPaxFirstClass != 0 else {return 0}
        
        let ratio = Double(paxTotal) / Double(maxPaxTotal)
        return UInt((ratio * Double(maxPaxFirstClass)).rounded())
    }
    
    public var paxBusiness: UInt {
        guard maxPaxBusiness != 0 else {return 0}
        
        let ratio = Double(paxTotal) / Double(maxPaxTotal)
        return UInt((ratio * Double(maxPaxBusiness)).rounded())
    }
    
    public var paxEconomy: UInt {
        paxTotal - paxFirstClass - paxBusiness
    }
    
    public var maxPaxTotal: UInt {
        maxPaxFirstClass + maxPaxBusiness + maxPaxEconomy
    }
    
    public var maxPaxFirstClass: UInt {
        if cabinType == .mixed {
            aircraft.firstClass
        } else {
            0
        }
    }
    
    public var maxPaxBusiness: UInt {
        if cabinType == .mixed {
            aircraft.business
        } else {
            0
        }
    }
    
    public var maxPaxEconomy: UInt {
        switch cabinType {
            case .mixed:
                aircraft.economy
            case .economyOnly:
                aircraft.allEconomyPaxNo
            case .cargo:
                0
        }
    }
    
    public var paxWeightFirstClass: Measurement<UnitMass> {
        Double(paxFirstClass) * passengerWeight
    }
    
    public var paxWeightBusiness: Measurement<UnitMass> {
        Double(paxBusiness) * passengerWeight
    }
    
    public var paxWeightEconomy: Measurement<UnitMass> {
        paxWeightTotal - paxWeightFirstClass - paxWeightBusiness
    }
    
    public var paxWeightTotal: Measurement<UnitMass> {
        Double(paxTotal) * passengerWeight
    }
    
    public var paxAndBaggageTotal: Measurement<UnitMass> {
        Double(paxTotal) * totalPassengerWeight
    }
    
    public var maxCargoWeight: Measurement<UnitMass> {
        if cabinType == .cargo {
            return max(kgs(0),maxPayloadWeight - paxAndBaggageTotal)
        } else {
            let baggageAndCargoLimit = max(kgs(0), maxBaggageAndCargoWeight - baggageWeightTotal)
            let payloadLimit = max(kgs(0),maxPayloadWeight - paxAndBaggageTotal)
            let rampLimit = maxRampWeight - blockFuel - actualOEW - paxAndBaggageTotal
            let towLimit = maxTOW - blockFuel + taxiOut - actualOEW - paxAndBaggageTotal
            let limitation = min(baggageAndCargoLimit, payloadLimit, rampLimit, towLimit)
            return max(kgs(0), limitation)
        }
    }
    
    public var situationalMaxTOW: Measurement<UnitMass> {
        let landingWeightPotential = maxLandingWT + tripFuel
        return min(maxTOW, landingWeightPotential)
    }
    
    public var situationalMaxZFW: Measurement<UnitMass> {
        let rampWeightPotential = min(maxRampWeight, maxTOW + taxiOut) - blockFuel
        let fuelToLanding = taxiOut + tripFuel
        let remainingFuel = blockFuel - fuelToLanding
        let landingWeightPotential = maxLandingWT - remainingFuel
        return min(maxZFW, rampWeightPotential, landingWeightPotential)
    }
    
    public var situationalMaxOEW: Measurement<UnitMass> {
        return situationalMaxZFW - payloadWeight
    }
    
    public var extraFuel: Measurement<UnitMass> {
        blockFuel - taxiOut - tripFuel - contingencyFuel - alternate - finalReserve
    }
    
    public var minimumTOFuel: Measurement<UnitMass> {
        blockFuel - taxiOut - extraFuel
    }
    
    public var maxFuelWeight: Measurement<UnitMass> {
        aircraft.maxFuelWeight
    }
    
    public var situationalMaxFuelWeight: Measurement<UnitMass> {
        let rampWeightPotential = min(maxRampWeight, maxTOW + taxiOut) - zeroFuelWeight
        let fuelToLanding = taxiOut + tripFuel
        let landingWeightPotential = maxLandingWT - zeroFuelWeight + fuelToLanding
        return min(maxFuelWeight, rampWeightPotential, landingWeightPotential)
    }
    
    public var fuelTanks: [(name: String, fillPercentage: Double, weight: Measurement<UnitMass>, capacity: Measurement<UnitMass>)] {
        var result = [(name: String, fillPercentage: Double, weight: Measurement<UnitMass>, capacity: Measurement<UnitMass>)]()
        var distributedFuel = kgs(0)
        for tank in aircraft.tanks {
            let fillWith = min(tank.weight, blockFuel - distributedFuel)
            distributedFuel = distributedFuel + fillWith
            let fillPercentage = fillWith.kgsVal / tank.weight.kgsVal * 100
            result.append((name: tank.name, fillPercentage: fillPercentage, weight: fillWith, capacity: tank.weight))
        }
        let totalCapacity = aircraft.maxFuelWeight
        result.insert((name: "Total", fillPercentage: blockFuel.kgsVal / totalCapacity.kgsVal * 100, weight: blockFuel, capacity: totalCapacity), at: 0)
        
        return result
    }
    
    public var totalFuelVolume: Measurement<UnitVolume> {
        Measurement(value: blockFuel.kgsVal * 1.245576, unit: UnitVolume.liters)
    }
    
    public var actualOEW: Measurement<UnitMass> {
        revisedOEW ?? savedOEW
    }
    
    public var savedOEW: Measurement<UnitMass> {
        if useStandardEO {
            aircraft.oew
        } else {
            aircraft.engines.altEngineOEW
        }
    }
    
    public var weightDifference: Measurement<UnitMass> {
        payloadWeight - (paxAndBaggageTotal + cargoWeight)
    }
    
    public var payloadWeight: Measurement<UnitMass> {
        if let actualZFW {
            actualZFW - actualOEW
        } else {
            paxAndBaggageTotal + cargoWeight
        }
    }
    
    public var payloadLoadPercentage: Double {
        payloadWeight.kgsVal / maxPayloadWeight.kgsVal * 100
    }
    
    public var maxPayloadWeight: Measurement<UnitMass> {
        if cabinType == .cargo {
            return aircraft.maximumPayload
        } else {
            return aircraft.maxZFW - actualOEW
        }
    }
    
    public var baggageWeightTotal: Measurement<UnitMass> {
        Double(paxTotal) * baggageWeight
    }
    
    public var totalMainDeckCargoWeight: Measurement<UnitMass>? {
        guard cabinType == .cargo else {return nil}
        return cargoWeight - totalFrontCargoWeight - totalRearCargoWeight
    }
    
    public var maxMainDeckCargoWeight: Measurement<UnitMass>? {
        guard cabinType == .cargo else {return nil}
        return aircraft.mainDeck
    }
    
    public var totalBaggageAndCargoWeight: Measurement<UnitMass> {
        cargoWeight + baggageWeightTotal
    }
    
    public var maxBaggageAndCargoWeight: Measurement<UnitMass> {
        min(maxPayloadWeight, maxFrontCargoWeight + maxRearCargoWeight + (maxMainDeckCargoWeight ?? kgs(0)))
    }
    
    public var totalFrontCargoWeight: Measurement<UnitMass> {
        if cabinType == .cargo {
            cargoWeight * (maxFrontCargoWeight.kgsVal / maxPayloadWeight.kgsVal)
        } else {
            cargoWeight * (maxFrontCargoWeight.kgsVal / (maxFrontCargoWeight + maxRearCargoWeight).kgsVal) + baggageWeightFront
        }
    }
    
    public var maxFrontCargoWeight: Measurement<UnitMass> {
        aircraft.frontCargo
    }
    
    public var baggageWeightFront: Measurement<UnitMass> {
        baggageWeightTotal * (maxFrontCargoWeight.kgsVal / (maxFrontCargoWeight + maxRearCargoWeight + (maxMainDeckCargoWeight ?? kgs(0))).kgsVal)
    }
    
    public var totalRearCargoWeight: Measurement<UnitMass> {
        if cabinType == .cargo {
            cargoWeight * (maxRearCargoWeight.kgsVal / maxPayloadWeight.kgsVal)
        } else {
            totalBaggageAndCargoWeight - totalFrontCargoWeight
        }
    }
    
    public var maxRearCargoWeight: Measurement<UnitMass> {
        aircraft.rearCargo
    }
    
    public var baggageWeightRear: Measurement<UnitMass> {
        baggageWeightTotal - baggageWeightFront
    }
    
    public var zeroFuelWeight: Measurement<UnitMass> {
        actualOEW + payloadWeight
    }
    
    public var maxZFW: Measurement<UnitMass> {
        aircraft.maxZFW
    }
    
    public var rampWeight: Measurement<UnitMass> {
        zeroFuelWeight + blockFuel
    }
    
    public var maxRampWeight: Measurement<UnitMass> {
        aircraft.maxRampWT
    }
    
    public var tow: Measurement<UnitMass> {
        rampWeight - taxiOut
    }
    
    public var maxTOW: Measurement<UnitMass> {
        aircraft.maxTOW
    }
    
    public var destinationLandingWeight: Measurement<UnitMass> {
        tow - tripFuel
    }
    
    public var alternateLandingWeight: Measurement<UnitMass> {
        destinationLandingWeight - alternate
    }
    
    public var maxLandingWT: Measurement<UnitMass> {
        aircraft.maxLandingWT
    }
    
    public var canCalculateTrim: Bool {
        return aircraft.maxNoseUpTrim != nil && aircraft.maxNoseDownTrim != nil && aircraft.zeroTrimCG != nil
    }
    
    /// - Returns negative Value if nose down trim
    public var toTrim: Double? {
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
    
    public var departureHeadOrTailWind: Measurement<UnitSpeed> {
        let trueWind = cos((departureWindDir - rwyDir(name: departureRunway.name)).radiansVal)
        return departureWindSpd * trueWind
    }
    public var departureCrossWind: Measurement<UnitSpeed> {
        let trueXWind = abs(sin((rwyDir(name: departureRunway.name) - departureWindDir).radiansVal))
        return departureWindSpd * trueXWind
    }
    
    public var departureCrosswindDirection: CrossWindDirection {
        let diff = rwyDir(name: departureRunway.name) - departureWindDir
        if diff > degs(180) {
            return .right
        } else if diff > degs(0) && diff < degs(180) {
            return .left
        } else if diff < degs(0) && diff > degs(-180)  {
            return .right
        }  else if diff < degs(-180) {
            return .left
        } else {
            return .no
        }
    }
    
    private func rwyDir(name: String) -> Measurement<UnitAngle> {
        guard name.count > 1 else {return degs(0)}
        let index0 = name.startIndex
        let index1 = name.index(after: index0)
        let number = Double(name[index0 ... index1]) ?? 0
        
        return degs(number * 10)
    }
}

public struct RunwayCondition: Codable, Equatable, Hashable {
    public let description: String
    public let rcc: UInt
    
    static public let dry = RunwayCondition(description: "Dry", rcc: 6)
    static public let wetThin = RunwayCondition(description: "Wet / Frost / Slush / Snow  < 3mm", rcc: 5)
    static public let snowCompacted = RunwayCondition(description: "Snow Compacted", rcc: 4)
    static public let slipperyWet = RunwayCondition(description: "Wet 'Slippery Wet' Runway", rcc: 3)
    static public let snowThick = RunwayCondition(description: "Snow - Wet or Dry > 3mm", rcc: 3)
    static public let standingWaterThick = RunwayCondition(description: "Standing Water / Slush > 3mm", rcc: 2)
    static public let ice = RunwayCondition(description: "Ice", rcc: 1)
    static public let waterOnIce = RunwayCondition(description: "Water or Snow on Ice", rcc: 0)
    
    private init(description: String, rcc: UInt) {
        self.description = description
        self.rcc = rcc
    }
}

public enum CabinType: Codable, Equatable {
    case mixed, economyOnly, cargo
}

public enum RequestedFlexType: Codable, Equatable, Hashable {
    case standardThrust, selectedFlex, autoFlex, derate(Int)
}

public enum BrakingQuality: Codable, Equatable {
    case brakingGood, brakingGoodToMedium, brakingMedium, brakingMediumToPoor, brakingPoor, brakingBelowPoor
}

private func calculateBrakingQuality(rcc: UInt) -> BrakingQuality {
    switch rcc {
        case 0:
            return .brakingBelowPoor
        case 1:
            return .brakingPoor
        case 2:
            return .brakingMediumToPoor
        case 3:
            return .brakingMedium
        case 4:
            return .brakingGoodToMedium
        default:
            return .brakingGood
    }
}

public struct InternalData: Codable, Equatable {
    var aircraft: Aircraft
    var useStandardEO = true
    var cabinType = CabinType.mixed
    
    var packsOn = false
    var antiIce = false
    var takeoffFlapsIndex = 1
    
    var requestedFlexType = RequestedFlexType.autoFlex
    var selectedFlexTemp = celsius(74)
    
    var departureAirport: Airport
    var departureRunwayIndex: UInt = 0
    var departureRunwayCondition: RunwayCondition = RunwayCondition.dry
    var departureRunwayLengthSubtraction = ft(0)
    var paxTotal: UInt = 0
    
    var cargoWeight = kgs(0)
    var blockFuel = kgs(0)
    var tripFuel = kgs(0)
    var contingencyFuel = kgs(0)
    var taxiOut = kgs(0)
    var alternate = kgs(0)
    var finalReserve = kgs(0)
    
    var actualZFW = nil as Measurement<UnitMass>?
    
    var revisedOEW = nil as Measurement<UnitMass>?
    
    var zfwCG = 25.0
    
    var departureWindDir = degs(0)
    var departureWindSpd = knts(0)
    
    var departureTemp = celsius(15)
    var departureQNH = hps(1013)
    
    init(aircraft: Aircraft, departureAirport: Airport) {
        self.aircraft = aircraft
        self.departureAirport = departureAirport
    }
    
    public var passengerWeight = Measurement(value: 175, unit: UnitMass.pounds)
    public var baggageWeight = Measurement(value: 55, unit: UnitMass.pounds)
}

public enum CrossWindDirection {
    case left, no, right
}
