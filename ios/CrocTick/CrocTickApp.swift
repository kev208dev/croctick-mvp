import SwiftUI

@main
struct CrocTickApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup { ContentView().environmentObject(model) }
    }
}
