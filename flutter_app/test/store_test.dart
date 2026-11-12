import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:croctick/store.dart';
import 'package:croctick/main.dart';

void main() {
  late Store s;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    s = Store(await SharedPreferences.getInstance());
  });
  test('펀딩은 금액과 티켓을 저장하고 틱 변경과 중복 참여를 막는다', () async {
    final show = s.shows.first;
    final before = s.progress(show);
    await s.join(show);
    expect(s.progress(show), greaterThan(before));
    expect(s.tickets.length, 1);
    expect(s.tick, 18);
    await expectLater(s.join(show), throwsStateError);
    final loaded = Store(s.prefs);
    expect(loaded.tickets.length, 1);
    expect(loaded.tick, 18);
  });
  test('겹친 예약은 차단하고 바로 이어지는 예약은 허용한다', () async {
    final existing = s.shows.first;
    final begin = DateTime.parse(existing['start']);
    final finish = DateTime.parse(existing['end']);
    expect(
      s.conflicts(
        existing['placeId'],
        begin.add(const Duration(minutes: 30)),
        finish.add(const Duration(hours: 1)),
      ),
      true,
    );
    expect(
      s.conflicts(
        existing['placeId'],
        finish,
        finish.add(const Duration(hours: 2)),
      ),
      false,
    );
    await expectLater(
      s.addShow({
        ...existing,
        'start': begin.toIso8601String(),
        'end': finish.toIso8601String(),
      }),
      throwsStateError,
    );
  });
  test('등급 경계와 초기화', () async {
    expect(Tier.forTick(19).name, 'Rookie');
    expect(Tier.forTick(20).name, 'Rising');
    expect(Tier.forTick(110).name, 'Headliner');
    await s.join(s.shows.first);
    await s.reset();
    expect(s.tickets, isEmpty);
    expect(s.tick, 18);
    expect(s.places.length, 44);
  });
  testWidgets('공간 목록과 마이 정산 화면 표시', (tester) async {
    await tester.pumpWidget(CrocApp(store: s));
    await tester.pumpAndSettle();
    expect(find.text('Recommend'), findsOneWidget);
    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    expect(find.text('내 틱 정산'), findsOneWidget);
  });
  test('공연 종료·평가 후 한 번만 틱 및 배분 정산', () async {
    final show = s.shows.first;
    show['end'] = DateTime.now()
        .subtract(const Duration(hours: 1))
        .toIso8601String();
    show['funded'] = 450000;
    await s.settle(show, 5);
    expect(s.tick, 24);
    expect(show['settlement'], {
      'space': 225000,
      'artist': 180000,
      'platform': 45000,
    });
    await expectLater(s.settle(show, 5), throwsStateError);
  });
  test('취소는 티켓을 환불 처리하고 예약 시간을 해제', () async {
    final show = s.shows.first;
    await s.join(show);
    await s.cancel(show);
    expect(s.tickets.first['refunded'], true);
    expect(s.status(show), '취소');
    expect(
      s.conflicts(
        show['placeId'],
        DateTime.parse(show['start']),
        DateTime.parse(show['end']),
      ),
      false,
    );
  });

  test('정원 초과와 목표 달성 후 마감된 공연 참여를 차단', () async {
    final show = s.shows.first;
    show['funded'] = show['audience'] * show['price'];
    expect(s.participationBlockReason(show), '정원이 모두 찼습니다.');
    await expectLater(s.join(show), throwsStateError);
    expect(s.tickets, isEmpty);
    show['funded'] = show['goal'];
    show['audience'] += 10;
    show['deadline'] = DateTime.now()
        .subtract(const Duration(minutes: 1))
        .toIso8601String();
    expect(s.status(show), '공연 확정');
    expect(s.participationBlockReason(show), '모집이 마감되었습니다.');
    await expectLater(s.join(show), throwsStateError);
  });

  test('티켓 수입으로 달성할 수 없는 목표는 등록하지 않는다', () async {
    final show = s.shows.first;
    final start = DateTime.parse(show['end']).add(const Duration(days: 1));
    final before = s.shows.length;
    await expectLater(
      s.addShow({
        ...show,
        'start': start.toIso8601String(),
        'end': start.add(const Duration(hours: 1)).toIso8601String(),
        'price': 10000,
        'audience': 2,
        'goal': 30000,
      }),
      throwsStateError,
    );
    expect(s.shows.length, before);
  });
}
