# today-lunch 구현 설계서 (MVP 기준)

## 1. 추천 스택 요약

| 영역 | 선택 |
|---|---|
| 모노레포 관리 도구 | `melos` + Dart pub workspace |
| Flutter 앱 구조 방식 | `feature-first` + feature 내부 `presentation/application/domain/data` |
| 백엔드 프레임워크 | Dart `shelf` + `shelf_router` (초기에는 단순 HTTP 핸들러로 시작) |
| 데이터베이스 | MVP: 서버 DB 없음, 로컬 저장만 사용 (`shared_preferences`) |
| 상태관리 | `flutter_riverpod` |
| 네트워크 계층 | `dio` + 얇은 API client 래퍼 |
| 로깅/분석/에러 추적 | `logger`(기본), `sentry_flutter`(선택, env로 on/off) |
| 테스트 도구 | `flutter_test`, `integration_test`, `mocktail`, `dart test` |
| CI/CD 방향 | GitHub Actions (lint/test/build), 이후 태그 기반 배포 파이프라인 확장 |

## 2. 왜 이 스택이 today-lunch에 최적인지

1. Flutter와 잘 맞음
- `melos`는 Flutter/Dart 모노레포 표준 조합에 가깝다.
- 앱/공유패키지/서버가 모두 Dart 기반이라 타입과 모델 공유가 쉽다.

2. 모노레포에 적합함
- `apps/`, `packages/`, `server/`를 단일 워크스페이스에서 관리한다.
- 공통 DTO(`packages/shared_models`)를 앱과 서버가 함께 사용해 중복을 줄인다.

3. AI가 다루기 쉬움
- feature 경계가 분명하고 파일 책임이 명확하다.
- 레이어를 과도하게 분리하지 않고, feature 내부에서 필요한 만큼만 분리한다.
- 작은 파일 단위로 수정 가능하므로 Claude/Codex가 안전하게 패치하기 좋다.

4. Kent Beck 스타일 개발에 유리함
- MVP는 DB 없이 시작해 YAGNI를 지킨다.
- endpoint 1개, 화면 1개 단위의 vertical slice로 빠르게 통과시킬 수 있다.
- 테스트를 먼저 쓰고 구현하는 작은 루프에 맞는다.

## 3. 전체 모노레포 구조

```text
today-lunch/
├─ apps/
│  └─ mobile/
│     ├─ .env.example
│     ├─ pubspec.yaml
│     ├─ lib/
│     │  ├─ main.dart
│     │  └─ src/
│     │     ├─ core/
│     │     │  ├─ error/
│     │     │  ├─ network/
│     │     │  ├─ routing/
│     │     │  ├─ theme/
│     │     │  └─ widgets/
│     │     └─ features/
│     │        ├─ location/
│     │        │  ├─ application/
│     │        │  ├─ data/
│     │        │  ├─ domain/
│     │        │  └─ presentation/
│     │        ├─ recommendation/
│     │        │  ├─ application/
│     │        │  ├─ data/
│     │        │  ├─ domain/
│     │        │  └─ presentation/
│     │        └─ settings/
│     │           ├─ application/
│     │           ├─ data/
│     │           ├─ domain/
│     │           └─ presentation/
│     ├─ test/
│     │  ├─ application/
│     │  ├─ unit/
│     │  └─ widget/
│     └─ integration_test/
├─ packages/
│  ├─ shared_models/
│  │  ├─ pubspec.yaml
│  │  ├─ lib/
│  │  │  ├─ shared_models.dart
│  │  │  └─ src/
│  │  └─ test/
│  └─ shared_utils/
│     ├─ pubspec.yaml
│     ├─ lib/
│     │  ├─ shared_utils.dart
│     │  └─ src/
│     └─ test/
├─ server/
│  └─ api/
│     ├─ .env.example
│     ├─ pubspec.yaml
│     ├─ bin/
│     │  └─ server.dart
│     ├─ lib/src/
│     │  ├─ core/
│     │  └─ features/
│     │     ├─ health/
│     │     ├─ places/
│     │     └─ recommendation/
│     └─ test/
│        ├─ integration/
│        └─ unit/
├─ docs/
│  ├─ architecture/
│  ├─ contracts/
│  ├─ runbook/
│  └─ README.draft.md
├─ scripts/
├─ infra/
│  ├─ docker/
│  └─ github/workflows/
├─ pubspec.yaml
├─ .gitignore
└─ readme.md
```

### 디렉토리 책임

- `apps/mobile`: Flutter 앱 실행 코드와 UI/기능 코드.
- `packages/shared_models`: 앱/서버 공통 DTO, 값 객체.
- `packages/shared_utils`: 공통 유틸(카테고리 정규화 등).
- `server/api`: 장소 조회/추천 API.
- `docs`: 아키텍처, API 계약, 운영 문서.
- `scripts`: 로컬 자동화 스크립트(bootstrap, format, release-helper).
- `infra`: CI/CD, Docker, 배포 템플릿.

### 구조 판단

- 앱은 `feature-first`를 선택한다.
- 단, feature 내부에서는 `presentation/application/domain/data`를 유지해 테스트 경계를 명확히 한다.
- 이유: 화면/기능 단위 작업이 많고, 1인 개발 + AI 수정 흐름에서 feature 단위가 변경 영향 파악이 가장 쉽다.

## 4. MVP 범위

### 4.1 MVP 포함
- 현재 위치 또는 회사 위치 저장/선택
- 주변 음식점 조회
- 랜덤 추천 1건
- 최소 필터: 거리(`radiusMeters`), 카테고리(`category`)
- 최근 추천 제외(최근 N개 placeId 제외)
- 외부 지도 앱 열기(좌표/이름 전달)

### 4.2 MVP 제외
- 회원가입/로그인
- 클라우드 즐겨찾기 동기화
- 추천 히스토리 서버 영구 저장
- 팀 투표/협업 기능
- AI 텍스트 추천 사유 생성

### 4.3 출시 후 2차 기능
- 즐겨찾기(로컬 -> 서버 동기화)
- 최근 본 음식점 목록
- 추천 히스토리(기기별/유저별)
- 팀 점심 투표
- 개인화 추천(시간대, 선호 카테고리 학습)

### 4.4 이렇게 나눈 이유
- MVP는 “오늘 점심 추천” 핵심 루프만 완성하면 가치가 즉시 발생한다.
- 로그인/동기화는 확장 가치가 있지만 출시 지연 요인이므로 2차로 분리한다.
- Kent Beck 원칙상 “지금 필요한 기능”만 만든다.

## 5. Kent Beck 스타일 개발 순서

각 단계는 “실행 가능 + 테스트 가능 + 즉시 배포 가능 상태”를 목표로 한다.

### Step 0. 모노레포 부트스트랩
- 목표: 기본 폴더/패키지/스크립트 구성 완료
- 완료 조건: `dart run melos run test` 명령이 최소 smoke test를 통과
- 테스트: 각 패키지 smoke test
- 리팩토링 포인트: 공통 스크립트 이름 정리

### Step 1. 서버 health check
- 목표: `GET /health` 구현
- 완료 조건: `{status:"ok"}` 반환
- 테스트: `server/api/test/unit/health_test.dart`
- 리팩토링 포인트: 공통 에러 응답 포맷 파일 분리

### Step 2. 앱 더미 추천 UI
- 목표: 버튼 클릭 -> 더미 추천 카드 표시
- 완료 조건: 앱 내에서 추천 결과 텍스트 렌더링
- 테스트: widget test (버튼 탭 후 카드 표시)
- 리팩토링 포인트: 뷰 모델 분리 여부 판단

### Step 3. 앱-서버 health 연결
- 목표: 앱에서 서버 health 호출
- 완료 조건: 연결 성공/실패 상태를 UI에 표시
- 테스트: API client 단위 테스트 + widget test(성공/실패)
- 리팩토링 포인트: API client 인터페이스 추출

### Step 4. 위치 선택(현재/회사) + 로컬 저장
- 목표: 위치 모드 전환 및 회사 위치 저장
- 완료 조건: 앱 재시작 후 마지막 선택 유지
- 테스트: application/service test, shared_preferences mock
- 리팩토링 포인트: `LocationPreferenceRepository` 추상화

### Step 5. 주변 음식점 조회 API(더미 Provider)
- 목표: `GET /v1/places/nearby` 구현(초기 더미 데이터)
- 완료 조건: 필터 반영된 목록 반환
- 테스트: endpoint validation + 응답 구조 테스트
- 리팩토링 포인트: Provider 인터페이스 도입

### Step 6. 앱 주변 목록 연동
- 목표: 앱에서 실제 목록 조회/표시
- 완료 조건: 로딩/성공/에러 상태 처리
- 테스트: repository test(HTTP mock), widget test
- 리팩토링 포인트: 에러 메시지 매핑 통합

### Step 7. 추천 1건 뽑기 + 최근 제외
- 목표: `POST /v1/recommendations/pick` 구현
- 완료 조건: 제외 목록 반영해서 1건 반환
- 테스트: domain test(랜덤 선택 규칙), endpoint test
- 리팩토링 포인트: 난수 선택 로직 함수 추출

### Step 8. 앱 추천 결과 화면 + 다시 추천
- 목표: 추천 결과 카드, 다시 추천 버튼 구현
- 완료 조건: 직전 추천 placeId가 제외 목록에 추가됨
- 테스트: application/service test(제외 목록 갱신), widget test
- 리팩토링 포인트: 결과 상태 모델 단순화

### Step 9. 필터(거리/카테고리) 반영
- 목표: 필터 UI + 조회/추천에 동일 적용
- 완료 조건: 필터 변경 시 결과가 즉시 달라짐
- 테스트: filter domain unit test + integration test
- 리팩토링 포인트: 필터 DTO를 shared_models로 승격

### Step 10. 외부 지도 앱 열기
- 목표: 추천 결과에서 지도 앱 이동
- 완료 조건: iOS/Android 딥링크 호출 성공
- 테스트: URL 빌더 unit test, widget intent test
- 리팩토링 포인트: MapLauncher 어댑터 분리

### Step 11. 실제 장소 Provider 연결
- 목표: 더미 Provider -> 실제 API(Kakao/Google 등) 교체
- 완료 조건: 실제 위치 기반 결과 확인
- 테스트: provider contract test, 통합 smoke test
- 리팩토링 포인트: provider별 응답 매핑 공통화

## 6. 도메인 모델 설계

### 6.1 `Place` (공유 모델)
- 위치: `packages/shared_models/lib/src/place.dart`
- 필드
  - `id: String`
  - `name: String`
  - `category: String`
  - `latitude: double`
  - `longitude: double`
  - `distanceMeters: int`
  - `address: String?`
- 책임: 조회/추천의 기본 대상 엔티티
- 테스트 포인트
  - 필수 필드 누락 방지
  - 거리/좌표 값 범위 검증

### 6.2 `NearbySearchCriteria` (공유 모델)
- 위치: `packages/shared_models/lib/src/nearby_search_criteria.dart`
- 필드
  - `latitude: double`
  - `longitude: double`
  - `radiusMeters: int`
  - `category: String?`
- 책임: 조회/추천 요청 조건 표현
- 테스트 포인트: 반경 최소/최대, 좌표 범위

### 6.3 `Recommendation` (공유 모델)
- 위치: `packages/shared_models/lib/src/recommendation.dart`
- 필드
  - `place: Place`
  - `reason: String`
  - `generatedAt: DateTime`
- 책임: 추천 결과 전달
- 테스트 포인트: `place` null 불가, timestamp 생성 정책

### 6.4 `OfficeLocation` (공유 모델)
- 위치: `packages/shared_models/lib/src/office_location.dart`
- 필드
  - `name: String`
  - `latitude: double`
  - `longitude: double`
- 책임: 회사 기준 위치 저장
- 테스트 포인트: 이름 trim/좌표 검증

### 6.5 `UserPreferences` (앱 전용)
- 위치: `apps/mobile/lib/src/features/settings/domain/user_preferences.dart`
- 필드
  - `locationMode: enum(current, office)`
  - `radiusMeters: int`
  - `category: String?`
- 책임: 사용자 필터/모드 관리
- 테스트 포인트: 기본값, 직렬화/역직렬화

### 6.6 `RecommendationHistory` (앱 전용, MVP는 로컬)
- 위치: `apps/mobile/lib/src/features/recommendation/domain/recommendation_history.dart`
- 필드
  - `recentPlaceIds: List<String>` (최대 N개, 예: 5)
- 책임: 최근 추천 제외 목록
- 테스트 포인트: 최대 길이 유지, 중복 제거

### 6.7 `PlaceProviderItem` (서버 전용)
- 위치: `server/api/lib/src/features/places/place_provider_item.dart`
- 필드
  - `externalId: String`
  - `name: String`
  - `lat: double`
  - `lng: double`
  - `category: String`
- 책임: 외부 장소 API 응답을 내부 `Place`로 변환하기 전 중간 모델
- 테스트 포인트: provider 응답 매핑 정확성

## 7. API 설계

### 공통 규칙
- Base path: `/v1`
- 인증: MVP에서는 미사용(`Authorization` 선택)
- 디바이스 식별: 선택 헤더 `X-Device-Id`
- 에러 응답 포맷
```json
{
  "error": {
    "code": "INVALID_ARGUMENT",
    "message": "radius_meters must be between 100 and 3000"
  }
}
```

### 7.1 Health Check
- Endpoint: `GET /health`
- Request: 없음
- Response
```json
{
  "status": "ok",
  "version": "0.1.0"
}
```
- Validation: 없음
- 인증: 불필요
- 테스트
  - 200 응답 여부
  - json shape 검증

### 7.2 주변 음식점 조회
- Endpoint: `GET /v1/places/nearby`
- Query
  - `lat` (required)
  - `lng` (required)
  - `radius_meters` (optional, default: 700)
  - `category` (optional)
  - `limit` (optional, default: 20)
- Response
```json
{
  "items": [
    {
      "id": "plc_123",
      "name": "백반집",
      "category": "korean",
      "latitude": 37.5,
      "longitude": 127.0,
      "distanceMeters": 230,
      "address": "서울 ..."
    }
  ]
}
```
- Validation
  - lat: -90~90
  - lng: -180~180
  - radius: 100~3000
  - limit: 1~50
- 인증: 불필요
- 에러 처리
  - 400: 파라미터 오류
  - 502: 외부 장소 API 실패
- 테스트
  - validation 실패 케이스
  - 정상 목록 반환
  - provider 장애 fallback

### 7.3 추천 1건 선택
- Endpoint: `POST /v1/recommendations/pick`
- Request
```json
{
  "criteria": {
    "latitude": 37.5,
    "longitude": 127.0,
    "radiusMeters": 700,
    "category": "korean"
  },
  "excludePlaceIds": ["plc_111", "plc_222"]
}
```
- Response
```json
{
  "recommendationId": "rec_20260306_001",
  "generatedAt": "2026-03-06T12:00:00Z",
  "place": {
    "id": "plc_333",
    "name": "국수집",
    "category": "korean",
    "latitude": 37.5,
    "longitude": 127.0,
    "distanceMeters": 190,
    "address": "서울 ..."
  },
  "map": {
    "latitude": 37.5,
    "longitude": 127.0,
    "label": "국수집"
  }
}
```
- Validation
  - `excludePlaceIds` 최대 20개
  - 후보가 0개면 `NO_CANDIDATE_PLACE` 반환
- 인증: 불필요
- 에러 처리
  - 400: invalid payload
  - 404: 후보 없음
  - 500: 내부 오류
- 테스트
  - 제외 목록 반영 검증
  - 후보 1개/다수 케이스
  - 후보 없음 에러 케이스

### 7.4 로그인 확장 여지
- 현재는 익명 호출 허용
- 추후 `Authorization: Bearer` 추가 시
  - 동일 endpoint 유지
  - 내부에서 `deviceId -> userId` 매핑만 추가

## 8. 데이터 저장 전략

### 8.1 MVP에서 로컬 저장 (앱)
- 회사 위치(`OfficeLocation`)
- 위치 모드(current/office)
- 필터 설정(radius/category)
- 최근 추천 제외 목록(recent placeIds)
- 익명 디바이스 ID(UUID)

저장 위치:
- `apps/mobile/lib/src/features/*/data/local/*`
- 저장 매체: `shared_preferences` (간단 key-value)

### 8.2 MVP에서 서버 저장하지 않음
- 추천 히스토리 영구 저장
- 사용자 계정/프로필
- 즐겨찾기

이유:
- 핵심 가치 검증 전 DB 도입은 과설계다.
- 운영 복잡도(마이그레이션/백업/보안) 증가를 피한다.

### 8.3 이후 서버 저장 전환 후보
- 추천 이벤트 로그
- 즐겨찾기
- 사용자별 필터 프리셋

### 8.4 DB 필요성 판단
- 결론: MVP에는 서버 DB 불필요
- 단, 2차 기능에서 필요해지면 PostgreSQL 도입

#### PostgreSQL 초안 스키마(2차)
- `recommendation_events(id, device_id, place_id, created_at)`
- `saved_places(id, user_or_device_id, place_id, created_at)`
- `user_preferences(id, user_or_device_id, radius, category, updated_at)`

## 9. Flutter 앱 구조

### 9.1 구조 선택
- 선택: `feature-first`
- feature 내부에 최소 4계층 적용
  - `presentation`: 화면, 위젯, 컨트롤러
  - `application`: 유스케이스/서비스
  - `domain`: 엔티티, 규칙
  - `data`: repository 구현, local/remote datasource

### 9.2 라우트 구조
- `/` : 홈(추천 진입)
- `/result` : 추천 결과
- `/settings/location` : 회사 위치/위치 모드 설정
- `/settings/filter` : 거리/카테고리 필터

### 9.3 상태관리
- `flutter_riverpod`
- 원칙
  - 위젯은 provider 상태만 소비
  - 비즈니스 규칙은 `application`에 위치
  - 로컬 저장/네트워크는 repository로 캡슐화

### 9.4 Repository 패턴
- 적용함 (단순화된 형태)
- 인터페이스 예시
  - `RecommendationRepository`
  - `LocationRepository`
- 이점: 테스트에서 fake/mock 대체가 쉽다.

### 9.5 API client 구조
- `apps/mobile/lib/src/core/network/api_client.dart`
- 공통 처리
  - base URL/env
  - timeout
  - 공통 에러 파싱

### 9.6 공통 widget 위치
- `apps/mobile/lib/src/core/widgets`
  - `app_button.dart`
  - `error_state_view.dart`
  - `loading_view.dart`

### 9.7 디자인 시스템 확장 전략
- 처음에는 최소 토큰만 유지
  - color, spacing, text style
- 추후 컴포넌트 확장 시 `core/theme`에서만 변경
- feature 폴더는 디자인 토큰을 직접 정의하지 않는다.

### 9.8 질문에 대한 답

왜 AI가 수정하기 쉬운가?
- 기능별 디렉토리와 레이어 역할이 명확해서 수정 범위를 좁히기 쉽다.

왜 작은 단계 TDD에 적합한가?
- application/domain 경계가 분명해 단위 테스트 작성 지점이 명확하다.

처음부터 만들 것 vs 나중에 추가할 것
- 처음부터: 추천 핵심 flow, 위치/필터/제외 목록
- 나중에: 로그인, 즐겨찾기 동기화, 분석 대시보드, 고급 디자인 시스템

## 10. 테스트 전략

### 10.1 domain unit test
- 대상: 추천 제외 규칙, 필터 검증, 모델 불변성
- mock: 없음
- 우선순위: 가장 먼저 작성

예시 파일:
- `apps/mobile/test/unit/recommendation_policy_test.dart`
- `packages/shared_models/test/nearby_search_criteria_test.dart`

### 10.2 application/service test
- 대상: 유스케이스(추천 요청, 위치 모드 전환, 필터 적용)
- mock: repository interface mock/mocktail
- 우선순위: domain 다음

예시 파일:
- `apps/mobile/test/application/request_recommendation_use_case_test.dart`

### 10.3 repository test
- 대상: remote/local datasource 결합 로직
- mock: HTTP client fake server, local storage fake
- 실제 연결: contract 수준에서만 로컬 test server 허용

예시 파일:
- `apps/mobile/test/unit/recommendation_repository_test.dart`
- `server/api/test/integration/recommendation_endpoint_test.dart`

### 10.4 widget test
- 대상: 버튼 클릭, 로딩/에러/성공 렌더링, 필터 입력 반영
- mock: provider override
- 우선순위: vertical slice UI 완료 직전

예시 파일:
- `apps/mobile/test/widget/home_page_test.dart`
- `apps/mobile/test/widget/recommendation_result_page_test.dart`

### 10.5 integration test
- 대상: 앱 시작 -> 위치 선택 -> 추천 받기 -> 지도 열기 직전까지
- mock: 초기에는 fake API, 이후 staging API smoke
- 우선순위: 각 Epic 종료 시 최소 1개

예시 파일:
- `apps/mobile/integration_test/mvp_flow_test.dart`

### 테스트 루프 원칙
- red(실패 테스트) -> green(최소 구현) -> refactor(중복 제거)
- 테스트 때문에 구조가 복잡해지면 즉시 단순화 리팩토링

## 11. 개발 이슈 분해 (Epic / Story / Task)

### Epic A: MVP bootstrap

Story A1: Monorepo setup
- Task: 루트 `pubspec.yaml` workspace 설정
- Task: `apps/mobile`, `packages`, `server/api` 생성
- Task: `.env.example` 파일 추가
- Task: CI 기본 워크플로우 추가

Story A2: Shared package setup
- Task: `shared_models` 패키지 생성
- Task: `Place`, `Recommendation`, `OfficeLocation` 모델 추가
- Task: shared_models 테스트 추가

### Epic B: Core recommendation flow

Story B1: API 최소 동작
- Task: `GET /health` 구현 + 테스트
- Task: `GET /v1/places/nearby` 더미 응답 구현
- Task: `POST /v1/recommendations/pick` 구현

Story B2: App 추천 기본 흐름
- Task: 홈 화면 버튼 + 결과 카드
- Task: API client 연결
- Task: 추천 결과 화면 라우팅

Story B3: 제외 목록/필터
- Task: 최근 추천 placeId 로컬 저장
- Task: 제외 목록 포함해 추천 호출
- Task: 거리/카테고리 필터 UI + 적용

### Epic C: Location and map

Story C1: 위치 처리
- Task: 현재 위치 가져오기
- Task: 회사 위치 저장/불러오기
- Task: current/office 모드 토글

Story C2: 외부 지도 연결
- Task: 지도 딥링크 URL 빌더 구현
- Task: 추천 결과에서 지도 열기 버튼 연결
- Task: 플랫폼별 동작 테스트

### Epic D: Stabilization

Story D1: 품질/문서
- Task: widget/integration 테스트 보강
- Task: API 계약 문서(`docs/contracts`) 작성
- Task: README 보강

## 12. 브랜치/커밋 규칙

### 브랜치 규칙
- 형식: `feature/#이슈번호-페이지-기능명`
- 예시
  - `feature/12-home-random-recommend`
  - `feature/18-settings-office-location`
  - `feature/24-result-open-map`
  - `feature/31-api-nearby-filter`

### 커밋 컨벤션
- `:sparkles: feat: ...`
- `:bug: fix: ...`
- `:memo: docs: ...`
- `:recycle: refactor: ...`

실사용 예시
- `:sparkles: feat: add nearby places endpoint with radius filter`
- `:sparkles: feat: show random recommendation card on home page`
- `:bug: fix: prevent duplicate place ids in exclusion history`
- `:memo: docs: add api contract for recommendation pick`
- `:recycle: refactor: extract map launcher adapter from result page`

## 13. README 초안

아래 내용은 `docs/README.draft.md`로도 분리해 두었다.

README 초안 핵심 구성:
- 프로젝트 소개와 목적
- MVP 핵심 기능 목록
- 기술 스택
- 모노레포 구조
- 실행 방법
- 환경 변수 설명
- 테스트 실행 방법
- 주요 문서 위치

전체 초안 본문은 `docs/README.draft.md`에 있다.

## 14. AI 친화 개발 규칙

### 14.1 파일 크기/책임
- Dart 파일 1개는 가급적 300줄 이하, 최대 500줄 제한.
- 한 파일은 한 책임만 가진다.
- 한 클래스는 한 이유로만 변경되게 유지한다.

### 14.2 feature 디렉토리 규칙
- feature 당 하위 폴더는 `presentation/application/domain/data`만 허용.
- feature 루트에 직접 파일을 두지 않고 하위 계층에 배치.
- feature 간 직접 import 금지, 필요한 경우 `application` 인터페이스로 노출.

### 14.3 shared 모델 규칙
- `packages/shared_models`에는 Flutter 의존 import 금지.
- 공유 모델은 직렬화 필드명 변경 시 서버/앱 동시 PR에서 처리.
- 외부 API 응답 원문 모델은 shared에 두지 않는다(서버 전용).

### 14.4 API 응답 모델 규칙
- 엔드포인트별 request/response DTO 분리.
- 에러 포맷은 전 endpoint 공통 구조 유지.
- nullable 필드는 문서(`docs/contracts`)에 명시.

### 14.5 테스트 규칙
- 새 유스케이스 추가 시 최소 domain/application 테스트 1개 이상 필수.
- 버그 수정 시 회귀 테스트 먼저 추가.
- 테스트는 동작 의도를 이름에 포함
  - 예: `returns_404_when_no_candidate_place`.

### 14.6 문서 동기화 규칙
- API 변경 시 `docs/contracts` 동시 수정.
- 구조 변경 시 `docs/architecture/today-lunch-blueprint.md` 업데이트.
- 실행/환경 변수 변경 시 README 초안 동시 수정.

### 14.7 리팩토링 규칙
- 리팩토링 PR에서 동작 변경 금지.
- rename/extract는 작은 커밋으로 분리.
- 중복 2회 이상 발견 시 함수 추출 고려.

### 14.8 추상화 추가 기준
- 같은 변경이 3번 반복될 때만 추상화 추가.
- 구현체 1개인 인터페이스는 테스트 격리가 필요할 때만 허용.
- 미래 가능성만으로 패턴 추가 금지(YAGNI).

### 14.9 패키지 분리 기준
- 아래 3가지 중 2가지 이상 만족 시 새 패키지 분리
  - 두 앱/서비스 이상에서 재사용
  - 릴리즈 주기가 독립적
  - 의존성 격리가 필요

### 14.10 실패 모드 분리 기준
- 외부 API 실패, 입력 검증 실패, 내부 버그를 서로 다른 에러 코드로 분리.
- UI는 사용자 메시지와 개발자 로그를 분리해서 처리.
