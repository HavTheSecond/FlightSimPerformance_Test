import SwiftUI
import PerformanceCalculator

@main
struct FlightSimPerformanceApp: App {
    @State var userPreferences = UserPreferences()
    @State var storage = Storage()
    
    init() {
        storage.importAircraft()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(userPreferences)
        .environment(storage)
    }
}
