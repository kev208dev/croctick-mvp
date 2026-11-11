import 'package:croctick/main.dart';
import 'package:croctick/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('402×874 Figma 원본 크기 홈·공연 렌더링', (tester) async {
    final oldShadowSetting = debugDisableShadows;
    debugDisableShadows = false;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    tester.view.padding = FakeViewPadding(top: 54, bottom: 18);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    final font = FontLoader('Pretendard');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      font.addFont(rootBundle.load('assets/fonts/Pretendard-$weight.otf'));
    }
    await font.load();
    SharedPreferences.setMockInitialValues({});
    final store = Store(await SharedPreferences.getInstance());
    await tester.pumpWidget(CrocApp(store: store));
    await tester.runAsync(() async {
      final context = tester.element(find.byType(Scaffold).first);
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final path in manifest.listAssets().where(
        (path) => path.startsWith('assets/figma/') && path.endsWith('.png'),
      )) {
        await precacheImage(AssetImage(path), context);
      }
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrocApp),
      matchesGoldenFile('goldens/home-402.png'),
    );
    await tester.tap(find.byKey(const ValueKey('tab-공연')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrocApp),
      matchesGoldenFile('goldens/shows-402.png'),
    );
    debugDisableShadows = oldShadowSetting;
  });
}
