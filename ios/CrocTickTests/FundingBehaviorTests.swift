import SwiftUI

@main
@MainActor
struct FundingBehaviorTests {
    static func main() {
        let model = AppModel()
        let show = Show(
            id: "funding-test-show",
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
