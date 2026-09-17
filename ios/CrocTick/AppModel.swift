import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "crocTick.userName") }
    }
    @Published var joinedShowIDs: Set<String> = [] {
        didSet { UserDefaults.standard.set(Array(joinedShowIDs), forKey: "crocTick.joinedShowIDs") }
    }
    @Published private var fundingContributions: [String: Int] = [:] {
        didSet { UserDefaults.standard.set(fundingContributions, forKey: "crocTick.fundingContributions") }
    }
    @Published var createdShows: [Show] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(createdShows) {
                UserDefaults.standard.set(data, forKey: "crocTick.createdShows")
            }
        }
    }
    @Published var registeredPlaces: [Place] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(registeredPlaces) {
                UserDefaults.standard.set(data, forKey: "crocTick.registeredPlaces")
            }
        }
    }
    init() {
        let savedName = UserDefaults.standard.string(forKey: "crocTick.userName")
        userName = savedName == nil || savedName == "이채호" ? "김청휘" : savedName!
        if let savedTickets = UserDefaults.standard.stringArray(forKey: "crocTick.joinedShowIDs") {
            joinedShowIDs = Set(savedTickets)
        } else {
            joinedShowIDs = ["show-pocket"]
        }
        fundingContributions = UserDefaults.standard.dictionary(forKey: "crocTick.fundingContributions") as? [String: Int] ?? [:]
        if let data = UserDefaults.standard.data(forKey: "crocTick.createdShows"),
           let savedShows = try? JSONDecoder().decode([Show].self, from: data) {
            createdShows = savedShows
        }
        if let data = UserDefaults.standard.data(forKey: "crocTick.registeredPlaces"),
           let savedPlaces = try? JSONDecoder().decode([Place].self, from: data) {
            registeredPlaces = savedPlaces
        } else {
            registeredPlaces = [samplePlaces[1]]
        }
    }

    var allShows: [Show] { createdShows + sampleShows }
    var allPlaces: [Place] {
        Array((registeredPlaces + samplePlaces).reduce(into: [String: Place]()) { result, place in
            result[place.id] = place
        }.values).sorted { $0.name < $1.name }
    }
    var joinedShows: [Show] { allShows.filter { joinedShowIDs.contains($0.id) } }

    func join(_ show: Show) {
        guard joinedShowIDs.insert(show.id).inserted else { return }
        fundingContributions[show.id, default: 0] += show.ticketPrice ?? 15_000
    }

    func fundingProgress(for show: Show) -> Double {
        let targetAmount = max(show.fundingGoal ?? (show.ticketPrice ?? 15_000) * (show.targetAudience ?? 30), 1)
        return min(1, show.progress + Double(fundingContributions[show.id, default: 0]) / Double(targetAmount))
    }

    func add(show: Show) {
        createdShows.insert(show, at: 0)
    }

    func add(place: Place) {
        registeredPlaces.insert(place, at: 0)
    }
}
