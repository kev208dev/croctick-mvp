import SwiftUI

struct Place: Identifiable {
    let id: String
    let name: String
    let location: String
    let capacity: String
    let rating: String
    let artwork: Int
}

struct Show: Identifiable {
    let id: String
    let title: String
    let date: String
    let location: String
    let category: String
    let progress: Double
    let artwork: Int
}

let samplePlaces = [
    Place(id: "place-hanmaeum", name: "한마음 교회", location: "경기도 남양주시 해밀예당 1로 189번길", capacity: "최대 150명", rating: "(2394)", artwork: 0),
    Place(id: "place-hopyeong", name: "호평 주 평화 교회", location: "남양주시 호평동 천마산로 1", capacity: "최대 30명", rating: "(198)", artwork: 1),
    Place(id: "place-haemaji", name: "해맞이 그린 센터", location: "경상북도 포항시 환호동", capacity: "최대 54명", rating: "(54)", artwork: 2),
    Place(id: "place-ihyun", name: "이현 교회", location: "용인시 기흥구 영덕동", capacity: "최대 80명", rating: "(593)", artwork: 3)
]

let sampleShows = [
    Show(id: "show-sultan", title: "술탄 오브 더 디스코", date: "10/24~10/25", location: "경기도 시흥시 능곡동", category: "Solo concert", progress: 0.82, artwork: 0),
    Show(id: "show-pocket", title: "Poket Music Fst", date: "10/3~10/5", location: "Dragon phony,Han...", category: "Music", progress: 0.64, artwork: 1),
    Show(id: "show-oasis", title: "Oasis concert", date: "12/12~12/15", location: "Oasis", category: "Lo-fi", progress: 0.47, artwork: 2),
    Show(id: "show-indie", title: "Indie Band Bond", date: "11/24~12/1", location: "Silica Gell", category: "Band", progress: 0.71, artwork: 3)
]

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        Group {
            switch selectedTab {
            case 1: ShowsView()
            case 2: MyPageView()
            default: HomeView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CrocTabBar(selection: $selectedTab)
        }
    }
}

struct CrocTabBar: View {
    @Binding var selection: Int
    private let tabs = [("홈", "house.fill"), ("공연", "ticket.fill"), ("마이", "person.fill")]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button { selection = index } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tabs[index].1).font(.system(size: 21, weight: .semibold))
                        Text(tabs[index].0).font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(selection == index ? CrocTheme.orange : .white)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 79)
        .background(Color.black)
    }
}

struct TopBar: View {
    var settingsAction: (() -> Void)? = nil
    @State private var notice: String?
    var body: some View {
        HStack {
            Button { notice = "메뉴" } label: { Image(systemName: "line.3.horizontal").font(.headline) }
                .buttonStyle(.bordered).buttonBorderShape(.circle).controlSize(.small)
            Spacer()
            CrocLogo()
            Spacer()
            HStack(spacing: 8) {
                Button { notice = "새 알림이 없습니다." } label: { Image(systemName: "bell") }.buttonStyle(.bordered).buttonBorderShape(.circle).controlSize(.small)
                if let settingsAction {
                    Button(action: settingsAction) { Image(systemName: "gearshape") }.buttonStyle(.bordered).buttonBorderShape(.circle).controlSize(.small)
                } else {
                    Button { notice = "프로필은 마이페이지에서 관리할 수 있어요." } label: { Image(systemName: "person") }.buttonStyle(.bordered).buttonBorderShape(.circle).controlSize(.small)
                }
            }
        }
        .tint(CrocTheme.ink)
        .alert("CrocTick", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) { Button("확인", role: .cancel) {} } message: { Text(notice ?? "") }
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
    @State private var selectedCategory = "Calm"
    @State private var showPlaces = false
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
                        SectionHeader(title: "Recommend", action: { showPlaces = true })
                        NavigationLink { PlaceListView() } label: {
                            HStack(spacing: 10) {
                                PlaceArtwork(index: 0).frame(width: 76, height: 76).clipShape(RoundedRectangle(cornerRadius: 11))
                                VStack(alignment: .leading, spacing: 4) { Text("한마음 교회").font(.subheadline.weight(.bold)); Text("경기도 남양주시 해밀예당 1로 189번길").font(.caption2).foregroundStyle(.secondary); RatingView(value: "(2394)") }
                                Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                            }
                            .padding(9).background(.white, in: RoundedRectangle(cornerRadius: 15)).shadow(color: CrocTheme.cardShadow, radius: 8, y: 3)
                        }.buttonStyle(.plain)
                        SectionHeader(title: "Place", action: { showPlaces = true })
                        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 8) { ForEach(samplePlaces) { PlaceCard(place: $0) } } }
                        SectionHeader(title: "Categories")
                        HStack(spacing: 8) { ForEach(["Calm", "Band", "Lo-fi", "Jazz"], id: \.self) { category in Button { selectedCategory = category } label: { Text(category).font(.caption).foregroundStyle(selectedCategory == category ? .white : CrocTheme.ink).padding(.horizontal, 16).padding(.vertical, 8).background(selectedCategory == category ? CrocTheme.ink : .white, in: Capsule()).overlay(Capsule().stroke(.quaternary)) } } }
                    }
                    .padding(16)
                }
            }
            .background(CrocTheme.canvas)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showPlaces) { NavigationStack { PlaceListView() } }
        }
    }
}

struct PlaceCard: View {
    let place: Place
    var body: some View { NavigationLink { PlaceDetailView(place: place) } label: { VStack(alignment: .leading, spacing: 3) { PlaceArtwork(index: place.artwork).frame(width: 104, height: 72).clipShape(RoundedRectangle(cornerRadius: 9)); Text(place.name).font(.caption2.weight(.bold)).lineLimit(1); Text(place.location).font(.system(size: 8)).foregroundStyle(.secondary); RatingView(value: place.rating) }.frame(width: 104, alignment: .leading).padding(5).background(.white, in: RoundedRectangle(cornerRadius: 12)) }.buttonStyle(.plain) }
}

struct ShowsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var query = ""
    @State private var category = "추천순"
    @State private var highFundingOnly = false
    @State private var showAll = false
    var filtered: [Show] {
        let categoryMap = ["잔잔한": "Lo-fi", "신나는": "Music", "나만 아는": "Band"]
        return model.allShows
            .filter { query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) }
            .filter { category == "추천순" || category == "내 주변" || $0.category == categoryMap[category] }
            .filter { !highFundingOnly || $0.progress >= 0.7 }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    TopBar().padding(.top, 6)
                    SearchPill(text: $query)
                        .background(CrocTheme.peach.opacity(0.33), in: Capsule())
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(["추천순", "잔잔한", "신나는", "나만 아는", "내 주변"], id: \.self) { chip in
                                Button("#\(chip)") { category = chip }
                                    .font(.caption2)
                                    .foregroundStyle(category == chip ? .white : CrocTheme.ink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(category == chip ? CrocTheme.ink : .white, in: Capsule())
                            }
                            Button { highFundingOnly.toggle() } label: { Image(systemName: "slider.horizontal.3").foregroundStyle(highFundingOnly ? .white : CrocTheme.ink) }
                                .padding(8)
                                .background(highFundingOnly ? CrocTheme.ink : .white, in: Circle())
                        }
                    }
                    SectionHeader(title: "Recommend", action: { showAll = true })
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(filtered) { ShowCard(show: $0) }
                    }
                }
                .padding(16)
            }
            .background(CrocTheme.canvas)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAll) { ShowsView() }
        }
    }
}

struct ShowCard: View {
    let show: Show
    var body: some View { NavigationLink { ShowDetailView(show: show) } label: { VStack(alignment: .leading, spacing: 6) { PlaceArtwork(index: show.artwork).frame(height: 132).clipShape(RoundedRectangle(cornerRadius: 13)); Text(show.title).font(.caption.weight(.bold)).lineLimit(1); Text(show.date).font(.caption2); Text(show.location).font(.system(size: 9)).foregroundStyle(.secondary); HStack { Text("\(Int(show.progress * 100))% funded").font(.system(size: 9, weight: .bold)).foregroundStyle(CrocTheme.orange); Spacer(); Text("30 tickets").font(.system(size: 9)).foregroundStyle(.secondary) }; ProgressView(value: show.progress).tint(CrocTheme.orange) }.padding(9).background(.white, in: RoundedRectangle(cornerRadius: 15)).shadow(color: CrocTheme.cardShadow, radius: 8, y: 3) }.buttonStyle(.plain) }
}

struct MyPageView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showCreate = false
    @State private var showSettings = false
    var body: some View { NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 14) { TopBar { showSettings = true }; HStack { Image(systemName: "person.circle.fill").font(.system(size: 43)).foregroundStyle(CrocTheme.orange); VStack(alignment: .leading) { Text("\(model.userName)님, 안녕하세요!").font(.headline); Text("오늘도 가까운 곳에서 만나는 무대").font(.caption2).foregroundStyle(.secondary) }; Spacer() }; HStack { Stat(value: "1", label: "예매 티켓"); Stat(value: "1", label: "내 공간"); Stat(value: "1", label: "진행 공연") }.padding(14).background(.white, in: RoundedRectangle(cornerRadius: 15)); SectionHeader(title: "My ticket"); NavigationLink { ShowDetailView(show: sampleShows[1]) } label: { TicketRow() }.buttonStyle(.plain); SectionHeader(title: "My space"); NavigationLink { PlaceListView() } label: { PlaceRow(place: samplePlaces[1]) }.buttonStyle(.plain); SectionHeader(title: "Show edit"); Button { showCreate = true } label: { HStack { Image(systemName: "music.note").foregroundStyle(CrocTheme.orange).padding(8).background(CrocTheme.peach.opacity(0.35), in: RoundedRectangle(cornerRadius: 9)); VStack(alignment: .leading) { Text("우리 동네 어쿠스틱 나잇").font(.caption.weight(.bold)); Text("작성 중 · 공연 정보를 완성해 보세요").font(.caption2).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary) }.padding(12).background(.white, in: RoundedRectangle(cornerRadius: 15)) }.buttonStyle(.plain) }.padding(16) }.background(CrocTheme.canvas).toolbar(.hidden, for: .navigationBar).sheet(isPresented: $showCreate) { CreateShowView() }.sheet(isPresented: $showSettings) { SettingsView() } } }
}

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section("프로필") {
                    TextField("사용자명", text: $model.userName)
                }
                Section {
                    Button("저장") { dismiss() }
                }
            }
            .navigationTitle("설정")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}

struct Stat: View { let value: String; let label: String; var body: some View { VStack { Text(value).font(.headline); Text(label).font(.caption2).foregroundStyle(.secondary) }.frame(maxWidth: .infinity) } }
struct TicketRow: View { var body: some View { HStack { ZStack { CrocTheme.orange; Image(systemName: "music.note").foregroundStyle(.white) }.frame(width: 70, height: 78).clipShape(RoundedRectangle(cornerRadius: 10)); VStack(alignment: .leading, spacing: 4) { Text("예매 완료").font(.caption2).foregroundStyle(CrocTheme.orange); Text("Pocket Music Fest").font(.caption.weight(.bold)); Text("10.03 (토) · 18:00\n한마음 교회 · 일반석 1매").font(.system(size: 9)).foregroundStyle(.secondary) }; Spacer(); Text("티켓 보기 →").font(.system(size: 9, weight: .bold)).foregroundStyle(.white).padding(8).background(CrocTheme.orange, in: Capsule()) }.padding(10).background(.white, in: RoundedRectangle(cornerRadius: 15)) } }
struct PlaceRow: View { let place: Place; var body: some View { HStack { PlaceArtwork(index: place.artwork).frame(width: 55, height: 55).clipShape(RoundedRectangle(cornerRadius: 10)); VStack(alignment: .leading, spacing: 3) { Text("운영 중").font(.caption2).foregroundStyle(CrocTheme.orange); Text(place.name).font(.caption.weight(.bold)); Text("\(place.location) · \(place.capacity)").font(.system(size: 9)).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary) }.padding(9).background(.white, in: RoundedRectangle(cornerRadius: 15)) } }

struct PlaceListView: View { var body: some View { List(samplePlaces) { place in NavigationLink { PlaceDetailView(place: place) } label: { PlaceRow(place: place).listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)) }.listRowSeparator(.hidden) }.listStyle(.plain).navigationTitle("공간 찾기") } }
struct PlaceDetailView: View { let place: Place; @State private var showCreate = false; var body: some View { ScrollView { VStack(alignment: .leading, spacing: 18) { PlaceArtwork(index: place.artwork).frame(height: 260); Text(place.name).font(.largeTitle.bold()); Text("\(place.location) · \(place.capacity)").foregroundStyle(.secondary); RatingView(value: place.rating); Button("이 공간에서 공연 만들기") { showCreate = true }.buttonStyle(.borderedProminent).tint(CrocTheme.orange) }.padding(.bottom) }.ignoresSafeArea(edges: .top).sheet(isPresented: $showCreate) { CreateShowView(defaultPlace: place.name) } } }
struct ShowDetailView: View { let show: Show; @EnvironmentObject private var model: AppModel; var isJoined: Bool { model.joinedShowIDs.contains(show.id) }; var body: some View { ScrollView { VStack(alignment: .leading, spacing: 16) { PlaceArtwork(index: show.artwork).frame(height: 270); VStack(alignment: .leading, spacing: 9) { Text(show.category).font(.caption).foregroundStyle(CrocTheme.orange); Text(show.title).font(.largeTitle.bold()); Text("\(show.date)\n\(show.location)").foregroundStyle(.secondary); VStack(alignment: .leading, spacing: 8) { HStack { Text("펀딩 달성률").font(.subheadline.bold()); Spacer(); Text("\(Int(show.progress * 100))%").font(.title3.bold()).foregroundStyle(CrocTheme.orange) }; ProgressView(value: show.progress).tint(CrocTheme.orange); Text("목표 달성 시 공연이 확정돼요 · 목표 30명").font(.caption2).foregroundStyle(.secondary) }.padding(14).background(CrocTheme.canvas, in: RoundedRectangle(cornerRadius: 14)); Text("이런 공연이에요").font(.headline); Text("좋아하는 아티스트의 무대를 우리 동네에서 만나요. 관객의 사전 티켓 구매로 공연이 만들어집니다.").font(.subheadline).foregroundStyle(.secondary).lineSpacing(4); Button(isJoined ? "참여 완료! 티켓을 확인하세요" : "티켓 펀딩 참여하기 · 15,000원") { model.join(show) }.buttonStyle(.borderedProminent).tint(isJoined ? .green : CrocTheme.orange).frame(maxWidth: .infinity) }.padding(.horizontal, 16) }.padding(.bottom) }.navigationTitle("공연 상세").navigationBarTitleDisplayMode(.inline) } }
struct CreateShowView: View { @Environment(\.dismiss) private var dismiss; @EnvironmentObject private var model: AppModel; var defaultPlace: String = "한마음 교회"; @State private var title = ""; @State private var place = "한마음 교회"; @State private var price = "15,000"; @State private var audience = "30"; var body: some View { NavigationStack { Form { Section("공연 정보") { TextField("공연 제목", text: $title); Picker("공연할 공간", selection: $place) { Text("한마음 교회").tag("한마음 교회"); Text("호평 주 평화 교회").tag("호평 주 평화 교회"); Text("해맞이 그린 센터").tag("해맞이 그린 센터"); Text("이현 교회").tag("이현 교회") }; TextField("티켓 가격", text: $price).keyboardType(.numberPad); TextField("목표 관객 수", text: $audience).keyboardType(.numberPad) }; Section { Button("공연 등록하기") { model.add(show: Show(id: "created-\(UUID().uuidString)", title: title, date: "새로 등록한 공연", location: place, category: "Music", progress: 0, artwork: 0)); dismiss() }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) } }.navigationTitle("새 공연").onAppear { place = defaultPlace }.toolbar { ToolbarItem(placement: .cancellationAction) { Button("닫기") { dismiss() } } } } } }
