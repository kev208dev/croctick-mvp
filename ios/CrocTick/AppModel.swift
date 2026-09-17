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
        let savedName = UserDefaults.standard.string(forKey: "crocTick.userName")
        userName = savedName == nil || savedName == "이채호" ? "김청휘" : savedName!
    }

    var allShows: [Show] { createdShows + sampleShows }

    func join(_ show: Show) {
        joinedShowIDs.insert(show.id)
    }

    func add(show: Show) {
        createdShows.insert(show, at: 0)
    }
}
