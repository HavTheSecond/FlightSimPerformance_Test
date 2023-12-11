import SwiftUI
import PerformanceCalculator

struct DepartureView: View {
    @Bindable var calculator: Calculator
    @Environment(UserPreferences.self) var prefs
    @Environment(Storage.self) var storage
    
    @State private var airportCode = "EDDF"
    @State private var airportFound = true
    @State private var departureRunway: Runway
    @State private var selectedFlex = 0.0
    @State private var cg = 25.0
    @State private var selectedRWCondition = 0
    
    @State private var unitReset = false
    
    private let conditions = [RunwayCondition]([.dry, .wetThin, .snowCompacted, .slipperyWet, .snowThick, .standingWaterThick, .ice, .waterOnIce])
    
    init(calculator: Calculator) {
        self.calculator = calculator
        if calculator.departureAirport.runways.contains(calculator.departureRunway) {
            _departureRunway = .init(initialValue: calculator.departureRunway)
        } else {
            _departureRunway = .init(initialValue: calculator.departureAirport.runways.first ?? Runway(name: "N/A", length: meters(0)))
        }
    }
    
    private var airport: Airport {
        calculator.departureAirport
    }
    
    func loadDepartureAirport() {
        var found = false
        for airport in storage.airports {
            if airport.icao == airportCode {
                found = true
                calculator.departureAirport = airport
                break
            }
        }
        airportFound = found
    }
    
    var body: some View {
        Form {
            HStack {
                Text("Departure Airport")
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                TextField("Departure Airport", text: $airportCode)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .onSubmit {
                        airportCode = airportCode.uppercased()
                        loadDepartureAirport()
                    }
            }
            
            if airportFound {
                furtherSetup
            } else {
                Text("The airport with the code \(airportCode) was not found!")
                    .foregroundStyle(.red)
                    .font(.title2)
            }
        }
        .navigationTitle("Departure / Take-Off")
        .onAppear {
            loadDepartureAirport()
        }
    }
    
    @ViewBuilder
    var furtherSetup: some View {
        infos
        weather
        remainingSetup
        calculatedInfos
    }
    
    @ViewBuilder
    var infos: some View {
        Section("INFOS") {
            Text(airport.name)
                .font(.title)
            LabeledContent("Elevation") {
                Text(prefs.stringFromElevation(airport.elevation))
            }
            LabeledContent("Longest Runway") {
                Text(longestRunwayText)
            }
        }
    }
    
    var longestRunwayText: String {
        guard let longestRunwayLength = airport.runways.max(by: { lhs, rhs in
            lhs.length < rhs.length
        })?.length else { return "N/A"}
        
        let runwayList = airport.runways.filter { rw in
            rw.length >= longestRunwayLength
        }
        
        var listString = runwayList.reduce("Runways") { partialResult, rw in
            partialResult.appending(" \(rw.name),")
        }
        
        listString.removeLast()
        
        return "\(listString) with \(prefs.stringFromRWLength(longestRunwayLength, rule: .down))"
    }
    
    var weather: some View {
        Section("WEATHER INPUT") {
            HStack {
                Text("Wind Direction in \(UnitAngle.degrees.symbol)")
                
                Spacer()
                
                MeasurementTextField(prompt: "Wind Direction in \(UnitAngle.degrees.symbol)", value: $calculator.departureWindDir, unit: {.degrees}, consistencyReset: .constant(false), unitReset: .constant(false)) { oldValue, value in
                    if value >= degs(0) && value < degs(360) {
                        value
                    } else if oldValue >= degs(0) && oldValue < degs(360) {
                        oldValue
                    } else {
                        calculator.departureWindDir
                    }
                }
            }
            
            HStack {
                Text("Wind Speed in \(prefs.speedUnit.symbol)")
                
                Spacer()
                
                MeasurementTextField(prompt: "Wind Speed in \(prefs.speedUnit.symbol)", value: $calculator.departureWindSpd, unit: {prefs.speedUnit}, consistencyReset: .constant(false), unitReset: $unitReset) { oldValue, value in
                    if value >= knts(0) {
                        value
                    } else if oldValue >= knts(0) {
                        oldValue
                    } else {
                        calculator.departureWindSpd
                    }
                }
                .onChange(of: prefs.speedUnit) { oldValue, newValue in
                    unitReset.toggle()
                }
            }
            
            HStack {
                Text("Outside Air Temperature in \(prefs.tempUnit.symbol)")
                
                Spacer()
                
                MeasurementTextField(prompt: "Outside Air Temperature in \(prefs.tempUnit.symbol)", value: $calculator.departureTemp, unit: {prefs.tempUnit}, consistencyReset: .constant(false), unitReset: $unitReset) { oldValue, value in
                    if value > Measurement(value: 0, unit: .kelvin) {
                        value
                    } else if oldValue > Measurement(value: 0, unit: .kelvin) {
                        oldValue
                    } else {
                        calculator.departureTemp
                    }
                }
                .onChange(of: prefs.tempUnit) { oldValue, newValue in
                    unitReset.toggle()
                }
            }
            
            HStack {
                Text("QNH in \(prefs.pressureUnit.symbol)")
                
                Spacer()
                
                MeasurementTextField(prompt: "QNH in \(prefs.pressureUnit.symbol)", value: $calculator.departureQNH, unit: {prefs.pressureUnit}, consistencyReset: .constant(false), unitReset: $unitReset) { value in
                    switch prefs.pressureUnit {
                        case .hectopascals:
                            value.rounded()
                        case .bars:
                            value.roundTo(1000)
                        default:
                            value.roundedToHundreths()
                    }
                } consistencyFix: { oldValue, value in
                    value
                }
                .onChange(of: prefs.pressureUnit) { oldValue, newValue in
                    unitReset.toggle()
                }
            }
            
            runwayStatePicker
        }
    }
    
    var runwayStatePicker: some View {
        Picker("Runway State", selection: $selectedRWCondition) {
            ForEach(conditions.enumerated().map({$0}), id: \.offset) { index, conditon in
                Text(conditon.description)
                    .tag(index)
            }
        }
        .onChange(of: selectedRWCondition) { oldValue, newValue in
            calculator.departureRunwayCondition = conditions[selectedRWCondition]
        }
        .onChange(of: calculator.departureRunwayCondition) { oldValue, newValue in
            selectedRWCondition = conditions.firstIndex(of: newValue) ?? 0
        }
        .onAppear {
            selectedRWCondition = conditions.firstIndex(of: calculator.departureRunwayCondition) ?? 0
        }
    }
    
    var remainingSetup: some View {
        Section("REMAINING SETUP") {
            Picker("Runway", selection: $departureRunway) {
                ForEach(airport.runways, id: \.self) { rw in
                    Text("\(rw.name) - \(prefs.stringFromRWLength(rw.length, rule: .down))")
                }
            }
            .onAppear {
                departureRunway = calculator.departureRunway
            }
            .onChange(of: departureRunway) { oldValue, newValue in
                calculator.departureRunwayIndex = UInt(airport.runways.firstIndex(of: departureRunway) ?? 0)
            }
            .onChange(of: calculator.departureRunway) { oldValue, newValue in
                departureRunway = newValue
            }
            
            Picker("T/O Config", selection: $calculator.requestedFlexType) {
                Text("Standard Thrust")
                    .tag(RequestedFlexType.standardThrust)
                if calculator.flexPermitted {
                    Text("Selected Flex")
                        .tag(RequestedFlexType.selectedFlex)
                    Text("Auto Flex")
                        .tag(RequestedFlexType.autoFlex)
                }
                ForEach(calculator.aircraft.derates ?? [], id: \.self) { derate in
                    Text("\(derate.name) (-\(derate.minusPercent)%)")
                        .tag(RequestedFlexType.derate(Int(derate.minusPercent)))
                }
                if let bump = calculator.aircraft.bump {
                    Text("\(bump.name) (+\(bump.plusPercent)%)")
                        .tag(RequestedFlexType.derate(-Int(bump.plusPercent)))
                }
            }
            .onChange(of: calculator.flexPermitted) { oldValue, newValue in
                if !newValue {
                    if calculator.requestedFlexType == .autoFlex || calculator.requestedFlexType == .selectedFlex {
                        calculator.requestedFlexType = .standardThrust
                    }
                }
            }
            .onAppear {
                if !calculator.flexPermitted {
                    if calculator.requestedFlexType == .autoFlex || calculator.requestedFlexType == .selectedFlex {
                        calculator.requestedFlexType = .standardThrust
                    }
                }
            }
            
            selectToTemp
            
            Picker("Flaps", selection: $calculator.takeoffFlapsIndex) {
                ForEach(calculator.aircraft.flaps.enumerated().map({$0}), id: \.offset) { offset, flap in
                    if flap.toPerfImpactPercent != nil {
                        Text(flap.name)
                            .tag(offset)
                    }
                }
            }
            
            if calculator.canCalculateTrim {
                HStack {
                    Text("ZFW Center of Gravity")
                    
                    Spacer()
                    
                    TextField("ZFW Center of Gravity", value: $cg, format: .number)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: cg) { oldValue, newValue in
                            if !(0 <= cg && 100 >= cg) {
                                cg = oldValue
                            }
                        }
                        .onSubmit {
                            calculator.zfwCG = cg
                        }
                        .onAppear {
                            cg = calculator.zfwCG
                        }
                        .onChange(of: calculator.zfwCG) { oldValue, newValue in
                            cg = calculator.zfwCG
                        }
                }
                .onChange(of: calculator.canCalculateTrim) { oldValue, newValue in
                    if !calculator.canCalculateTrim && (cg < 0 || cg > 100) {
                        cg = 25
                    }
                }
            }
            
            Toggle("Engine Anti Ice", isOn: $calculator.antiIce)
            
            Toggle("PACKS / Air Conditioning", isOn: $calculator.packsOn)
            
            TakeoffRunwayReducedLength(calculator: calculator, departureRunway: $departureRunway)
        }
    }
    
    var maxFlexTemp: Int {
        Int(max(calculator.rwyMaxFlex, calculator.minFlex + celsius(1)).converted(to: prefs.tempUnit).value)
    }
    
    @ViewBuilder
    var selectToTemp: some View {
        if calculator.requestedFlexType == .selectedFlex {
            HStack {
                
                Text("Flex T/O Temp: \(Int(selectedFlex))\(prefs.tempUnit.symbol) / Max: \(maxFlexTemp)\(prefs.tempUnit.symbol)")
                
                Spacer()
                    .padding(.horizontal)
                
                Slider(value: $selectedFlex, in: calculator.minFlex.converted(to: prefs.tempUnit).value...Double(maxFlexTemp)) { editing in
                    if !editing {
                        calculator.selectedFlexTemp = Measurement(value: selectedFlex.rounded(), unit: prefs.tempUnit)
                        calculator.selectedFlexTemp = min(calculator.selectedFlexTemp, calculator.rwyMaxFlex).rounded(.down, type: prefs.tempUnit)
                        calculator.selectedFlexTemp = max(calculator.selectedFlexTemp, calculator.minFlex).rounded(.up, type: prefs.tempUnit)
                        selectedFlex = calculator.selectedFlexTemp.converted(to: prefs.tempUnit).value
                    }
                }
                .onAppear {
                    calculator.selectedFlexTemp = min(calculator.selectedFlexTemp, calculator.rwyMaxFlex).rounded(.down, type: prefs.tempUnit)
                    calculator.selectedFlexTemp = max(calculator.selectedFlexTemp, calculator.minFlex).rounded(.up, type: prefs.tempUnit)
                    selectedFlex = calculator.selectedFlexTemp.converted(to: prefs.tempUnit).value
                }
                .onChange(of: calculator.selectedFlexTemp) { _, _ in
                    calculator.selectedFlexTemp = min(calculator.selectedFlexTemp, calculator.rwyMaxFlex).rounded(.down, type: prefs.tempUnit)
                    calculator.selectedFlexTemp = max(calculator.selectedFlexTemp, calculator.minFlex).rounded(.up, type: prefs.tempUnit)
                    selectedFlex = calculator.selectedFlexTemp.converted(to: prefs.tempUnit).value
                }
                .onChange(of: calculator.rwyMaxFlex, { _, _ in
                    calculator.selectedFlexTemp = min(calculator.selectedFlexTemp, calculator.rwyMaxFlex).rounded(.down, type: prefs.tempUnit)
                    selectedFlex = calculator.selectedFlexTemp.converted(to: prefs.tempUnit).value
                })
                .onChange(of: prefs.tempUnit) { _, _ in
                    calculator.selectedFlexTemp = calculator.selectedFlexTemp.rounded(type: prefs.tempUnit)
                    selectedFlex = calculator.selectedFlexTemp.converted(to: prefs.tempUnit).value
                }
                .onChange(of: calculator.minFlex) { _, _ in
                    calculator.selectedFlexTemp = max(calculator.selectedFlexTemp, calculator.minFlex).rounded(.up, type: prefs.tempUnit)
                    selectedFlex = calculator.selectedFlexTemp.converted(to: prefs.tempUnit).value
                }
            }
        }
    }
    
    var calculatedInfos: some View {
        Section("CALCULATED INFORMATION") {
            alerts
            LabeledContent("Head- / Tailwind") {
                Text(headOrTailwind)
                    .foregroundStyle(calculator.departureHeadOrTailWind < knts(0) ? .red : .secondary)
            }
            LabeledContent("Crosswind", value: crosswind)
            LabeledContent("Altitude", value: prefs.stringFromElevation(airport.elevation))
            LabeledContent("Density Altitude", value: prefs.stringFromElevation(calculator.departureDensityAltitude))
            if calculator.requestedFlexType == .autoFlex || calculator.requestedFlexType == .selectedFlex {
                LabeledContent("Flex T/O Temp", value: "\((calculator.calculatedFlexTemp?.converted(to: prefs.tempUnit).value ?? selectedFlex).rounded(.down).formatted()) \(prefs.tempUnit.symbol)")
                    .font(.title3)
            }
            if calculator.canCalculateTrim {
                LabeledContent("Trim for MCDU Perf Page", value: trimSetting)
            }
            LabeledContent("Actual Runway Length", value: prefs.stringFromRWLength(calculator.departureRunwayLength, rule: .down))
            LabeledContent("Required Distance", value: prefs.stringFromRWLength(calculator.requiredDistance, rule: .up))
            LabeledContent {
                HStack(spacing: 0) {
                    vRText
                    Text(differenceText)
                }
            } label: {
                v1Text
            }
        }
    }
    
    var v1Text: some View {
        HStack(spacing: 0) {
            Text("V")
            Text("1")
                .font(.caption)
                .padding(.top)
        }
    }
    
    var vRText: some View {
        HStack(spacing: 0) {
            Text("V")
            Text("R")
                .font(.caption)
                .padding(.top)
        }
    }
    
    var differenceText: String {
        let speedValue = calculator.v1DifferenceToVR.converted(to: prefs.speedUnit).value.rounded(.down)
        guard speedValue != 0 else {return ""}
        let speedValueStr = abs(speedValue).formatted()
        let negative = speedValue < 0
        let speedUnit = prefs.speedUnit.symbol
        
        return " \(negative ? "-" : "+") \(speedValueStr) \(speedUnit)"
    }
    
    var headOrTailwind: String {
        let wind = calculator.departureHeadOrTailWind
        var result = Int(abs(wind.converted(to: prefs.speedUnit).value).rounded()).formatted() + " " + prefs.speedUnit.symbol
        
        if wind < knts(0) {
            result += " Tail"
        } else if wind > knts(0) {
            result += " Head"
        }
        
        return result
    }
    
    var crosswind: String {
        let wind = calculator.departureCrossWind
        var result = Int(wind.converted(to: prefs.speedUnit).value.rounded()).formatted() + " " + prefs.speedUnit.symbol
        
        let dir = calculator.departureCrosswindDirection
        
        if dir == .left {
            result += " from the Left"
        } else if dir == .right {
            result += " from the Right"
        }
        
        return result
    }
    
    var trimSetting: String {
        guard let trim = calculator.toTrim else {return ""}
        
        let flapIndex = calculator.takeoffFlapsIndex
        let flap = calculator.aircraft.flaps[flapIndex]
        let initFlapStr = flap.name
        var flapStr = ""
        for char in initFlapStr {
            if char >= "0" && char <= "9" {
                flapStr += "\(char)"
            } else {
                break
            }
        }
        if flapStr.count == 0 {
            flapStr = String(initFlapStr.first ?? "0")
        }
        
        let trimUp = trim > 0
        let trimDn = trim < 0
        var trimStr = String(abs(trim).roundedToTenths())
        
        if trimUp {
            trimStr += " UP"
        }
        if trimDn {
            trimStr += " DN"
        }
        
        return flapStr + " / " + trimStr
    }
    
    @ViewBuilder
    var alerts: some View {
        let minCG = calculator.aircraft.maxNoseUpTrim?.cg ?? 0.0
        let maxCG = calculator.aircraft.maxNoseDownTrim?.cg ?? 100.0
        Group {
            if cg < minCG {
                Text("ZFW Center of Gravity too far front (Min: \(minCG.roundedToTenths().formatted()))")
            }
            if cg > maxCG {
                Text("ZFW Center of Gravity too far aft (Max: \(maxCG.roundedToTenths().formatted()))")
            }
            if !calculator.runwayContaminatedFlexAllowed {
                Text("Flex not allowed: Runway Contamination")
            }
            
            if !calculator.runwayWetFlexAllowed {
                Text("Flex not allowed: Runway Wet")
            }
            
            if !calculator.runwayLongEnoughForFlex {
                Text("Flex not allowed: Runway too short (Min RW Length: \(prefs.stringFromRWLength(calculator.minRunwayLengthForFlex, rule: .up)))")
            }
            
            if calculator.runwayContaminatedFlexAllowed && calculator.runwayWetFlexAllowed && calculator.runwayLongEnoughForFlex && !calculator.flexPermitted {
                Text("Flex not allowed: Temperatures don't align (\(tempAlertString))")
            }
        }
        .font(.title3)
        .foregroundStyle(.red)
    }
    
    var tempAlertString: String {
        let min = "Min Flex: \(calculator.minFlex.converted(to: prefs.tempUnit).value.rounded(.down).formatted()) \(prefs.tempUnit.symbol)"
        let max = "Max Flex: \(calculator.rwyMaxFlex.converted(to: prefs.tempUnit).value.rounded(.down).formatted()) \(prefs.tempUnit.symbol)"
        return min + ", " + max
    }
}

#Preview {
    DepartureView(calculator: Calculator())
}
