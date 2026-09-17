import SwiftUI

enum CrocTheme {
    static let orange = Color(red: 1.0, green: 0.43, blue: 0.08)
    static let peach = Color(red: 1.0, green: 0.80, blue: 0.64)
    static let ink = Color(red: 0.10, green: 0.08, blue: 0.07)
    static let canvas = Color(red: 1.0, green: 0.975, blue: 0.955)
    static let cardShadow = Color.black.opacity(0.08)
}

struct OrangeHero: View {
    var body: some View {
        LinearGradient(colors: [CrocTheme.orange, Color(red: 1.0, green: 0.61, blue: 0.32), CrocTheme.peach], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct RatingView: View {
    var value: String = "4.8"
    var body: some View {
        Label(value, systemImage: "star.fill")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(CrocTheme.orange)
    }
}

struct PlaceArtwork: View {
    let index: Int
    var body: some View {
        Image(placeImageName(index))
            .resizable()
            .scaledToFill()
        .clipped()
    }

    private func placeImageName(_ index: Int) -> String {
        switch index {
        case 0: return "place-hopyeong"
        case 1: return "place-haemaji"
        case 2: return "place-ihyun"
        default: return "place-hopyeong"
        }
    }
}

struct PosterArtwork: View {
    let index: Int

    var body: some View {
        Image(posterImageName(index))
            .resizable()
            .scaledToFill()
            .clipped()
    }

    private func posterImageName(_ index: Int) -> String {
        switch index {
        case 0: return "poster-sultan"
        case 1: return "poster-pocket"
        case 2: return "poster-oasis"
        default: return "poster-indie"
        }
    }
}

struct CrocLogo: View {
    var body: some View {
        Image("croc-logo")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
    }
}
