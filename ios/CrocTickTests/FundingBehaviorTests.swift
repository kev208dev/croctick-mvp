import SwiftUI

@main
@MainActor
struct FundingBehaviorTests {
    static func main() {
        let rising = TickTier.level(for: 20)
        precondition(rising.name == "Rising", "20 Tick부터 Rising 등급이어야 합니다.")
        precondition(rising.maxAudience == 80, "Rising 등급의 최대 관객 수는 80명이어야 합니다.")

        let booked = Show(id: "booked", title: "첫 공연", date: "2026. 9. 20. 오후 7:00", location: "성수 라이브홀", category: "Music", progress: 0, artwork: 0)
        let duplicate = Show(id: "duplicate", title: "겹친 공연", date: "2026. 9. 20. 오후 7:00", location: "성수 라이브홀", category: "Band", progress: 0, artwork: 1)
        precondition(Show.conflicts(booked, duplicate), "같은 공간과 시간에는 공연을 중복 등록할 수 없어야 합니다.")

        let placePhoto = Data([1, 2, 3])
        let place = Place(id: "venue", name: "성수 라이브홀", location: "서울", capacity: "최대 80명", rating: "신규", artwork: 2, photoData: placePhoto)
        precondition(Show.defaultPosterData(for: place) == placePhoto, "공간 대표 사진은 공연 포스터의 기본값이어야 합니다.")

        let model = AppModel()
        let show = Show(
            id: "funding-test-show-\(UUID().uuidString)",
            title: "펀딩 테스트 공연",
            date: "2026.10.01",
            location: "테스트 공간",
            category: "Music",
            progress: 0.25,
            artwork: 0
        )

        let before = model.fundingProgress(for: show)
        model.join(show)
        let after = model.fundingProgress(for: show)

        precondition(after > before, "펀딩 참여 후 달성률이 증가해야 합니다.")
    }
}
