import 'package:croctick/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('실기기 탐색·검색·Tick·등록 필수값 검증', (tester) async {
    await app.main();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Recommend'), findsOneWidget);
    expect(find.text('Place'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '빠띠오 델 솔');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('search-result-candidate-001')));
    await tester.pumpAndSettle();
    expect(find.text('공간 상세'), findsOneWidget);
    expect(find.text('제휴 후보 · 미확정'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    Finder tab(String label) => find.byKey(ValueKey('tab-$label'));

    await tester.tap(tab('공연'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '없는공연검색검증');
    await tester.pumpAndSettle();
    expect(find.text('검색 결과가 없습니다.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    await tester.tap(tab('마이'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('나의 현재 등급'));
    await tester.pumpAndSettle();
    expect(find.text('틱 정산 시스템'), findsOneWidget);
    expect(find.text('나의 현재 등급'), findsOneWidget);
    expect(find.byKey(const ValueKey('current-tier-pinned')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('공간 등록 +'),
      150,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 12,
    );
    await tester.tap(find.text('공간 등록 +'));
    await tester.pumpAndSettle();
    expect(find.text('공간 등록'), findsOneWidget);
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.text('필수 항목입니다'), findsWidgets);
    expect(find.text('공간 등록'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
  });
}
