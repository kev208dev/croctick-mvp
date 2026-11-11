# CrocTick Flutter

공통 소스: lib/main.dart(화면), lib/store.dart(상태·정산·저장).

```
flutter pub get
flutter analyze
flutter test
flutter run -d R54X104CWVE
flutter build apk --debug
```

현재 macOS/Xcode에서 범용 시뮬레이터 아키텍처 전달 문제가 있을 경우:

```
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO build
```

iOS 실기기는 Xcode에서 Runner의 개발 팀을 선택한 뒤 flutter run을 사용한다.
사진 선택 권한 설명은 ios/Runner/Info.plist에 포함한다.

패키지 ID com.croctick.croctick. 기존 SwiftUI/Capacitor 앱과 별도로 설치하여 데이터 보존.
기존 앱의 데이터는 자동 이관하지 않으며 공통 앱은 시연 공간/공연으로 시작한다.
설정에서 로컬 입력 자료를 초기화할 수 있다. 실제 결제와 서버 동기화는 아직 연결되지 않았다.
