import SwiftUI
import PerformanceCalculator

struct AircraftSetup: View {
    @Bindable var calculator: Calculator
    @Environment(UserPreferences.self) var prefs
    
    var aircraft: Aircraft {
        calculator.aircraft
    }
    
    @State private var selectedPax = 0
    @State private var selectedCargo = 0
    @State private var blockFuel = 0
    @State private var tripFuel = 0
    @State private var contingencyFuel = 0
    @State private var taxiFuel = 0
    @State private var alternate = 0
    @State private var finalReserve = 0
    @State private var useStdOEW = true
    @State private var setOEW = 0
    
    @State private var setActualZFW = false
    var currentState: String {
        if let actualWeight = calculator.actualZFW {
            return prefs.stringFromWeight(actualWeight)
        } else {
            return "not set"
        }
    }
    
    private func fixSelectedValues() {
        let preventionBypass = !prefs.overWeightPrevention
        if selectedPax >= 0 && selectedPax <= calculator.maxPaxTotal || preventionBypass {
            calculator.paxTotal = UInt(selectedPax)
        }  else {
            calculator.paxTotal = min(calculator.maxPaxTotal, calculator.paxTotal)
            selectedPax = Int(calculator.paxTotal)
        }
        
        if selectedCargo >= 0 && selectedCargo <= prefs.fromWeight(calculator.maxCargoWeight) || preventionBypass {
            calculator.cargoWeight = prefs.toWeight(selectedCargo)
        } else {
            calculator.cargoWeight = min(calculator.maxCargoWeight, calculator.cargoWeight)
            selectedCargo = prefs.fromWeight(calculator.cargoWeight)
        }
        
        if blockFuel >= 0 && blockFuel <= prefs.fromWeight(calculator.maxFuelWeight) || preventionBypass {
            calculator.blockFuel = prefs.toWeight(blockFuel)
        } else {
            calculator.blockFuel = min(calculator.maxFuelWeight, calculator.blockFuel)
            blockFuel = prefs.fromWeight(calculator.blockFuel)
        }
        
        calculator.tripFuel = prefs.toWeight(tripFuel)
        calculator.contingencyFuel = prefs.toWeight(contingencyFuel)
        calculator.taxiOut = prefs.toWeight(taxiFuel)
        calculator.alternate = prefs.toWeight(alternate)
        calculator.finalReserve = prefs.toWeight(finalReserve)
    }
    
    func switchUnits() {
        selectedCargo = prefs.fromWeight(calculator.cargoWeight)
        blockFuel = prefs.fromWeight(calculator.blockFuel)
        tripFuel = prefs.fromWeight(calculator.tripFuel)
        contingencyFuel = prefs.fromWeight(calculator.contingencyFuel)
        taxiFuel = prefs.fromWeight(calculator.taxiOut)
        alternate = prefs.fromWeight(calculator.alternate)
        finalReserve = prefs.fromWeight(calculator.finalReserve)
    }
    
    func setUp() {
        selectedPax = Int(calculator.paxTotal)
        selectedCargo = prefs.fromWeight(calculator.cargoWeight)
        blockFuel = prefs.fromWeight(calculator.blockFuel)
        tripFuel = prefs.fromWeight(calculator.tripFuel)
        contingencyFuel = prefs.fromWeight(calculator.contingencyFuel)
        taxiFuel = prefs.fromWeight(calculator.taxiOut)
        alternate = prefs.fromWeight(calculator.alternate)
        finalReserve = prefs.fromWeight(calculator.finalReserve)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("INFOS") {
                    HStack {
                        Text(aircraft.name)
                            .font(.title)
                        Spacer()
                        Text("ICAO: \(aircraft.typeCheck)")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent {
                        Text(aircraft.performanceSummary)
                    } label: {
                        Text("Performance Summary")
                    }
                    LabeledContent {
                        Text(aircraft.approachDetails)
                    } label: {
                        Text("Approach Details")
                    }
                }
                
                Section("CONFIGURATION") {
                    Picker("Engine Option", selection: $calculator.useStandardEO) {
                        Text(aircraft.engines.name)
                            .tag(true)
                        if aircraft.engines.name != aircraft.engines.altName {
                            Text(aircraft.engines.altName)
                                .tag(false)
                        }
                    }
                    
                    Picker("Cabin Type", selection: $calculator.cabinType) {
                        Text("Mixed Classes")
                            .tag(CabinType.mixed)
                        Text("Economy Only")
                            .tag(CabinType.economyOnly)
                        Text("Cargo")
                            .tag(CabinType.cargo)
                    }
                }
                
                Section("WEIGHTS") {
                    HStack {
                        Text("Pax (Max: \(calculator.maxPaxTotal))")
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        TextField("Pax", value: $selectedPax, format: .number)
                            .onChange(of: selectedPax) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .onChange(of: calculator.maxPaxTotal) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                    HStack {
                        Text("Cargo Weight in \(prefs.weightUnit.symbol) (Max: \(prefs.stringFromWeight(calculator.maxCargoWeight, rule: .down)))")
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        TextField("Cargo Weight in \(prefs.weightUnit.symbol)", value: $selectedCargo, format: .number)
                            .onChange(of: selectedCargo) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .onChange(of: calculator.maxCargoWeight) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                    HStack {
                        Text("Block Fuel in \(prefs.weightUnit.symbol) (Standard Max: \(prefs.stringFromWeight(calculator.maxFuelWeight, rule: .down)), Current Max: \(prefs.stringFromWeight(calculator.situationalMaxFuelWeight, rule: .down)))")
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        TextField("Block Fuel in \(prefs.weightUnit.symbol)", value: $blockFuel, format: .number)
                            .onChange(of: blockFuel) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .onChange(of: calculator.maxFuelWeight) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(calculator.blockFuel <= calculator.situationalMaxFuelWeight ? Color.secondary : Color.red)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                            .fixedSize()
                    }
                    HStack {
                        Text("Trip Fuel in \(prefs.weightUnit.symbol)")
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        TextField("Trip Fuel in \(prefs.weightUnit.symbol)", value: $tripFuel, format: .number)
                            .onChange(of: tripFuel) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(tripFuel <= blockFuel ? Color.secondary : Color.red)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                    HStack {
                        Text("Contingency Fuel in \(prefs.weightUnit.symbol)")
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        TextField("Contingency Fuel in \(prefs.weightUnit.symbol)", value: $contingencyFuel, format: .number)
                            .onChange(of: contingencyFuel) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(contingencyFuel <= blockFuel ? Color.secondary : Color.red)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                    HStack {
                        Text("Taxi Fuel in \(prefs.weightUnit.symbol)")
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        TextField("Taxi Fuel in \(prefs.weightUnit.symbol)", value: $taxiFuel, format: .number)
                            .onChange(of: taxiFuel) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(taxiFuel <= blockFuel ? Color.secondary : Color.red)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                    HStack {
                        Text("Alternate Fuel in \(prefs.weightUnit.symbol)")
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        TextField("Taxi Fuel in \(prefs.weightUnit.symbol)", value: $alternate, format: .number)
                            .onChange(of: alternate) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(alternate <= blockFuel ? Color.secondary : Color.red)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                    HStack {
                        Text("Final Reserve in \(prefs.weightUnit.symbol)")
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        TextField("Final Reserve in \(prefs.weightUnit.symbol)", value: $finalReserve, format: .number)
                            .onChange(of: finalReserve) { oldValue, newValue in
                                fixSelectedValues()
                            }
                            .keyboardType(.numberPad)
                            .foregroundStyle(finalReserve <= blockFuel ? Color.secondary : Color.red)
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                    }
                    Toggle("Use Standard Operating Empty Weight / OEW (\(prefs.stringFromWeight(calculator.savedOEW)))", isOn: $useStdOEW)
                        .onChange(of: useStdOEW) { oldValue, newValue in
                            if !useStdOEW {
                                setOEW = prefs.fromWeight(calculator.actualOEW)
                            } else {
                                calculator.revisedOEW = nil
                            }
                        }
                        .onChange(of: setOEW) { oldValue, newValue in
                            if !useStdOEW {
                                calculator.revisedOEW = prefs.toWeight(setOEW)
                            }
                        }
                    if !useStdOEW {
                        HStack {
                            Text("OEW in \(prefs.weightUnit.symbol) (Current Max: \(prefs.stringFromWeight(calculator.situationalMaxOEW, rule: .down)))")
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            TextField("OEW in \(prefs.weightUnit.symbol)", value: $setOEW, format: .number)
                                .keyboardType(.numberPad)
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.trailing)
                                .fixedSize()
                        }
                    }
                    ActualZFWSelector(calculator: calculator)
                }
                .onChange(of: prefs.weightUnitIndex) { oldValue, newValue in
                    switchUnits()
                }
                .onChange(of: prefs.resetCount) { oldValue, newValue in
                    setUp()
                }
                .onAppear {
                    setUp()
                }
                .onChange(of: prefs.overWeightPrevention) { _, _ in
                    fixSelectedValues()
                }
                
                Section("WEIGHT INFORMATION") {
                    if calculator.tow > calculator.maxTOW {
                        Text("TOW too high! \(prefs.stringFromWeight(calculator.tow)) Estimated / \(prefs.stringFromWeight(calculator.maxTOW, rule: .down)) Allowed")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    
                    let sum = tripFuel + contingencyFuel + taxiFuel + alternate + finalReserve
                    if sum > blockFuel {
                        Text("Fuel Usage too high! \(sum.formatted()) \(prefs.weightUnit.symbol) Used / \(prefs.stringFromWeight(calculator.blockFuel, rule: .down)) Available")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    
                    if calculator.zeroFuelWeight > calculator.maxZFW {
                        Text("ZFW too high! \(prefs.stringFromWeight(calculator.zeroFuelWeight)) Present / \(prefs.stringFromWeight(calculator.maxZFW, rule: .down)) Allowed")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    
                    if calculator.rampWeight > calculator.maxRampWeight {
                        Text("Ramp Weight too high! \(prefs.stringFromWeight(calculator.rampWeight)) Present / \(prefs.stringFromWeight(calculator.maxRampWeight, rule: .down)) Allowed")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    
                    if calculator.payloadWeight > calculator.maxPayloadWeight {
                        Text("Payload Weight too high! \(prefs.stringFromWeight(calculator.payloadWeight)) Loaded / \(prefs.stringFromWeight(calculator.maxPayloadWeight, rule: .down)) Allowed")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    
                    if calculator.blockFuel > calculator.maxFuelWeight {
                        Text("Fuel Weight too high! \(prefs.stringFromWeight(calculator.blockFuel)) Loaded / \(prefs.stringFromWeight(calculator.maxFuelWeight, rule: .down)) Allowed")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    
                    if calculator.destinationLandingWeight > calculator.maxLandingWT {
                        Text("Landing Weight at the Destination too high! \(prefs.stringFromWeight(calculator.destinationLandingWeight)) Estimated / \(prefs.stringFromWeight(calculator.maxLandingWT, rule: .down)) Allowed")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    if calculator.alternateLandingWeight > calculator.maxLandingWT {
                        Text("Landing Weight at the Alternate too high! \(prefs.stringFromWeight(calculator.alternateLandingWeight)) Estimated / \(prefs.stringFromWeight(calculator.maxLandingWT, rule: .down)) Allowed")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    
                    LabeledContent {
                        Text(prefs.stringFromWeight(calculator.tow))
                    } label: {
                        Text("Take-Off Weight / TOW (Standard Max: \(prefs.stringFromWeight(calculator.maxTOW, rule: .down)), Current Max: \(prefs.stringFromWeight(calculator.situationalMaxTOW, rule: .down)))")
                    }
                    LabeledContent {
                        Text(prefs.stringFromWeight(calculator.zeroFuelWeight))
                    } label: {
                        Text("Zero Fuel Weight (Standard Max: \(prefs.stringFromWeight(calculator.maxZFW, rule: .down)), Current Max: \(prefs.stringFromWeight(calculator.situationalMaxZFW, rule: .down)))")
                    }
                    
                    LabeledContent("Minimum Take-Off Fuel") {
                        Text(prefs.stringFromWeight(calculator.minimumTOFuel, rule: .up))
                    }
                    
                    LabeledContent("Extra Fuel") {
                        Text(prefs.stringFromWeight(calculator.extraFuel))
                    }
                    
                    LabeledContent("Payload Percentage") {
                        Text("\(calculator.payloadLoadPercentage.roundedToTenths().formatted()) %")
                    }
                    
                    LabeledContent("Fuel Volume") {
                        let number = calculator.totalFuelVolume.converted(to: prefs.volumeUnit).value.rounded().formatted()
                        Text("\(number) \(prefs.volumeUnit.symbol)")
                    }
                    
                    LoadSheets(calculator: calculator)
                }
            }
            .navigationTitle("Aircraft Setup")
        }
    }
}

#Preview {
    NavigationStack {
        AircraftSetup(calculator: Calculator())
    }
}
