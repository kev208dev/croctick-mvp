import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "crocTick.userName") }
    }
    @Published var joinedShowIDs: Set<String> = []
    @Published var createdShows: [Show] = []
    @Published var selectedPlace: Place?

    init() {
        userName = UserDefaults.standard.string(forKey: "crocTick.userName") ?? "이채호"
    }

    var allShows: [Show] { createdShows + sampleShows }

    func join(_ show: Show) {
        joinedShowIDs.insert(show.id)
    }

    func add(show: Show) {
        createdShows.insert(show, at: 0)
    }
}
