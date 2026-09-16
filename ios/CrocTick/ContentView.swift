import SwiftUI

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let capacity: String
    let rating: String
    let artwork: Int
}

struct Show: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let location: String
    let category: String
    let progress: Double
    let artwork: Int
}

let samplePlaces = [
    Place(name: "한울교회", location: "경기도 남양주시", capacity: "최대 150명", rating: "4.8", artwork: 0),
    Place(name: "망원동 카페 웨이브", location: "서울 마포구", capacity: "최대 50명", rating: "4.6", artwork: 1),
    Place(name: "이음 문화센터", location: "서울 성동구", capacity: "최대 80명", rating: "4.9", artwork: 2)
]

let sampleShows = [
    Show(title: "술탄 오브 더 디스코", date: "10/24–10/25", location: "경기도 시흥 시흥교회", category: "Music", progress: 0.82, artwork: 0),
    Show(title: "Pocket Music Fest", date: "10.03 (토) · 18:00", location: "한울교회 · 30석", category: "Music", progress: 0.64, artwork: 1),
    Show(title: "Oasis concert", date: "12/02–12/15", location: "망원동 카페 웨이브", category: "Lo-fi", progress: 0.47, artwork: 2),
    Show(title: "Indie Band Bon", date: "11/24–12/01", location: "서울 성동구", category: "Band", progress: 0.71, artwork: 3)
]

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("홈", systemImage: "house.fill") }
            ShowsView().tabItem { Label("공연", systemImage: "ticket.fill") }
            MyPageView().tabItem { Label("마이", systemImage: "person.fill") }
        }
        .tint(CrocTheme.orange)
    }
}

struct TopBar: View {
    var body: some View {
        HStack {
            Button(action: {}) { Image(systemName: "line.3.horizontal").font(.headline) }
                .buttonStyle(.bordered).buttonBorderShape(.circle).controlSize(.small)
            Spacer()
            Text("Croc").font(.system(size: 21, weight: .black, design: .rounded)).italic()
            Spacer()
            HStack(spacing: 8) {
                Button(action: {}) { Image(systemName: "bell") }.buttonStyle(.bordered).buttonBorderShape(.circle).controlSize(.small)
                Button(action: {}) { Image(systemName: "person") }.buttonStyle(.bordered).buttonBorderShape(.circle).controlSize(.small)
            }
        }
        .tint(CrocTheme.ink)
    }
}

struct SearchPill: View {
    @Binding var text: String
    var body: some View {
        HStack(spacing: 8) { Image(systemName: "magnifyingglass"); TextField("Searching...", text: $text) }
            .font(.subheadline).foregroundStyle(.secondary)
            .padding(.horizontal, 14).frame(height: 42)
            .background(.white.opacity(0.66), in: Capsule())
    }
}

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var body: some View {
        HStack { Text(title).font(.headline); Spacer(); if let action { Button("see all", action: action).font(.caption2).foregroundStyle(.secondary) } }
    }
}

struct HomeView: View {
    @State private var query = ""
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        OrangeHero().frame(height: 318)
                        VStack(alignment: .leading, spacing: 16) {
                            TopBar().padding(.top, 6)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Find your stage").font(.caption).foregroundStyle(CrocTheme.ink.opacity(0.62))
                                Text("무대 위\n스타를\n우리 집 앞으로").font(.system(size: 27, weight: .black)).lineSpacing(-3)
                            }
                            .overlay(alignment: .topTrailing) { Image(systemName: "music.note.list").font(.system(size: 54)).foregroundStyle(.white.opacity(0.58)).rotationEffect(.degrees(-14)).offset(x: -4, y: 10) }
                            SearchPill(text: $query)
                        }
                        .padding(.horizontal, 16)
                    }
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "Recommend")
                        NavigationLink { PlaceListView() } label: {
                            HStack(spacing: 10) {
                                PlaceArtwork(index: 0).frame(width: 76, height: 76).clipShape(RoundedRectangle(cornerRadius: 11))
                                VStack(alignment: .leading, spacing: 4) { Text("한울교회").font(.subheadline.weight(.bold)); Text("경기도 남양주시 · 최대 150명").font(.caption2).foregroundStyle(.secondary); RatingView() }
                                Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                            }
                            .padding(9).background(.white, in: RoundedRectangle(cornerRadius: 15)).shadow(color: CrocTheme.cardShadow, radius: 8, y: 3)
                        }.buttonStyle(.plain)
                        SectionHeader(title: "Place")
                        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 8) { ForEach(samplePlaces) { PlaceCard(place: $0) } } }
                        SectionHeader(title: "Categories")
                        HStack(spacing: 8) { ForEach(["Music", "Band", "Lo-fi", "Jazz"], id: \.self) { Text($0).font(.caption).padding(.horizontal, 16).padding(.vertical, 8).background(.white, in: Capsule()).overlay(Capsule().stroke(.quaternary)) } }
                    }
                    .padding(16)
                }
            }
            .background(CrocTheme.canvas)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct PlaceCard: View {
    let place: Place
    var body: some View { NavigationLink { PlaceListView() } label: { VStack(alignment: .leading, spacing: 3) { PlaceArtwork(index: place.artwork).frame(width: 104, height: 72).clipShape(RoundedRectangle(cornerRadius: 9)); Text(place.name).font(.caption2.weight(.bold)).lineLimit(1); Text(place.location).font(.system(size: 8)).foregroundStyle(.secondary); RatingView(value: place.rating) }.frame(width: 104, alignment: .leading).padding(5).background(.white, in: RoundedRectangle(cornerRadius: 12)) }.buttonStyle(.plain) }
}

struct ShowsView: View {
    @State private var query = ""
    @State private var category = "추천순"
    var filtered: [Show] { sampleShows.filter { query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) }.filter { category == "추천순" || $0.category == category } }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    SearchPill(text: $query)
                        .background(CrocTheme.peach.opacity(0.33), in: Capsule())
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(["추천순", "Music", "Band", "Lo-fi", "Jazz"], id: \.self) { chip in
                                Button("#\(chip)") { category = chip }
                                    .font(.caption2)
                                    .foregroundStyle(category == chip ? .white : CrocTheme.ink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(category == chip ? CrocTheme.ink : .white, in: Capsule())
                            }
                            Button(action: {}) { Image(systemName: "slider.horizontal.3") }
                                .padding(8)
                                .background(.white, in: Circle())
                        }
                    }
                    SectionHeader(title: "Recommend")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(filtered) { ShowCard(show: $0) }
                    }
                }
                .padding(16)
            }
            .background(CrocTheme.canvas)
            .navigationTitle("공연")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ShowCard: View {
    let show: Show
    var body: some View { NavigationLink { ShowDetailView(show: show) } label: { VStack(alignment: .leading, spacing: 6) { PlaceArtwork(index: show.artwork).frame(height: 132).clipShape(RoundedRectangle(cornerRadius: 13)); Text(show.title).font(.caption.weight(.bold)).lineLimit(1); Text(show.date).font(.caption2); Text(show.location).font(.system(size: 9)).foregroundStyle(.secondary); HStack { Text("\(Int(show.progress * 100))% funded").font(.system(size: 9, weight: .bold)).foregroundStyle(CrocTheme.orange); Spacer(); Text("30 tickets").font(.system(size: 9)).foregroundStyle(.secondary) }; ProgressView(value: show.progress).tint(CrocTheme.orange) }.padding(9).background(.white, in: RoundedRectangle(cornerRadius: 15)).shadow(color: CrocTheme.cardShadow, radius: 8, y: 3) }.buttonStyle(.plain) }
}

struct MyPageView: View {
    @State private var showCreate = false
    var body: some View { NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 14) { HStack { Image(systemName: "person.circle.fill").font(.system(size: 43)).foregroundStyle(CrocTheme.orange); VStack(alignment: .leading) { Text("김철희님, 안녕하세요!").font(.headline); Text("오늘도 가장 가까운 무대를 찾아보세요.").font(.caption2).foregroundStyle(.secondary) }; Spacer(); Button(action: {}) { Image(systemName: "gearshape") } }; HStack { Stat(value: "1", label: "에티켓"); Stat(value: "4", label: "내 공연"); Stat(value: "1", label: "진행 중 공연") }.padding(14).background(.white, in: RoundedRectangle(cornerRadius: 15)); SectionHeader(title: "My ticket"); NavigationLink { ShowDetailView(show: sampleShows[1]) } label: { TicketRow() }.buttonStyle(.plain); SectionHeader(title: "My space"); NavigationLink { PlaceListView() } label: { PlaceRow(place: samplePlaces[0]) }.buttonStyle(.plain); SectionHeader(title: "Show edit"); Button { showCreate = true } label: { HStack { Image(systemName: "music.note").foregroundStyle(CrocTheme.orange).padding(8).background(CrocTheme.peach.opacity(0.35), in: RoundedRectangle(cornerRadius: 9)); VStack(alignment: .leading) { Text("우리 동네 뮤지션 나눔").font(.caption.weight(.bold)); Text("뮤지션 · 공연 정보를 등록해보세요").font(.caption2).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary) }.padding(12).background(.white, in: RoundedRectangle(cornerRadius: 15)) }.buttonStyle(.plain) }.padding(16) }.background(CrocTheme.canvas).navigationTitle("마이").navigationBarTitleDisplayMode(.inline).sheet(isPresented: $showCreate) { CreateShowView() } } }
}

struct Stat: View { let value: String; let label: String; var body: some View { VStack { Text(value).font(.headline); Text(label).font(.caption2).foregroundStyle(.secondary) }.frame(maxWidth: .infinity) } }
struct TicketRow: View { var body: some View { HStack { ZStack { CrocTheme.orange; Image(systemName: "music.note").foregroundStyle(.white) }.frame(width: 70, height: 78).clipShape(RoundedRectangle(cornerRadius: 10)); VStack(alignment: .leading, spacing: 4) { Text("예매 완료").font(.caption2).foregroundStyle(CrocTheme.orange); Text("Pocket Music Fest").font(.caption.weight(.bold)); Text("10.03 (토) · 18:00\n한울교회 · 30석").font(.system(size: 9)).foregroundStyle(.secondary) }; Spacer(); Text("티켓 보기").font(.system(size: 9, weight: .bold)).foregroundStyle(.white).padding(8).background(CrocTheme.orange, in: Capsule()) }.padding(10).background(.white, in: RoundedRectangle(cornerRadius: 15)) } }
struct PlaceRow: View { let place: Place; var body: some View { HStack { PlaceArtwork(index: place.artwork).frame(width: 55, height: 55).clipShape(RoundedRectangle(cornerRadius: 10)); VStack(alignment: .leading, spacing: 3) { Text("운영 중").font(.caption2).foregroundStyle(CrocTheme.orange); Text(place.name).font(.caption.weight(.bold)); Text("\(place.location) · \(place.capacity)").font(.system(size: 9)).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary) }.padding(9).background(.white, in: RoundedRectangle(cornerRadius: 15)) } }

struct PlaceListView: View { var body: some View { List(samplePlaces) { place in NavigationLink { PlaceDetailView(place: place) } label: { PlaceRow(place: place).listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)) }.listRowSeparator(.hidden) }.listStyle(.plain).navigationTitle("공간 찾기") } }
struct PlaceDetailView: View { let place: Place; var body: some View { ScrollView { VStack(alignment: .leading, spacing: 18) { PlaceArtwork(index: place.artwork).frame(height: 260); Text(place.name).font(.largeTitle.bold()); Text("\(place.location) · \(place.capacity)").foregroundStyle(.secondary); RatingView(value: place.rating); Button("이 공간에서 공연 만들기") {}.buttonStyle(.borderedProminent).tint(CrocTheme.orange) }.padding(.bottom) }.ignoresSafeArea(edges: .top) } }
struct ShowDetailView: View { let show: Show; @State private var joined = false; var body: some View { ScrollView { VStack(alignment: .leading, spacing: 16) { PlaceArtwork(index: show.artwork).frame(height: 270); VStack(alignment: .leading, spacing: 9) { Text(show.category).font(.caption).foregroundStyle(CrocTheme.orange); Text(show.title).font(.largeTitle.bold()); Text("\(show.date)\n\(show.location)").foregroundStyle(.secondary); VStack(alignment: .leading, spacing: 8) { HStack { Text("펀딩 달성률").font(.subheadline.bold()); Spacer(); Text("\(Int(show.progress * 100))%").font(.title3.bold()).foregroundStyle(CrocTheme.orange) }; ProgressView(value: show.progress).tint(CrocTheme.orange); Text("목표 달성 시 공연이 확정돼요 · 목표 30명").font(.caption2).foregroundStyle(.secondary) }.padding(14).background(CrocTheme.canvas, in: RoundedRectangle(cornerRadius: 14)); Text("이런 공연이에요").font(.headline); Text("좋아하는 아티스트의 무대를 우리 동네에서 만나요. 관객의 사전 티켓 구매로 공연이 만들어집니다.").font(.subheadline).foregroundStyle(.secondary).lineSpacing(4); Button(joined ? "참여 완료! 티켓을 확인하세요" : "티켓 펀딩 참여하기 · 15,000원") { joined = true }.buttonStyle(.borderedProminent).tint(joined ? .green : CrocTheme.orange).frame(maxWidth: .infinity) }.padding(.horizontal, 16) }.padding(.bottom) }.navigationTitle("공연 상세").navigationBarTitleDisplayMode(.inline) } }
struct CreateShowView: View { @Environment(\.dismiss) private var dismiss; @State private var title = ""; var body: some View { NavigationStack { Form { Section("공연 정보") { TextField("공연 제목", text: $title); Picker("공연할 공간", selection: .constant("한울교회")) { Text("한울교회").tag("한울교회"); Text("망원동 카페 웨이브").tag("망원동 카페 웨이브") }; TextField("티켓 가격", text: .constant("15,000")); TextField("목표 관객 수", text: .constant("30")) }; Section { Button("공연 등록하기") { dismiss() }.disabled(title.isEmpty) } }.navigationTitle("새 공연").toolbar { ToolbarItem(placement: .cancellationAction) { Button("닫기") { dismiss() } } } } } }
