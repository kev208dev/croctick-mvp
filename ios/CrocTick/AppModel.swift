import SwiftUI

struct TickTier: Identifiable, Equatable {
    let minimumTick: Int
    let maximumTick: Int?
    let name: String
    let symbol: String
    let ticketLimit: String
    let venueDescription: String
    let maxAudience: Int?
    let note: String
    let accent: Color

    var id: String { name }
    var rangeLabel: String { maximumTick.map { "\(minimumTick)–\($0) Tick" } ?? "\(minimumTick)+ Tick" }
    var audienceLabel: String { maxAudience.map { "\($0)명" } ?? "무제한" }
    var isTopLevel: Bool { maximumTick == nil }

    static let all: [TickTier] = [
        TickTier(minimumTick: 0, maximumTick: 19, name: "Rookie", symbol: "R", ticketLimit: "₩15,000", venueDescription: "지역 거점 공간", maxAudience: 50, note: "첫 무대를 위한 실속형 공간", accent: Color(red: 0.08, green: 0.79, blue: 0.57)),
        TickTier(minimumTick: 20, maximumTick: 39, name: "Rising", symbol: "R+", ticketLimit: "₩60,000", venueDescription: "도심 인접 공간", maxAudience: 80, note: "접근성과 규모를 함께 확보", accent: Color(red: 0.22, green: 0.50, blue: 0.96)),
        TickTier(minimumTick: 40, maximumTick: 69, name: "Artist", symbol: "star.fill", ticketLimit: "₩150,000", venueDescription: "도심 중심 공간", maxAudience: 150, note: "브랜드 경험이 시작되는 단계", accent: Color(red: 0.53, green: 0.32, blue: 0.91)),
        TickTier(minimumTick: 70, maximumTick: 109, name: "Pro", symbol: "triangle.fill", ticketLimit: "₩250,000", venueDescription: "핵심 상권 · 프라임 공간", maxAudience: 300, note: "확장 공연을 위한 프리미엄 구성", accent: Color(red: 1.0, green: 0.43, blue: 0.12)),
        TickTier(minimumTick: 110, maximumTick: nil, name: "Headliner", symbol: "diamond.fill", ticketLimit: "무제한", venueDescription: "랜드마크 · 대표 공간", maxAudience: nil, note: "최상위 공연을 위한 플래그십", accent: Color(red: 1.0, green: 0.22, blue: 0.39))
    ]

    static func level(for tick: Int) -> TickTier {
        all.last { tick >= $0.minimumTick } ?? all[0]
    }
}

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
    @Published private(set) var tickBalance: Int {
        didSet { UserDefaults.standard.set(tickBalance, forKey: "crocTick.tickBalance") }
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
        tickBalance = UserDefaults.standard.object(forKey: "crocTick.tickBalance") as? Int ?? 18
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
    var tickTier: TickTier { TickTier.level(for: tickBalance) }

    func hasScheduleConflict(for show: Show) -> Bool {
        allShows.contains { Show.conflicts($0, show) }
    }

    func join(_ show: Show) {
        guard joinedShowIDs.insert(show.id).inserted else { return }
        fundingContributions[show.id, default: 0] += show.ticketPrice ?? 15_000
        tickBalance += 1
    }

    func fundingProgress(for show: Show) -> Double {
        let targetAmount = max(show.fundingGoal ?? (show.ticketPrice ?? 15_000) * (show.targetAudience ?? 30), 1)
        return min(1, show.progress + Double(fundingContributions[show.id, default: 0]) / Double(targetAmount))
    }

    func add(show: Show) {
        createdShows.insert(show, at: 0)
        tickBalance += 10
    }

    func add(place: Place) {
        registeredPlaces.insert(place, at: 0)
        tickBalance += 5
    }
}
