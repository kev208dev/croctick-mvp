# CrocTick MVP

## Flutter 통합판 (현재 개발 기준)

설계 문서:
- `DESIGN_REQUIREMENTS.md`: 화면별 디자인 요구서·Figma 납품 기준
- `SYSTEM_ARCHITECTURE.md`: 서버 구성·데이터 모델·예약/결제/정산 구조도
- `API_SPEC.md`: 내부/외부 API·권한·오류·백그라운드 작업 명세
- `DEVELOPMENT_ROADMAP.md`: 미완성 기능·개발 순서·검증 기준·미확정 정책

Android와 iOS 공통 앱은 `flutter_app/`입니다. 기존 React·SwiftUI 코드는 참고용으로 보존합니다.
`FLUTTER_PLAN.md`에 기능 차이, 미완성 항목, 확정된 사업 정책, 추가 디자인 요청과 후속 작업 순서를 정리했습니다.

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter run
```

플랫폼별 빌드 안내는 `flutter_app/RUNBOOK.md`를 참고하세요. 현재 로컬 시연 MVP이며 실제 결제·송금과 다중 사용자 서버는 연결되지 않았습니다.

유휴 공간과 인디 뮤지션을 연결하고, 관객의 사전 티켓 펀딩으로 공연을 확정하는 CrocTick의 모바일 웹 MVP입니다.

## Run

```bash
npm install
npm run dev
```

홈·공연·마이 3개 탭, 공간/공연 탐색, 공연 상세, 티켓 펀딩 참여, 공연 등록 플로우를 데모 데이터와 로컬 상태로 제공합니다.

## iPhone SwiftUI app

`ios/CrocTick.xcodeproj`를 Xcode로 열고 iPhone Simulator 또는 연결된 iPhone을 선택한 뒤 Run 하면 됩니다.

CLI 빌드 확인:

```bash
cd ios
xcodegen generate
xcodebuild -project CrocTick.xcodeproj -scheme CrocTick -configuration Debug \
  -destination 'platform=iOS Simulator,id=B65AE5FC-7B67-4276-8B13-A39D1655CB97' \
  CODE_SIGNING_ALLOWED=NO build
```

SwiftUI 화면은 Figma의 홈·공연·마이 프레임(각 402×874)을 기준으로 구성되어 있습니다.
