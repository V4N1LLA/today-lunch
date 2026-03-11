# CLAUDE.md

This file is the fastest way to get back into productive work on `today-lunch`.

## Read order

1. If present locally, read `WORK_CYCLE.md` for the current execution cycle.
2. If present locally, read `readme.md` for the original product request.
3. Read `docs/architecture/today-lunch-blueprint.md` for the agreed structure and implementation order.
4. Read `docs/contracts/http-api.md` before changing endpoint shape or request/response payloads.
5. Read `docs/runbook/README.md` and `scripts/README.md` before changing setup or validation commands.

## Skill cues

- Use `kent-beck-style` when deciding slice size, naming, and refactoring boundaries.
- Use `clean-architecture` when adding or moving code across `presentation/application/domain/data` boundaries.
- Use `parallel-worktree-manager` before starting a new parallel task or worktree.

## Project rules

- Keep the stack Flutter + Dart monorepo with shared packages.
- Prefer the smallest vertical slice that can be tested end to end.
- Do not add abstractions before there is a concrete second use case.
- Keep source dependencies pointing inward. Framework code should stay in outer layers.
- Share DTOs and simple models through `packages/shared_models`.
- Keep local workflow repeatable through `scripts/bootstrap.ps1`, `scripts/analyze.ps1`, and `scripts/test.ps1`.

## Authority and conflict resolution

- For `today-lunch`, the project-specific API base is `/v1` as documented in `docs/contracts/http-api.md`.
- If local `WORK_CYCLE.md` mentions `/api/v1`, treat that as a generic workflow note. The project-specific contract wins.
- `readme.md` and `WORK_CYCLE.md` are currently local working documents and should not be committed unless the user explicitly asks.

## Current status

- Active branch: `feat/today-lunch-bootstrap`
- Open PR: `#1 Bootstrap today-lunch monorepo scaffold`
- Bootstrap scripts exist and are verified in the current Windows environment.
- `melos bootstrap` is still unstable on this Windows setup, so `scripts/bootstrap.ps1` defaults to package-level `pub get`.

## Next slices

1. Replace the placeholder server health test with a real route/handler test.
2. Refactor server health code out of `server/api/bin/server.dart` into `server/api/lib/src/features/health/`.
3. Add a minimal mobile health-check service under `apps/mobile/lib/src/core/network/` and show status on the home screen.
4. After health is stable, implement `GET /v1/places/nearby` and then `POST /v1/recommendations/pick`.

## File map for the next slice

- Server health implementation: `server/api/lib/src/features/health/`
- Server routing glue: `server/api/bin/server.dart`
- Mobile HTTP client: `apps/mobile/lib/src/core/network/`
- Mobile first UI update: `apps/mobile/lib/main.dart`
- Shared payloads when needed: `packages/shared_models/lib/src/`

## Definition of done

- Code and docs are updated together.
- Verification commands are recorded in the PR body.
- Changes are committed, pushed, and reflected in the open PR unless the user narrows the scope.
