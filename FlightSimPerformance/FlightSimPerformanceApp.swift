import SwiftUI
import PerformanceCalculator

@main
struct FlightSimPerformanceApp: App {
    @State var userPreferences = UserPreferences()
    @State var storage = Storage()
    
    init() {
        storage.importAircraft()
        storage.importAirports()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(userPreferences)
        .environment(storage)
    }
}
