import 'venue_candidates.dart';

const demoCatalogVersion = 1;

const _concerts = [
  ('퇴근길 어쿠스틱', '느린오후 듀오', 'Music'),
  ('창가의 작은 재즈', '윈도우 트리오', 'Jazz'),
  ('책 사이로 흐르는 노래', '페이지 싱어', 'Music'),
  ('금요일의 언플러그드', '로컬웨이브', 'Band'),
  ('피아노로 쓰는 편지', '건반의 계절', 'Lo-fi'),
  ('해질녘 보사노바', '라이트 보사', 'Jazz'),
  ('동네에서 만난 포크', '골목의 목소리', 'Music'),
  ('둘이서 만드는 작은 무대', '포레스트 듀오', 'Band'),
  ('비 오는 날의 재즈', '레인 체크', 'Jazz'),
  ('마음을 쉬게 하는 피아노', '소프트 키즈', 'Lo-fi'),
  ('주말 오후의 작은 콘서트', '오후 네 시', 'Music'),
  ('우리 동네 싱어송라이터', '가로등 싱어', 'Music'),
  ('별빛 아래 언플러그드', '나이트레터', 'Band'),
  ('기타 한 대의 여행', '스트링 워커', 'Music'),
  ('작은 공간의 스윙', '미니 스윙 트리오', 'Jazz'),
  ('차 한 잔과 로파이', '티타임 키보드', 'Lo-fi'),
  ('너에게 들려주는 팝', '허밍버드 듀오', 'Music'),
  ('낮은 목소리의 저녁', '저녁의 숲', 'Music'),
  ('어쿠스틱으로 만난 인디', '파인드 밴드', 'Band'),
  ('가까이 듣는 재즈 듀오', '클로즈 업', 'Jazz'),
  ('마을의 첫 번째 무대', '동네의 리듬', 'Music'),
  ('주말에 만나는 포크', '작은 항해', 'Music'),
  ('오후를 채우는 멜로디', '멜로디 박스', 'Lo-fi'),
  ('우리만의 미니 라이브', '리틀 스테이지', 'Band'),
  ('책장을 넘기는 피아노', '페이퍼 키즈', 'Lo-fi'),
  ('커피 향 재즈 세션', '브루잉 트리오', 'Jazz'),
  ('노을을 닮은 노래', '선셋 레터', 'Music'),
  ('작은 무대 큰 이야기', '스토리 듀오', 'Music'),
  ('동네 밴드의 어쿠스틱 데이', '로컬 데이즈', 'Band'),
  ('창밖 풍경과 영화 음악', '시네마 피아노', 'Lo-fi'),
  ('계절을 노래하는 밤', '시즌 싱어', 'Music'),
  ('함께 듣는 재즈 스탠더드', '라운드 테이블', 'Jazz'),
  ('가까운 무대의 온기', '웜톤 듀오', 'Music'),
  ('선율로 만나는 이웃', '네이버후드', 'Band'),
  ('한 시간의 피아노 산책', '워크 앤 키즈', 'Lo-fi'),
  ('나지막한 어쿠스틱 세션', '로우 보이스', 'Music'),
  ('주중 저녁의 재즈 한 곡', '위크데이 듀오', 'Jazz'),
  ('우리 동네 작은 음악회', '타운 멜로디', 'Music'),
  ('볼륨을 낮춘 밴드 라이브', '어쿠스틱 코너', 'Band'),
  ('다시 만나고 싶은 멜로디', '리프레인 듀오', 'Music'),
];

List<Map<String, dynamic>> demoPlaces() => [
  for (var i = 0; i < venueCandidates.length; i++)
    {
      ...venueCandidates[i],
      // A missing public capacity remains explicit; 30 is only a demo input.
      'capacity': venueCandidates[i]['capacity'] ?? 30,
      'capacityIsEstimate': venueCandidates[i]['capacity'] == null,
      'fee': 0,
      'image': '',
      'mine': false,
      'candidate': true,
      'demo': true,
      'artVariant': i,
    },
];

List<Map<String, dynamic>> demoShows(
  List<Map<String, dynamic>> places,
  DateTime now,
) {
  final day = now.add(const Duration(days: 30));
  return [
    for (var i = 0; i < places.length; i++)
      _show(
        places[i],
        i,
        DateTime(day.year, day.month, day.day + i ~/ 2, i.isEven ? 17 : 19),
      ),
  ];
}

Map<String, dynamic> _show(
  Map<String, dynamic> place,
  int index,
  DateTime start,
) {
  final concept = _concerts[index % _concerts.length];
  final audience = (place['capacity'] as int).clamp(1, 40);
  final price = [10000, 12000, 15000][index % 3];
  final supporters = index % 10 == 0
      ? audience - 1
      : (audience * (.25 + (index % 7) * .1)).floor();
  return {
    'id': 'demo-show-${(index + 1).toString().padLeft(3, '0')}',
    'title': concept.$1,
    'placeId': place['id'],
    'start': start.toIso8601String(),
    'end': start.add(const Duration(hours: 1)).toIso8601String(),
    'deadline': start.subtract(const Duration(days: 3)).toIso8601String(),
    'genre': concept.$3,
    'description':
        '실제 예정 공연이 아닌 가상 시연 공연입니다. 장소 제휴·예약·출연은 확정되지 않았습니다.\n\n'
        '${place['name']}의 공개 공간 유형을 참고해 구성한 가까운 거리의 소규모 음악회입니다. '
        '보컬과 어쿠스틱 악기 중심으로 60분간 진행하는 예시이며, 좌석·음향·허용 음량은 운영자 협의가 필요합니다. '
        '아래 펀딩 금액과 참여 수치도 시연 값입니다.',
    'artists': '${concept.$2} (가상 출연자)',
    'price': price,
    'audience': audience,
    'goal': audience * price,
    'funded': supporters * price,
    'approved': true,
    'image': '',
    'mine': false,
    'demo': true,
    'artVariant': index,
  };
}
