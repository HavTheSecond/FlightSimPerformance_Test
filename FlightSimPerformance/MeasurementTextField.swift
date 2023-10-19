import SwiftUI

struct MeasurementTextField<UnitType>: View where UnitType: Dimension {
    @State private var internalValue = 0
    
    @Binding var value: Measurement<UnitType>
    var unit: () -> UnitType
    var prompt: String
    var consistencyFix: (Measurement<UnitType>) -> Measurement<UnitType>
    
    private func setUp() {
        internalValue = Int(value.converted(to: unit()).value.rounded())
    }
    
    private var valueAsMeasurement: Measurement<UnitType> {
        Measurement(value: Double(internalValue), unit: unit())
    }
    
    init(prompt: String, value: Binding<Measurement<UnitType>>, unit: @escaping () -> UnitType, consistencyFix: @escaping (Measurement<UnitType>) -> Measurement<UnitType>) {
        self._value = value
        self.unit = unit
        self.prompt = prompt
        self.consistencyFix = consistencyFix
    }
    
    var body: some View {
        TextField(prompt, value: $internalValue, format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .fixedSize()
            .onAppear {
                setUp()
            }
            .onChange(of: internalValue) { oldValue, newValue in
                value = consistencyFix(valueAsMeasurement)
                setUp()
            }
            .onChange(of: value) { oldValue, newValue in
                setUp()
            }
            .onChange(of: unit()) { oldValue, newValue in
                setUp()
            }
            .onChange(of: consistencyFix(valueAsMeasurement)) { oldValue, newValue in
                value = newValue
                setUp()
            }
    }
}

#Preview {
    MeasurementTextField(prompt: "Test", value: .constant(Measurement(value: 10, unit: UnitMass.kilograms)), unit: {.kilograms}) { newValue in
        newValue
    }
}
