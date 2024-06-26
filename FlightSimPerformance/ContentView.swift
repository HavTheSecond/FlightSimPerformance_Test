import SwiftUI
import PerformanceCalculator

struct ContentView: View {
    @Environment(UserPreferences.self) var prefs
    
    @State private var calculator: Calculator = Calculator()
    @State private var settings = false
    @State private var selectedContent = SelectedContent.aircraftSetup
    private let userDefaults = UserDefaults.standard
    
    func saveCalculator(_ calculator: Calculator) {
        let json = try? JSONEncoder().encode(calculator)
        userDefaults.setValue(json, forKey: "calculator")
    }
    
    func getCalculator() -> Calculator {
        let data = userDefaults.value(forKey: "calculator") as? Data ?? Data()
        let calculator = (try? JSONDecoder().decode(Calculator.self, from: data)) ?? Calculator()
        if let passengerWeights = prefs.loadPassengerWeights() {
            calculator.passengerWeight = passengerWeights.passenger
            calculator.baggageWeight = passengerWeights.baggage
        }
        return calculator
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch selectedContent {
                    case .aircraftSetup:
                        AircraftSetup(calculator: calculator)
                    case .departure:
                        DepartureView(calculator: calculator)
                }
            }
            .toolbar {
                Button("Settings", systemImage: "gear") {
                    settings = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Menu", selection: $selectedContent) {
                        ForEach(SelectedContent.allCases, id: \.self) { content in
                            Text(content.rawValue)
                        }
                    }
                }
            }
        }
        .onChange(of: calculator.data) { oldValue, newValue in
            saveCalculator(calculator)
        }
        .onAppear {
            calculator = getCalculator()
        }
        .sheet(isPresented: $settings) {
            SettingsView(calculator: calculator)
        }
    }
}

enum SelectedContent: String, CaseIterable {
    case aircraftSetup = "Aircraft Setup"
    case departure = "Departure / Take-Off"
}

#Preview {
    ContentView()
}
