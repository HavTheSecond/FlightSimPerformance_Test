import SwiftUI
import PerformanceCalculator

struct LoadSheets: View {
    @Bindable var calculator: Calculator
    @Environment(UserPreferences.self) var prefs
    
    var body: some View {
        Group {
            NavigationLink("Load Sheet") {
                Table(of: LoadSheetEntry.self) {
                    TableColumn("") { entry in
                        Text(entry.name)
                    }
                    TableColumn("Estimated") { entry in
                        Text(prefs.stringFromWeight(entry.estimated))
                    }
                    TableColumn("Maximum") { entry in
                        Text(prefs.stringFromWeight(entry.maximum, rule: .down))
                    }
                } rows: {
                    TableRow(LoadSheetEntry(name: "Zero Fuel Weight / ZFW", estimated: calculator.zeroFuelWeight, maximum: calculator.maxZFW))
                    TableRow(LoadSheetEntry(name: "Ramp Weight / RW", estimated: calculator.rampWeight, maximum: calculator.maxRampWeight))
                    TableRow(LoadSheetEntry(name: "Payload", estimated: calculator.payloadWeight, maximum: calculator.maxPayloadWeight))
                    TableRow(LoadSheetEntry(name: "Fuel", estimated: calculator.blockFuel, maximum: calculator.maxFuelWeight))
                    TableRow(LoadSheetEntry(name: "Take-Off Weight / TOW", estimated: calculator.tow, maximum: calculator.maxTOW))
                    TableRow(LoadSheetEntry(name: "Landing Weight / LW (Destination)", estimated: calculator.destinationLandingWeight, maximum: calculator.maxLandingWT))
                    TableRow(LoadSheetEntry(name: "Landing Weight / LW (Alternate)", estimated: calculator.alternateLandingWeight, maximum: calculator.maxLandingWT))
                }
            }
            
            NavigationLink("Passengers") {
                Table(of: PassengerEntry.self) {
                    TableColumn("Class") { entry in
                        Text(entry.passengerClass)
                    }
                    TableColumn("On Board") { entry in
                        Text(entry.onBoard.formatted())
                    }
                    TableColumn("Capacity") { entry in
                        Text(entry.capacity.formatted())
                    }
                    TableColumn("Passenger Weight") { entry in
                        Text(prefs.stringFromWeight(entry.weight))
                    }
                } rows: {
                    TableRow(PassengerEntry(passengerClass: "First Class", onBoard: calculator.paxFirstClass, capacity: calculator.maxPaxFirstClass, weight: calculator.paxWeightFirstClass))
                    TableRow(PassengerEntry(passengerClass: "Business Class", onBoard: calculator.paxBusiness, capacity: calculator.maxPaxBusiness, weight: calculator.paxWeightBusiness))
                    TableRow(PassengerEntry(passengerClass: "Economy", onBoard: calculator.paxEconomy, capacity: calculator.maxPaxEconomy, weight: calculator.paxWeightEconomy))
                    TableRow(PassengerEntry(passengerClass: "Total", onBoard: calculator.paxTotal, capacity: calculator.maxPaxTotal, weight: calculator.paxWeightTotal))
                }
            }
            
            NavigationLink("Baggage & Cargo") {
                Table(of: CargoEntry.self) {
                    TableColumn("Cargo Hold") { entry in
                        Text(entry.cargoHold)
                    }
                    TableColumn("Baggage") { entry in
                        if calculator.cabinType == .cargo {
                            Text("N/A")
                        } else {
                            Text(prefs.stringFromWeight(entry.baggageWeight))
                        }
                    }
                    TableColumn("Baggage & Other Cargo") { entry in
                        Text(prefs.stringFromWeight(entry.allCargo))
                    }
                    TableColumn("Capacity") { entry in
                        Text(prefs.stringFromWeight(entry.capacity, rule: .down))
                    }
                } rows: {
                    TableRow(CargoEntry(cargoHold: "Front", baggageWeight: calculator.baggageWeightFront, allCargo: calculator.totalFrontCargoWeight, capacity: calculator.maxFrontCargoWeight))
                    TableRow(CargoEntry(cargoHold: "Rear", baggageWeight: calculator.baggageWeightRear, allCargo: calculator.totalRearCargoWeight, capacity: calculator.maxRearCargoWeight))
                    if let total = calculator.totalMainDeckCargoWeight,
                       let max = calculator.maxMainDeckCargoWeight {
                        TableRow(CargoEntry(cargoHold: "Main Deck", baggageWeight: kgs(0), allCargo: total, capacity: max))
                    }
                    TableRow(CargoEntry(cargoHold: "Total", baggageWeight: calculator.baggageWeightTotal, allCargo: calculator.totalBaggageAndCargoWeight, capacity: calculator.maxBaggageAndCargoWeight))
                }
            }
            
            NavigationLink("Fuel") {
                Table(of: FuelTank.self) {
                    TableColumn("Fuel Tank") { entry in
                        Text(entry.name)
                    }
                    
                    TableColumn("Fill Percentage") { entry in
                        Text("\(entry.fillLevelPercent.roundedToTenths().formatted()) %")
                    }
                    
                    TableColumn("Fuel Weight") { entry in
                        Text(prefs.stringFromWeight(entry.fillLevel))
                    }
                    
                    TableColumn("Capacity") { entry in
                        Text(prefs.stringFromWeight(entry.capacity))
                    }
                } rows: {
                    ForEach(calculator.fuelTanks, id: \.name) { tank in
                        TableRow(FuelTank(name: tank.name, fillLevelPercent: tank.fillPercentage, fillLevel: tank.weight, capacity: tank.capacity))
                    }
                }

            }
        }
        .foregroundStyle(Color.accentColor)
    }
}

struct LoadSheetEntry: Identifiable {
    let name: String
    let estimated: Measurement<UnitMass>
    let maximum: Measurement<UnitMass>
    var id: String {
        name
    }
}

struct PassengerEntry: Identifiable {
    let passengerClass: String
    let onBoard: UInt
    let capacity: UInt
    let weight: Measurement<UnitMass>
    var id: String {
        passengerClass
    }
}

struct CargoEntry: Identifiable {
    let cargoHold: String
    let baggageWeight: Measurement<UnitMass>
    let allCargo: Measurement<UnitMass>
    let capacity: Measurement<UnitMass>
    
    var id: String {cargoHold}
}

struct FuelTank: Identifiable {
    let name: String
    let fillLevelPercent: Double
    let fillLevel: Measurement<UnitMass>
    let capacity: Measurement<UnitMass>
    var id: String {name}
}

#Preview {
    LoadSheets(calculator: Calculator())
        .environment(UserPreferences())
}
