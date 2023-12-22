import PerformanceCalculator
import SwiftUI

struct TakeoffRunwayReducedLength: View {
    @Bindable var calculator: Calculator
    @Environment(UserPreferences.self) var prefs
    @Binding var departureRunway: Runway

    @State private var takeoffRunwayLengthType = TORunwayLengthType.normal
    @State private var takeoffRunwayReduceLength = meters(0)
    @State private var takeoffRunwayTrueLength = meters(0)

    @State private var unitReset = false
    @State private var consistencyReset = false

    var body: some View {
        Picker("Reduced Runway Length", selection: $takeoffRunwayLengthType) {
            Text("Full Length")
                .tag(TORunwayLengthType.normal)
            Text("Reduced Length")
                .tag(TORunwayLengthType.reduced)
            Text("Set Length")
                .tag(TORunwayLengthType.set)
        }
        .onChange(of: prefs.rwLengthUnit) { _, _ in
            unitReset.toggle()
        }
        .onChange(of: departureRunway) { _, _ in
            if takeoffRunwayLengthType == .normal {
                return
            } else if takeoffRunwayLengthType == .reduced {
                takeoffRunwayReduceLength = min(calculator.departureRunwayLengthSubtraction, departureRunway.length)
                calculator.departureRunwayLengthSubtraction = takeoffRunwayReduceLength
                takeoffRunwayTrueLength = departureRunway.length - takeoffRunwayReduceLength
            } else {
                takeoffRunwayTrueLength = min(takeoffRunwayTrueLength, departureRunway.length)
                takeoffRunwayReduceLength = departureRunway.length - takeoffRunwayTrueLength
                calculator.departureRunwayLengthSubtraction = takeoffRunwayReduceLength
            }
            consistencyReset.toggle()
        }
        .onAppear {
            let reduced = calculator.departureRunwayLengthSubtraction
            takeoffRunwayReduceLength = reduced
            takeoffRunwayTrueLength = calculator.departureRunwayLength
            if reduced > meters(0) && takeoffRunwayLengthType == .normal {
                takeoffRunwayLengthType = .set
            }
        }
        .onChange(of: takeoffRunwayReduceLength) { _, _ in
            calculator.departureRunwayLengthSubtraction = takeoffRunwayReduceLength
        }
        .onChange(of: takeoffRunwayTrueLength) { _, _ in
            calculator.departureRunwayLengthSubtraction = departureRunway.length - takeoffRunwayTrueLength
        }
        .onChange(of: calculator.departureRunwayLengthSubtraction) { _, _ in
            let reduced = calculator.departureRunwayLengthSubtraction
            takeoffRunwayReduceLength = reduced
            takeoffRunwayTrueLength = calculator.departureRunwayLength
            if reduced > meters(0) && takeoffRunwayLengthType == .normal {
                takeoffRunwayLengthType = .set
            }
        }
        .onChange(of: takeoffRunwayLengthType) { _, _ in
            if takeoffRunwayLengthType == .normal {
                calculator.departureRunwayLengthSubtraction = meters(0)
            }
        }
        if takeoffRunwayLengthType == .reduced {
            HStack {
                Text("Reduce by ... in \(prefs.rwLengthUnit.symbol) (Max: \(prefs.stringFromRWLength(departureRunway.length, rule: .down)))")
                Spacer()
                MeasurementTextField(prompt: "Reduce by", value: $takeoffRunwayReduceLength, unit: { prefs.rwLengthUnit }, consistencyReset: $consistencyReset, unitReset: $unitReset, roundingPolicy: { $0.rounded(.down) }, consistencyFix: { oldValue, reduceLength in
                    if reduceLength >= meters(0), reduceLength <= departureRunway.length {
                        reduceLength
                    } else if oldValue >= meters(0), oldValue <= departureRunway.length {
                        oldValue
                    } else {
                        min(takeoffRunwayReduceLength, departureRunway.length)
                    }
                })
            }
        } else if takeoffRunwayLengthType == .set {
            HStack {
                Text("True Length in \(prefs.rwLengthUnit.symbol) (Max: \(prefs.stringFromRWLength(departureRunway.length, rule: .down)))")
                Spacer()
                MeasurementTextField(prompt: "True Length", value: $takeoffRunwayTrueLength, unit: { prefs.rwLengthUnit }, consistencyReset: $consistencyReset, unitReset: $unitReset, roundingPolicy: { $0.rounded(.down) }, consistencyFix: { oldValue, trueLength in
                    if trueLength >= meters(0), trueLength <= departureRunway.length {
                        trueLength
                    } else if oldValue >= meters(0), oldValue <= departureRunway.length {
                        oldValue
                    } else {
                        min(takeoffRunwayTrueLength, departureRunway.length)
                    }
                })
            }
        }
    }
}

private enum TORunwayLengthType {
    case normal, reduced, set
}

#Preview {
    TakeoffRunwayReducedLength(calculator: Calculator(), departureRunway: .constant(DefaultData.eddf.runways.first!))
}
