import SwiftUI
import PerformanceCalculator

struct ActualZFWSelector: View {
    @Bindable var calculator: Calculator
    @Environment(UserPreferences.self) var prefs
    
    @State private var overwriteZFW = false
    @State private var weightToSet = 0
    
    private func writeValues() {
        if overwriteZFW {
            if weightToSet <= prefs.fromWeight(calculator.maxZFW, rule: .down) || !prefs.overWeightPrevention {
                calculator.actualZFW = prefs.toWeight(weightToSet)
            } else {
                weightToSet = min(prefs.fromWeight(calculator.situationalMaxZFW, rule: .down), prefs.fromWeight(calculator.zeroFuelWeight))
            }
        } else {
            calculator.actualZFW = nil
            weightToSet = prefs.fromWeight(calculator.zeroFuelWeight)
        }
    }
    
    var body: some View {
        Toggle("Set Actual Zero Fuel Weight", isOn: $overwriteZFW)
            .onChange(of: overwriteZFW) { oldValue, newValue in
                weightToSet = prefs.fromWeight(calculator.zeroFuelWeight)
                writeValues()
            }
            .onAppear {
                overwriteZFW = calculator.actualZFW != nil
                weightToSet = prefs.fromWeight(calculator.zeroFuelWeight)
            }
            .onChange(of: prefs.overWeightPrevention) { oldValue, newValue in
                writeValues()
            }
        
        if overwriteZFW {
            HStack {
                Text("Actual ZFW in \(prefs.weightUnit.symbol) (Standard Max: \(prefs.stringFromWeight(calculator.maxZFW, rule: .down)), Current Max: \(prefs.stringFromWeight(calculator.situationalMaxZFW, rule: .down)))")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                TextField("ZFW in \(prefs.weightUnit.symbol)", value: $weightToSet, format: .number)
                    .onChange(of: weightToSet) { oldValue, newValue in
                        writeValues()
                    }
                    .onChange(of: calculator.maxZFW) { oldValue, newValue in
                        writeValues()
                    }
                    .keyboardType(.numberPad)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize()
            }
            Text("The changes made here only affect general weights like TOW, ZFW and Payload,\nspecific distributions won't be changed")
            LabeledContent("Difference to expected ZFW") {
                Text("\(calculator.weightDifference > kgs(0) ? "+" : "")\(prefs.stringFromWeight(calculator.weightDifference))")
            }
        }
    }
}

#Preview {
    ActualZFWSelector(calculator: Calculator())
}
