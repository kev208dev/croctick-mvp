import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'catalog_widgets.dart';
import 'store.dart';

const _ink = Color(0xff3d2d17);
const _muted = Color(0xff745d3d);

double _frameScale(BuildContext context, double width) {
  final height = MediaQuery.sizeOf(context).height;
  return math.min(width / 402, (height / 874).clamp(1.0, 1.65));
}

const _shadow = BoxShadow(
  color: Color(0x40000000),
  offset: Offset(0, 4),
  blurRadius: 4,
);

Widget _asset(int page, String name, {BoxFit fit = BoxFit.fill}) {
  final path = 'assets/figma/$page-$name';
  return name.endsWith('.svg')
      ? SvgPicture.asset(path, fit: fit)
      : Image.asset(path, fit: fit, excludeFromSemantics: true);
}

Widget _at(double x, double y, double w, double h, Widget child) =>
    Positioned(left: x, top: y, width: w, height: h, child: child);

Widget _label(
  String text,
  double x,
  double y,
  double width,
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = _ink,
  int lines = 1,
}) => _at(
  x,
  y,
  width,
  size * 1.2 * lines,
  Text(
    text,
    maxLines: lines,
    softWrap: lines > 1,
    overflow: TextOverflow.visible,
    textScaler: TextScaler.noScaling,
    style: TextStyle(
      fontFamily: 'Pretendard',
      fontSize: size,
      height: 1.2,
      fontWeight: weight,
      color: color,
      letterSpacing: 0,
    ),
  ),
);

Widget _panel(
  double x,
  double y,
  double w,
  double h,
  double radius, {
  Color color = Colors.white,
  bool shadow = false,
}) => _at(
  x,
  y,
  w,
  h,
  DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ? [_shadow] : null,
    ),
  ),
);

Widget _tap(Widget child, VoidCallback? onTap, {String? label, Key? key}) =>
    Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );

/// Native Flutter reconstruction of Figma 15:64 and 15:65, at a 402-point width.
class FigmaBrowse extends StatefulWidget {
  final Store store;
  final bool isPlace;
  final VoidCallback onMenu, onActivity, onProfile, onSeeAll;
  final void Function(Map<String, dynamic>, bool) onOpen;
  final ValueChanged<String> onCategory;
  final VoidCallback onFilters;
  const FigmaBrowse({
    super.key,
    required this.store,
    required this.isPlace,
    required this.onMenu,
    required this.onActivity,
    required this.onProfile,
    required this.onSeeAll,
    required this.onOpen,
    required this.onCategory,
    required this.onFilters,
  });
  @override
  State<FigmaBrowse> createState() => _FigmaBrowseState();
}

class _FigmaBrowseState extends State<FigmaBrowse> {
  final _search = TextEditingController();
  final _placesScroll = ScrollController();
  String _query = '';
  int get _page => widget.isPlace ? 0 : 1;
  List<Record> get _items =>
      widget.isPlace ? widget.store.places : widget.store.shows;
  @override
  void didUpdateWidget(covariant FigmaBrowse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlace != widget.isPlace) {
      _search.clear();
      _query = '';
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _placesScroll.dispose();
    super.dispose();
  }

  Record? _seed(String id) {
    for (final item in _items) {
      if (item['id'] == id) return item;
    }
    return null;
  }

  void _openSeed(String id) {
    final item = _seed(id);
    if (item != null) widget.onOpen(item, widget.isPlace);
  }

  Widget _image(
    String name,
    double x,
    double y,
    double w,
    double h, {
    BorderRadius? radius,
  }) => _at(
    x,
    y,
    w,
    h,
    ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: _asset(_page, name, fit: BoxFit.cover),
    ),
  );
  Widget _svg(String name, double x, double y, double w, double h) =>
      _at(x, y, w, h, _asset(_page, name));

  Widget _seeAll(double x, double y, {VoidCallback? onTap, Key? key}) => _at(
    x - 3,
    y - 15,
    47,
    44,
    _tap(
      Stack(
        clipBehavior: Clip.none,
        children: [
          _at(
            3,
            15,
            41,
            11,
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.black, width: .2),
              ),
            ),
          ),
          _label('see all', 12, 15, 25, 8, color: Colors.black),
        ],
      ),
      onTap ?? widget.onSeeAll,
      key: key,
      label: '전체 보기',
    ),
  );

  Widget _toolbar() => _at(
    0,
    54,
    402,
    48,
    Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        for (final action in <(double, String, String, VoidCallback)>[
          (20, 'imgFrame3.svg', '메뉴', widget.onMenu),
          (282, 'imgFrame4.svg', '알림', widget.onActivity),
          (338, 'imgFrame5.svg', '마이페이지', widget.onProfile),
        ])
          _at(
            action.$1,
            0,
            44,
            44,
            _tap(
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: _asset(_page, action.$2),
                ),
              ),
              action.$4,
              key: ValueKey('toolbar-${action.$3}'),
              label: action.$3,
            ),
          ),
        _at(
          169,
          -10,
          64,
          64,
          Semantics(
            label: 'CrocTick',
            image: true,
            child: _asset(_page, 'imgCrocTickLogo.png', fit: BoxFit.cover),
          ),
        ),
      ],
    ),
  );

  List<Widget> _searchField() {
    final top = widget.isPlace ? 261.0 : 118.0;
    return [
      _panel(21, top, 360, 50, 50, color: const Color(0xfff6c19b)),
      _svg(
        'imgVector.svg',
        36.0192,
        widget.isPlace ? 276.9706 : 133.9842,
        18.0058,
        18.0058,
      ),
      _at(
        21,
        top,
        360,
        50,
        TextField(
          key: ValueKey(widget.isPlace ? 'search-home' : 'search-shows'),
          controller: _search,
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            height: 1.2,
            color: _ink,
          ),
          decoration: InputDecoration(
            hintText: 'Searching...',
            isDense: true,
            filled: false,
            hintStyle: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.2,
              color: widget.isPlace
                  ? const Color(0xffaa612e)
                  : const Color(0xffb87342),
            ),
            contentPadding: const EdgeInsets.fromLTRB(42, 15, 16, 15),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    ];
  }

  List<Widget> _home() => [
    _panel(12, 325, 378, 155, 20),
    _panel(12, 494, 378, 202, 20),
    _panel(12, 710, 378, 85, 20),
    _label(
      '무대 위\n스타를\n우리 집 앞으로',
      20,
      126,
      265,
      32,
      weight: FontWeight.w800,
      lines: 3,
    ),
    _at(
      289,
      132,
      92.811,
      102.188,
      Center(
        child: Transform.rotate(
          angle: 17.12 * math.pi / 180,
          child: SizedBox(
            width: 70.903,
            height: 85.083,
            child: _asset(0, 'imgDecorativeMusicNote.png', fit: BoxFit.cover),
          ),
        ),
      ),
    ),
    _at(
      326,
      199,
      50.635,
      56.504,
      Center(
        child: Transform.rotate(
          angle: 13.93 * math.pi / 180,
          child: SizedBox(
            width: 40.205,
            height: 48.246,
            child: _asset(0, 'imgDecorativeMusicNote.png', fit: BoxFit.cover),
          ),
        ),
      ),
    ),
    _label('Recommend', 27, 338, 141, 20, weight: FontWeight.w700),
    _panel(24, 361, 349, 100, 20, shadow: true),
    _image(
      'imgRecommendationImage.png',
      267,
      344,
      108,
      117,
      radius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    _image(
      'imgCategoryIcon.png',
      38,
      374,
      44,
      43,
      radius: BorderRadius.circular(10),
    ),
    _svg('imgEllipse240.svg', 232, 374, 26, 26),
    _svg('imgEllipse240.svg', 201, 374, 26, 26),
    _label('한마음 교회', 90, 378, 100, 15, weight: FontWeight.w700),
    _svg('imgRecommendationRating.svg', 89, 396, 80, 16),
    _label(
      '경기도 남양주시 해밀예당 1로 189번길',
      41,
      422,
      192,
      11,
      weight: FontWeight.w500,
      color: _muted,
    ),
    _label(
      '(2394)',
      209,
      422,
      50,
      11,
      weight: FontWeight.w600,
      color: const Color(0x80745d3d),
    ),
    _at(
      24,
      344,
      351,
      117,
      _tap(const SizedBox.expand(), () => _openSeed('p0'), label: '한마음 교회'),
    ),
    _label('Place', 27, 508, 100, 20, weight: FontWeight.w700),
    _seeAll(336, 508),
    _placeCards(),
    _at(
      369,
      571,
      18,
      64,
      _tap(
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xfff6c19b),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Transform.rotate(
              angle: -30.5 * math.pi / 180,
              child: SizedBox(
                width: 10.9067,
                height: 9.43696,
                child: _asset(0, 'imgPolygon3.svg'),
              ),
            ),
          ),
        ),
        () {
          if (_placesScroll.hasClients) {
            _placesScroll.animateTo(
              math.min(
                _placesScroll.offset + 118,
                _placesScroll.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        },
        label: '다음 공간',
      ),
    ),
    _label('Categories', 27, 718, 127, 20, weight: FontWeight.w700),
    _seeAll(
      336,
      722,
      onTap: () => widget.onCategory('전체'),
      key: const ValueKey('all-categories'),
    ),
    for (final category in <(double, double, String)>[
      (26, 40, 'Calm'),
      (125, 139, 'Band'),
      (219, 233, 'Lo-fi'),
      (312, 326, 'Jazz'),
    ]) ...[
      // The exported SVG includes four pixels on each side and eight below.
      _at(
        category.$1 - 4,
        744,
        66,
        56,
        Stack(
          children: [
            _panel(4, 0, 58, 48, 29, shadow: true),
            Positioned.fill(child: _asset(0, 'imgEllipse236.svg')),
          ],
        ),
      ),
      _label(category.$3, category.$2, 769, 40, 14, weight: FontWeight.w700),
      _at(
        category.$1 - 4,
        741,
        66,
        54,
        _tap(
          const SizedBox.expand(),
          () => widget.onCategory(category.$3),
          key: ValueKey('category-${category.$3}'),
          label: category.$3,
        ),
      ),
    ],
  ];

  Widget _placeCards() {
    final extras = widget.store.places
        .where((item) => !RegExp(r'^p[0-3]$').hasMatch('${item['id']}'))
        .toList();
    final count = 3 + extras.length;
    return _at(
      29,
      527,
      350,
      148,
      SingleChildScrollView(
        controller: _placesScroll,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: count * 118.0 - 4,
          height: 148,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < count; i++)
                _at(
                  4 + i * 118.0,
                  4,
                  106,
                  133,
                  i < 3 ? _originalPlace(i) : _extraPlace(extras[i - 3]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _originalPlace(int i) {
    const names = ['호평 주 평화 교회', '해맞이 그린 센터', '이현 교회'];
    const addresses = ['남양주시 호평동 천마산로 1', '경상북도 포항시 환호동', '용인시 기흥구 영덕동'];
    const images = [
      'imgPlaceImage.png',
      'imgPlaceImage1.png',
      'imgCategoryImage.png',
    ];
    const counts = ['(198)', '(54)', '(593)'];
    return _tap(
      Stack(
        clipBehavior: Clip.none,
        children: [
          _panel(0, 0, 106, 133, 10, shadow: true),
          _image(
            images[i],
            0,
            0,
            106,
            80,
            radius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          _label(names[i], 7, 86, 99, 10, weight: FontWeight.w700),
          _label(
            addresses[i],
            7,
            98,
            99,
            8,
            weight: FontWeight.w600,
            color: _muted,
          ),
          _svg('imgRating.svg', 7, 108, 60, 12),
          _label(
            counts[i],
            67,
            109,
            35,
            8,
            weight: FontWeight.w600,
            color: const Color(0x80745d3d),
          ),
          _svg('imgEllipse267.svg', 51, 74, 4, 4),
          _svg('imgEllipse268.svg', 45, 74, 4, 4),
          _svg('imgEllipse269.svg', 57, 74, 4, 4),
        ],
      ),
      () => _openSeed('p${i + 1}'),
      label: names[i],
    );
  }

  Widget _extraPlace(Record item) => _tap(
    Stack(
      children: [
        _panel(0, 0, 106, 133, 10, shadow: true),
        _at(
          0,
          0,
          106,
          80,
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: _recordImage(item, true, 106, 80),
          ),
        ),
        _at(
          7,
          86,
          94,
          37,
          Text(
            '${item['name']}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
      ],
    ),
    () => widget.onOpen(item, true),
  );

  List<Widget> _shows() => [
    _panel(11, 514, 443, 257, 20),
    // Match the Union's exported overflow bounds, including its native shadow.
    _at(
      11,
      266,
      380,
      215,
      CustomPaint(
        painter: const _UnionShadow(),
        child: _asset(1, 'imgUnion.svg'),
      ),
    ),
    _label(
      'Recommend',
      22,
      242,
      180,
      20,
      weight: FontWeight.w700,
      color: Colors.black,
    ),
    for (final tag in <(double, String, String)>[
      (19, '#잔잔한', '잔잔한'),
      (103, '#신나는', '신나는'),
      (187, '#나만 아는', '나만 아는'),
      (271, '#내 주변', '내 주변'),
    ])
      _at(
        tag.$1,
        168,
        77,
        44,
        _tap(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xfffbd7be),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  tag.$2,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffc07c4d),
                  ),
                ),
              ),
            ),
          ),
          () => widget.onCategory(tag.$3),
          key: ValueKey('show-tag-${tag.$3}'),
          label: tag.$2,
        ),
      ),
    _at(
      350,
      168,
      44,
      44,
      _tap(
        Stack(
          children: [
            _at(5, 8, 28, 28, _asset(1, 'imgEllipse260.svg')),
            _at(11.45, 15.43, 14.4387, 13.7709, _asset(1, 'imgVector1.svg')),
          ],
        ),
        widget.onFilters,
        key: const ValueKey('show-filters'),
        label: '공연 필터',
      ),
    ),
    _image(
      'imgFeaturedEventImage.png',
      29,
      296,
      118,
      158,
      radius: BorderRadius.circular(20),
    ),
    _label(
      '술탄 오브 더 디스코',
      173,
      315,
      229,
      24,
      weight: FontWeight.w800,
      color: Colors.black,
    ),
    _label(
      '10/24~10/25',
      173,
      360,
      180,
      16,
      weight: FontWeight.w600,
      color: const Color(0xcc000000),
    ),
    _label(
      'Solo concert',
      173,
      379,
      180,
      15,
      weight: FontWeight.w600,
      color: const Color(0xcc000000),
    ),
    _label(
      '경기도 시흥시 능곡동',
      173,
      395,
      190,
      13,
      weight: FontWeight.w600,
      color: const Color(0x80000000),
    ),
    _svg('imgRating.svg', 173, 425, 120, 24),
    _label(
      '(2120)',
      299,
      427,
      75,
      16,
      weight: FontWeight.w600,
      color: const Color(0x80745d3d),
    ),
    _at(
      15,
      266,
      372,
      207,
      _tap(
        const SizedBox.expand(),
        () => _openSeed('s0'),
        label: '술탄 오브 더 디스코',
      ),
    ),
    _label(
      'Categories',
      24,
      526,
      200,
      20,
      weight: FontWeight.w700,
      color: Colors.black,
    ),
    _seeAll(345, 526),
    _showCards(),
  ];

  Widget _showCards() => _at(
    0,
    550,
    402,
    217,
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 454,
        height: 217,
        child: Stack(
          children: [
            for (int i = 0; i < 3; i++) ...[
              _image(
                [
                  'imgCategoryImage.png',
                  'imgCategoryImage1.png',
                  'imgCategoryImage2.png',
                ][i],
                24 + i * 132.0,
                0,
                118,
                158,
                radius: BorderRadius.circular(20),
              ),
              _label(
                ['Poket Music Fst', 'Oasis concert', 'Indie Band Bond'][i],
                [24.0, 163.0, 291.0][i],
                158,
                160,
                16,
                weight: FontWeight.w600,
                color: Colors.black,
              ),
              _label(
                ['10/3~10/5', '12/12~12/15', '11/24~12/1'][i],
                [24.0, 163.0, 291.0][i],
                i == 2 ? 177 : 175,
                140,
                13,
                weight: FontWeight.w500,
                color: const Color(0xcc000000),
              ),
              _label(
                ['Dragon phony,Han...', 'Oasis', 'Silica Gell'][i],
                [24.0, 163.0, 292.0][i],
                196,
                150,
                13,
                color: const Color(0x80474747),
              ),
              _at(
                24 + i * 132.0,
                0,
                118,
                217,
                _tap(
                  const SizedBox.expand(),
                  () => _openSeed('s${i + 1}'),
                  label: [
                    'Poket Music Fst',
                    'Oasis concert',
                    'Indie Band Bond',
                  ][i],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  List<Record> _results() {
    final query = _normalize(_query.trim());
    return _items.where((item) {
      var text = item.values
          .where((value) => value is String || value is num)
          .join(' ');
      if (!widget.isPlace) {
        for (final place in widget.store.places) {
          if (place['id'] == item['placeId']) {
            text += ' ${place['name']} ${place['address']}';
            break;
          }
        }
      }
      return _normalize(text).contains(query);
    }).toList();
  }

  Widget _recordImage(Record item, bool isPlace, double width, double height) {
    Widget fallback(BuildContext context, Object error, StackTrace? stack) =>
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: math.max(180, width),
            height: math.max(180, height),
            child: CatalogArtwork(
              item: item,
              isPlace: isPlace,
              height: math.max(180, height),
            ),
          ),
        );
    final path = '${item['image'] ?? ''}';
    if (path.startsWith('assets/')) {
      return path.endsWith('.svg')
          ? SvgPicture.asset(path, fit: BoxFit.cover)
          : Image.asset(path, fit: BoxFit.cover, errorBuilder: fallback);
    }
    if (path.isNotEmpty && !kIsWeb) {
      return Image.file(
        File(path.startsWith('file:') ? Uri.parse(path).toFilePath() : path),
        fit: BoxFit.cover,
        errorBuilder: fallback,
      );
    }
    return fallback(context, StateError('Artwork unavailable'), null);
  }

  List<Widget> _searchResults(List<Record> results, double top) => [
    if (results.isEmpty)
      _at(
        21,
        top,
        360,
        90,
        const Center(
          child: Text(
            '검색 결과가 없습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: _ink,
              fontSize: 16,
            ),
          ),
        ),
      ),
    for (int i = 0; i < results.length; i++)
      _at(
        21,
        top + i * 112,
        360,
        100,
        _tap(
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                SizedBox(
                  width: 106,
                  height: 100,
                  child: _recordImage(results[i], widget.isPlace, 106, 100),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${results[i][widget.isPlace ? 'name' : 'title']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            color: _ink,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${results[i][widget.isPlace ? 'address' : 'artists'] ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          () => widget.onOpen(results[i], widget.isPlace),
          key: ValueKey('search-result-${results[i]['id']}'),
        ),
      ),
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final scale = _frameScale(context, constraints.maxWidth);
        final media = MediaQuery.of(context);
        final extraTop = math.max(0.0, media.viewPadding.top - 54 * scale);
        final searching = _query.trim().isNotEmpty;
        final results = searching ? _results() : <Record>[];
        final resultTop = widget.isPlace ? 325.0 : 226.0;
        final fullHeight = searching
            ? math.max(795.0, resultTop + results.length * 112 + 24)
            : 795.0;
        return ColoredBox(
          color: const Color(0xfff8f3f0),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: constraints.maxWidth,
                height: 874 * scale,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xffeb6c12),
                        Color(0xfff8f3f0),
                        Color(0xfff8f3f0),
                      ],
                      stops: [0, .91304, 1],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                key: ValueKey('figma-scroll-$_page'),
                padding: EdgeInsets.only(top: extraTop),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: fullHeight * scale,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 402,
                      height: fullHeight,
                      child: MediaQuery(
                        data: media.copyWith(textScaler: TextScaler.noScaling),
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              width: 402,
                              height: fullHeight,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  if (!searching)
                                    ...widget.isPlace ? _home() : _shows(),
                                  if (searching)
                                    ..._searchResults(results, resultTop),
                                  ..._searchField(),
                                  _toolbar(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// The exported Union's filter is reproduced natively because flutter_svg does
/// not render SVG filter primitives. Its foreground remains the original SVG.
class _UnionShadow extends CustomPainter {
  const _UnionShadow();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(132, 0)
      ..cubicTo(143.046, 0, 152, 8.95431, 152, 20)
      ..lineTo(152, 26.3447)
      ..lineTo(356, 26.3447)
      ..cubicTo(367.046, 26.3447, 376, 35.299, 376, 46.3447)
      ..lineTo(376, 187)
      ..cubicTo(376, 198.046, 367.046, 207, 356, 207)
      ..lineTo(24, 207)
      ..cubicTo(12.9543, 207, 4, 198.046, 4, 187)
      ..lineTo(4, 46.3447)
      ..cubicTo(4, 45.6658, 4.03355, 44.9945, 4.09961, 44.333)
      ..cubicTo(4.03359, 43.6717, 4, 43.0009, 4, 42.3223)
      ..lineTo(4, 20)
      ..cubicTo(4, 8.95431, 12.9543, 0, 24, 0)
      ..close();
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0x40000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(covariant _UnionShadow oldDelegate) => false;
}

class FigmaNavigation extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const FigmaNavigation({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = _frameScale(context, constraints.maxWidth);
      final left = (constraints.maxWidth - 402 * scale) / 2;
      final bottom = MediaQuery.paddingOf(context).bottom;
      final contentHeight = math.max(57 * scale, 79 * scale - bottom);
      return ColoredBox(
        color: const Color(0xff17130f),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: contentHeight,
            child: Stack(
              children: [
                for (int i = 0; i < 3; i++)
                  Positioned(
                    left: left + [34.0, 168.0, 302.0][i] * scale,
                    top: 4 * scale,
                    width: 66 * scale,
                    height: 53 * scale,
                    child: _tap(
                      FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          width: 66,
                          height: 53,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: selected == i
                                  ? const Color(0xff3d2d20)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: Stack(
                              children: [
                                _at(
                                  22,
                                  6,
                                  22,
                                  22,
                                  _asset(
                                    i == 0 && selected != 0 ? 1 : 0,
                                    i == 0
                                        ? 'imgFrame.svg'
                                        : i == 1
                                        ? 'imgFrame1.svg'
                                        : 'imgFrame2.svg',
                                  ),
                                ),
                                if (selected == 1 && i == 1)
                                  _at(
                                    22,
                                    6,
                                    22,
                                    22,
                                    _asset(1, 'imgFrame1.svg'),
                                  ),
                                if (selected == 2 && i == 2)
                                  _at(
                                    22,
                                    6,
                                    22,
                                    22,
                                    ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xffff9a50),
                                        BlendMode.srcIn,
                                      ),
                                      child: _asset(0, 'imgFrame2.svg'),
                                    ),
                                  ),
                                _at(
                                  0,
                                  32,
                                  66,
                                  18,
                                  Text(
                                    ['홈', '공연', '마이'][i],
                                    textAlign: TextAlign.center,
                                    textScaler: TextScaler.noScaling,
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 10,
                                      height: 1.2,
                                      fontWeight: FontWeight.w700,
                                      color: selected == i
                                          ? const Color(0xffff9a50)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      () => onSelected(i),
                      key: ValueKey('tab-${['홈', '공연', '마이'][i]}'),
                      label: ['홈', '공연', '마이'][i],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
