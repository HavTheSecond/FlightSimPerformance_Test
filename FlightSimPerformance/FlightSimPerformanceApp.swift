import SwiftUI

@main
struct FlightSimPerformanceApp: App {
    @State var userPreferences = UserPreferences()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(userPreferences)
    }
}
