import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'store.dart';

String placeCapacity(Record place) => place['capacityIsEstimate'] == true
    ? '공연 정원 미확인 · 시연 ${place['capacity']}명'
    : '공개 최대 ${place['capacity']}명${place['candidate'] == true ? ' · 공연 좌석 협의' : ''}';

class CatalogBadge extends StatelessWidget {
  final bool isPlace;
  final bool candidate;
  const CatalogBadge({super.key, required this.isPlace, this.candidate = true});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xffffeadb),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      isPlace ? (candidate ? '제휴 후보 · 미확정' : '기존 시연 공간') : '시연 공연 · 가상 일정',
      style: const TextStyle(
        color: Color(0xffa34508),
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );
}

class CatalogArtwork extends StatelessWidget {
  final Record item;
  final bool isPlace;
  final double height;
  const CatalogArtwork({
    super.key,
    required this.item,
    required this.isPlace,
    this.height = 180,
  });
  @override
  Widget build(BuildContext context) {
    final palettes = [
      [const Color(0xff58483c), const Color(0xffa98768)],
      [const Color(0xff243c45), const Color(0xff6b9296)],
      [const Color(0xff4b354e), const Color(0xff9b7893)],
      [const Color(0xff334b3b), const Color(0xff819779)],
      [const Color(0xff504733), const Color(0xffb09a68)],
    ];
    final variant = (item['artVariant'] as int? ?? 0) % palettes.length;
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palettes[variant],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth < 150) {
            return Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPlace
                          ? Icons.storefront_outlined
                          : Icons.music_note_rounded,
                      color: Colors.white70,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPlace ? '공간 사진\n준비 중' : '시연 공연',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isPlace
                        ? Icons.storefront_outlined
                        : Icons.music_note_rounded,
                    color: Colors.white70,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPlace ? '공간 사진 준비 중' : 'CROCTICK · DEMO LIVE',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item[isPlace ? 'name' : 'title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              Text(
                isPlace ? item['address'] : '${item['genre']} · 가상 시연 공연',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CandidateInfo extends StatelessWidget {
  final Record place;
  const CandidateInfo({super.key, required this.place});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: const Color(0xfffff4ea),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CatalogBadge(isPlace: true),
          const SizedBox(height: 16),
          const Text(
            '이 공간을 후보로 선정한 이유',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(place['fitReason'], style: const TextStyle(height: 1.6)),
          const SizedBox(height: 18),
          const Text(
            '공연 전 확인할 조건',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            place['verificationNeeded'],
            style: const TextStyle(height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text(
            '제휴·예약·유료 입장·매출 배분은 확정되지 않았습니다. 공간의 공개 수용 인원은 공연 좌석 수와 다를 수 있습니다.',
            style: TextStyle(color: Color(0xff805933), height: 1.5),
          ),
          const Divider(height: 28),
          Text(
            '출처 · ${place['sourceTitle']}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            '자료 확인일 ${place['checkedAt']}',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SelectableText(
            place['sourceUrl'],
            style: const TextStyle(fontSize: 13, color: Color(0xffa34508)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('운영자·대관 원문 보기'),
            onPressed: () async {
              try {
                final opened = await launchUrl(
                  Uri.parse(place['sourceUrl']),
                  mode: LaunchMode.externalApplication,
                );
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('링크를 열지 못했어요. 위 주소를 복사해 주세요.'),
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('브라우저를 열지 못했어요. 위 주소를 복사해 주세요.'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}
