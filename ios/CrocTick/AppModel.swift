import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var userName = "이채호"
    @Published var joinedShowIDs: Set<UUID> = []
    @Published var createdShows: [Show] = []
    @Published var selectedPlace: Place?

    var allShows: [Show] { createdShows + sampleShows }

    func join(_ show: Show) {
        joinedShowIDs.insert(show.id)
    }

    func add(show: Show) {
        createdShows.insert(show, at: 0)
    }
}
