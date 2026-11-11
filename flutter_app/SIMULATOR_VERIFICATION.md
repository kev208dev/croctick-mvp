# 맥북 시뮬레이터 검증

2026-11-12, Asia/Seoul. 제품 코드 기준 b353803, codex/restore-figma-catalog.

## 실행 환경

- Android Emulator, Keeper_Pixel_Tablet_API_35, emulator-5554. 화면이 표시되는 GUI 모드로 실행.
- iPad (A16), iOS Simulator, 8B98886D-C59E-4D17-A1C7-FA4C7764CD88.

## 확인 결과

- 정적 분석에서 No issues found.
- 단위·위젯·화면 회귀 테스트 19개 통과.
- Android에서 integration_test 전체 실행, 시나리오 2개 통과.
- iPad에서 device_smoke_test.dart와 simulator_flow_test.dart 각각 통과.
- 원본 크기 402×874 홈·공연 렌더링 회귀 검사 통과.
- 실제 장소 후보 40개와 연결된 시연 공연 40개의 출처·고정 ID·참조 관계 검사 통과.

탐색 시나리오는 홈 → 후보 공간 검색 → 상세 → 공연 탭 → 검색 결과 없음 → 마이 → 현재 Tick 고정 표시 → 공간 등록의 빈 필드 차단을 확인했다.

등록 시나리오는 홈 메뉴에서 공간 이름·주소·소개·정원·대관료·운영 시간·장비를 입력해 저장하고, 검색으로 등록 공간에 다시 진입했다. 해당 공간에서 공연 제목·소개·출연자·티켓 가격·목표 관객·목표 금액을 입력해 저장했다. 승인 대기와 승인 처리를 확인한 다음, 20,000원 목표 공연에 10,000원으로 참여해 펀딩 50%와 티켓 1장을 확인했다. 참여 전후 Tick은 같았고, Store를 다시 생성해 등록 공간·공연 금액·티켓 저장 내용을 확인했다.

검증용 공간·공연·참여 기록은 테스트 종료 시 원래 저장 데이터로 복구한다. 접근성 검사 핸들은 finally에서 해제한다.

## 실행 명령

```sh
flutter analyze --no-pub
flutter test test --no-pub
flutter test integration_test -d emulator-5554 --no-pub
flutter test integration_test/device_smoke_test.dart -d 8B98886D-C59E-4D17-A1C7-FA4C7764CD88 --no-pub
flutter test integration_test/simulator_flow_test.dart -d 8B98886D-C59E-4D17-A1C7-FA4C7764CD88 --no-pub
python3 ../scripts/build_venue_catalog.py --check
```

## 범위

이번 결과는 맥북의 Android·iOS 시뮬레이터에서 실행한 로컬 시연 기능 검증이다. 사진을 갤러리에서 고르는 네이티브 흐름, 실기기 하드웨어 동작, 서버 다중 사용자와 실결제는 별도 검증 범위다. 저장 확인은 같은 프로세스에서 Store를 다시 생성하는 방식이다.

일반 실행용 APK와 iOS Simulator 앱도 lib/main.dart로 다시 빌드해 설치·실행했다. 직접 Xcode 빌드 시 테스트 임시 진입점이 남아 있으면 Flutter config-only와 FLUTTER_TARGET=lib/main.dart로 일반 실행 진입점을 설정해야 한다.
