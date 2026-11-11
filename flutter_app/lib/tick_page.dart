import 'package:flutter/material.dart';
import 'store.dart';

const tierColors = [
  Color(0xff19c98b),
  Color(0xff3d8bff),
  Color(0xff8b5cf6),
  Color(0xffff7a2f),
  Color(0xfff43f5e),
];
const _notes = [
  '첫 무대를 위한 실속형 공간',
  '접근성과 규모를 함께 확보',
  '브랜드 경험이 시작되는 단계',
  '확장 공연을 위한 프리미엄 구성',
  '최상위 공연을 위한 플래그십',
];
const _symbols = ['R', 'R+', '★', '▲', '◆'];
const _tierNames = ['루키', '라이징', '아티스트', '프로', '헤드라이너'];
String _price(int value) =>
    '₩${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

class TickPage extends StatelessWidget {
  final Store store;
  const TickPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        title: const Text('내 Tick'),
        backgroundColor: const Color(0xfff7f8fa),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            key: const ValueKey('current-tier-pinned'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: tierColors[Tier.all.indexOf(store.tier)].withValues(
              alpha: .14,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '● 내 현재 등급: ${store.tier.name} · ${store.tick} Tick',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff151923),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -160,
            left: -140,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0d19c98b),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            right: -160,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0af43f5e),
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1720),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  LayoutBuilder(
                    builder: (context, box) {
                      const title = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '틱 정산 시스템',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xff151923),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '무대의 경험이 쌓일수록, 더 큰 무대로',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff687180),
                            ),
                          ),
                        ],
                      );
                      return box.maxWidth >= 1000
                          ? Row(
                              children: [
                                const Expanded(flex: 2, child: title),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 3,
                                  child: TickOverview(store: store),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                title,
                                const SizedBox(height: 24),
                                TickOverview(store: store),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '성장 단계별 공연 규모와 티켓 정책',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, box) {
                      final columns = box.maxWidth >= 1280
                          ? 5
                          : box.maxWidth >= 1050
                          ? 3
                          : box.maxWidth >= 620
                          ? 2
                          : 1;
                      final width =
                          (box.maxWidth - 16 * (columns - 1)) / columns;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: List.generate(
                          5,
                          (index) => SizedBox(
                            width: width,
                            child: TierPanel(
                              index: index,
                              current: store.tier == Tier.all[index],
                              currentTick: store.tick,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tick은 어떻게 쌓이나요?',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '공연이 끝난 뒤 완료 확인과 평가를 거쳐 적립돼요. 공간 등록이나 펀딩 참여만으로는 적립되지 않아요.',
                          style: TextStyle(
                            height: 1.6,
                            color: Color(0xff687180),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.white,
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: const Text('현재 시연 적립 기준'),
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text(
                                  '공연 완료 1 Tick + 평가 1~5 Tick\n운영 정책 확정 전의 시연 기준이에요.',
                                  style: TextStyle(
                                    color: Color(0xff687180),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '최근 획득 내역',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  if (store.ledger.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 30,
                            color: Color(0xff8b939f),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '첫 공연의 기록을 기다리고 있어요',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '공연 완료 후 적립 내역이 여기에 표시돼요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xff687180)),
                          ),
                        ],
                      ),
                    ),
                  ...store.ledger.map((entry) {
                    final at = DateTime.parse(entry['at']);
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        title: Text(entry['reason']),
                        subtitle: Text('${at.year}.${at.month}.${at.day}'),
                        trailing: Text(
                          '+${entry['amount']} Tick',
                          style: const TextStyle(
                            color: Color(0xff19a775),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class TickOverview extends StatelessWidget {
  final Store store;
  final VoidCallback? onTap;
  const TickOverview({super.key, required this.store, this.onTap});
  @override
  Widget build(BuildContext context) {
    final index = Tier.all.indexOf(store.tier), accent = tierColors[index];
    final next = index < 4 ? Tier.all[index + 1] : null;
    final progress = next == null
        ? 1.0
        : ((store.tick - store.tier.minimum) /
                  (next.minimum - store.tier.minimum))
              .clamp(0.0, 1.0);
    return Material(
      color: const Color(0xff14171d),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '나의 현재 등급',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .65),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _symbols[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${store.tier.name} · ${_tierNames[index]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${store.tick} Tick',
                    style: TextStyle(
                      color: accent,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  color: accent,
                  backgroundColor: const Color(0xff313741),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                next == null
                    ? '최상위 등급에 도달했어요'
                    : '${next.name}까지 ${next.minimum - store.tick} Tick 남았어요',
                style: const TextStyle(color: Color(0xffc0c6d0), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TierPanel extends StatelessWidget {
  final int index;
  final bool current;
  final int? currentTick;
  const TierPanel({
    super.key,
    required this.index,
    required this.current,
    this.currentTick,
  });
  @override
  Widget build(BuildContext context) {
    final tier = Tier.all[index], accent = tierColors[index];
    final range = index == 4
        ? '110+ Tick'
        : '${tier.minimum}–${Tier.all[index + 1].minimum - 1} Tick';
    return Semantics(
      label: current
          ? '지금 나의 등급: ${tier.name}, ${currentTick ?? tier.minimum} Tick'
          : '${tier.name} 등급 안내',
      child: Container(
        constraints: const BoxConstraints(minHeight: 560),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: current
              ? Color.alphaBlend(
                  accent.withValues(alpha: .12),
                  const Color(0xff14171d),
                )
              : index == 4
              ? const Color(0xff17324f)
              : const Color(0xff14171d),
          borderRadius: BorderRadius.circular(28),
          boxShadow: current
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: .25),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : null,
          border: Border.all(
            color: current ? accent : const Color(0xff303641),
            width: current ? 4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (current)
              Container(
                key: const ValueKey('current-tier-card-banner'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                color: accent,
                child: Text(
                  '✓ 지금 나의 등급${currentTick == null ? '' : ' · $currentTick Tick'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff10151d),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: DefaultTextStyle(
                style: const TextStyle(color: Color(0xfff8fafc), fontSize: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _symbols[index],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tier.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [_pill(range, accent)],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '최저 티켓가 설정 한도',
                      style: TextStyle(color: Color(0xff858b98), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tier.price == null ? '무제한' : _price(tier.price!),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier.price == null ? '티켓가 제한 없음' : '/ 1매',
                      style: const TextStyle(
                        color: Color(0xff858b98),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Divider(color: Color(0xff2a2f39)),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .22),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '✓',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              tier.venue,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '최대 관객',
                      style: TextStyle(color: Color(0xff858b98), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tier.audience == null ? '무제한' : '${tier.audience}명',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: [.22, .38, .58, .78, 1.0][index],
                        color: accent,
                        backgroundColor: const Color(0xff313741),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _notes[index],
                      style: const TextStyle(
                        color: Color(0xff858b98),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (index == 4) _pill('TOP LEVEL', accent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: accent,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
