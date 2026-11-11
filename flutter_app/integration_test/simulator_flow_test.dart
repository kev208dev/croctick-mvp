import 'package:croctick/main.dart' as app;
import 'package:croctick/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('공간·공연 등록부터 승인·펀딩·재시작 저장까지', (tester) async {
    final semantics = tester.ensureSemantics();
    final prefs = await SharedPreferences.getInstance();
    final original = prefs.getString('croctick.v1');
    try {
      await app.main();
      await tester.pumpAndSettle();
      final store = tester.widget<app.CrocApp>(find.byType(app.CrocApp)).store;
      final initialTick = store.tick;
      final suffix = DateTime.now().millisecondsSinceEpoch;
      final spaceName = '시뮬레이터 검증 공간 $suffix';
      final showName = '시뮬레이터 검증 공연 $suffix';

      Future<void> press(Finder target) async {
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      Future<void> fill(String id, String value) async {
        final field = find.byKey(ValueKey(id));
        await tester.ensureVisible(field);
        await tester.enterText(field, value);
        await tester.pumpAndSettle();
      }

      // Start at the same home menu used by a person registering a space.
      await press(find.bySemanticsLabel('메뉴'));
      await press(find.text('공간 등록 +'));
      await fill('name', spaceName);
      await fill('address', '서울시 마포구 시뮬레이터 검증 주소');
      await fill('description', '공연 구역이 분리된 40인 실내 공간');
      await press(find.text('다음'));
      await fill('capacity', '40');
      await fill('fee', '50000');
      await fill('hours', '10:00–22:00');
      await fill('equipment', '마이크 2대, 믹서, 스피커, 기본 조명');
      await press(find.text('다음'));
      await press(find.text('등록하기'));
      final place = store.places.firstWhere((p) => p['name'] == spaceName);
      expect(place['equipment'], contains('마이크'));

      await tester.enterText(find.byType(TextField).first, spaceName);
      await tester.pumpAndSettle();
      await press(find.byKey(ValueKey('search-result-${place['id']}')));
      await tester.scrollUntilVisible(
        find.text('이 공간에서 공연 만들기'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await press(find.text('이 공간에서 공연 만들기'));
      await fill('name', showName);
      await fill('description', '검증용 어쿠스틱 공연 소개');
      await fill('artists', '시뮬레이터 검증 듀오');
      await press(find.text('다음'));
      await press(find.text('다음'));
      await fill('price', '10000');
      await fill('capacity', '2');
      await fill('goal', '20000');
      await press(find.text('등록하기'));
      final show = store.shows.firstWhere((s) => s['title'] == showName);
      expect(store.status(show), '공간 승인 대기');
      expect(show['image'], place['image']);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await press(find.byKey(const ValueKey('tab-공연')));
      await tester.enterText(find.byType(TextField).first, showName);
      await tester.pumpAndSettle();
      await press(find.byKey(ValueKey('search-result-${show['id']}')));
      await tester.scrollUntilVisible(
        find.text('공간 제공자 승인 처리'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await press(find.text('공간 제공자 승인 처리'));
      expect(store.status(show), '펀딩 중');
      final join = find.text('펀딩 참여 · 10,000원');
      await press(join);
      expect(store.progress(show), .5);
      expect(store.tick, initialTick);
      expect(find.textContaining('펀딩 50%'), findsOneWidget);
      expect(find.text('참여 완료 · 마이페이지에서 티켓 확인'), findsOneWidget);
      final loaded = Store(prefs);
      expect(
        loaded.shows.firstWhere((s) => s['id'] == show['id'])['funded'],
        10000,
      );
      expect(
        loaded.tickets.where((t) => t['showId'] == show['id']),
        hasLength(1),
      );
      expect(
        loaded.places.firstWhere((p) => p['id'] == place['id'])['capacity'],
        40,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      if (original == null) {
        await prefs.remove('croctick.v1');
      } else {
        await prefs.setString('croctick.v1', original);
      }
    }
  });
}
