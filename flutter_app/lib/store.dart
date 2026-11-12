import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'demo_catalog.dart';

typedef Record = Map<String, dynamic>;

class Tier {
  final String name, venue;
  final int minimum;
  final int? price, audience;
  const Tier(this.name, this.minimum, this.price, this.audience, this.venue);
  static const all = [
    Tier('Rookie', 0, 15000, 50, '지역 거점 공간'),
    Tier('Rising', 20, 60000, 80, '도심 인접 공간'),
    Tier('Artist', 40, 150000, 150, '도심 중심 공간'),
    Tier('Pro', 70, 250000, 300, '핵심 상권 · 프라임 공간'),
    Tier('Headliner', 110, null, null, '랜드마크 · 대표 공간'),
  ];
  static Tier forTick(int tick) =>
      all.lastWhere((t) => tick >= t.minimum, orElse: () => all.first);
}

class Store extends ChangeNotifier {
  final SharedPreferences prefs;
  List<Record> places = [], shows = [], tickets = [], ledger = [];
  List<Record> notifications = [];
  String name = '김청휘';
  int tick = 18;
  int catalogVersion = 0;
  bool loadFailed = false;
  Store(this.prefs) {
    load();
  }
  Tier get tier => Tier.forTick(tick);
  void load() {
    final raw = prefs.getString('croctick.v1');
    if (raw == null) {
      seed();
      return;
    }
    try {
      final d = jsonDecode(raw) as Record;
      name = d['name'];
      tick = d['tick'];
      places = List<Record>.from(d['places']);
      shows = List<Record>.from(d['shows']);
      tickets = List<Record>.from(d['tickets']);
      ledger = List<Record>.from(d['ledger']);
      notifications = List<Record>.from(d['notifications'] ?? []);
      catalogVersion = d['catalogVersion'] ?? 0;
      if (catalogVersion < demoCatalogVersion) _addDemoCatalog();
    } catch (_) {
      loadFailed = true;
      seed();
    }
  }

  void seed() {
    name = '김청휘';
    tick = 18;
    tickets = [];
    ledger = [];
    notifications = [];
    places = List.generate(
      4,
      (i) => {
        'id': 'p$i',
        'name': ['한마음 교회', '호평 주 평화 교회', '해맞이 그린 센터', '이현 교회'][i],
        'address': ['경기도 남양주시', '남양주시 호평동', '경상북도 포항시', '용인시 기흥구'][i],
        'capacity': [150, 30, 54, 80][i],
        'fee': 50000,
        'hours': '10:00–22:00',
        'equipment': '마이크 4개, 믹서, 스피커, 기본 조명',
        'description': '동네 관객과 아티스트가 가까이 만나는 공연 공간입니다. 좌석과 무대 배치는 협의할 수 있어요.',
        'image':
            'assets/place-${['hopyeong', 'haemaji', 'ihyun', 'hopyeong'][i]}.png',
        'mine': false,
      },
    );
    final day = DateTime.now().add(const Duration(days: 30));
    shows = List.generate(4, (i) {
      final start = DateTime(day.year, day.month, day.day + i, 19);
      return {
        'id': 's$i',
        'title': [
          '술탄 오브 더 디스코',
          'Pocket Music Fest',
          'Oasis concert',
          'Indie Band Bond',
        ][i],
        'placeId': 'p$i',
        'start': start.toIso8601String(),
        'end': start.add(const Duration(hours: 2)).toIso8601String(),
        'genre': ['Music', 'Band', 'Lo-fi', 'Jazz'][i],
        'description': '좋아하는 아티스트의 무대를 우리 동네에서 만나요. 관객의 사전 참여로 공연을 함께 만듭니다.',
        'artists': ['술탄 오브 더 디스코', '동네 뮤지션', 'Oasis', '인디 밴드'][i],
        'price': 15000,
        'audience': 30,
        'goal': 450000,
        'funded': [369000, 288000, 211500, 319500][i],
        'image':
            'assets/poster-${['sultan', 'pocket', 'oasis', 'indie'][i]}.png',
        'mine': false,
      };
    });
    _addDemoCatalog();
  }

  void _addDemoCatalog() {
    final candidates = demoPlaces();
    final knownPlaces = places.map((p) => p['id']).toSet();
    places.insertAll(
      0,
      candidates.where((p) => !knownPlaces.contains(p['id'])),
    );
    final knownShows = shows.map((s) => s['id']).toSet();
    final generated = demoShows(candidates, DateTime.now());
    shows.insertAll(0, generated.where((s) => !knownShows.contains(s['id'])));
    for (final place in places) {
      if (RegExp(r'^p[0-3]$').hasMatch(place['id']) && place['mine'] != true) {
        place['demo'] = true;
      }
    }
    for (final show in shows) {
      if (RegExp(r'^s[0-3]$').hasMatch(show['id']) && show['mine'] != true) {
        show['demo'] = true;
      }
    }
    catalogVersion = demoCatalogVersion;
  }

  Future<void> save() async {
    if (loadFailed) throw StateError('기존 기록을 읽지 못해 저장을 중단했습니다. 원본 데이터는 유지됩니다.');
    final ok = await prefs.setString(
      'croctick.v1',
      jsonEncode({
        'name': name,
        'tick': tick,
        'places': places,
        'shows': shows,
        'tickets': tickets,
        'ledger': ledger,
        'notifications': notifications,
        'catalogVersion': catalogVersion,
      }),
    );
    if (!ok) throw StateError('기기에 저장하지 못했습니다.');
    notifyListeners();
  }

  String id() => DateTime.now().microsecondsSinceEpoch.toString();

  void _recordNotification(Record show, String title) {
    notifications.insert(0, {
      'title': title,
      'showId': show['id'],
      'at': DateTime.now().toIso8601String(),
      'read': false,
    });
  }

  Future<void> readNotification(Record notification) async {
    if (notification['read'] == true) return;
    notification['read'] = true;
    try {
      await save();
    } catch (_) {
      notification['read'] = false;
      rethrow;
    }
  }

  void award(int amount, String reason) {
    tick += amount;
    ledger.insert(0, {
      'amount': amount,
      'reason': reason,
      'at': DateTime.now().toIso8601String(),
    });
  }

  Record placeFor(Record show) =>
      places.firstWhere((p) => p['id'] == show['placeId']);
  double progress(Record s) => (s['funded'] as num) / (s['goal'] as num);
  bool joined(Record s) => tickets.any((t) => t['showId'] == s['id']);
  String? participationBlockReason(Record show) {
    if (joined(show)) return '이미 참여한 공연입니다.';
    final state = status(show);
    if (state == '공간 승인 대기') return '공간 승인 후 참여할 수 있어요.';
    if (state == '취소') return '취소된 공연입니다.';
    if (!DateTime.parse(show['start']).isAfter(DateTime.now())) {
      return '이미 시작되었거나 종료된 공연입니다.';
    }
    if (!DateTime.parse(
      show['deadline'] ?? show['start'],
    ).isAfter(DateTime.now())) {
      return '모집이 마감되었습니다.';
    }
    if (!['펀딩 중', '공연 확정'].contains(state)) return '현재 참여할 수 없는 공연입니다.';
    if (show['funded'] + show['price'] > show['audience'] * show['price']) {
      return '정원이 모두 찼습니다.';
    }
    return null;
  }

  bool conflicts(String place, DateTime start, DateTime end) => shows.any(
    (s) =>
        status(s) != '취소' &&
        s['placeId'] == place &&
        start.isBefore(DateTime.parse(s['end'])) &&
        end.isAfter(DateTime.parse(s['start'])),
  );
  Future<void> join(Record s) async {
    final reason = participationBlockReason(s);
    if (reason != null) throw StateError(reason);
    s['funded'] += s['price'];
    tickets.insert(0, {
      'id': id(),
      'showId': s['id'],
      'amount': s['price'],
      'at': DateTime.now().toIso8601String(),
    });
    _recordNotification(s, '펀딩 참여가 완료됐어요');
    if (s['funded'] - s['price'] < s['goal'] && progress(s) >= 1) {
      _recordNotification(s, '펀딩 목표를 달성했어요');
    }
    await save();
  }

  Future<Record> addPlace(Record p) async {
    final created = {...p, 'id': id(), 'mine': true};
    places.insert(0, created);
    await save();
    return created;
  }

  Future<Record> addShow(Record s) async {
    final start = DateTime.parse(s['start']), end = DateTime.parse(s['end']);
    if (!end.isAfter(start)) throw StateError('종료 시간은 시작 시간 이후여야 합니다.');
    if (conflicts(s['placeId'], start, end)) {
      throw StateError('선택한 공간에 시간이 겹치는 공연이 있습니다.');
    }
    if (s['audience'] > placeFor(s)['capacity']) {
      throw StateError('공간의 최대 수용 인원을 초과했습니다.');
    }
    if (tier.price != null && s['price'] > tier.price) {
      throw StateError('${tier.name}의 티켓 설정 한도는 ${tier.price}원입니다.');
    }
    if (tier.audience != null && s['audience'] > tier.audience) {
      throw StateError('${tier.name}의 관객 한도는 ${tier.audience}명입니다.');
    }
    if (s['goal'] > s['price'] * s['audience']) {
      throw StateError('펀딩 목표는 티켓 가격 × 목표 관객 수 이하여야 합니다.');
    }
    final created = <String, dynamic>{
      ...s,
      'demo': s['demo'] == true || placeFor(s)['demo'] == true,
      'id': id(),
      'mine': true,
      'funded': 0,
      'approved': false,
    };
    shows.insert(0, created);
    await save();
    return created;
  }

  Future<void> reset() async {
    seed();
    loadFailed = false;
    await save();
  }

  String status(Record s) {
    if (s['cancelled'] == true) return '취소';
    if (s['settled'] == true) return '정산 완료';
    if (s['approved'] == false) return '공간 승인 대기';
    if (progress(s) >= 1) {
      return DateTime.parse(s['end']).isBefore(DateTime.now())
          ? '평가 대기'
          : '공연 확정';
    }
    final deadline = DateTime.parse(s['deadline'] ?? s['start']);
    return deadline.isBefore(DateTime.now()) ? '펀딩 미달' : '펀딩 중';
  }

  Future<void> approve(Record s) async {
    if (s['approved'] != false || s['cancelled'] == true) return;
    s['approved'] = true;
    _recordNotification(s, '공간 예약이 승인됐어요');
    await save();
  }

  Future<void> cancel(Record s) async {
    if (s['settled'] == true) throw StateError('이미 정산된 공연입니다.');
    if (s['cancelled'] == true) return;
    s['cancelled'] = true;
    for (final t in tickets.where((t) => t['showId'] == s['id'])) {
      t['refunded'] = true;
    }
    _recordNotification(s, '공연이 취소됐어요');
    await save();
  }

  Future<void> settle(Record s, int rating) async {
    if (status(s) != '평가 대기') throw StateError('목표를 달성하고 종료된 공연만 정산할 수 있습니다.');
    if (rating < 1 || rating > 5) throw StateError('1~5점 평가를 선택하세요.');
    final amount = s['funded'] as int;
    s['settlement'] = {
      'space': amount * 50 ~/ 100,
      'artist': amount * 40 ~/ 100,
      'platform': amount - (amount * 50 ~/ 100) - (amount * 40 ~/ 100),
    };
    s['rating'] = rating;
    s['settled'] = true;
    award(1 + rating, '${s['title']} 공연 완료·평가 정산');
    _recordNotification(s, '공연 정산으로 ${1 + rating} Tick을 받았어요');
    await save();
  }
}
