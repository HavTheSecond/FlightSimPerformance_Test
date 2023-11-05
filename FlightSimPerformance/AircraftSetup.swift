import SwiftUI
import PerformanceCalculator

struct AircraftSetup: View {
    @Bindable var calculator: Calculator
    @Environment(UserPreferences.self) var prefs
    @Environment(Storage.self) var storage
    
    var aircraft: Aircraft {
        calculator.aircraft
    }
    
    @State private var aircraftSelection: Int = 0
    
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
    
    @State private var consistencyReset = false
    @State private var unitReset = false
    
    var currentState: String {
        if let actualWeight = calculator.actualZFW {
            return prefs.stringFromWeight(actualWeight)
        } else {
            return "not set"
        }
    }
    
    private var preventionBypass: Bool {
        !prefs.overWeightPrevention
    }
    
    private func fixPaxNo() {
        if selectedPax >= 0 && selectedPax <= calculator.maxPaxTotal || preventionBypass {
            calculator.paxTotal = UInt(selectedPax)
        }  else {
            calculator.paxTotal = min(calculator.maxPaxTotal, calculator.paxTotal)
            selectedPax = Int(calculator.paxTotal)
        }
        consistencyReset.toggle()
    }
    
    func setUp() {
        selectedPax = Int(calculator.paxTotal)
    }
    
    var infosSection: some View {
        Section("INFOS") {
            Picker("Aircraft Selection", selection: $aircraftSelection) {
                ForEach(storage.aircraft.enumerated().map({$0}), id: \.offset) {index, aircraft in
                    Text("\(aircraft.name) (\(aircraft.typeCheck))")
                        .tag(index)
                }
            }
            .onAppear {
                aircraftSelection = storage.aircraft.firstIndex(where: { aircraft in
                    aircraft.name == calculator.aircraft.name
                }) ?? 0
                if storage.aircraft.count > 0 {
                    calculator.aircraft = storage.aircraft[aircraftSelection]
                } else {
                    calculator.aircraft = DefaultData.a20n
                }
            }
            .onChange(of: aircraftSelection) { oldValue, newValue in
                if storage.aircraft.count > 0 {
                    calculator.aircraft = storage.aircraft[aircraftSelection]
                } else {
                    calculator.aircraft = DefaultData.a20n
                }
            }
            
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
    }
    
    var configSection: some View {
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
    }
    
    var weightsSection: some View {
        Section("WEIGHTS") {
            HStack {
                Text("Pax (Max: \(calculator.maxPaxTotal))")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                TextField("Pax", value: $selectedPax, format: .number)
                    .onChange(of: selectedPax) { oldValue, newValue in
                        fixPaxNo()
                    }
                    .onChange(of: calculator.maxPaxTotal) { oldValue, newValue in
                        fixPaxNo()
                    }
                    .keyboardType(.numberPad)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize()
            }
            .onChange(of: calculator.paxTotal) { oldValue, newValue in
                setUp()
            }
            .onAppear {
                setUp()
            }
            .onChange(of: prefs.overWeightPrevention) { _, _ in
                fixPaxNo()
            }
            
            HStack {
                Text("Cargo Weight in \(prefs.weightUnit.symbol) (Max: \(prefs.stringFromWeight(calculator.maxCargoWeight, rule: .down)))")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                MeasurementTextField(prompt: "Cargo Weight in \(prefs.weightUnit.symbol)", value: $calculator.cargoWeight, unit: {prefs.weightUnit}, consistencyReset: $consistencyReset, unitReset: $unitReset) { oldValue, value in
                    if value >= kgs(0) && (value <= calculator.maxCargoWeight || preventionBypass) {
                        return value
                    } else if oldValue >= kgs(0) && (oldValue <= calculator.maxCargoWeight || preventionBypass) {
                        return oldValue
                    } else {
                        return min(calculator.maxCargoWeight, calculator.cargoWeight)
                    }
                }
                .foregroundStyle(.secondary)
            }
            .onChange(of: prefs.weightUnit) { oldValue, newValue in
                unitReset.toggle()
            }
            
            HStack {
                Text("Block Fuel in \(prefs.weightUnit.symbol) (Standard Max: \(prefs.stringFromWeight(calculator.maxFuelWeight, rule: .down)), Current Max: \(prefs.stringFromWeight(calculator.situationalMaxFuelWeight, rule: .down)))")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                MeasurementTextField(prompt: "Block Fuel in \(prefs.weightUnit.symbol)", value: $calculator.blockFuel, unit: {prefs.weightUnit}, consistencyReset: $consistencyReset, unitReset: $unitReset) { oldValue, value in
                    if value >= kgs(0) && (value <= calculator.maxFuelWeight || preventionBypass) {
                        return value
                    } else if oldValue >= kgs(0) && (oldValue <= calculator.maxFuelWeight || preventionBypass) {
                        return oldValue
                    } else {
                        return min(calculator.maxFuelWeight, calculator.blockFuel)
                    }
                }
                .foregroundStyle(calculator.blockFuel <= calculator.situationalMaxFuelWeight ? Color.secondary : Color.red)
            }
            
            HStack {
                Text("Trip Fuel in \(prefs.weightUnit.symbol)")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                MeasurementTextField(prompt: "Trip Fuel in \(prefs.weightUnit.symbol)", value: $calculator.tripFuel, unit: {prefs.weightUnit}, consistencyReset: $consistencyReset, unitReset: $unitReset) { oldValue, value in
                    value
                }
                .foregroundStyle(calculator.tripFuel <= calculator.blockFuel ? Color.secondary : Color.red)
            }
            
            HStack {
                Text("Contingency Fuel in \(prefs.weightUnit.symbol)")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                
                MeasurementTextField(prompt: "Contingency Fuel in \(prefs.weightUnit.symbol)", value: $calculator.contingencyFuel, unit: {prefs.weightUnit}, consistencyReset: $consistencyReset, unitReset: $unitReset) { oldValue, value in
                    value
                }
                .foregroundStyle(calculator.contingencyFuel <= calculator.blockFuel ? Color.secondary : Color.red)
            }
            
            HStack {
                Text("Taxi Fuel in \(prefs.weightUnit.symbol)")
                    .multilineTextAlignment(.leading)
                
                Spacer()
            
                MeasurementTextField(prompt: "Taxi Fuel in \(prefs.weightUnit.symbol)", value: $calculator.taxiOut, unit: {prefs.weightUnit}, consistencyReset: $consistencyReset, unitReset: $unitReset) { oldValue, value in
                    value
                }
                .foregroundStyle(calculator.taxiOut <= calculator.blockFuel ? Color.secondary : Color.red)
            }
            
            HStack {
                Text("Alternate Fuel in \(prefs.weightUnit.symbol)")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                
                MeasurementTextField(prompt: "Alternate Fuel in \(prefs.weightUnit.symbol)", value: $calculator.alternate, unit: {prefs.weightUnit}, consistencyReset: $consistencyReset, unitReset: $unitReset) { oldValue, value in
                    value
                }
                .foregroundStyle(calculator.alternate <= calculator.blockFuel ? Color.secondary : Color.red)
            }
            
            HStack {
                Text("Final Reserve in \(prefs.weightUnit.symbol)")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                
                MeasurementTextField(prompt: "FinalReserve Fuel in \(prefs.weightUnit.symbol)", value: $calculator.finalReserve, unit: {prefs.weightUnit}, consistencyReset: $consistencyReset, unitReset: $unitReset) { oldValue, value in
                    value
                }
                .foregroundStyle(calculator.finalReserve <= calculator.blockFuel ? Color.secondary : Color.red)
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
    }
    
    var weightsInfosSection: some View {
        Section("CALCULATED INFORMATION") {
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
    
    var body: some View {
        NavigationStack {
            Form {
                infosSection
                
                configSection
                
                weightsSection
                
                weightsInfosSection
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
