# CrocTick API 설계 명세 v1

작성: 2026-11-11. 아직 배포되지 않은 구현 대상 명세. 경로는 `/api/v1` 기준이며 인증 서비스 자체 API는 해당 서비스 계약을 따른다. 최종 구현 시 OpenAPI YAML/Swagger와 contract test를 함께 작성한다.

## 1. 공통 규약

- 인증: `Authorization: Bearer <access_token>`. 서버가 issuer/audience/만료/서명을 검증한다.
- 쓰기 body는 JSON. 금액은 KRW 정수, 수량은 양의 정수, 시간은 offset을 포함한 RFC3339. 응답은 UTC 기준.
- UUID ID, cursor 기반 페이지네이션. 목록 응답 `{data: [], nextCursor: null}`. 상세 응답 `{data: {...}}`.
- 클라이언트에서 전송한 userId/ownerId/틱/가격 합계를 신뢰하지 않는다. 행위자는 토큰에서 정한다.
- 동일 쓰기의 재시도는 `Idempotency-Key` 사용. 주문/승인/취소/환불/정산/지급에 필수. 요청 fingerprint와 결과를 저장.
- 수정은 `version` 또는 `If-Match`로 동시 변경 감지. 버전 불일치 시 409 VERSION_CONFLICT.
- `requestId`를 응답 헤더·오류 본문에 반환. 내부 stack/결제 비밀키는 노출하지 않는다.
- 400 입력 오류, 401 인증 필요, 403 권한 없음, 404 없음, 409 상태·예약·재고 충돌, 422 업무 한도 위반, 429 요청 제한, 503 외부 서비스 확인 지연.

오류 예:
```json
{
  "error": {
    "code": "RESERVATION_CONFLICT",
    "message": "준비 시간을 포함한 예약 구간에 다른 공연이 있습니다.",
    "field": "reservation.startAt",
    "retryable": false,
    "requestId": "request-id"
  }
}
```

권한 표기: 공개 / 로그인 / 본인 / 공연자(해당 공연 소유자) / 제공자(해당 공간 멤버) / 운영자. 단순히 역할을 가진 것만으로 타인의 공간·공연에 접근할 수 없다.

## 2. 계정·프로필·정책

| 메서드·경로 | 권한 | 입력·출력/규칙 | 디자인 |
|---|---|---|---|
| GET /me | 로그인 | 프로필, 역할, 상태, 읽지 않은 알림 수 | H03/P21 |
| PATCH /me | 본인 | 이름·사진 mediaId, version | P01/P21 |
| PUT /me/roles | 본인 | audience/artist/host 활성화; 관리자 부여 불가 | P01 |
| PUT /me/artist-profile | 본인 | 소개·활동 링크·표시명 | P06/P13 |
| GET /policies/current | 공개 | 약관 버전, 펀딩/취소/Tick 정책의 사용자 표시값 | P01/P06/P08/P18 |
| POST /me/consents | 본인 | 문서 ID·버전·동의 시각; 필수/선택 구분 | P01/P08 |
| POST /me/deletion-requests | 본인 | 사유; 진행중 환불·정산 여부 확인 후 접수 | P21 |
| GET /me/deletion-requests/current | 본인 | 접수/보류/완료 | P21 |

로그인·로그아웃·토큰 갱신·복구는 인증 제공자 SDK를 사용한다. 앱에서 access token을 일반 JSON 상태 파일에 저장하지 않는다.

## 3. 이미지 업로드

| 메서드·경로 | 권한 | 입력·출력/규칙 | 디자인 |
|---|---|---|---|
| POST /media/upload-intents | 로그인 | 용도, MIME, byteLength → mediaId, 제한된 signed upload URL, 만료 | P04/P06 |
| POST /media/{id}/complete | 소유자 | 업로드 크기·타입을 서버가 확인, processing/ready | P04/P06 |
| GET /media/{id} | 공개/권한별 | ready 상태, 썸네일/원본 URL, width/height | 카드/상세 |
| DELETE /media/{id} | 소유자 | 사용중 여부 확인; 예약된 참조 삭제 방지 | P04/P06 |

원본 업로드 URL을 공연 레코드에 저장하지 않는다. 레코드는 mediaId를 참조하고 목록·상세가 같은 media/thumbnail 정책을 사용한다. 증빙은 비공개 URL로만 접근한다.

## 4. 공간·가용 시간

| 메서드·경로 | 권한 | 입력·출력/규칙 | 디자인 |
|---|---|---|---|
| GET /venues | 공개 | q, region, startAt/endAt, capacity, equipment, cursor | H01/P02 |
| GET /venues/{id} | 공개/소유자 | 소개·주소·정원·장비·사진·운영조건·게시 상태 | P03 |
| POST /venues | 로그인 host | 기본/시설/운영 정보, draft 생성 | P04 |
| PATCH /venues/{id} | 제공자 | 수정·version; 운영 중 예약 영향 검사 | P04 |
| POST /venues/{id}/submit | 제공자 | 게시 검토 요청, 필수 정보 검증 | P05 |
| GET /venues/{id}/availability | 공개 | from/to → 운영 구간·예약 불가 구간; 타인 예약 개인정보 제외 | P03/P15 |
| PUT /venues/{id}/availability-rules | 제공자 | 요일별 운영시간, timezone, version | P04/P15 |
| POST /venues/{id}/blackouts | 제공자 | 시작/종료·사유; 확정 예약과 충돌 시 거절 | P15 |
| DELETE /venues/{id}/blackouts/{blockId} | 제공자 | 본인 공간의 block만 해제 | P15 |
| GET /me/venues | 본인 | 소유/관리 공간, 검토 상태, 요청 건수 | H03/P15 |
| GET /venues/{id}/reservation-requests | 제공자 | 상태·기간 필터, 개인정보 권한 확인 | P14/P15 |

공간 DTO: name, type, address, addressDetail, coordinates(선택), description, capacity, stageInfo, equipment[{type,quantity,note}], rules, mediaIds, primaryMediaId. 담당자 연락처와 공개 주소는 권한별 응답에서 구분한다.

## 5. 공연·예약 승인

| 메서드·경로 | 권한 | 입력·출력/규칙 | 디자인 |
|---|---|---|---|
| GET /shows | 공개 | q, genre, region, date, fundingStatus, cursor | H02 |
| GET /shows/{id} | 공개/관계자 | 공개 상태만 일반 조회, 비공개 draft는 소유자만 | P07 |
| POST /shows | 공연자 | draft 생성; 공간 ID·포스터·목표·기간 | P06 |
| PATCH /shows/{id} | 공연자 | draft/보완 상태에서 수정. 게시 후 민감 변경 제한 | P06/P13 |
| POST /shows/{id}/reservation-requests | 공연자 | 준비/공연/철수 구간·장비요청 → requestId | P06/P14 |
| POST /reservations/{id}/approve | 제공자 | version; 운영시간·정원·DB 예약 제약 검증 | P14 |
| POST /reservations/{id}/request-revision | 제공자 | 사유·보완 필드 | P14 |
| POST /reservations/{id}/reject | 제공자 | 사유; 거절 후 해당 보유 해제 | P14 |
| POST /reservations/{id}/withdraw | 공연자 | 펀딩 게시 전 요청 철회 | P14 |
| POST /shows/{id}/publish | 공연자 | 유효 승인·목표·가격·등급·마감 검증 | P06/P13 |
| POST /shows/{id}/change-requests | 공연자 | 게시 후 시간/장소 등 변경 요청, version | P13 |
| POST /shows/{id}/cancellation-requests | 공연자/제공자 | 사유; 정책에 따른 자동/운영 승인 여부 반환 | P13/P14 |
| GET /me/shows | 본인 | 상태 필터, 승인·펀딩·정산 요약 | H03/P13 |
| GET /shows/{id}/attendees | 공연자/제공자 | 업무에 필요한 티켓 수·검표 정보, 과도한 개인정보 제외 | P13/P22 |

공연 등록 예:
```json
{
  "title": "금요일 밤 인디 라이브",
  "venueId": "a48531b7-d566-40a4-81b5-b0b034facbbc",
  "description": "공연 소개",
  "genre": "Band",
  "posterMediaId": "a0cd9f4b-a825-47db-a644-14af138048df",
  "startAt": "2026-12-04T19:00:00+09:00",
  "endAt": "2026-12-04T21:00:00+09:00",
  "setupStartsAt": "2026-12-04T18:00:00+09:00",
  "teardownEndsAt": "2026-12-04T21:30:00+09:00",
  "fundingDeadline": "2026-12-01T23:59:00+09:00",
  "ticketPrice": 15000,
  "ticketCapacity": 30,
  "fundingGoal": 450000,
  "equipmentRequest": "마이크 3개 사용"
}
```

필수 서버 검증: 예약 구간의 포함 관계, 미래 시작, 마감<시작, 양수 금액·정원, 공간 정원·Tick 한도, 승인 버전, 목표액≤전체 티켓 판매 가능액(다른 수익이 없다는 MVP 기준). 지역·장르·배분 비율을 클라이언트 임의 문자열로 확정하지 않는다.

## 6. 주문·결제·환불

| 메서드·경로 | 권한 | 입력·출력/규칙 | 디자인 |
|---|---|---|---|
| POST /orders | 로그인 | showId, quantity, policyConsentVersion → 주문번호·서버 총액·보유 만료 | P08 |
| GET /orders/{id} | 구매자/운영자 | 주문·결제·환불 확정 상태 | P09/P10 |
| POST /orders/{id}/confirm-payment | 구매자 | PG 인증 정보; 주문 금액은 DB와 PG 대조 | P09 |
| POST /orders/{id}/cancellations | 구매자 | 취소 사유·대상 ticketIds, 서버 환불액 계산 | P10 |
| GET /orders/{id}/refunds | 구매자/운영자 | 요청/처리/완료/실패, 금액·시각 | P10 |
| GET /me/orders | 본인 | 상태·기간 필터 | P11 |
| POST /webhooks/payments/{provider} | PG 검증 | 외부 provider 서명/검증 방식 사용; 사용자 JWT 아님 | 서버 |
| POST /webhooks/payouts/{provider} | PG 검증 | 지급 이벤트 중복 제거·조회 대조 | 서버 |

주문 POST에는 표시 가격을 최종 금액으로 받지 않는다. PG의 paymentKey 등 provider-specific 필드는 adapter 계층에서 처리한다. 주문 응답에는 서버 계산 금액·통화·만료·정책 버전을 포함한다. 비동기 작업 접수는 202와 조회 URL을 반환한다.

펀딩 미달에 대한 전체 환불은 클라이언트가 반복 호출하는 기능이 아니라 Scheduler → jobs → RefundService 경로로 처리한다. 고객 취소와 공연 취소의 환불 규칙은 다를 수 있다.

## 7. 티켓·검표

| 메서드·경로 | 권한 | 입력·출력/규칙 | 디자인 |
|---|---|---|---|
| GET /me/tickets | 본인 | 예정/대기/지난/환불 상태 | P11 |
| GET /tickets/{id} | 소유자/검표자 | 티켓·공연·주문 요약. 타인 개인정보 제외 | P12 |
| POST /tickets/{id}/entry-tokens | 소유자 | 확정·유효 티켓에 짧은 수명의 입장 token 발급 | P12 |
| POST /shows/{id}/check-ins | 해당 공연 검표자 | entryToken 또는 권한 있는 수동 조회; 원자적 1회 사용 | P22 |
| GET /shows/{id}/check-ins | 검표자/공연자 | 입장 수·이력 | P13/P22 |

QR은 서명된 식별자일 뿐 결제 증거로 신뢰하지 않는다. 검표 시 서버에서 공연/취소/사용 이력을 확인한다. 스캔 재시도는 같은 성공 결과를 반환하고 새 입장으로 누적하지 않는다.

## 8. 완료·평가·Tick·정산

| 메서드·경로 | 권한 | 입력·출력/규칙 | 디자인 |
|---|---|---|---|
| POST /shows/{id}/completion-confirmations | 해당 공연자/제공자 | 완료 여부·사유·증빙; 종료 시각과 이력 확인 | P16 |
| POST /shows/{id}/reviews | 유효 관객/제공자 | 별점·항목·내용, 평가자별 중복 제한, 자가평가 금지 | P16 |
| GET /shows/{id}/reviews | 공개/관계자 | 공개 정책에 맞는 요약·목록, 신고 내용 제외 | P03/P07/P16 |
| GET /me/tick | 본인 | 잔액, 레벨, 다음 레벨, 정책 버전 | H03/P18 |
| GET /me/tick-ledger | 본인 | 공연/사유/점수/정정 원장 | P18 |
| GET /tick/tiers | 공개 | 서버 등급·가격/관객 한도·설명 | P18 |
| GET /me/settlements | 수취인 | 금전 정산 목록; Tick과 별도 | P17 |
| GET /settlements/{id} | 해당 수취인/운영자 | 기준액·정책 snapshot·배분·보류·지급 상태 | P17 |
| POST /me/payout-onboarding | 수취인 | PG 수취인 등록 연결/상태. 민감 필드 최소화 | P19 |
| GET /me/payout-account | 본인 | 마스킹 정보·검증 상태 | P19 |
| GET /me/payouts | 본인 | 지급 예정/처리/완료/실패 | P17/P19 |

고객 앱용 POST /tick/add 또는 POST /settlements/{id}/paid는 만들지 않는다. Tick 정산은 완료·유효평가·정책을 확인한 워커가 수행한다. 수익 원장 확정과 지급은 관리자 승인 또는 검증된 지급 이벤트로만 전이한다.

## 9. 알림·신고·운영 API

| 메서드·경로 | 권한 | 입력·출력/규칙 | 디자인 |
|---|---|---|---|
| GET /me/notifications | 본인 | 읽음·유형 필터, 안전한 목적지 식별자 | P20 |
| POST /me/notifications/{id}/read | 본인 | 읽음 처리; 반복 호출 안전 | P20 |
| PUT /me/device-tokens/{deviceId} | 본인 | 플랫폼·push token·동의; 기기 교체 처리 | P20/P21 |
| DELETE /me/device-tokens/{deviceId} | 본인 | 로그아웃 기기의 토큰 제거 | P21 |
| POST /reports | 로그인 | 대상 종류/ID/사유·증빙 | 상세/P16 |
| GET /admin/reviews | 운영자 | 공간 검토/신고 작업함 | A01 |
| POST /admin/venues/{id}/decisions | 운영자 | 승인/보완/반려 + 사유 | A01 |
| POST /admin/reports/{id}/decisions | 운영자 | 분쟁 결과·정산 보류/해제 연계 | A01 |
| GET /admin/payments/reconciliation | 결제 운영자 | PG-DB 불일치 목록 | A02 |
| POST /admin/refunds/{id}/retry | 결제 운영자 | 기존 PG 요청 조회 후 재시도 작업 생성 | A02 |
| POST /admin/settlements/{id}/approve | 정산 운영자 | 기준액·버전 확인 후 지급 승인 | A02 |
| POST /admin/settlements/{id}/hold | 정산 운영자 | 사유·보류 | A02 |
| POST /admin/payouts/{id}/retry | 정산 운영자 | 기존 지급 조회 후 재시도 | A02 |
| POST /admin/tick-adjustments | 권한 운영자 | 대상·공연·조정점수·사유, 반대 원장 | A03 |
| GET /admin/audit-logs | 감사 권한 | actor/대상/기간 검색 | A03 |

관리자 권한은 역할 범위를 분리하고 모든 민감 작업을 감사 기록한다. 클라이언트에서 admin=true를 보내 승격할 수 없다.

## 10. 백그라운드 작업 (공개 API 아님)

| 작업 | 수행 내용·재시도 기준 |
|---|---|
| expire_reservations | 만료된 승인 보유 해제, 재승인·새 승인 경합 안전성 확인 |
| expire_inventory_holds | 미결제 주문 재고 반환, PG 확인 중 주문은 조회 후 처리 |
| close_funding | 마감 스냅샷·진행중 결제 정리 후 성공/미달 확정 |
| refund_cancelled_show | 취소 공연 주문별 취소 요청 생성; 완료 전후 주문 중복 환불 차단 |
| reconcile_payments | PG 성공/DB 미반영, 응답 유실·지연 이벤트 대조 |
| finalize_reviews_and_tick | 완료/평가 마감/분쟁 정책 확인 후 Tick 1회 원장 생성 |
| build_settlements | 환불·분쟁 정리된 대상액과 정책 snapshot으로 배분 원장 생성 |
| execute_payouts | 승인된 지급 요청, 결과 불확실 시 조회하고 수렴 |
| send_notifications | 수신자/내용/목적지별 이벤트 중복 제거, 실패 재시도 |

모든 jobs는 시도 횟수·다음 실행 시각·고유 업무키를 갖는다. 지수 백오프와 최대 시도 후 운영자 확인 상태를 둔다. 앱이 종료되어도 마감·환불은 서버가 실행한다.

## 11. 외부 API 최소 목록

- 필수: 인증 SDK/API, PG 결제 승인/조회/취소/webhook, 이미지 signed upload/조회, 푸시(FCM/APNs).
- 지급 자동화 단계: PG 수취인 등록·검증/지급/조회/지급 webhook. 결제 승인만 연동했다고 수익 지급까지 되는 것은 아니다.
- 선택: 주소 검색·지도/좌표 변환, 거래성 이메일/SMS, 신원·사업자 확인(지급 제공자가 대체 가능).
- 불필요한 초기 구성: AI API, 별도 검색엔진, 대규모 메시지 브로커, 실시간 채팅 서버. 필요성이 검증되면 추가.

PG 후보 예시는 Toss Payments이며 실제 계약 가능 여부와 필요한 지급 기능은 별도 확인한다. 승인·웹훅 중복과 멱등키 설계는 공식 보안/API 문서를 따른다.
- https://docs.tosspayments.com/reference
- https://docs.tosspayments.com/reference/using-api/security-trust
- https://docs.tosspayments.com/guides/v2/payouts
