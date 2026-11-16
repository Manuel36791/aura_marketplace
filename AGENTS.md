# AGENTS.md — Aura Marketplace

Read this file first. It describes what this project is, where it stands, the rules to follow, and what to build next.
When you finish a step, update the **Status** and **Roadmap** sections below so the next session starts from the truth.

---

## 1. What this project is

**Aura Marketplace** is a public portfolio project: a multi-vendor e-commerce platform built as a **Flutter monorepo with 3 apps**. It is built **one roadmap step at a time**, each step shipped as a small, reviewable pull request, to show recruiters and hiring managers advanced Flutter skills (architecture, patterns, packages, testing, security, CI/CD).

Because it is a portfolio, **code quality and repo cleanliness matter as much as features**: clean commits, real tests, no template leftovers, an up-to-date README.

| App | Path | Purpose |
|-----|------|---------|
| Store | `apps/store` | Customer-facing shopping app |
| Courier | `apps/courier` | Delivery app (live location, pickup/dropoff) |
| Partner | `apps/partner` | Vendor/seller app (catalog, inventory, orders) |

| Package | Path | Purpose |
|---------|------|---------|
| `core_ui` | `packages/core_ui` | Shared design system. Brand color is orange (`#FF6B00`); `AuraTheme.light()` / `AuraTheme.dark()` |
| `core_di` | `packages/core_di` | Shared dependency injection: `AppConfig` per environment + `Dio`, exposed as an injectable **micro package** |

Repo: `github.com/Manuel36791/aura_marketplace` (public, default branch `main`).

---

## 2. Current status

Completed and merged to `main`:

- **Step 1 — Flavors.** `dev` / `stg` / `prod` via `flutter_flavorizr`. Each app has its own `flavorizr.yaml` and a **single** `lib/main.dart`. Flavorizr generates `lib/flavors.dart` (the `F` class); `main.dart` sets `F.appFlavor` from Flutter's `appFlavor` global. Flavorizr does not create any app-level config, so `AppConfig` was built by hand.
- **Step 2 — Melos monorepo.** Melos 8 with Dart pub workspaces. There is **no `melos.yaml`**: Melos config and scripts live in the **root `pubspec.yaml`** under `melos:`. Shared dependency versions are declared in `melos.command.bootstrap`.
- **Step 3 — Dependency injection.** `get_it` + `injectable`. `core_di` is a micro package (`@InjectableInit.microPackage()`, generated class `CoreDiPackageModule`). Each app has `lib/core/di/injection.dart` which pulls it in via `externalPackageModulesBefore: [ExternalModule(CoreDiPackageModule)]` and exposes `configureDependencies(String environment)`. The environment string is the flavor name (`dev` / `stg` / `prod`).
- **Hotfix (GitHub PR #4 and follow-up).** Fixed DI wiring, repo hygiene (`.gitignore`, untracked IDE/generated files), template tests and placeholders.

### Verification completed

1. **`AppConfig` registration.** `packages/core_di/lib/src/micro_package.module.dart` registers `AppConfig` for each environment (`_dev`, `_stg`, `_prod`) *before* the `Dio` registration. Module methods are correctly named `devConfig()`, `stagingConfig()`, `prodConfig()`.
2. **Guard test.** `packages/core_di/test/core_di_test.dart` initializes `CoreDiPackageModule` for `dev`, `stg`, and `prod` and resolves `AppConfig` and `Dio` from a fresh `GetIt.asNewInstance()`.
3. Workspace pipeline (`melos bootstrap && melos run generate && melos run analyze && melos run test`) is completely green.
4. `apply_fixes.py` removed from root.

---

## 3. Commands

Run from the repo root:

```bash
dart pub global activate melos     # once
melos bootstrap                    # link workspace packages + pub get
melos run generate                 # build_runner in every package that uses it
melos run analyze
melos run test
melos run format
```

Run an app: `cd apps/store && flutter run --flavor dev` (also `stg`, `prod`; same for `courier`, `partner`).

**Done-check for any step:** `melos bootstrap && melos run generate && melos run analyze && melos run test` all pass.

---

## 4. Rules and conventions

**Repo hygiene**
- Commit **generated DI files** (`*.config.dart`, `*.module.dart`) so a fresh clone builds without extra steps. Never hand-edit them; regenerate with `melos run generate`.
- Never commit IDE or machine-specific files (`.idea/`, `.vscode/`, `.dart_tool/`, `local.properties`, `Generated.xcconfig`, `ephemeral/`). The root `.gitignore` covers them.
- No template leftovers: no "A new Flutter project." descriptions, no `TODO` LICENSE/CHANGELOG, no default counter tests.
- Do not add a `melos.yaml`; Melos 8 reads the root `pubspec.yaml`.

**Architecture**
- Clean Architecture inside each app, organised by feature: `lib/features/<feature>/{data,domain,presentation}`.
- Shared infrastructure goes in `packages/`. Start a feature inside one app and promote it to a package only when a second app needs it.
- Environments are always `dev` / `stg` / `prod`. The flavor name is the injectable environment name. Use `F.appFlavor` (non-nullable, `late final`) — set once in `main.dart`.
- Per-environment registrations: do **not** name a module method the same as an environment annotation (`@dev`, `@prod`, `@test`, or the custom `@staging`).
- State management: **Bloc** for the Store app (auth, checkout) and **Riverpod** for the Partner app (catalog), on purpose, so the repo shows the same architecture with two state layers. Document the comparison in the README.
- Change flavors by editing the app's `flavorizr.yaml` and re-running flavorizr. Be careful: flavorizr can overwrite `main.dart` / `app.dart` / `flavors.dart`; re-check them after running it.
- Use `AuraTheme` from `core_ui` for all theming. Do not hard-code a different primary color.
- There is **no backend**. Base URLs in `AppConfig` are placeholders (`*.aura-marketplace.example`). Hide data access behind repository interfaces and use a fake/mock data source (for example a mock Dio adapter) so the apps run without a server.

**Tests**
- Every step ships real tests (unit and/or widget). Widget tests that touch `F` must set `F.appFlavor = Flavor.dev` in `setUpAll` (it can only be assigned once per test file).

**Pull requests and commits**
- One branch and one PR per roadmap step. Keep PRs small (about 300–600 lines changed).
- Conventional commit messages (`feat:`, `fix:`, `chore:`, `test:`, `docs:`).
- Every step also updates the root `README.md` (see below).

**README (single evolving file)**
- Do not create a new README per step. In every step: tick the box in the **Progress / Features** checklist, add one line to the **Progress Log**, update the architecture tree if packages changed, and update **Next up**.
- Use "Step N" in the README. GitHub PR numbers no longer match the step numbers.

**LinkedIn post (outside the repo)**
- After each step, write the owner a LinkedIn post draft **in Egyptian Arabic** (colloquial, Arabic script, light emoji, a few English hashtags such as `#Flutter #FlutterDev`). It says what was built, the one interesting technical decision, and what the next step is. Give it in your reply; do **not** commit it.

---

## 5. Roadmap

Legend: ✅ done · ⏭️ next · ⬜ not started

| # | Step | App(s) | Demonstrates | Status |
|---|------|--------|--------------|--------|
| 1 | Flavors (dev/stg/prod) | store | flutter_flavorizr, per-flavor IDs and icons | ✅ |
| 2 | Melos monorepo + courier + partner + `core_ui` | all | Workspaces, shared design system | ✅ |
| 3 | DI with `get_it` + `injectable` + `core_di` | all | Micro package, environment-aware config | ✅ |
| 4 | **Auth** — Bloc, token refresh, secure storage | store | Clean Architecture + Bloc, Dio interceptor | ⏭️ |
| 5 | Product catalog and inventory — Riverpod | partner | Bloc vs Riverpod, same architecture | ⬜ |
| 6 | Checkout — domain events / CQRS-lite | store | Command/query separation | ⬜ |
| 7 | Offline-first product browsing — `drift` + sync | store | Local persistence, conflict resolution | ⬜ |
| 8 | Live order tracking — location stream + maps | courier → store | Streams, `google_maps_flutter`, background location | ⬜ |
| 9 | Store ↔ Partner chat | store, partner | Real-time messaging, pagination, typing indicators | ⬜ |
| 10 | Push notifications + deep linking | all | FCM, `go_router` deep links, auth guards | ⬜ |
| 11 | Custom platform plugin — barcode scanner | partner | Writing a plugin, platform channels | ⬜ |
| 12 | iOS Live Activities — order status | store | ActivityKit, `live_activities` | ⬜ |
| 13 | Home screen widgets (Android + iOS) | store | `home_widget`, WidgetKit, widget deep links | ⬜ |
| 14 | Biometric login + secure storage | store | `local_auth`, `flutter_secure_storage` | ⬜ |
| 15 | Certificate pinning — shared Dio interceptor | all | Network security | ⬜ |
| 16 | Feature flags — Firebase Remote Config | all | Progressive rollout, kill switches | ⬜ |
| 17 | Crashlytics + analytics abstraction | all | Observability, swappable providers | ⬜ |
| 18 | Test suite — unit, widget, golden (`mocktail`) | all | Testing discipline | ⬜ |
| 19 | Integration test: login → browse → checkout (`patrol`) | store | End-to-end confidence | ⬜ |
| 20 | GitHub Actions CI (lint/test/build × 9 flavors) + Fastlane | all | DevOps | ⬜ |
| 21 | Architecture docs — diagram + ADRs | repo | Communication | ⬜ |

---

## 6. Next step in detail — Step 4: Auth (Store app)

Goal: a complete, tested authentication feature in `apps/store` with Bloc.

Scope:
1. **Structure:** `apps/store/lib/features/auth/{data,domain,presentation}`.
2. **Domain:** `User` entity, `AuthRepository` interface, use cases (login, register, logout, restore session).
3. **Data:** remote data source behind an interface. There is no backend, so ship a fake/mock implementation that behaves like a real API (success, wrong password, expired token). Use `getIt<Dio>()` from `core_di` for the HTTP layer.
4. **Token handling:** access and refresh tokens in `flutter_secure_storage`. A Dio interceptor attaches the access token and, on a 401, refreshes once and retries the request (guard against refresh loops and concurrent refreshes). Keep the interceptor in the Store app for now; Step 15 will move network-security pieces into a shared package.
5. **Presentation:** `AuthBloc` (events/states), login and register screens using `AuraTheme`, a session gate at startup.
6. **DI:** register everything with `injectable` in the Store app's own `injection.dart` (on top of `CoreDiPackageModule`).
7. **Tests:** unit tests for the Bloc (`bloc_test`) and repository, a test for the interceptor's refresh-and-retry logic, and at least one widget test for the login screen.
8. **Docs:** tick "Auth" in the README checklist, add the Progress Log line, set Next up to Step 5.

Out of scope for this step: biometric login (Step 14), certificate pinning (Step 15).

After finishing, reply with: a short summary of what changed, the exact commands you ran and their results, any decision the owner should review, and the Egyptian Arabic LinkedIn post draft.
