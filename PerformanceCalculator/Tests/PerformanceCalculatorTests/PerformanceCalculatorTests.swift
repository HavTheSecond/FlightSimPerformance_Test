import XCTest
@testable import PerformanceCalculator

final class PerformanceCalculatorTests: XCTestCase {
    let calculator = Calculator()
    
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
    
    func testWeights() {
        DefaultData.passengerWeight = Measurement(value: 80, unit: UnitMass.kilograms)
        DefaultData.baggageWeight = Measurement(value: 24, unit: UnitMass.kilograms)
        calculator.paxTotal = 100
        calculator.cargoWeight = kgs(150)
        calculator.blockFuel = kgs(7000)
        calculator.tripFuel = kgs(4979)
        calculator.taxiOut = kgs(227)
        calculator.alternate = kgs(1001)
        calculator.finalReserve = kgs(193)
        calculator.cabinType = .mixed
        
        XCTAssertEqual(calculator.actualOEW.kgsVal.rounded(), 42500)
        XCTAssertEqual(calculator.maxZFW.kgsVal.rounded(), 62500)
        XCTAssertEqual(calculator.zeroFuelWeight.kgsVal.rounded(), 53050)
        XCTAssertEqual(calculator.maxRampWeight.kgsVal.rounded(), 79301)
        XCTAssertEqual(calculator.rampWeight.kgsVal.rounded(), 60050)
        XCTAssertEqual(calculator.maxPayloadWeight.kgsVal.rounded(), 20000)
        XCTAssertEqual(calculator.payloadWeight.kgsVal.rounded(), 10550)
        XCTAssertEqual(calculator.maxFuelWeight.kgsVal.rounded(), 19046)
        XCTAssertEqual(calculator.maxTOW.kgsVal.rounded(), 79000)
        XCTAssertEqual(calculator.tow.kgsVal.rounded(), 59823)
        XCTAssertEqual(calculator.maxLandingWT.kgsVal.rounded(), 67400)
        XCTAssertEqual(calculator.destinationLandingWeight.kgsVal.rounded(), 54844)
        XCTAssertEqual(calculator.alternateLandingWeight.kgsVal.rounded(), 53843)
        XCTAssertEqual(calculator.minimumTOFuel.kgsVal.rounded(), 6773)
        
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
        
        XCTAssertEqual(calculator.payloadLoadPercentage.roundedToTenths(), 52.8)
        
        let tanks = calculator.fuelTanks
        
        XCTAssertEqual(tanks.count, 4)
        
        let total = tanks[0]
        XCTAssertEqual(total.name, "TOTAL")
        XCTAssertEqual(total.capacity.kgsVal.rounded(), 19046)
        XCTAssertEqual(total.weight.kgsVal.rounded(), 7000)
        XCTAssertEqual(total.fillPercentage.roundedToTenths(), 36.8)
        
        guard tanks.count == 4 else {return}
        
        let outer = tanks[1]
        XCTAssertEqual(outer.name, "OUTER WINGS")
        XCTAssertEqual(outer.capacity.kgsVal.rounded(), 1386)
        XCTAssertEqual(outer.weight.kgsVal.rounded(), 1386)
        XCTAssertEqual(outer.fillPercentage.roundedToTenths(), 100)
        
        let inner = tanks[2]
        XCTAssertEqual(inner.name, "INNER WINGS")
        XCTAssertEqual(inner.capacity.kgsVal.rounded(), 11038)
        XCTAssertEqual(inner.weight.kgsVal.rounded(), 5614)
        XCTAssertEqual(inner.fillPercentage.roundedToTenths(), 50.9)
        
        let centre = tanks[3]
        XCTAssertEqual(centre.name, "CENTRE")
        XCTAssertEqual(centre.capacity.kgsVal.rounded(), 6622)
        XCTAssertEqual(centre.weight.kgsVal.rounded(), 0)
        XCTAssertEqual(centre.fillPercentage.roundedToTenths(), 0)
    }
}
