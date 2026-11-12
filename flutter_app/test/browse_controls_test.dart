import 'package:croctick/main.dart';
import 'package:croctick/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Store store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = Store(await SharedPreferences.getInstance());
  });

  testWidgets('상단 Tick과 장르·공연 태그·지역 필터가 구분된다', (tester) async {
    await tester.pumpWidget(CrocApp(store: store));
    await tester.pumpAndSettle();
    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> back() async {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tap(find.byKey(const ValueKey('category-Calm')));
    expect(find.text('공연 필터 · 잔잔한'), findsOneWidget);
    expect(find.text('퇴근길 어쿠스틱'), findsOneWidget);
    await back();

    final tick = find.byKey(const ValueKey('toolbar-내 Tick 보기'));
    await tap(tick);
    expect(find.text('● 내 현재 등급: Rookie · 18 Tick'), findsOneWidget);
    await back();
    await tap(find.byKey(const ValueKey('tab-공연')));
    await tap(tick);
    expect(find.text('● 내 현재 등급: Rookie · 18 Tick'), findsOneWidget);
    await back();
    await tap(find.byKey(const ValueKey('show-tag-신나는')));
    expect(find.text('공연 필터 · 신나는'), findsOneWidget);
    await back();
    await tap(find.byKey(const ValueKey('show-tag-나만 아는')));
    expect(find.text('공연 필터 · 나만 아는'), findsOneWidget);
    expect(find.text('동네에서 만난 포크'), findsOneWidget);
    await back();

    await tap(find.byKey(const ValueKey('show-tag-내 주변')));
    expect(find.textContaining('위에서 지역을 선택하면'), findsOneWidget);
    await tap(find.text('지역 선택 · 전국'));
    await tap(find.text('서울').last);
    expect(find.text('퇴근길 어쿠스틱'), findsOneWidget);
    expect(find.textContaining('위에서 지역을 선택하면'), findsNothing);
    await tester.enterText(find.byType(TextField), '시네마 피아노');
    await tester.pumpAndSettle();
    expect(find.text('검색 결과가 없습니다.'), findsOneWidget);
    await back();

    await tap(find.byKey(const ValueKey('show-filters')));
    expect(find.byType(ChoiceChip), findsWidgets);
    expect(find.text('지역 선택 · 전국'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('알림 벨에서 기록을 열면 읽음 상태가 저장되고 공연으로 이동', (tester) async {
    await tester.pumpWidget(CrocApp(store: store));
    await tester.pumpAndSettle();
    final bell = find.byKey(const ValueKey('toolbar-알림'));
    await tester.tap(bell);
    await tester.pumpAndSettle();
    expect(find.text('아직 받은 알림이 없어요.'), findsOneWidget);
    final show = store.shows.first;
    await store.join(show);
    await tester.pumpAndSettle();
    await tester.tap(find.text('펀딩 참여가 완료됐어요'));
    await tester.pumpAndSettle();
    expect(find.text('공연 상세'), findsOneWidget);
    final reloaded = Store(store.prefs);
    expect(
      reloaded.notifications.firstWhere(
        (n) => n['title'] == '펀딩 참여가 완료됐어요',
      )['read'],
      true,
    );
  });
}
