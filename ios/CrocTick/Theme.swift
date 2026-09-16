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
        ZStack {
            LinearGradient(colors: [Color(hue: 0.08 + Double(index) * 0.06, saturation: 0.52, brightness: 0.36), Color(hue: 0.06 + Double(index) * 0.05, saturation: 0.3, brightness: 0.72)], startPoint: .top, endPoint: .bottom)
            Image(systemName: index == 0 ? "building.columns.fill" : index == 1 ? "cup.and.saucer.fill" : "square.grid.2x2.fill")
                .font(.system(size: 26))
                .foregroundStyle(.white.opacity(0.78))
        }
        .clipped()
    }
}
