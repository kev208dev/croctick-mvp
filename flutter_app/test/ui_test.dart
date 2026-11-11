import 'package:croctick/main.dart';
import 'package:croctick/store.dart';
import 'package:croctick/tick_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Store store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = Store(await SharedPreferences.getInstance());
  });

  for (final width in [402.0, 820.0, 1340.0, 1600.0]) {
    testWidgets('Tick 등급 카드 ${width.toInt()}px에서 넘침 없이 표시', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 1000),
              textScaler: const TextScaler.linear(1.15),
            ),
            child: TickPage(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rising까지 2 Tick 남았어요'), findsOneWidget);
      expect(find.text('✓ 지금 나의 등급 · 18 Tick'), findsOneWidget);
      await tester.ensureVisible(find.text('TOP LEVEL'));
      await tester.pumpAndSettle();
      expect(
        find.text('● 내 현재 등급: Rookie · 18 Tick').hitTestable(),
        findsOneWidget,
      );
      expect(find.text('110+ Tick'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('등급이 바뀌어도 해당 카드 하나만 현재 등급으로 강조', (tester) async {
    for (final tick in [0, 20, 40, 70, 110]) {
      store.tick = tick;
      await tester.pumpWidget(
        MaterialApp(
          home: TickPage(key: ValueKey(tick), store: store),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('current-tier-card-banner')),
        findsOneWidget,
      );
      expect(find.text('✓ 지금 나의 등급 · $tick Tick'), findsOneWidget);
      expect(
        find.text('● 내 현재 등급: ${store.tier.name} · $tick Tick').hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('공간 등록은 필수값 검증·이전 입력 유지·최종 저장', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => Registration(store: store, isPlace: true),
                ),
              ),
              child: const Text('시작'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('시작'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('필수 항목입니다'), findsNWidgets(3));
    Future<void> fill(String id, String value) async {
      final field = find.byKey(ValueKey(id));
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
    }

    await fill('name', '테스트 스테이지');
    await fill('address', '서울시 마포구 테스트로 1');
    await fill('description', '분리된 실내 공연 공간입니다.');
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await fill('capacity', '40');
    await fill('fee', '50000');
    await fill('hours', '10:00–22:00');
    await fill('equipment', '마이크 2대, 믹서');
    await tester.tap(find.text('이전'));
    await tester.pumpAndSettle();
    expect(find.text('테스트 스테이지'), findsOneWidget);
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('마이크 2대, 믹서'), findsOneWidget);
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('등록하기'));
    await tester.pumpAndSettle();
    expect(find.text('시작'), findsOneWidget);
    expect(store.places.first['name'], '테스트 스테이지');
    expect(store.places.first['capacity'], 40);
    expect(tester.takeException(), isNull);
  });

  testWidgets('후보 공간 검색과 상세의 원문·미확인 조건을 표시', (tester) async {
    final place = store.places.firstWhere((p) => p['candidate'] == true);
    await tester.pumpWidget(CrocApp(store: store));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, place['name']);
    await tester.pumpAndSettle();
    final result = find.byKey(ValueKey('search-result-${place['id']}'));
    await tester.ensureVisible(result);
    await tester.tap(result);
    await tester.pumpAndSettle();
    expect(find.text('공간 상세'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('운영자·대관 원문 보기'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text(place['sourceUrl']), findsOneWidget);
    expect(find.text('공연 전 확인할 조건'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
