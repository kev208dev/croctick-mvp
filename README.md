# CrocTick MVP

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
