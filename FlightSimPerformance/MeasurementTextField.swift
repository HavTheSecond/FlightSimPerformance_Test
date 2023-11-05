import SwiftUI

struct MeasurementTextField<UnitType>: View where UnitType: Dimension {
    @State private var internalValue = 0.0
    @FocusState private var focused: Bool
    
    @Binding var value: Measurement<UnitType>
    var unit: () -> UnitType
    var prompt: String
    var consistencyFix: (Measurement<UnitType>, Measurement<UnitType>) -> Measurement<UnitType>
    var roundingPolicy: (Double) -> Double
    
    @Binding var consistencyReset: Bool
    @Binding var unitReset: Bool
    
    private func setUp() {
        internalValue = fromMeasurement(value: value)
    }
    
    private var valueAsMeasurement: Measurement<UnitType> {
        asMeasurement(value: internalValue)
    }
    
    private func asMeasurement(value: Double) -> Measurement<UnitType> {
        Measurement(value: roundingPolicy(value), unit: unit())
    }
    
    private func fromMeasurement(value: Measurement<UnitType>) -> Double {
        roundingPolicy(value.converted(to: unit()).value)
    }
    
    private static func standardRounding(_ value: Double) -> Double {
        value.rounded()
    }
    
    init(prompt: String, value: Binding<Measurement<UnitType>>, unit: @escaping () -> UnitType, consistencyReset: Binding<Bool>, unitReset: Binding<Bool>, roundingPolicy: @escaping (Double) -> Double = standardRounding, consistencyFix: @escaping (Measurement<UnitType>, Measurement<UnitType>) -> Measurement<UnitType>) {
        self._value = value
        self.unit = unit
        self.prompt = prompt
        self.consistencyFix = consistencyFix
        self._consistencyReset = consistencyReset
        self._unitReset = unitReset
        self.roundingPolicy = roundingPolicy
    }
    
    var body: some View {
        TextField(prompt, value: $internalValue, format: .number)
            .focused($focused)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .fixedSize()
            .onAppear {
                setUp()
            }
            .onSubmit {
                value = consistencyFix(value, valueAsMeasurement)
                setUp()
            }
            .onChange(of: internalValue) { oldValue, newValue in
                internalValue = fromMeasurement(value: consistencyFix(asMeasurement(value: oldValue), valueAsMeasurement))
            }
            .onChange(of: value) { oldValue, newValue in
                setUp()
            }
            .onChange(of: unitReset) { oldValue, newValue in
                setUp()
            }
            .onChange(of: focused, { oldValue, newValue in
                value = consistencyFix(value, valueAsMeasurement)
                setUp()
            })
            .onChange(of: consistencyReset) { oldValue, newValue in
                value = consistencyFix(value, valueAsMeasurement)
                setUp()
            }
    }
}

#Preview {
    MeasurementTextField(prompt: "Test", value: .constant(Measurement(value: 10, unit: UnitMass.kilograms)), unit: {.kilograms}, consistencyReset: .constant(false), unitReset: .constant(false)) { oldValue, value in
        value
    }
}
