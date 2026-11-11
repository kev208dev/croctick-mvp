import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'store.dart';
import 'tick_page.dart';
import 'catalog_widgets.dart';
import 'figma_browse.dart';

const orange = Color(0xffeb6c12),
    canvas = Color(0xfff8f3f0),
    ink = Color(0xff3d2d17);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = Store(await SharedPreferences.getInstance());
  if (store.loadFailed) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storage_rounded, size: 48),
                    const SizedBox(height: 20),
                    const Text(
                      '저장된 기록을 읽지 못했어요',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '기존 데이터는 그대로 보존했습니다. 앱을 다시 실행해 주세요. 문제가 계속되면 기록을 백업한 뒤 복구가 필요합니다.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: main, child: const Text('다시 시도')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  await store.save();
  runApp(CrocApp(store: store));
}

String money(dynamic n) =>
    '${n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
String dateLabel(String v) {
  final d = DateTime.parse(v);
  return '${d.year}.${d.month}.${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

void open(BuildContext c, Widget p) =>
    Navigator.push(c, MaterialPageRoute<void>(builder: (_) => p));
void error(BuildContext c, Object e) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('$e')));

class CrocApp extends StatelessWidget {
  final Store store;
  const CrocApp({super.key, required this.store});
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'CrocTick',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Pretendard',
      colorScheme: ColorScheme.fromSeed(seedColor: orange),
      scaffoldBackgroundColor: canvas,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xff17130f),
        indicatorColor: const Color(0xff3d2d20),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? const Color(0xffff9a50)
                : Colors.white,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? const Color(0xffff9a50)
                : Colors.white,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: orange,
        centerTitle: true,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
        ),
      ),
    ),
    home: Home(store: store),
  );
}

class Artwork extends StatelessWidget {
  final String path;
  final double height;
  final Record? item;
  final bool isPlace;
  const Artwork(
    this.path, {
    super.key,
    this.height = 180,
    this.item,
    this.isPlace = false,
  });
  @override
  Widget build(BuildContext c) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: path.isEmpty && item != null
          ? CatalogArtwork(item: item!, isPlace: isPlace, height: height)
          : path.isEmpty
          ? const ColoredBox(
              color: Color(0xffe9e0d8),
              child: Center(
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: Color(0xff9b8268),
                ),
              ),
            )
          : path.startsWith('assets/')
          ? Image.asset(path, fit: BoxFit.cover)
          : Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, e, st) =>
                  const Icon(Icons.broken_image_outlined),
            ),
    ),
  );
}

class Home extends StatefulWidget {
  final Store store;
  const Home({super.key, required this.store});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  Store get s => widget.store;
  Widget card(Widget child, {VoidCallback? tap}) => Card(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
  Widget heading(String text, String action, VoidCallback call) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        TextButton(onPressed: call, child: Text(action)),
      ],
    ),
  );
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: s,
    builder: (c, _) => Scaffold(
      backgroundColor: tab == 2 ? canvas : orange,
      appBar: tab == 2
          ? AppBar(
              leading: PopupMenuButton<int>(
                onSelected: (i) => setState(() => tab = i),
                itemBuilder: (_) => List.generate(
                  3,
                  (i) => PopupMenuItem(
                    value: i,
                    child: Text(['홈 · 공간', '공연', '마이페이지'][i]),
                  ),
                ),
              ),
              title: Image.asset('assets/croc-logo.png', height: 62),
              toolbarHeight: 80,
              actions: [
                IconButton(
                  tooltip: '활동 내역',
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => open(c, TickPage(store: s)),
                ),
                IconButton(
                  tooltip: '설정',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => open(c, SettingsPage(store: s)),
                ),
              ],
            )
          : null,
      body: tab != 2
          ? AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: Color(0xff17130f),
                systemNavigationBarIconBrightness: Brightness.light,
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: FigmaBrowse(
                  key: ValueKey(tab),
                  store: s,
                  isPlace: tab == 0,
                  onMenu: () => showModalBottomSheet<void>(
                    context: c,
                    builder: (sheet) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add_business_outlined),
                            title: const Text('공간 등록 +'),
                            onTap: () {
                              Navigator.pop(sheet);
                              open(c, Registration(store: s, isPlace: true));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.add_circle_outline),
                            title: const Text('공연 등록 +'),
                            onTap: () {
                              Navigator.pop(sheet);
                              open(c, Registration(store: s, isPlace: false));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.settings_outlined),
                            title: const Text('설정'),
                            onTap: () {
                              Navigator.pop(sheet);
                              open(c, SettingsPage(store: s));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  onActivity: () => open(c, TickPage(store: s)),
                  onProfile: () => setState(() => tab = 2),
                  onSeeAll: () =>
                      open(c, CatalogPage(store: s, isPlace: tab == 0)),
                  onOpen: (item, place) =>
                      open(c, Detail(store: s, item: item, isPlace: place)),
                  onCategory: (g) => open(
                    c,
                    CatalogPage(
                      store: s,
                      isPlace: false,
                      initialGenre: g == 'Calm' ? 'Lo-fi' : g,
                    ),
                  ),
                ),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [orange, canvas],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: ListView(
                    padding: const EdgeInsets.all(22),
                    children: myPage(),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: FigmaNavigation(
        selected: tab,
        onSelected: (i) => setState(() {
          tab = i;
        }),
      ),
    ),
  );
  List<Widget> myPage() => [
    Text(
      '${s.name}님, 안녕하세요!',
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 18),
    card(
      Wrap(
        spacing: 24,
        children: [
          Text('티켓 ${s.tickets.length}'),
          Text('내 공간 ${s.places.where((p) => p['mine'] == true).length}'),
          Text('내 공연 ${s.shows.where((p) => p['mine'] == true).length}'),
        ],
      ),
    ),
    const Padding(
      padding: EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        '내 틱 정산',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
    TickOverview(
      store: s,
      onTap: () => open(context, TickPage(store: s)),
    ),
    const SizedBox(height: 16),
    heading('My ticket', '전체 보기', () => open(context, TicketsPage(store: s))),
    if (s.tickets.isEmpty) const Text('아직 참여한 공연이 없습니다.'),
    ...s.tickets.take(2).map((t) {
      final show = s.shows.firstWhere((p) => p['id'] == t['showId']);
      return card(
        ListTile(
          title: Text(show['title']),
          subtitle: Text('티켓 ${t['id']}\n${dateLabel(show['start'])}'),
        ),
        tap: () => open(context, Detail(store: s, item: show, isPlace: false)),
      );
    }),
    heading(
      'My space',
      '공간 등록 +',
      () => open(context, Registration(store: s, isPlace: true)),
    ),
    ...s.places
        .where((p) => p['mine'] == true)
        .map(
          (p) => card(
            ListTile(title: Text(p['name']), subtitle: Text(p['address'])),
            tap: () => open(context, Detail(store: s, item: p, isPlace: true)),
          ),
        ),
    heading(
      'My shows',
      '공연 등록 +',
      () => open(context, Registration(store: s, isPlace: false)),
    ),
    ...s.shows
        .where((p) => p['mine'] == true)
        .map(
          (p) => card(
            ListTile(
              title: Text(p['title']),
              subtitle: Text(dateLabel(p['start'])),
            ),
            tap: () => open(context, Detail(store: s, item: p, isPlace: false)),
          ),
        ),
  ];
}

class CatalogPage extends StatefulWidget {
  final Store store;
  final bool isPlace;
  final String initialGenre;
  const CatalogPage({
    super.key,
    required this.store,
    required this.isPlace,
    this.initialGenre = '전체',
  });
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String query = '';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final places = widget.isPlace;
      final items = (places ? widget.store.places : widget.store.shows).where((
        item,
      ) {
        final text = places
            ? '${item['name']} ${item['address']}'
            : '${item['title']} ${item['artists']} ${widget.store.placeFor(item)['name']} ${widget.store.placeFor(item)['address']}';
        return text.toLowerCase().contains(query.toLowerCase()) &&
            (places ||
                widget.initialGenre == '전체' ||
                item['genre'] == widget.initialGenre);
      }).toList();
      return Scaffold(
        appBar: AppBar(
          title: Text(places ? '모든 공간' : '모든 공연'),
          actions: [
            IconButton(
              tooltip: places ? '공간 등록 +' : '공연 등록 +',
              icon: const Icon(Icons.add),
              onPressed: () => open(
                context,
                Registration(store: widget.store, isPlace: places),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Searching...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => query = value),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () => open(
                              context,
                              Detail(
                                store: widget.store,
                                item: item,
                                isPlace: places,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Artwork(
                                      item['image'],
                                      height: 120,
                                      item: item,
                                      isPlace: places,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item[places ? 'name' : 'title'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          places
                                              ? '${item['address']}\n${placeCapacity(item)}'
                                              : dateLabel(item['start']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

class Detail extends StatelessWidget {
  final Store store;
  final Record item;
  final bool isPlace;
  const Detail({
    super.key,
    required this.store,
    required this.item,
    required this.isPlace,
  });
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: store,
    builder: (c, _) => Scaffold(
      appBar: AppBar(title: Text(isPlace ? '공간 상세' : '공연 상세')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Artwork(item['image'], height: 320, item: item, isPlace: isPlace),
              const SizedBox(height: 20),
              Text(
                item[isPlace ? 'name' : 'title'],
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              if (item['candidate'] == true || item['demo'] == true) ...[
                CatalogBadge(
                  isPlace: isPlace,
                  candidate: item['candidate'] == true,
                ),
                const SizedBox(height: 14),
              ],
              Text(
                isPlace
                    ? '${item['address']}\n${placeCapacity(item)}\n${item['candidate'] == true ? '대관·매출 배분 조건 협의 필요' : '${money(item['fee'])} / 회차'}\n운영 ${item['hours']}'
                    : '${dateLabel(item['start'])} – ${dateLabel(item['end'])}\n${store.placeFor(item)['name']} · ${money(item['price'])}',
              ),
              const SizedBox(height: 20),
              Text(
                item['description'],
                style: const TextStyle(fontSize: 18, height: 1.6),
              ),
              const SizedBox(height: 20),
              if (isPlace) ...[
                if (item['candidate'] == true) ...[
                  CandidateInfo(place: item),
                  const SizedBox(height: 20),
                ],
                Text('보유 장비\n${item['equipment']}'),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => open(
                    c,
                    Registration(
                      store: store,
                      isPlace: false,
                      placeId: item['id'],
                    ),
                  ),
                  child: Text(
                    item['candidate'] == true
                        ? '이 후보 공간으로 시연 공연 만들기'
                        : '이 공간에서 공연 만들기',
                  ),
                ),
              ] else ...[
                Text(
                  '상태 · ${store.status(item)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('출연 ${item['artists']} · ${item['genre']}'),
                const SizedBox(height: 20),
                Text(
                  '펀딩 ${(store.progress(item) * 100).floor()}% · ${money(item['funded'])} / ${money(item['goal'])}',
                ),
                LinearProgressIndicator(
                  value: store.progress(item).clamp(0, 1),
                  color: orange,
                ),
                Text('목표 관객 ${item['audience']}명'),
                const SizedBox(height: 20),
                const Text('시연용 펀딩입니다. 실제 결제는 발생하지 않습니다.'),
                FilledButton(
                  onPressed:
                      store.joined(item) ||
                          !['펀딩 중', '공연 확정'].contains(store.status(item))
                      ? null
                      : () async {
                          try {
                            await store.join(item);
                          } catch (e) {
                            if (c.mounted) error(c, e);
                          }
                        },
                  child: Text(
                    store.joined(item)
                        ? '참여 완료 · 마이페이지에서 티켓 확인'
                        : '펀딩 참여 · ${money(item['price'])}',
                  ),
                ),
                const SizedBox(height: 20),
                if (item['mine'] == true)
                  ShowOperations(store: store, show: item),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class ShowOperations extends StatefulWidget {
  final Store store;
  final Record show;
  const ShowOperations({super.key, required this.store, required this.show});
  @override
  State<ShowOperations> createState() => _ShowOperationsState();
}

class _ShowOperationsState extends State<ShowOperations> {
  int rating = 5;
  Future<void> perform(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (mounted) error(context, e);
    }
  }

  @override
  Widget build(BuildContext c) {
    final s = widget.store, p = widget.show;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '공연 운영 · 로컬 시연',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('공간 제공자의 승인과 공연 후 평가 과정을 이 기기에서 시연합니다.'),
            if (s.status(p) == '공간 승인 대기')
              FilledButton(
                onPressed: () => perform(() => s.approve(p)),
                child: const Text('공간 제공자 승인 처리'),
              ),
            if (s.status(p) == '평가 대기') ...[
              DropdownButton<int>(
                value: rating,
                items: List.generate(
                  5,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('공연 평가 ${i + 1}점'),
                  ),
                ),
                onChanged: (v) => setState(() => rating = v!),
              ),
              FilledButton(
                onPressed: () => perform(() => s.settle(p, rating)),
                child: const Text('공연 완료 · 평가 정산'),
              ),
            ],
            if (p['settlement'] != null)
              Text(
                '공간 50%: ${money(p['settlement']['space'])}\n공연자 40%: ${money(p['settlement']['artist'])}\n플랫폼 10%: ${money(p['settlement']['platform'])}\n시연 계산이며 실제 송금은 발생하지 않습니다.',
              ),
            if (!['취소', '정산 완료'].contains(s.status(p)))
              TextButton(
                onPressed: () async {
                  final yes = await showDialog<bool>(
                    context: c,
                    builder: (c) => AlertDialog(
                      title: const Text('공연 취소'),
                      content: const Text(
                        '참여 티켓을 환불 처리하고 예약 시간을 해제합니다. 실제 결제는 없는 시연입니다.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('돌아가기'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('취소 확정'),
                        ),
                      ],
                    ),
                  );
                  if (yes == true) await perform(() => s.cancel(p));
                },
                child: Text(s.status(p) == '펀딩 미달' ? '미달 취소 · 환불 처리' : '공연 취소'),
              ),
          ],
        ),
      ),
    );
  }
}

class Registration extends StatefulWidget {
  final Store store;
  final bool isPlace;
  final String? placeId;
  const Registration({
    super.key,
    required this.store,
    required this.isPlace,
    this.placeId,
  });
  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final key = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  late String place;
  String genre = 'Music', image = '';
  bool busy = false;
  int step = 0;
  final scroll = ScrollController();
  DateTime start = DateTime.now().add(const Duration(days: 1)),
      end = DateTime.now().add(const Duration(days: 1, hours: 2));
  @override
  void initState() {
    super.initState();
    place = widget.placeId ?? widget.store.places.first['id'];
  }

  @override
  void dispose() {
    scroll.dispose();
    for (final f in fields.values) {
      f.dispose();
    }
    super.dispose();
  }

  String val(String id) => fields[id]?.text.trim() ?? '';
  Widget field(String id, String label, {bool number = false, int lines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          key: ValueKey(id),
          controller: fields.putIfAbsent(id, () => TextEditingController()),
          decoration: InputDecoration(labelText: label),
          maxLines: lines,
          keyboardType: number ? TextInputType.number : TextInputType.multiline,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return '필수 항목입니다';
            if (number && (int.tryParse(v) == null || int.parse(v) <= 0)) {
              return '0보다 큰 정수를 입력하세요';
            }
            return null;
          },
        ),
      );
  Future<void> pick() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (x == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final file = await File(
        x.path,
      ).copy('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg');
      if (mounted) setState(() => image = file.path);
    } catch (e) {
      if (mounted) error(context, e);
    }
  }

  Future<void> date(bool ending) async {
    final base = ending ? end : start;
    final day = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2035),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    setState(() {
      final value = DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );
      if (ending) {
        end = value;
      } else {
        start = value;
        end = start.add(const Duration(hours: 2));
      }
    });
  }

  Future<void> submit() async {
    if (!key.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final s = widget.store;
      if (widget.isPlace) {
        await s.addPlace({
          'name': val('name'),
          'address': val('address'),
          'description': val('description'),
          'capacity': int.parse(val('capacity')),
          'fee': int.parse(val('fee')),
          'equipment': val('equipment'),
          'hours': val('hours'),
          'image': image.isEmpty ? 'assets/place-hopyeong.png' : image,
        });
      } else {
        if (!start.isAfter(DateTime.now())) {
          throw StateError('미래의 공연 시간을 선택하세요.');
        }
        final p = s.places.firstWhere((p) => p['id'] == place);
        await s.addShow({
          'title': val('name'),
          'placeId': place,
          'description': val('description'),
          'artists': val('artists'),
          'genre': genre,
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
          'price': int.parse(val('price')),
          'audience': int.parse(val('capacity')),
          'goal': int.parse(val('goal')),
          'image': image.isEmpty ? p['image'] : image,
        });
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) error(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void next() {
    if (!key.currentState!.validate()) return;
    if (step == 1 && !widget.isPlace) {
      if (!start.isAfter(DateTime.now()) || !end.isAfter(start)) {
        error(context, '시작은 현재 이후, 종료는 시작 이후로 선택해 주세요.');
        return;
      }
      if (widget.store.conflicts(place, start, end)) {
        error(context, '이미 예약된 시간이에요. 다른 시간이나 공간을 선택해 주세요.');
        return;
      }
    }
    FocusScope.of(context).unfocus();
    setState(() => step++);
    scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext c) {
    final p = widget.isPlace;
    final titles = p
        ? ['어떤 공간인가요?', '이용 조건을 알려주세요', '대표 사진을 골라주세요']
        : ['어떤 공연인가요?', '언제, 어디서 열리나요?', '티켓과 포스터를 준비해요'];
    final hints = p
        ? [
            '이름과 위치, 소개부터 입력해요.',
            '관객 수와 장비를 알려주면 공연자가 준비하기 쉬워요.',
            '목록과 상세 화면에 같은 사진이 표시돼요.',
          ]
        : [
            '제목과 소개, 출연자를 알려주세요.',
            '준비와 철수 시간을 포함해 공간을 확보해 주세요.',
            '금액은 원 단위, 관객 수는 명 단위로 입력해요.',
          ];
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: Text(p ? '공간 등록' : '새 공연 등록'),
        backgroundColor: canvas,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${step + 1} / 3단계',
                      style: const TextStyle(
                        color: orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (step + 1) / 3,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      titles[step],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hints[step],
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: key,
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      if (step == 0) ...[
                        field('name', p ? '공간 이름' : '공연 제목'),
                        if (p) field('address', '상세 주소'),
                        field('description', p ? '공간 소개' : '공연 소개', lines: 4),
                        if (!p) field('artists', '출연자'),
                      ],
                      if (step == 1 && p) ...[
                        field('capacity', '최대 수용 관객 수 (명)', number: true),
                        field('fee', '회차당 대관료 (원)', number: true),
                        field('hours', '운영 시간 · 예: 10:00–22:00'),
                        field('equipment', '보유 장비 · 마이크, 믹서, 조명 등', lines: 3),
                      ],
                      if (step == 1 && !p) ...[
                        DropdownButtonFormField<String>(
                          initialValue: place,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: '공연 공간'),
                          items: widget.store.places
                              .map(
                                (p) => DropdownMenuItem<String>(
                                  value: p['id'],
                                  child: Text(
                                    p['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => place = v!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: genre,
                          decoration: const InputDecoration(labelText: '장르'),
                          items: ['Music', 'Band', 'Lo-fi', 'Jazz']
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (v) => genre = v!,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('공연 시작'),
                                subtitle: Text(
                                  dateLabel(start.toIso8601String()),
                                ),
                                trailing: const Icon(Icons.calendar_month),
                                onTap: () => date(false),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                title: const Text('공연 종료'),
                                subtitle: Text(
                                  dateLabel(end.toIso8601String()),
                                ),
                                trailing: const Icon(Icons.schedule),
                                onTap: () => date(true),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (step == 2) ...[
                        if (!p) ...[
                          field('price', '티켓 가격 (원)', number: true),
                          field('capacity', '목표 관객 수 (명)', number: true),
                          field('goal', '펀딩 목표 금액 (원)', number: true),
                          Text(
                            '나의 등급: ${widget.store.tier.name} · 티켓 ${widget.store.tier.price == null ? '가격 제한 없음' : '최대 ${money(widget.store.tier.price)}'} · 관객 ${widget.store.tier.audience ?? '제한 없음'}',
                            style: const TextStyle(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Artwork(
                          image.isEmpty
                              ? (p
                                    ? 'assets/place-hopyeong.png'
                                    : widget.store.places.firstWhere(
                                        (p) => p['id'] == place,
                                      )['image'])
                              : image,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: busy ? null : pick,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(
                            image.isEmpty
                                ? (p ? '공간 사진 선택' : '공연 포스터 선택')
                                : '사진 변경',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p
                              ? '사진을 선택하지 않으면 기본 사진을 사용해요.'
                              : '포스터를 선택하지 않으면 공간 사진을 사용해요.',
                          style: const TextStyle(
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '등록할 내용',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  val('name'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p
                                      ? val('address')
                                      : dateLabel(start.toIso8601String()),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p
                                      ? '최대 ${val('capacity')}명 · 대관료 ${val('fee')}원'
                                      : widget.store.places.firstWhere(
                                          (p) => p['id'] == place,
                                        )['name'],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Row(
                    children: [
                      if (step > 0) ...[
                        OutlinedButton(
                          onPressed: busy
                              ? null
                              : () {
                                  FocusScope.of(c).unfocus();
                                  setState(() => step--);
                                  scroll.jumpTo(0);
                                },
                          child: const Text('이전'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: busy
                              ? null
                              : step < 2
                              ? next
                              : submit,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              busy
                                  ? '저장 중…'
                                  : step < 2
                                  ? '다음'
                                  : '등록하기',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketsPage extends StatelessWidget {
  final Store store;
  const TicketsPage({super.key, required this.store});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('내 티켓')),
    body: store.tickets.isEmpty
        ? const Center(child: Text('아직 참여한 공연이 없습니다.'))
        : ListView(
            children: store.tickets.map((t) {
              final show = store.shows.firstWhere(
                (p) => p['id'] == t['showId'],
              );
              return ListTile(
                title: Text(show['title']),
                subtitle: Text('${dateLabel(show['start'])}\n참여 번호 ${t['id']}'),
                onTap: () =>
                    open(c, Detail(store: store, item: show, isPlace: false)),
              );
            }).toList(),
          ),
  );
}

class SettingsPage extends StatefulWidget {
  final Store store;
  const SettingsPage({super.key, required this.store});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController name = TextEditingController(
    text: widget.store.name,
  );
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: canvas,
    appBar: AppBar(title: const Text('설정'), backgroundColor: canvas),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              '프로필',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              '앱에서 사용할 이름을 변경해요.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: '프로필 이름'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        if (name.text.trim().isEmpty) return;
                        widget.store.name = name.text.trim();
                        await widget.store.save();
                        if (c.mounted) Navigator.pop(c);
                      },
                      child: const Text('프로필 저장'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              color: Colors.white,
              child: ExpansionTile(
                leading: const Icon(Icons.tune_rounded),
                title: const Text('시연 데이터 관리'),
                subtitle: const Text('초기화가 필요할 때만 열어주세요'),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  const Text(
                    '직접 등록한 공간·공연과 참여 내역을 지우고 기본 시연 상태로 돌아가요.',
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      final yes = await showDialog<bool>(
                        context: c,
                        builder: (c) => AlertDialog(
                          title: const Text('시연 데이터로 초기화'),
                          content: const Text('등록한 공간·공연·티켓과 틱 획득 내역을 삭제합니다.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('초기화'),
                            ),
                          ],
                        ),
                      );
                      if (yes == true) {
                        await widget.store.reset();
                        if (c.mounted) Navigator.pop(c);
                      }
                    },
                    child: const Text('시연 데이터만 남기고 초기화'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
