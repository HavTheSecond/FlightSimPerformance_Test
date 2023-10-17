import SwiftUI
import PerformanceCalculator

struct SettingsView: View {
    @Environment(UserPreferences.self) var prefs
    var calculator: Calculator
    
    @State private var weightUnit = UnitMass.kilograms
    @State private var volumeUnit = UnitVolume.liters
    @State private var passengerWeightUnit = UnitMass.kilograms
    @State private var passengerWeight = 0
    @State private var baggageWeight = 0
    @State private var overWeightPrevention = true
    
    
    func loadWeightsStart() {
        passengerWeightUnit = weightUnit
        if let (passenger, baggage) = prefs.loadPassengerWeights() {
            calculator.passengerWeight = passenger
            calculator.baggageWeight = baggage
        }
        passengerWeight = Int(calculator.passengerWeight.converted(to: passengerWeightUnit).value.rounded())
        baggageWeight = Int(calculator.baggageWeight.converted(to: passengerWeightUnit).value.rounded())

    }
    
    var body: some View {
        Form {
            Section("Unit Types") {
                Picker("Weight", selection: $weightUnit) {
                    ForEach(prefs.allowedWeightUnits, id: \.self) { unit in
                        Text(unit.symbol)
                            .tag(unit)
                    }
                }
                .onAppear {
                    weightUnit = prefs.weightUnit
                }
                .onChange(of: weightUnit) { oldValue, newValue in
                    prefs.weightUnitIndex = prefs.allowedWeightUnits.firstIndex(of: weightUnit) ?? 0
                }
                Picker("Volume", selection: $volumeUnit) {
                    ForEach(prefs.allowedVolumeUnits, id: \.self) { unit in
                        Text(unit.symbol)
                            .tag(unit)
                    }
                }
                .onAppear {
                    volumeUnit = prefs.volumeUnit
                }
                .onChange(of: volumeUnit) { oldValue, newValue in
                    prefs.volumeUnitIndex = prefs.allowedVolumeUnits.firstIndex(of: volumeUnit) ?? 0
                }
            }
            
            Section("Miscellaneous") {
                Toggle("Simple Overweight Prevention", isOn: $overWeightPrevention)
                    .onAppear {
                        overWeightPrevention = prefs.overWeightPrevention
                    }
                    .onChange(of: overWeightPrevention) { _, _ in
                        prefs.overWeightPrevention = overWeightPrevention
                    }
                    .onChange(of: prefs.overWeightPrevention) { _, _ in
                        overWeightPrevention = prefs.overWeightPrevention
                    }
                Text("The Overweight Prevention only applies to the standard maxima of the edited value,\nindirect effects aren't checked to prevent deadlocks")
                Button("Reset Sheets", role: .destructive) {
                    calculator.resetData()
                    prefs.resetCount += 1
                    loadWeightsStart()
                }
            }
            Section("Passenger Weights") {
                HStack {
                    VStack {
                        Text("Passenger Weight")
                        TextField("Passenger Weight", value: $passengerWeight, format: .number)
                            .keyboardType(.numberPad)
                    }
                    VStack {
                        Text("Baggage Weight")
                        TextField("Baggage Weight", value: $baggageWeight, format: .number)
                            .keyboardType(.numberPad)
                    }
                    VStack {
                        Picker("Weight Unit", selection: $passengerWeightUnit) {
                            ForEach(prefs.allowedWeightUnits, id: \.self) { unit in
                                Text(unit.symbol)
                                    .tag(unit)
                            }
                        }
                        .labelsHidden()
                        .onAppear {
                            loadWeightsStart()
                        }
                        .onChange(of: passengerWeight) { oldValue, newValue in
                            calculator.passengerWeight = Measurement(value: Double(passengerWeight), unit: passengerWeightUnit)
                            prefs.savePassengerWeights(passenger: calculator.passengerWeight, baggage: calculator.baggageWeight)
                            prefs.resetCount += 1
                        }
                        .onChange(of: baggageWeight) { oldValue, newValue in
                            calculator.baggageWeight = Measurement(value: Double(baggageWeight), unit: passengerWeightUnit)
                            prefs.savePassengerWeights(passenger: calculator.passengerWeight, baggage: calculator.baggageWeight)
                            prefs.resetCount += 1
                        }
                        .onChange(of: passengerWeightUnit) { oldValue, newValue in
                            passengerWeight = Int(calculator.passengerWeight.converted(to: passengerWeightUnit).value.rounded())
                            baggageWeight = Int(calculator.baggageWeight.converted(to: passengerWeightUnit).value.rounded())
                        }
                    }
                }
                .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView(calculator: Calculator())
}
