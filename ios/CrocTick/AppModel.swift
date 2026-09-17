import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "crocTick.userName") }
    }
    @Published var joinedShowIDs: Set<String> = [] {
        didSet { UserDefaults.standard.set(Array(joinedShowIDs), forKey: "crocTick.joinedShowIDs") }
    }
    @Published var createdShows: [Show] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(createdShows) {
                UserDefaults.standard.set(data, forKey: "crocTick.createdShows")
            }
        }
    }
    @Published var selectedPlace: Place?

    init() {
        let savedName = UserDefaults.standard.string(forKey: "crocTick.userName")
        userName = savedName == nil || savedName == "이채호" ? "김청휘" : savedName!
        joinedShowIDs = Set(UserDefaults.standard.stringArray(forKey: "crocTick.joinedShowIDs") ?? [])
        if let data = UserDefaults.standard.data(forKey: "crocTick.createdShows"),
           let savedShows = try? JSONDecoder().decode([Show].self, from: data) {
            createdShows = savedShows
        }
    }

    var allShows: [Show] { createdShows + sampleShows }

    func join(_ show: Show) {
        joinedShowIDs.insert(show.id)
    }

    func add(show: Show) {
        createdShows.insert(show, at: 0)
    }
}
