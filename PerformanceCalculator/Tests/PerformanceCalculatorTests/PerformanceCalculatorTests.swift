import XCTest
import PerformanceCalculator

final class PerformanceCalculatorTests: XCTestCase {
    let calculator = Calculator()
    
    override func setUp() {
        calculator.passengerWeight = kgs(79.3)
        calculator.baggageWeight = kgs(24.7)
    }
    
    func testDensityAltitude() {
        calculator.departureTemp = celsius(10)
        calculator.departureQNH = hps(1022)
        XCTAssertEqual(calculator.departureAirport.elevation, ft(364))
        XCTAssertEqual(calculator.departureDensityAltitude.value.rounded(), -392)
    }
    
    func testTrim() {
        calculator.zfwCG = 35.0
        XCTAssertEqual(calculator.toTrim?.roundedToTenths(), -1.4)
    }
    
    func testWinds() {
        calculator.departureRunwayIndex = 0
        XCTAssertEqual(calculator.departureRunway.name, "07C")
        calculator.departureWindDir = degs(180)
        calculator.departureWindSpd = knts(5)
        XCTAssertEqual(calculator.departureHeadOrTailWind.value.rounded(), -2)
        XCTAssertEqual(calculator.departureCrossWind.value.rounded(), 5)
    }
    
    func testRunwayCondition() {
        calculator.departureRunwayCondition = .dry
        XCTAssertEqual(calculator.departureRunwayRCC, 6)
        calculator.departureRunwayCondition = .ice
        XCTAssertEqual(calculator.departureRunwayRCC, 1)
        calculator.departureRunwayCondition = .snowCompacted
        calculator.departureTemp = celsius(-30)
        XCTAssertEqual(calculator.departureRunwayRCC, 4)
        calculator.departureTemp = celsius(7)
        XCTAssertEqual(calculator.departureRunwayRCC, 3)
    }
    
    func testWeights() {
        calculator.cabinType = .mixed
        calculator.passengerWeight = Measurement(value: 80, unit: UnitMass.kilograms)
        calculator.baggageWeight = Measurement(value: 24, unit: UnitMass.kilograms)
        calculator.paxTotal = 100
        XCTAssertEqual(calculator.paxTotal, 100)
        calculator.cargoWeight = kgs(150)
        calculator.blockFuel = kgs(7000)
        calculator.tripFuel = kgs(4979)
        calculator.contingencyFuel = kgs(400)
        calculator.taxiOut = kgs(200)
        calculator.alternate = kgs(1001)
        calculator.finalReserve = kgs(193)
        
        XCTAssertEqual(calculator.actualOEW.kgsVal.rounded(), 42500)
        XCTAssertEqual(calculator.maxZFW.kgsVal.rounded(), 62500)
        XCTAssertEqual(calculator.zeroFuelWeight.kgsVal.rounded(), 53050)
        XCTAssertEqual(calculator.maxRampWeight.kgsVal.rounded(), 79301)
        XCTAssertEqual(calculator.rampWeight.kgsVal.rounded(), 60050)
        XCTAssertEqual(calculator.maxPayloadWeight.kgsVal.rounded(), 20000)
        XCTAssertEqual(calculator.payloadWeight.kgsVal.rounded(), 10550)
        XCTAssertEqual(calculator.maxFuelWeight.kgsVal.rounded(), 19046)
        XCTAssertEqual(calculator.maxTOW.kgsVal.rounded(), 79000)
        XCTAssertEqual(calculator.tow.kgsVal.rounded(), 59850)
        XCTAssertEqual(calculator.maxLandingWT.kgsVal.rounded(), 67400)
        XCTAssertEqual(calculator.destinationLandingWeight.kgsVal.rounded(), 54871)
        XCTAssertEqual(calculator.alternateLandingWeight.kgsVal.rounded(), 53870)
        XCTAssertEqual(calculator.minimumTOFuel.kgsVal.rounded(), 6573)
        XCTAssertEqual(calculator.maxCargoWeight.kgsVal, 7035)
        XCTAssertEqual(calculator.extraFuel.kgsVal.rounded(), 227)
        
        XCTAssertEqual(calculator.paxFirstClass, 0)
        XCTAssertEqual(calculator.maxPaxFirstClass, 0)
        XCTAssertEqual(calculator.paxWeightFirstClass, kgs(0))
        XCTAssertEqual(calculator.paxBusiness, 7)
        XCTAssertEqual(calculator.maxPaxBusiness, 12)
        XCTAssertEqual(calculator.paxWeightBusiness, kgs(560))
        XCTAssertEqual(calculator.paxEconomy, 93)
        XCTAssertEqual(calculator.maxPaxEconomy, 162)
        XCTAssertEqual(calculator.paxWeightEconomy, kgs(7440))
        XCTAssertEqual(calculator.maxPaxTotal, 174)
        XCTAssertEqual(calculator.paxWeightTotal, kgs(8000))
        
        XCTAssertEqual(calculator.baggageWeightTotal.kgsVal.rounded(), 2400)
        XCTAssertEqual(calculator.totalBaggageAndCargoWeight.kgsVal.rounded(), 2550)
        XCTAssertEqual(calculator.maxBaggageAndCargoWeight.kgsVal.rounded(), 9435)
        
        XCTAssertEqual(calculator.baggageWeightFront.kgsVal.rounded(), 865)
        XCTAssertEqual(calculator.totalFrontCargoWeight.kgsVal.rounded(), 919)
        XCTAssertEqual(calculator.maxFrontCargoWeight.kgsVal.rounded(), 3402)
        
        XCTAssertEqual(calculator.baggageWeightRear.kgsVal.rounded(), 1535)
        XCTAssertEqual(calculator.totalRearCargoWeight.kgsVal.rounded(), 1631)
        XCTAssertEqual(calculator.maxRearCargoWeight.kgsVal.rounded(), 6033)
        
        XCTAssertEqual(calculator.totalMainDeckCargoWeight, nil)
        XCTAssertEqual(calculator.maxMainDeckCargoWeight, nil)
        
        XCTAssertEqual(calculator.payloadLoadPercentage.roundedToTenths(), 52.8)
        
        let tanks = calculator.fuelTanks
        
        XCTAssertEqual(tanks.count, 4)
        
        let total = tanks[0]
        XCTAssertEqual(total.name, "Total")
        XCTAssertEqual(total.capacity.kgsVal.rounded(), 19046)
        XCTAssertEqual(total.weight.kgsVal.rounded(), 7000)
        XCTAssertEqual(total.fillPercentage.roundedToTenths(), 36.8)
        
        guard tanks.count == 4 else {return}
        
        let outer = tanks[1]
        XCTAssertEqual(outer.name, "Outer Wings")
        XCTAssertEqual(outer.capacity.kgsVal.rounded(), 1386)
        XCTAssertEqual(outer.weight.kgsVal.rounded(), 1386)
        XCTAssertEqual(outer.fillPercentage.roundedToTenths(), 100)
        
        let inner = tanks[2]
        XCTAssertEqual(inner.name, "Inner Wings")
        XCTAssertEqual(inner.capacity.kgsVal.rounded(), 11038)
        XCTAssertEqual(inner.weight.kgsVal.rounded(), 5614)
        XCTAssertEqual(inner.fillPercentage.roundedToTenths(), 50.9)
        
        let centre = tanks[3]
        XCTAssertEqual(centre.name, "Centre")
        XCTAssertEqual(centre.capacity.kgsVal.rounded(), 6622)
        XCTAssertEqual(centre.weight.kgsVal.rounded(), 0)
        XCTAssertEqual(centre.fillPercentage.roundedToTenths(), 0)
    }
    
    func testActualZFW() {
        calculator.cabinType = .mixed
        calculator.passengerWeight = Measurement(value: 80, unit: UnitMass.kilograms)
        calculator.baggageWeight = Measurement(value: 24, unit: UnitMass.kilograms)
        calculator.paxTotal = 100
        XCTAssertEqual(calculator.paxTotal, 100)
        calculator.cargoWeight = kgs(150)
        calculator.blockFuel = kgs(7000)
        calculator.tripFuel = kgs(4979)
        calculator.contingencyFuel = kgs(400)
        calculator.taxiOut = kgs(200)
        calculator.alternate = kgs(1001)
        calculator.finalReserve = kgs(193)
        calculator.actualZFW = kgs(53550)
        
        XCTAssertEqual(calculator.actualOEW.kgsVal.rounded(), 42500)
        XCTAssertEqual(calculator.maxZFW.kgsVal.rounded(), 62500)
        XCTAssertEqual(calculator.zeroFuelWeight.kgsVal.rounded(), 53550)
        XCTAssertEqual(calculator.maxRampWeight.kgsVal.rounded(), 79301)
        XCTAssertEqual(calculator.rampWeight.kgsVal.rounded(), 60550)
        XCTAssertEqual(calculator.maxPayloadWeight.kgsVal.rounded(), 20000)
        XCTAssertEqual(calculator.payloadWeight.kgsVal.rounded(), 11050)
        XCTAssertEqual(calculator.maxFuelWeight.kgsVal.rounded(), 19046)
        XCTAssertEqual(calculator.maxTOW.kgsVal.rounded(), 79000)
        XCTAssertEqual(calculator.tow.kgsVal.rounded(), 60350)
        XCTAssertEqual(calculator.maxLandingWT.kgsVal.rounded(), 67400)
        XCTAssertEqual(calculator.destinationLandingWeight.kgsVal.rounded(), 55371)
        XCTAssertEqual(calculator.alternateLandingWeight.kgsVal.rounded(), 54370)
        XCTAssertEqual(calculator.minimumTOFuel.kgsVal.rounded(), 6573)
        XCTAssertEqual(calculator.maxCargoWeight.kgsVal, 7035)
        XCTAssertEqual(calculator.extraFuel.kgsVal.rounded(), 227)
        
        XCTAssertEqual(calculator.paxFirstClass, 0)
        XCTAssertEqual(calculator.maxPaxFirstClass, 0)
        XCTAssertEqual(calculator.paxWeightFirstClass, kgs(0))
        XCTAssertEqual(calculator.paxBusiness, 7)
        XCTAssertEqual(calculator.maxPaxBusiness, 12)
        XCTAssertEqual(calculator.paxWeightBusiness, kgs(560))
        XCTAssertEqual(calculator.paxEconomy, 93)
        XCTAssertEqual(calculator.maxPaxEconomy, 162)
        XCTAssertEqual(calculator.paxWeightEconomy, kgs(7440))
        XCTAssertEqual(calculator.maxPaxTotal, 174)
        XCTAssertEqual(calculator.paxWeightTotal, kgs(8000))
        
        XCTAssertEqual(calculator.baggageWeightTotal.kgsVal.rounded(), 2400)
        XCTAssertEqual(calculator.totalBaggageAndCargoWeight.kgsVal.rounded(), 2550)
        XCTAssertEqual(calculator.maxBaggageAndCargoWeight.kgsVal.rounded(), 9435)
        
        XCTAssertEqual(calculator.baggageWeightFront.kgsVal.rounded(), 865)
        XCTAssertEqual(calculator.totalFrontCargoWeight.kgsVal.rounded(), 919)
        XCTAssertEqual(calculator.maxFrontCargoWeight.kgsVal.rounded(), 3402)
        
        XCTAssertEqual(calculator.baggageWeightRear.kgsVal.rounded(), 1535)
        XCTAssertEqual(calculator.totalRearCargoWeight.kgsVal.rounded(), 1631)
        XCTAssertEqual(calculator.maxRearCargoWeight.kgsVal.rounded(), 6033)
        
        XCTAssertEqual(calculator.totalMainDeckCargoWeight, nil)
        XCTAssertEqual(calculator.maxMainDeckCargoWeight, nil)
        
        XCTAssertEqual(calculator.payloadLoadPercentage.roundedToTenths(), 55.3)
        
        let tanks = calculator.fuelTanks
        
        XCTAssertEqual(tanks.count, 4)
        
        let total = tanks[0]
        XCTAssertEqual(total.name, "Total")
        XCTAssertEqual(total.capacity.kgsVal.rounded(), 19046)
        XCTAssertEqual(total.weight.kgsVal.rounded(), 7000)
        XCTAssertEqual(total.fillPercentage.roundedToTenths(), 36.8)
        
        guard tanks.count == 4 else {return}
        
        let outer = tanks[1]
        XCTAssertEqual(outer.name, "Outer Wings")
        XCTAssertEqual(outer.capacity.kgsVal.rounded(), 1386)
        XCTAssertEqual(outer.weight.kgsVal.rounded(), 1386)
        XCTAssertEqual(outer.fillPercentage.roundedToTenths(), 100)
        
        let inner = tanks[2]
        XCTAssertEqual(inner.name, "Inner Wings")
        XCTAssertEqual(inner.capacity.kgsVal.rounded(), 11038)
        XCTAssertEqual(inner.weight.kgsVal.rounded(), 5614)
        XCTAssertEqual(inner.fillPercentage.roundedToTenths(), 50.9)
        
        let centre = tanks[3]
        XCTAssertEqual(centre.name, "Centre")
        XCTAssertEqual(centre.capacity.kgsVal.rounded(), 6622)
        XCTAssertEqual(centre.weight.kgsVal.rounded(), 0)
        XCTAssertEqual(centre.fillPercentage.roundedToTenths(), 0)
    }

    
    func testCargoConfigWeights() {
        calculator.cabinType = .cargo
        calculator.paxTotal = 0
        calculator.cargoWeight = kgs(17589)
        calculator.blockFuel = kgs(7000)
        calculator.tripFuel = kgs(4979)
        calculator.contingencyFuel = kgs(400)
        calculator.taxiOut = kgs(200)
        calculator.alternate = kgs(1001)
        calculator.finalReserve = kgs(193)
        
        XCTAssertEqual(calculator.actualOEW.kgsVal.rounded(), 42500)
        XCTAssertEqual(calculator.maxZFW.kgsVal.rounded(), 62500)
        XCTAssertEqual(calculator.zeroFuelWeight.kgsVal.rounded(), 60089)
        XCTAssertEqual(calculator.maxRampWeight.kgsVal.rounded(), 79301)
        XCTAssertEqual(calculator.rampWeight.kgsVal.rounded(), 67089)
        XCTAssertEqual(calculator.maxPayloadWeight.kgsVal.rounded(), 20000)
        XCTAssertEqual(calculator.payloadWeight.kgsVal.rounded(), 17589)
        XCTAssertEqual(calculator.maxFuelWeight.kgsVal.rounded(), 19046)
        XCTAssertEqual(calculator.maxTOW.kgsVal.rounded(), 79000)
        XCTAssertEqual(calculator.tow.kgsVal.rounded(), 66889)
        XCTAssertEqual(calculator.maxLandingWT.kgsVal.rounded(), 67400)
        XCTAssertEqual(calculator.destinationLandingWeight.kgsVal.rounded(), 61910)
        XCTAssertEqual(calculator.alternateLandingWeight.kgsVal.rounded(), 60909)
        XCTAssertEqual(calculator.minimumTOFuel.kgsVal.rounded(), 6573)
        XCTAssertEqual(calculator.maxCargoWeight.kgsVal, 20000)
        XCTAssertEqual(calculator.extraFuel.kgsVal.rounded(), 227)
        
        XCTAssertEqual(calculator.paxFirstClass, 0)
        XCTAssertEqual(calculator.maxPaxFirstClass, 0)
        XCTAssertEqual(calculator.paxWeightFirstClass, kgs(0))
        XCTAssertEqual(calculator.paxBusiness,0)
        XCTAssertEqual(calculator.maxPaxBusiness, 0)
        XCTAssertEqual(calculator.paxWeightBusiness, kgs(0))
        XCTAssertEqual(calculator.paxEconomy, 0)
        XCTAssertEqual(calculator.maxPaxEconomy, 0)
        XCTAssertEqual(calculator.paxWeightEconomy, kgs(0))
        XCTAssertEqual(calculator.maxPaxTotal, 0)
        XCTAssertEqual(calculator.paxWeightTotal, kgs(0))
        
        XCTAssertEqual(calculator.baggageWeightTotal.kgsVal, 0)
        XCTAssertEqual(calculator.totalBaggageAndCargoWeight.kgsVal.rounded(), 17589)
        XCTAssertEqual(calculator.maxBaggageAndCargoWeight.kgsVal.rounded(), 20000)
        
        XCTAssertEqual(calculator.baggageWeightFront.kgsVal.rounded(), 0)
        XCTAssertEqual(calculator.totalFrontCargoWeight.kgsVal.rounded(), 2992)
        XCTAssertEqual(calculator.maxFrontCargoWeight.kgsVal.rounded(), 3402)
        
        XCTAssertEqual(calculator.baggageWeightRear.kgsVal.rounded(), 0)
        XCTAssertEqual(calculator.totalRearCargoWeight.kgsVal.rounded(), 5306)
        XCTAssertEqual(calculator.maxRearCargoWeight.kgsVal.rounded(), 6033)
        
        XCTAssertEqual(calculator.totalMainDeckCargoWeight?.kgsVal.rounded(), 9291)
        XCTAssertEqual(calculator.maxMainDeckCargoWeight?.kgsVal.rounded(), 10565)
        
        XCTAssertEqual(calculator.payloadLoadPercentage.roundedToTenths(), 87.9)
    }
    
    func testFlexNotPermitted() {
        calculator.departureRunwayIndex = 1
        calculator.departureTemp = celsius(17)
        calculator.departureQNH = hps(1022)
        calculator.departureWindDir = degs(250)
        calculator.departureWindSpd = knts(10)
        calculator.departureRunwayCondition = .dry
        calculator.takeoffFlapsIndex = 1
        calculator.antiIce = true
        calculator.packsOn = true
        calculator.departureRunwayLengthSubtraction = meters(1000)
        calculator.cabinType = .mixed
        calculator.paxTotal = 174
        calculator.cargoWeight = kgs(0)
        calculator.blockFuel = kgs(7000)
        calculator.taxiOut = kgs(227)
        calculator.useStandardEO = true
        calculator.revisedOEW = nil
        calculator.requestedFlexType = .standardThrust
       
        XCTAssertEqual(calculator.requiredDistance.meterVal.rounded(), 1959)
        XCTAssertFalse(calculator.flexPermitted)
        XCTAssertFalse(calculator.runwayLongEnoughForFlex)
        XCTAssert(calculator.runwayWetFlexAllowed)
        XCTAssert(calculator.runwayContaminatedFlexAllowed)
    }
    
    func testFlexPermitted() {
        calculator.departureRunwayIndex = 1
        calculator.departureTemp = celsius(17)
        calculator.departureQNH = hps(1022)
        calculator.departureWindDir = degs(70)
        calculator.departureWindSpd = knts(10)
        calculator.departureRunwayCondition = .dry
        calculator.takeoffFlapsIndex = 1
        calculator.antiIce = true
        calculator.packsOn = true
        calculator.departureRunwayLengthSubtraction = meters(0)
        calculator.cabinType = .mixed
        calculator.paxTotal = 174
        calculator.cargoWeight = kgs(0)
        calculator.blockFuel = kgs(7000)
        calculator.taxiOut = kgs(227)
        calculator.useStandardEO = true
        calculator.revisedOEW = nil
        calculator.requestedFlexType = .standardThrust
        
        XCTAssert(calculator.flexPermitted)
        XCTAssert(calculator.runwayLongEnoughForFlex)
        XCTAssert(calculator.runwayWetFlexAllowed)
        XCTAssert(calculator.runwayContaminatedFlexAllowed)
        XCTAssertEqual(calculator.requiredDistance.meterVal.rounded(), 1710)
        XCTAssertEqual(calculator.v1DifferenceToVR.kntValue.rounded(), 0)
        
        calculator.requestedFlexType = .autoFlex
        XCTAssertEqual(calculator.calculatedFlexTemp?.celsiusVal.rounded(.down), 52)
        XCTAssertEqual(calculator.requiredDistance.meterVal.rounded(), 2788)
        XCTAssertEqual(calculator.v1DifferenceToVR.kntValue.rounded(), -16)
        calculator.requestedFlexType = .selectedFlex
        calculator.selectedFlexTemp = celsius(37)
        XCTAssertEqual(calculator.requiredDistance.meterVal.rounded(), 2111)
        XCTAssertEqual(calculator.v1DifferenceToVR.kntValue.rounded(), -2)
    }
}
