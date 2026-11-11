import 'dart:convert';
import 'package:croctick/demo_catalog.dart';
import 'package:croctick/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Store store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = Store(await SharedPreferences.getInstance());
  });

  test('실제 출처가 있는 후보 40개와 시연 공연 40개가 연결된다', () {
    final places = store.places.where((p) => p['candidate'] == true).toList();
    final shows = store.shows
        .where((s) => (s['id'] as String).startsWith('demo-show-'))
        .toList();
    expect(places, hasLength(40));
    expect(shows, hasLength(40));
    expect(store.places.map((p) => p['id']).toSet(), hasLength(44));
    expect(store.shows.map((s) => s['id']).toSet(), hasLength(44));
    expect(places.map((p) => p['name']).toSet(), hasLength(40));
    for (final p in places) {
      expect(Uri.parse(p['sourceUrl']).scheme, 'https');
      expect(p['fitReason'], isNotEmpty);
      expect(p['verificationNeeded'], isNotEmpty);
      expect(p['capacity'], greaterThan(0));
      expect(p['mine'], false);
    }
    for (final s in shows) {
      expect(s['demo'], true);
      expect(s['artists'], contains('가상'));
      expect(s['audience'], lessThanOrEqualTo(store.placeFor(s)['capacity']));
      expect(s['audience'], lessThanOrEqualTo(40));
      expect(s['funded'] % s['price'], 0);
      expect(store.progress(s), lessThan(1));
      expect(
        DateTime.parse(s['deadline']).isBefore(DateTime.parse(s['start'])),
        true,
      );
      expect(
        store.shows.where(
          (other) =>
              other['id'] != s['id'] &&
              other['placeId'] == s['placeId'] &&
              DateTime.parse(
                other['start'],
              ).isBefore(DateTime.parse(s['end'])) &&
              DateTime.parse(other['end']).isAfter(DateTime.parse(s['start'])),
        ),
        isEmpty,
      );
    }
  });

  test('구버전 저장 데이터에 예시를 추가해도 내역은 유지하고 중복하지 않는다', () async {
    final originalShow = store.shows.firstWhere((s) => s['id'] == 's0');
    await store.join(originalShow);
    store.tick = 43;
    store.ledger.add({
      'amount': 5,
      'reason': '기존 공연 평가',
      'at': DateTime.now().toIso8601String(),
    });
    await store.addPlace({
      'name': '내 공간',
      'capacity': 35,
      'image': '/saved/user-image.jpg',
    });
    final ownPlace = store.places.first;
    final raw = {
      'name': '기존 사용자',
      'tick': store.tick,
      'places': store.places.where((p) => p['candidate'] != true).toList(),
      'shows': store.shows
          .where((s) => !(s['id'] as String).startsWith('demo-show-'))
          .toList(),
      'tickets': store.tickets,
      'ledger': store.ledger,
    };
    await store.prefs.setString('croctick.v1', jsonEncode(raw));
    final migrated = Store(store.prefs);
    expect(migrated.name, '기존 사용자');
    expect(migrated.tick, 43);
    expect(migrated.tickets.single['showId'], 's0');
    expect(migrated.ledger.single['reason'], '기존 공연 평가');
    expect(
      migrated.places.firstWhere((p) => p['id'] == ownPlace['id'])['image'],
      '/saved/user-image.jpg',
    );
    expect(
      migrated.shows.firstWhere((s) => s['id'] == 's0')['funded'],
      originalShow['funded'],
    );
    expect(migrated.places, hasLength(45));
    expect(migrated.shows, hasLength(44));
    await migrated.save();
    final reloaded = Store(store.prefs);
    expect(reloaded.catalogVersion, demoCatalogVersion);
    expect(reloaded.places, hasLength(45));
    expect(reloaded.shows, hasLength(44));
    expect(reloaded.tickets, hasLength(1));
    expect(reloaded.tick, 43);
  });

  test('추가 시연 공연도 참여 후 펀딩 비율과 재시작 저장에 반영', () async {
    final show = store.shows.firstWhere((s) => s['id'] == 'demo-show-001');
    final before = store.progress(show);
    await store.join(show);
    expect(store.progress(show), greaterThan(before));
    final reloaded = Store(store.prefs);
    expect(
      reloaded.shows.firstWhere((s) => s['id'] == show['id'])['funded'],
      show['funded'],
    );
    expect(reloaded.tick, 18);
  });

  test('손상된 저장 원본은 시작·저장 시 덮어쓰지 않는다', () async {
    const original = '{"name":"기존 사용자","places":';
    await store.prefs.setString('croctick.v1', original);
    final failed = Store(store.prefs);
    expect(failed.loadFailed, true);
    await expectLater(failed.save(), throwsStateError);
    expect(store.prefs.getString('croctick.v1'), original);
  });

  test('후보 장소에 직접 만든 공연도 시연 상태를 유지', () async {
    final place = store.places.firstWhere((p) => p['candidate'] == true);
    final start = DateTime.now().add(const Duration(days: 5));
    await store.addShow({
      'title': '나의 시연 공연',
      'placeId': place['id'],
      'start': start.toIso8601String(),
      'end': start.add(const Duration(hours: 1)).toIso8601String(),
      'audience': 20,
      'price': 10000,
      'goal': 200000,
      'description': '공연 소개',
      'artists': '우리 팀',
      'genre': 'Music',
      'image': '',
    });
    expect(store.shows.first['demo'], true);
    expect(store.shows.first['approved'], false);
    expect(store.shows.first['mine'], true);
  });
}
