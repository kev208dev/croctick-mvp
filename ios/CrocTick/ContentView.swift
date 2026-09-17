import SwiftUI
import PhotosUI

struct Place: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let capacity: String
    let rating: String
    let artwork: Int
    let introduction: String?
    let equipment: String?
    let rentalFee: Int?
    let operatingHours: String?
    let photoData: Data?

    init(id: String, name: String, location: String, capacity: String, rating: String, artwork: Int, introduction: String? = nil, equipment: String? = nil, rentalFee: Int? = nil, operatingHours: String? = nil, photoData: Data? = nil) {
        self.id = id
        self.name = name
        self.location = location
        self.capacity = capacity
        self.rating = rating
        self.artwork = artwork
        self.introduction = introduction
        self.equipment = equipment
        self.rentalFee = rentalFee
        self.operatingHours = operatingHours
        self.photoData = photoData
    }
}

struct Show: Identifiable, Codable {
    let id: String
    let title: String
    let date: String
    let location: String
    let category: String
    let progress: Double
    let artwork: Int
    let introduction: String?
    let artists: String?
    let ticketPrice: Int?
    let targetAudience: Int?
    let fundingGoal: Int?
    let posterData: Data?

    init(id: String, title: String, date: String, location: String, category: String, progress: Double, artwork: Int, introduction: String? = nil, artists: String? = nil, ticketPrice: Int? = nil, targetAudience: Int? = nil, fundingGoal: Int? = nil, posterData: Data? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.location = location
        self.category = category
        self.progress = progress
        self.artwork = artwork
        self.introduction = introduction
        self.artists = artists
        self.ticketPrice = ticketPrice
        self.targetAudience = targetAudience
        self.fundingGoal = fundingGoal
        self.posterData = posterData
    }

    static func conflicts(_ lhs: Show, _ rhs: Show) -> Bool {
        lhs.id != rhs.id &&
        lhs.location.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare(rhs.location.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame &&
        lhs.date == rhs.date
    }

    static func defaultPosterData(for place: Place?) -> Data? {
        place?.photoData
    }
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

enum AppTab: Int, CaseIterable, Identifiable {
    case home, shows, my

    var id: Int { rawValue }
    var title: String { ["홈", "공연", "마이"][rawValue] }
    var icon: String { ["house.fill", "ticket.fill", "person.fill"][rawValue] }
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: AppTab = .home
    @State private var selectedShowCategory = "추천순"
    @State private var showMenu = false
    @State private var showNotifications = false

    var body: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeView(
                    onMenu: { showMenu = true },
                    onNotifications: { showNotifications = true },
                    onProfile: { selectedTab = .my },
                    onCategory: openShows
                )
            case .shows:
                ShowsView(
                    category: $selectedShowCategory,
                    onMenu: { showMenu = true },
                    onNotifications: { showNotifications = true },
                    onProfile: { selectedTab = .my }
                )
            case .my:
                MyPageView(
                    onMenu: { showMenu = true },
                    onNotifications: { showNotifications = true }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CrocTabBar(selection: $selectedTab)
        }
        .sheet(isPresented: $showMenu) {
            MenuView { destination in
                selectedTab = destination
                showMenu = false
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .dynamicTypeSize(horizontalSizeClass == .regular ? .xxLarge : .xLarge)
    }

    private func openShows(category: String) {
        selectedShowCategory = category
        selectedTab = .shows
    }
}

struct CrocTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    withAnimation(.easeOut(duration: 0.18)) { selection = tab }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 21, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(selection == tab ? CrocTheme.orange : .white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(tab.title) 탭")
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .frame(height: 68)
        .background(Color.black.ignoresSafeArea(edges: .bottom))
    }
}

struct TopBar: View {
    let onMenu: () -> Void
    let onNotifications: () -> Void
    let trailingIcon: String
    let trailingLabel: String
    let trailingAction: () -> Void

    var body: some View {
        ZStack {
            CrocLogo().accessibilityLabel("CrocTick")
            HStack {
                RoundIconButton(icon: "line.3.horizontal", label: "메뉴", action: onMenu)
                Spacer(minLength: 0)
                HStack(spacing: 8) {
                    RoundIconButton(icon: "bell", label: "알림", action: onNotifications)
                    RoundIconButton(icon: trailingIcon, label: trailingLabel, action: trailingAction)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .frame(height: 76, alignment: .top)
        .padding(.top, 4)
    }
}

struct RoundIconButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(CrocTheme.ink)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.34), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

struct SearchPill: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField("Searching...", text: $text)
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
            if !text.isEmpty {
                Button { text = "" } label: { Image(systemName: "xmark.circle.fill") }
                    .buttonStyle(.plain)
                    .accessibilityLabel("검색어 지우기")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(.white.opacity(0.72), in: Capsule())
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle = "see all"
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title).font(.title3.weight(.semibold))
            Spacer()
            if let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let onMenu: () -> Void
    let onNotifications: () -> Void
    let onProfile: () -> Void
    let onCategory: (String) -> Void

    @State private var query = ""
    @State private var showPlaces = false
    @State private var showSpaceRegistration = false

    private var isRegular: Bool { horizontalSizeClass == .regular }

    private var visiblePlaces: [Place] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return model.allPlaces }
        return model.allPlaces.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.location.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        OrangeHero().frame(height: isRegular ? 420 : 340)
                        VStack(alignment: .leading, spacing: 16) {
                            TopBar(
                                onMenu: onMenu,
                                onNotifications: onNotifications,
                                trailingIcon: "person",
                                trailingLabel: "마이페이지",
                                trailingAction: onProfile
                            )
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Find your stage").font(.subheadline).foregroundStyle(CrocTheme.ink.opacity(0.62))
                                Text("무대 위\n스타를\n우리 집 앞으로")
                                    .font(.system(size: isRegular ? 40 : 34, weight: .black))
                                    .lineSpacing(-3)
                            }
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: isRegular ? 68 : 60))
                                    .foregroundStyle(.white.opacity(0.58))
                                    .rotationEffect(.degrees(-14))
                                    .offset(x: -4, y: 10)
                            }
                            SearchPill(text: $query)
                        }
                        .padding(.horizontal, 16)
                        .adaptivePage(maxWidth: 960)
                    }
                    VStack(alignment: .leading, spacing: 14) {
                        if query.isEmpty {
                            SectionHeader(title: "Recommend", action: { showPlaces = true })
                            NavigationLink { PlaceDetailView(place: samplePlaces[0]) } label: {
                                FeaturedPlaceCard(place: samplePlaces[0])
                            }
                            .buttonStyle(.plain)
                        }
                        SectionHeader(
                            title: query.isEmpty ? "Place" : "Search results",
                            actionTitle: query.isEmpty ? "공간 등록 +" : "",
                            action: query.isEmpty ? { showSpaceRegistration = true } : nil
                        )
                        if visiblePlaces.isEmpty {
                            EmptySearchView(message: "일치하는 공간이 없어요")
                        } else {
                            if isRegular {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                                    ForEach(visiblePlaces) { PlaceCard(place: $0) }
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) { ForEach(visiblePlaces) { PlaceCard(place: $0) } }
                                }
                            }
                        }
                        SectionHeader(title: "Categories")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                CategoryButton(title: "Calm") { onCategory("잔잔한") }
                                CategoryButton(title: "Band") { onCategory("나만 아는") }
                                CategoryButton(title: "Lo-fi") { onCategory("잔잔한") }
                                CategoryButton(title: "Jazz") { onCategory("추천순") }
                            }
                        }
                    }
                    .padding(16)
                    .adaptivePage(maxWidth: 960)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(CrocTheme.canvas)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showPlaces) { NavigationStack { PlaceListView() } }
            .sheet(isPresented: $showSpaceRegistration) { RegisterSpaceView() }
        }
    }
}

struct FeaturedPlaceCard: View {
    let place: Place

    var body: some View {
        HStack(spacing: 10) {
            PlaceArtwork(index: place.artwork)
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name).font(.subheadline.weight(.bold))
                Text(place.location).font(.caption2).foregroundStyle(.secondary)
                RatingView(value: place.rating)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
        }
        .padding(9)
        .crocCard()
    }
}

struct PlaceCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let place: Place

    private var cardWidth: CGFloat { horizontalSizeClass == .regular ? 180 : 104 }

    var body: some View {
        NavigationLink { PlaceDetailView(place: place) } label: {
            VStack(alignment: .leading, spacing: 3) {
                PlaceArtwork(index: place.artwork)
                    .frame(width: cardWidth, height: horizontalSizeClass == .regular ? 112 : 72)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                Text(place.name).font(.caption2.weight(.bold)).lineLimit(1)
                Text(place.location).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                RatingView(value: place.rating)
            }
            .frame(width: cardWidth, alignment: .leading)
            .padding(5)
            .background(.white, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct CategoryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) { Image(systemName: "music.note"); Text(title) }
                .font(.caption.weight(.medium))
                .foregroundStyle(CrocTheme.ink)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(.white, in: Capsule())
                .overlay(Capsule().stroke(.black.opacity(0.08)))
        }
        .buttonStyle(.plain)
    }
}

struct ShowsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var category: String
    let onMenu: () -> Void
    let onNotifications: () -> Void
    let onProfile: () -> Void

    @State private var query = ""
    @State private var highFundingOnly = false
    @State private var showAll = false
    private let chips = ["추천순", "잔잔한", "신나는", "나만 아는", "내 주변"]

    private var isRegular: Bool { horizontalSizeClass == .regular }

    private var isDefaultBrowse: Bool { query.isEmpty && category == "추천순" && !highFundingOnly && !showAll }

    private var filtered: [Show] {
        let categoryMap = ["잔잔한": "Lo-fi", "신나는": "Music", "나만 아는": "Band"]
        return model.allShows
            .filter { query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) || $0.location.localizedCaseInsensitiveContains(query) }
            .filter { category == "추천순" || category == "내 주변" || $0.category == categoryMap[category] }
            .filter { !highFundingOnly || $0.progress >= 0.7 }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    TopBar(
                        onMenu: onMenu,
                        onNotifications: onNotifications,
                        trailingIcon: "person",
                        trailingLabel: "마이페이지",
                        trailingAction: onProfile
                    )
                    SearchPill(text: $query).background(CrocTheme.peach.opacity(0.33), in: Capsule())
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(chips, id: \.self) { chip in
                                FilterChip(title: chip, selected: category == chip) { category = chip }
                            }
                            Button { highFundingOnly.toggle() } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundStyle(highFundingOnly ? .white : CrocTheme.ink)
                                    .frame(width: 32, height: 32)
                                    .background(highFundingOnly ? CrocTheme.ink : .white, in: Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("펀딩률 70% 이상만 보기")
                            .accessibilityValue(highFundingOnly ? "켜짐" : "꺼짐")
                        }
                    }
                    if isDefaultBrowse {
                        SectionHeader(title: "Recommend", action: { showAll = true })
                        FeaturedShowCard(show: sampleShows[0])
                        SectionHeader(title: "Categories", action: { showAll = true })
                        if isRegular {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 14)], spacing: 14) {
                                ForEach(model.allShows.filter { $0.id != sampleShows[0].id }) { CompactShowCard(show: $0) }
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(model.allShows.filter { $0.id != sampleShows[0].id }) { CompactShowCard(show: $0) }
                                }
                            }
                        }
                    } else {
                        SectionHeader(title: "Shows", actionTitle: "reset", action: resetFilters)
                        if filtered.isEmpty {
                            EmptySearchView(message: "조건에 맞는 공연이 없어요")
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: isRegular ? 210 : 145), spacing: 12)], spacing: 12) {
                                ForEach(filtered) { ShowCard(show: $0) }
                            }
                        }
                    }
                }
                .padding(16)
                .adaptivePage(maxWidth: 960)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(OrangeHero().opacity(0.68).ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func resetFilters() {
        query = ""
        category = "추천순"
        highFundingOnly = false
        showAll = false
    }
}

struct FilterChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button("#\(title)", action: action)
            .font(.caption2.weight(.medium))
            .foregroundStyle(selected ? .white : CrocTheme.ink)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(selected ? CrocTheme.ink : .white, in: Capsule())
            .buttonStyle(.plain)
    }
}

struct FeaturedShowCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let show: Show

    var body: some View {
        NavigationLink { ShowDetailView(show: show) } label: {
            HStack(spacing: 12) {
                PosterArtwork(index: show.artwork, data: show.posterData)
                    .frame(width: horizontalSizeClass == .regular ? 156 : 108, height: horizontalSizeClass == .regular ? 198 : 138)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 7) {
                    Text(show.title).font(.headline).lineLimit(2)
                    Divider()
                    Text(show.date).font(.subheadline.weight(.medium))
                    Text(show.category).font(.caption)
                    Text(show.location).font(.caption2).foregroundStyle(.secondary)
                    RatingView(value: "(2120)")
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .crocCard()
        }
        .buttonStyle(.plain)
    }
}

struct CompactShowCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let show: Show

    private var cardWidth: CGFloat { horizontalSizeClass == .regular ? 190 : 118 }

    var body: some View {
        NavigationLink { ShowDetailView(show: show) } label: {
            VStack(alignment: .leading, spacing: 4) {
                PosterArtwork(index: show.artwork, data: show.posterData)
                    .frame(width: cardWidth, height: horizontalSizeClass == .regular ? 238 : 158)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(show.title).font(.caption.weight(.bold)).lineLimit(1)
                Text(show.date).font(.caption2)
                Text(show.location).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            .frame(width: cardWidth, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

struct ShowCard: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let show: Show

    var body: some View {
        NavigationLink { ShowDetailView(show: show) } label: {
            VStack(alignment: .leading, spacing: 6) {
                PosterArtwork(index: show.artwork, data: show.posterData)
                    .frame(height: horizontalSizeClass == .regular ? 240 : 156)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                Text(show.title).font(.caption.weight(.bold)).lineLimit(1)
                Text(show.date).font(.caption2)
                Text(show.location).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                HStack {
                    Text("\(Int(model.fundingProgress(for: show) * 100))% funded")
                        .font(.caption.weight(.bold)).foregroundStyle(CrocTheme.orange)
                    Spacer()
                    Text("\(show.targetAudience ?? 30) tickets").font(.caption).foregroundStyle(.secondary)
                }
                ProgressView(value: model.fundingProgress(for: show)).tint(CrocTheme.orange)
            }
            .padding(9)
            .crocCard()
        }
        .buttonStyle(.plain)
    }
}

struct MyPageView: View {
    @EnvironmentObject private var model: AppModel
    let onMenu: () -> Void
    let onNotifications: () -> Void

    @State private var showCreate = false
    @State private var showSettings = false
    @State private var showTickets = false
    @State private var showSpaceRegistration = false
    @State private var showTickSystem = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    TopBar(
                        onMenu: onMenu,
                        onNotifications: onNotifications,
                        trailingIcon: "gearshape",
                        trailingLabel: "설정",
                        trailingAction: { showSettings = true }
                    )
                    HStack(spacing: 11) {
                        Image(systemName: "person.circle.fill").font(.system(size: 43)).foregroundStyle(CrocTheme.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(model.userName)님, 안녕하세요!").font(.headline)
                            Text("오늘도 가까운 곳에서 만나는 무대").font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    HStack {
                        Stat(value: "\(model.joinedShows.count)", label: "예매 티켓")
                        Divider().frame(height: 28)
                        Stat(value: "\(model.registeredPlaces.count)", label: "내 공간")
                        Divider().frame(height: 28)
                        Stat(value: "\(max(1, model.createdShows.count))", label: "진행 공연")
                    }
                    .padding(14)
                    .crocCard()
                    TickSummaryCard(tick: model.tickBalance, tier: model.tickTier) {
                        showTickSystem = true
                    }
                    SectionHeader(title: "My ticket", actionTitle: "전체 보기", action: { showTickets = true })
                    ForEach(model.joinedShows.prefix(2)) { show in
                        NavigationLink { ShowDetailView(show: show) } label: { TicketRow(show: show) }
                            .buttonStyle(.plain)
                    }
                    SectionHeader(title: "My space", actionTitle: "공간 등록 +", action: { showSpaceRegistration = true })
                    ForEach(model.registeredPlaces.prefix(2)) { place in
                        NavigationLink { PlaceDetailView(place: place) } label: { PlaceRow(place: place) }
                            .buttonStyle(.plain)
                    }
                    SectionHeader(title: "Show edit", actionTitle: "공연 만들기 +", action: { showCreate = true })
                    if model.createdShows.isEmpty {
                        DraftShowRow { showCreate = true }
                    } else {
                        ForEach(model.createdShows.prefix(3)) { show in
                            NavigationLink { ShowDetailView(show: show) } label: { CreatedShowRow(show: show) }
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
                .adaptivePage(maxWidth: 760)
            }
            .background(OrangeHero().opacity(0.68).ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCreate) { CreateShowView() }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showTickets) { TicketListView() }
            .sheet(isPresented: $showSpaceRegistration) { RegisterSpaceView() }
            .sheet(isPresented: $showTickSystem) { TickSystemView() }
        }
    }
}

struct TickSummaryCard: View {
    let tick: Int
    let tier: TickTier
    let action: () -> Void

    private var nextTier: TickTier? {
        TickTier.all.first { $0.minimumTick > tick }
    }

    private var progress: Double {
        guard let nextTier else { return 1 }
        let span = max(nextTier.minimumTick - tier.minimumTick, 1)
        return min(1, Double(tick - tier.minimumTick) / Double(span))
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("내 틱 정산").font(.title3.bold())
                        Text("성장 단계별 공연 규모와 티켓 정책").font(.caption).foregroundStyle(.white.opacity(0.66))
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.white.opacity(0.72))
                }
                HStack(spacing: 12) {
                    TickTierBadge(tier: tier, size: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(tier.name).font(.title2.bold())
                        Text(tier.rangeLabel).font(.caption.weight(.semibold)).foregroundStyle(tier.accent)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(tick)").font(.system(size: 32, weight: .black, design: .rounded))
                        Text("TICK").font(.caption2.weight(.bold)).foregroundStyle(.white.opacity(0.66))
                    }
                }
                ProgressView(value: progress).tint(tier.accent)
                Text(nextTier.map { "다음 \($0.name)까지 \(max($0.minimumTick - tick, 0)) Tick 남음" } ?? "최상위 Headliner 등급이에요")
                    .font(.caption.weight(.medium)).foregroundStyle(.white.opacity(0.74))
            }
            .padding(18)
            .background(Color(red: 0.07, green: 0.08, blue: 0.11), in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(tier.accent.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("내 틱 정산, \(tier.name), \(tick) Tick")
    }
}

struct TickSystemView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 230 : 165), spacing: 12)]
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("틱 정산 시스템").font(.largeTitle.bold())
                        Text("성장 단계별 공연 규모와 티켓 정책").foregroundStyle(.secondary)
                    }
                    TickSummaryCard(tick: model.tickBalance, tier: model.tickTier, action: {})
                        .allowsHitTesting(false)
                    Text("전체 레벨").font(.title3.bold())
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(TickTier.all) { tier in
                            TickTierCard(tier: tier, isCurrent: tier == model.tickTier)
                        }
                    }
                    Text("틱 획득 방법 · 펀딩 참여 +1 · 공간 등록 +5 · 공연 등록 +10")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(20)
                .adaptivePage(maxWidth: 980)
            }
            .background(CrocTheme.canvas)
            .navigationTitle("내 틱 정산")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("닫기") { dismiss() } } }
        }
    }
}

struct TickTierCard: View {
    let tier: TickTier
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                TickTierBadge(tier: tier, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(tier.name).font(.headline.bold())
                    Text(tier.rangeLabel).font(.caption2.weight(.bold)).foregroundStyle(tier.accent)
                }
                Spacer()
                if isCurrent { Text("CURRENT").font(.caption2.bold()).foregroundStyle(tier.accent) }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("최저 티켓가 설정 한도").font(.caption2).foregroundStyle(.white.opacity(0.52))
                Text(tier.ticketLimit).font(.title2.bold())
                Text("/ 1매").font(.caption2).foregroundStyle(.white.opacity(0.52))
            }
            Divider().overlay(.white.opacity(0.16))
            Label(tier.venueDescription, systemImage: "checkmark.circle.fill")
                .font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.9))
            VStack(alignment: .leading, spacing: 3) {
                Text("최대 관객").font(.caption2).foregroundStyle(.white.opacity(0.52))
                Text(tier.audienceLabel).font(.title2.bold())
            }
            ProgressView(value: isCurrent ? 1 : 0).tint(tier.accent).opacity(isCurrent ? 1 : 0.45)
            Text(tier.note).font(.caption2).foregroundStyle(.white.opacity(0.52)).frame(minHeight: 28, alignment: .topLeading)
            if tier.isTopLevel {
                Text("TOP LEVEL").font(.caption2.bold()).foregroundStyle(.white).padding(.horizontal, 10).padding(.vertical, 6).background(tier.accent, in: Capsule())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 300, alignment: .topLeading)
        .background(tier.isTopLevel ? Color(red: 0.09, green: 0.22, blue: 0.35) : Color(red: 0.07, green: 0.08, blue: 0.11), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isCurrent ? tier.accent : .white.opacity(0.08), lineWidth: isCurrent ? 2 : 1))
    }
}

struct TickTierBadge: View {
    let tier: TickTier
    let size: CGFloat

    var body: some View {
        Group {
            if tier.symbol == "R" || tier.symbol == "R+" {
                Text(tier.symbol).font(.system(size: size * 0.42, weight: .black, design: .rounded))
            } else {
                Image(systemName: tier.symbol).font(.system(size: size * 0.42, weight: .bold))
            }
        }
        .foregroundStyle(.white)
        .frame(width: size, height: size)
        .background(tier.accent, in: RoundedRectangle(cornerRadius: size * 0.28))
    }
}

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var draftName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("프로필") { TextField("사용자명", text: $draftName) }
                Section("앱 정보") {
                    LabeledContent("버전", value: "MVP 1.0")
                    LabeledContent("계정", value: "amysailer@hanmail.net")
                }
            }
            .navigationTitle("설정")
            .onAppear { draftName = model.userName }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        model.userName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                    .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct Stat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value).font(.headline)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TicketRow: View {
    let show: Show

    var body: some View {
        HStack(spacing: 10) {
            PosterArtwork(index: show.artwork).frame(width: 70, height: 78).clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text("예매 완료").font(.caption2).foregroundStyle(CrocTheme.orange)
                Text(show.id == "show-pocket" ? "Pocket Music Fest" : show.title)
                    .font(.caption.weight(.bold)).lineLimit(1)
                Text("\(show.date) · 18:00\n한마음 교회 · 일반석 1매")
                        .font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            Text("티켓 보기 →")
                .font(.caption.weight(.bold)).foregroundStyle(.white)
                .padding(8).background(CrocTheme.orange, in: Capsule())
        }
        .padding(10)
        .crocCard()
    }
}

struct PlaceRow: View {
    let place: Place

    var body: some View {
        HStack(spacing: 10) {
            PlaceArtwork(index: place.artwork).frame(width: 55, height: 55).clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text("운영 중").font(.caption2).foregroundStyle(CrocTheme.orange)
                Text(place.name).font(.caption.weight(.bold))
                Text("\(place.location) · \(place.capacity)").font(.system(size: 9)).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(9)
        .crocCard()
    }
}

struct DraftShowRow: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "music.note")
                    .foregroundStyle(CrocTheme.orange).padding(8)
                    .background(CrocTheme.peach.opacity(0.35), in: RoundedRectangle(cornerRadius: 9))
                VStack(alignment: .leading, spacing: 3) {
                    Text("우리 동네 어쿠스틱 나잇").font(.caption.weight(.bold))
                    Text("작성 중 · 공연 정보를 완성해 보세요").font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding(12)
            .crocCard()
        }
        .buttonStyle(.plain)
    }
}

struct CreatedShowRow: View {
    let show: Show

    var body: some View {
        HStack(spacing: 10) {
            PosterArtwork(index: show.artwork).frame(width: 52, height: 64).clipShape(RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 4) {
                Text("등록 완료").font(.caption2).foregroundStyle(CrocTheme.orange)
                Text(show.title).font(.caption.weight(.bold))
                Text("\(show.location) · \(show.category)").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(10)
        .crocCard()
    }
}

struct PlaceListView: View {
    @EnvironmentObject private var model: AppModel
    var body: some View {
        List(model.allPlaces) { place in
            NavigationLink { PlaceDetailView(place: place) } label: { PlaceRow(place: place) }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(CrocTheme.canvas)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(CrocTheme.canvas)
        .navigationTitle("공간 찾기")
    }
}

struct PlaceDetailView: View {
    let place: Place
    @State private var showCreate = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PlaceArtwork(index: place.artwork, data: place.photoData).frame(height: 280).clipShape(RoundedRectangle(cornerRadius: 22))
                Text(place.name).font(.largeTitle.bold())
                Label(place.location, systemImage: "mappin.and.ellipse").foregroundStyle(.secondary)
                Label(place.capacity, systemImage: "person.2").foregroundStyle(.secondary)
                RatingView(value: place.rating)
                Divider()
                Text("공간 소개").font(.headline)
                Text(place.introduction ?? "동네 관객과 아티스트가 가까이 만날 수 있는 공연 공간입니다. 공연 장비와 좌석 배치는 협의할 수 있어요.")
                    .font(.subheadline).foregroundStyle(.secondary).lineSpacing(4)
                if let equipment = place.equipment, !equipment.isEmpty {
                    Label(equipment, systemImage: "hifispeaker.2")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                if let rentalFee = place.rentalFee {
                    Label("대관료 \(rentalFee.formatted())원 / 회차", systemImage: "wonsign.circle")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                if let operatingHours = place.operatingHours, !operatingHours.isEmpty {
                    Label("운영 시간 \(operatingHours)", systemImage: "clock")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Button("이 공간에서 공연 만들기") { showCreate = true }
                    .buttonStyle(CrocPrimaryButtonStyle())
            }
            .padding(16)
        }
        .background(CrocTheme.canvas)
        .navigationTitle("공간 상세")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreate) { CreateShowView(defaultPlace: place.name) }
    }
}

struct ShowDetailView: View {
    let show: Show
    @EnvironmentObject private var model: AppModel

    private var isJoined: Bool { model.joinedShowIDs.contains(show.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PosterArtwork(index: show.artwork, data: show.posterData).frame(height: 360).clipShape(RoundedRectangle(cornerRadius: 22))
                VStack(alignment: .leading, spacing: 10) {
                    Text(show.category).font(.caption.weight(.semibold)).foregroundStyle(CrocTheme.orange)
                    Text(show.title).font(.largeTitle.bold())
                    Label(show.date, systemImage: "calendar")
                    Label(show.location, systemImage: "mappin.and.ellipse")
                    FundingCard(show: show)
                    Text("이런 공연이에요").font(.headline).padding(.top, 4)
                    Text(show.introduction ?? "좋아하는 아티스트의 무대를 우리 동네에서 만나요. 관객의 사전 티켓 구매로 공연이 만들어집니다.")
                        .font(.subheadline).foregroundStyle(.secondary).lineSpacing(4)
                    if let artists = show.artists, !artists.isEmpty {
                        Label(artists, systemImage: "music.mic")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    Button(isJoined ? "참여 완료! 티켓을 확인하세요" : "티켓 펀딩 참여하기 · \((show.ticketPrice ?? 15_000).formatted())원") { model.join(show) }
                        .buttonStyle(CrocPrimaryButtonStyle(color: isJoined ? .green : CrocTheme.orange))
                        .disabled(isJoined)
                }
            }
            .padding(16)
        }
        .background(CrocTheme.canvas)
        .navigationTitle("공연 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FundingCard: View {
    let show: Show
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("펀딩 달성률").font(.subheadline.bold())
                Spacer()
                Text("\(Int(model.fundingProgress(for: show) * 100))%").font(.title3.bold()).foregroundStyle(CrocTheme.orange)
            }
            ProgressView(value: model.fundingProgress(for: show)).tint(CrocTheme.orange)
            Text("목표 달성 시 공연이 확정돼요 · 목표 \(show.targetAudience ?? 30)명").font(.caption2).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct CreateShowView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: AppModel
    var defaultPlace = "한마음 교회"

    @State private var title = ""
    @State private var place = "한마음 교회"
    @State private var date = Date()
    @State private var category = "Music"
    @State private var price = "15000"
    @State private var audience = "30"
    @State private var fundingGoal = "450000"
    @State private var introduction = ""
    @State private var artists = ""
    @State private var artwork = 0
    @State private var selectedPoster: PhotosPickerItem?
    @State private var posterData: Data?
    @State private var useVenueImage = true
    @State private var showScheduleConflict = false

    private var selectedPlace: Place? {
        model.allPlaces.first { $0.name == place }
    }

    private var resolvedPosterData: Data? {
        posterData ?? (useVenueImage ? Show.defaultPosterData(for: selectedPlace) : nil)
    }

    private var resolvedArtwork: Int {
        useVenueImage && posterData == nil ? (selectedPlace?.artwork ?? artwork) : artwork
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !introduction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Int(price) ?? 0) > 0 && (Int(audience) ?? 0) > 0 && (Int(fundingGoal) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("공연 기본 정보") {
                    TextField("공연 제목 · 예: 금요일 밤 인디 라이브", text: $title)
                    TextField("출연 아티스트 · 예: 민수, 지민 밴드", text: $artists)
                    TextField("공연 소개 · 관객에게 공연의 매력을 알려주세요", text: $introduction, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("공연할 공간", selection: $place) {
                        ForEach(model.allPlaces) { item in Text(item.name).tag(item.name) }
                    }
                    DatePicker("공연 날짜와 시작 시간", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("카테고리", selection: $category) {
                        ForEach(["Music", "Band", "Lo-fi", "Solo concert"], id: \.self) { Text($0) }
                    }
                }
                Section("펀딩 설정") {
                    TextField("티켓 가격(원) · 예: 15000", text: $price).keyboardType(.numberPad)
                    TextField("목표 관객 수(명) · 예: 30", text: $audience).keyboardType(.numberPad)
                    TextField("펀딩 목표 금액(원) · 예: 450000", text: $fundingGoal).keyboardType(.numberPad)
                }
                Section("공연 포스터") {
                    PhotosPicker(selection: $selectedPoster, matching: .images) {
                        Label(posterData == nil ? "사진 보관함에서 포스터 선택" : "선택한 포스터 변경", systemImage: "photo.on.rectangle")
                    }
                    Toggle("공간 대표 사진을 포스터로 사용", isOn: $useVenueImage)
                    Picker("기본 포스터 디자인", selection: $artwork) {
                        ForEach(0..<4, id: \.self) { index in Text("디자인 \(index + 1)").tag(index) }
                    }
                    PosterArtwork(index: resolvedArtwork, data: resolvedPosterData)
                        .frame(height: 210)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Section {
                    Button("공연 등록하기") {
                        let show = Show(
                            id: "created-\(UUID().uuidString)",
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            date: date.formatted(date: .abbreviated, time: .shortened),
                            location: place,
                            category: category,
                            progress: 0,
                            artwork: resolvedArtwork,
                            introduction: introduction.trimmingCharacters(in: .whitespacesAndNewlines),
                            artists: artists.trimmingCharacters(in: .whitespacesAndNewlines),
                            ticketPrice: Int(price),
                            targetAudience: Int(audience),
                            fundingGoal: Int(fundingGoal),
                            posterData: resolvedPosterData
                        )
                        guard !model.hasScheduleConflict(for: show) else {
                            showScheduleConflict = true
                            return
                        }
                        model.add(show: show)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("새 공연")
            .onAppear { place = defaultPlace }
            .task(id: selectedPoster) {
                posterData = try? await selectedPoster?.loadTransferable(type: Data.self)
                if posterData != nil { useVenueImage = false }
            }
            .alert("이미 같은 시간에 잡힌 공연이 있어요", isPresented: $showScheduleConflict) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("\(place)에서 \(date.formatted(date: .abbreviated, time: .shortened))에 이미 다른 공연이 열립니다. 시간 또는 공간을 바꿔 주세요.")
            }
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("닫기") { dismiss() } } }
        }
    }
}

struct MenuView: View {
    let onSelect: (AppTab) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(AppTab.allCases) { tab in
                        Button { onSelect(tab) } label: {
                            Label(tab.title, systemImage: tab.icon).foregroundStyle(CrocTheme.ink)
                        }
                    }
                }
                Section("CrocTick") {
                    Label("우리 동네 공연을 함께 만들어요", systemImage: "sparkles")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("메뉴")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("닫기") { dismiss() } } }
        }
    }
}

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                NotificationRow(icon: "ticket.fill", title: "예매가 완료됐어요", detail: "Pocket Music Fest 티켓을 확인해 보세요.", time: "방금")
                NotificationRow(icon: "person.2.fill", title: "펀딩 목표가 가까워졌어요", detail: "술탄 오브 더 디스코 공연이 82%를 달성했어요.", time: "2시간 전")
            }
            .navigationTitle("알림")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("닫기") { dismiss() } } }
        }
    }
}

struct NotificationRow: View {
    let icon: String
    let title: String
    let detail: String
    let time: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).foregroundStyle(.white).frame(width: 38, height: 38).background(CrocTheme.orange, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
                Text(time).font(.caption2).foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TicketListView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if model.joinedShows.isEmpty {
                    ContentUnavailableView("아직 예매한 공연이 없어요", systemImage: "ticket", description: Text("공연을 둘러보고 첫 티켓을 만들어 보세요."))
                } else {
                    List(model.joinedShows) { show in
                        NavigationLink { ShowDetailView(show: show) } label: { TicketRow(show: show) }
                            .listRowInsets(EdgeInsets(top: 7, leading: 16, bottom: 7, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .background(CrocTheme.canvas)
            .navigationTitle("내 티켓")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("닫기") { dismiss() } } }
        }
    }
}

struct RegisterSpaceView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var location = ""
    @State private var capacity = ""
    @State private var introduction = ""
    @State private var equipment = ""
    @State private var rentalFee = ""
    @State private var operatingHours = ""
    @State private var artwork = 0
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !introduction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Int(capacity) ?? 0) > 0 && (Int(rentalFee) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("공간 기본 정보") {
                    TextField("공간 이름 · 예: 성수 라이브홀", text: $name)
                    TextField("주소 · 예: 서울 성동구 ...", text: $location)
                    TextField("공간 소개 · 어떤 공연에 어울리는 곳인가요?", text: $introduction, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("대관 및 장비") {
                    TextField("최대 수용 인원(명) · 예: 80", text: $capacity).keyboardType(.numberPad)
                    TextField("대관료(원/회차) · 예: 50000", text: $rentalFee).keyboardType(.numberPad)
                    TextField("운영 시간 · 예: 10:00 - 22:00", text: $operatingHours)
                    TextField("보유 장비 · 예: 마이크 4개, 믹서, 스피커", text: $equipment, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section("공간 대표 사진") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(photoData == nil ? "사진 보관함에서 대표 사진 선택" : "선택한 대표 사진 변경", systemImage: "photo.on.rectangle")
                    }
                    Picker("기본 이미지", selection: $artwork) {
                        ForEach(0..<4, id: \.self) { index in Text("이미지 \(index + 1)").tag(index) }
                    }
                    PlaceArtwork(index: artwork, data: photoData)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Section {
                    Button("공간 등록하기") {
                        model.add(place: Place(
                            id: "registered-\(UUID().uuidString)",
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                            capacity: "최대 \(capacity)명",
                            rating: "신규",
                            artwork: artwork,
                            introduction: introduction.trimmingCharacters(in: .whitespacesAndNewlines),
                            equipment: equipment.trimmingCharacters(in: .whitespacesAndNewlines),
                            rentalFee: Int(rentalFee),
                            operatingHours: operatingHours.trimmingCharacters(in: .whitespacesAndNewlines),
                            photoData: photoData
                        ))
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("공간 등록")
            .task(id: selectedPhoto) {
                photoData = try? await selectedPhoto?.loadTransferable(type: Data.self)
            }
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("닫기") { dismiss() } } }
        }
    }
}

struct EmptySearchView: View {
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass").font(.title2).foregroundStyle(.secondary)
            Text(message).font(.subheadline.weight(.medium))
            Text("검색어나 필터를 바꿔 보세요.").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct CrocPrimaryButtonStyle: ButtonStyle {
    var color: Color = CrocTheme.orange

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(color.opacity(configuration.isPressed ? 0.72 : 1), in: RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private extension View {
    func adaptivePage(maxWidth: CGFloat) -> some View {
        modifier(AdaptivePageModifier(maxWidth: maxWidth))
    }

    func crocCard() -> some View {
        background(.white, in: RoundedRectangle(cornerRadius: 15))
            .shadow(color: CrocTheme.cardShadow, radius: 8, y: 3)
    }
}

private struct AdaptivePageModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let maxWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: horizontalSizeClass == .regular ? maxWidth : .infinity)
            .frame(maxWidth: .infinity)
    }
}
