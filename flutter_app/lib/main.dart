import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'store.dart';

const orange = Color(0xffeb6c12),
    canvas = Color(0xfff8f3f0),
    ink = Color(0xff3d2d17);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CrocApp(store: Store(await SharedPreferences.getInstance())));
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
  const Artwork(this.path, {super.key, this.height = 180});
  @override
  Widget build(BuildContext c) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: path.startsWith('assets/')
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
  String query = '', genre = '전체';
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
      appBar: AppBar(
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
      ),
      body: Container(
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
              children: tab == 2 ? myPage() : browse(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() {
          tab = i;
          query = '';
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '홈'),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            label: '공연',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), label: '마이'),
        ],
      ),
    ),
  );
  List<Widget> browse() {
    final items = tab == 0 ? s.places : s.shows;
    final filtered = items
        .where(
          (p) =>
              (p[tab == 0 ? 'name' : 'title'] as String).toLowerCase().contains(
                query.toLowerCase(),
              ) &&
              (tab == 0 || genre == '전체' || p['genre'] == genre),
        )
        .toList();
    return [
      if (tab == 0)
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [orange, Color(0xffffcfac)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tab == 0 ? 'Find your stage' : 'Make the stage happen',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '무대 위\n스타를\n우리 집 앞으로',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/music-note.png',
                    width: 90,
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
        ),
      const SizedBox(height: 20),
      TextField(
        decoration: InputDecoration(
          labelText: tab == 0 ? '공간 이름 검색' : '공연 이름 검색',
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (v) => setState(() => query = v),
      ),
      if (tab == 1)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Wrap(
            spacing: 8,
            children: ['전체', 'Music', 'Band', 'Lo-fi', 'Jazz']
                .map(
                  (v) => ChoiceChip(
                    label: Text(v),
                    selected: genre == v,
                    onSelected: (_) => setState(() => genre = v),
                  ),
                )
                .toList(),
          ),
        ),
      if (query.isEmpty) ...[
        heading('Recommend', '전체 보기', () => setState(() => query = '')),
        card(
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tab == 0
                          ? s.places.first['name']
                          : s.shows.first['title'],
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tab == 0
                          ? s.places.first['address']
                          : dateLabel(s.shows.first['start']),
                    ),
                    const Text(
                      '★★★★★',
                      style: TextStyle(color: orange, fontSize: 24),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 120,
                child: Artwork(
                  (tab == 0 ? s.places.first : s.shows.first)['image'],
                  height: 150,
                ),
              ),
            ],
          ),
          tap: () => open(
            context,
            Detail(
              store: s,
              item: tab == 0 ? s.places.first : s.shows.first,
              isPlace: tab == 0,
            ),
          ),
        ),
      ],
      heading(
        tab == 0 ? '공간' : '공연',
        tab == 0 ? '공간 등록 +' : '공연 등록 +',
        () => open(context, Registration(store: s, isPlace: tab == 0)),
      ),
      if (filtered.isEmpty)
        const Padding(padding: EdgeInsets.all(30), child: Text('검색 결과가 없습니다.')),
      if (tab == 0)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 10,
            children: ['Calm', 'Band', 'Lo-fi', 'Jazz']
                .map(
                  (g) => ActionChip(
                    label: Text(g),
                    onPressed: () => setState(() {
                      tab = 1;
                      genre = g == 'Calm' ? 'Lo-fi' : g;
                    }),
                  ),
                )
                .toList(),
          ),
        ),
      LayoutBuilder(
        builder: (c, b) {
          final count = b.maxWidth > 800
              ? 3
              : b.maxWidth > 550
              ? 2
              : 1;
          return Wrap(
            spacing: 16,
            children: filtered
                .map(
                  (p) => SizedBox(
                    width: (b.maxWidth - 16 * (count - 1)) / count,
                    child: card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Artwork(p['image']),
                          const SizedBox(height: 12),
                          Text(
                            p[tab == 0 ? 'name' : 'title'],
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tab == 0
                                ? '${p['address']} · 최대 ${p['capacity']}명'
                                : dateLabel(p['start']),
                          ),
                          if (tab == 1) ...[
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: s.progress(p).clamp(0, 1),
                              color: orange,
                            ),
                            Text(
                              '${(s.progress(p) * 100).floor()}% 펀딩 · ${money(p['funded'])}',
                            ),
                          ],
                        ],
                      ),
                      tap: () =>
                          open(c, Detail(store: s, item: p, isPlace: tab == 0)),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    ];
  }

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
    card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 틱 정산',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            '${s.tick} Tick · ${s.tier.name}',
            style: const TextStyle(
              fontSize: 30,
              color: orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('등급 정책과 획득 내역 보기 →'),
        ],
      ),
      tap: () => open(context, TickPage(store: s)),
    ),
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
              Artwork(item['image'], height: 320),
              const SizedBox(height: 20),
              Text(
                item[isPlace ? 'name' : 'title'],
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isPlace
                    ? '${item['address']}\n최대 ${item['capacity']}명 · ${money(item['fee'])} / 회차\n운영 ${item['hours']}'
                    : '${dateLabel(item['start'])} – ${dateLabel(item['end'])}\n${store.placeFor(item)['name']} · ${money(item['price'])}',
              ),
              const SizedBox(height: 20),
              Text(
                item['description'],
                style: const TextStyle(fontSize: 18, height: 1.6),
              ),
              const SizedBox(height: 20),
              if (isPlace) ...[
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
                  child: const Text('이 공간에서 공연 만들기'),
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
  DateTime start = DateTime.now().add(const Duration(days: 1)),
      end = DateTime.now().add(const Duration(days: 1, hours: 2));
  @override
  void initState() {
    super.initState();
    place = widget.placeId ?? widget.store.places.first['id'];
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext c) {
    final p = widget.isPlace;
    return Scaffold(
      appBar: AppBar(title: Text(p ? '공간 등록' : '새 공연 등록')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: key,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                field('name', p ? '공간 이름' : '공연 제목'),
                field('description', p ? '공간 소개' : '공연 소개', lines: 4),
                if (p) ...[
                  field('address', '상세 주소'),
                  field('capacity', '최대 수용 관객 수 (명)', number: true),
                  field('fee', '회차당 대관료 (원)', number: true),
                  field('hours', '운영 시간 · 예: 10:00–22:00'),
                  field('equipment', '보유 장비 · 마이크, 믹서, 조명 등', lines: 3),
                ] else ...[
                  field('artists', '출연자'),
                  DropdownButtonFormField<String>(
                    initialValue: place,
                    decoration: const InputDecoration(labelText: '공연 공간'),
                    items: widget.store.places
                        .map(
                          (p) => DropdownMenuItem<String>(
                            value: p['id'],
                            child: Text(p['name']),
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
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => genre = v!,
                  ),
                  ListTile(
                    title: const Text('공연 시작'),
                    subtitle: Text(dateLabel(start.toIso8601String())),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () => date(false),
                  ),
                  ListTile(
                    title: const Text('공연 종료'),
                    subtitle: Text(dateLabel(end.toIso8601String())),
                    trailing: const Icon(Icons.schedule),
                    onTap: () => date(true),
                  ),
                  field('price', '티켓 가격 (원)', number: true),
                  field('capacity', '목표 관객 수 (명)', number: true),
                  field('goal', '펀딩 목표 금액 (원)', number: true),
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
                TextButton.icon(
                  onPressed: pick,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(p ? '대표 사진 선택' : '포스터 선택 · 미선택 시 공간 사진 사용'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy ? null : submit,
                  child: Text(busy ? '저장 중…' : '등록하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TickPage extends StatelessWidget {
  final Store store;
  const TickPage({super.key, required this.store});
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: store,
    builder: (c, _) => Scaffold(
      appBar: AppBar(title: const Text('내 틱 정산')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '${store.tick} Tick · ${store.tier.name}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                store.tick >= 110
                    ? '최상위 등급입니다'
                    : '다음 등급까지 ${Tier.all.firstWhere((t) => t.minimum > store.tick).minimum - store.tick} Tick',
              ),
              const SizedBox(height: 22),
              const Text('성장 단계별 공연 규모와 티켓 정책', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: Tier.all
                    .map(
                      (t) => Container(
                        width: 260,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: ink,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: t == store.tier
                                ? orange
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.name,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: orange,
                                ),
                              ),
                              Text('${t.minimum}+ Tick'),
                              const SizedBox(height: 22),
                              const Text('최저 티켓가 설정 한도'),
                              Text(
                                t.price == null ? '무제한' : money(t.price),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Text(t.venue),
                              Text(
                                '최대 관객 ${t.audience ?? '무제한'}${t.audience == null ? '' : '명'}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tick은 공연 완료 후 평가 정산 시 한 번만 적립됩니다.\nMVP 임시 산식: 공연 완료 1 + 평가 1~5 Tick',
              ),
              if (store.ledger.isEmpty)
                const ListTile(title: Text('아직 획득 내역이 없습니다.')),
              ...store.ledger.map(
                (e) => ListTile(
                  title: Text(e['reason']),
                  subtitle: Text(dateLabel(e['at'])),
                  trailing: Text('+${e['amount']} Tick'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
    appBar: AppBar(title: const Text('설정')),
    body: ListView(
      padding: const EdgeInsets.all(24),
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
        const SizedBox(height: 24),
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
  );
}
