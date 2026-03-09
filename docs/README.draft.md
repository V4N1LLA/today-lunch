# today-lunch

오늘 점심 메뉴 결정을 빠르게 끝내기 위한 Flutter 기반 추천 앱입니다.

## 왜 이 앱을 만드나
- 점심 메뉴 결정 피로를 줄인다.
- 로그인 없이 즉시 사용한다.
- 현재 위치 또는 회사 위치 기준으로 가까운 식당을 빠르게 추천받는다.

## 핵심 기능 (MVP)
- 현재 위치/회사 위치 선택
- 주변 음식점 조회
- 랜덤 추천 1건
- 필터(거리/카테고리)
- 최근 추천 제외
- 외부 지도 앱 열기

## 기술 스택
- Flutter + Riverpod
- Dart API Server (shelf 계열)
- Melos monorepo
- Shared models package
- GitHub Actions CI

## Monorepo 구조
```text
apps/mobile
packages/shared_models
packages/shared_utils
server/api
docs
scripts
infra
```

## 실행 방법
1. `dart pub global activate melos`
2. `dart pub get`
3. `dart run melos bootstrap`
4. 서버 실행: `dart run server/api/bin/server.dart`
5. 앱 실행: `cd apps/mobile && flutter run`

## 환경 변수
- 앱: `apps/mobile/.env.example`
- 서버: `server/api/.env.example`

## 테스트 실행
- 전체: `dart run melos run test`
- 모바일: `dart run melos run test:mobile`
- 서버: `dart run melos run test:server`

## 주요 문서
- 아키텍처: `docs/architecture/today-lunch-blueprint.md`
- API 계약: `docs/contracts/`
- 운영 메모: `docs/runbook/`
