# 🧡 Aura Marketplace

A multi-vendor e-commerce platform built as a 3-app Flutter monorepo — built publicly, one PR at a time, showcasing production-grade architecture, patterns, and tooling.

| App | Description |
|-----|-------------|
| 🛍️ **Store** | Customer-facing shopping app |
| 🛵 **Courier** | Delivery/courier app — live location, order pickup/dropoff |
| 🏪 **Partner** | Vendor/seller app — catalog, inventory, order management |

---

## ✅ Progress / Features

- [x] Multi-environment flavors (dev/staging/prod) — Store app, via `flutter_flavorizr`
- [ ] Melos monorepo + Courier & Partner apps + shared `core_ui` package
- [ ] Dependency injection (`get_it` + `injectable`)
- [ ] Auth — Bloc, token refresh, secure storage
- [ ] Product catalog & inventory — Riverpod
- [ ] Checkout — domain events / CQRS-lite
- [ ] Offline-first product browsing (`drift`)
- [ ] Live order tracking — streams + maps
- [ ] Store↔Partner real-time chat
- [ ] Push notifications + deep linking
- [ ] Custom platform plugin — barcode scanner
- [ ] iOS Live Activities — order status on Lock Screen
- [ ] Home screen widgets (Android + iOS)
- [ ] Biometric login + secure storage
- [ ] Certificate pinning
- [ ] Feature flags (Remote Config)
- [ ] Crashlytics + analytics abstraction
- [ ] Test suite — unit / widget / golden
- [ ] Integration tests (`patrol`)
- [ ] CI/CD — GitHub Actions + Fastlane
- [ ] Architecture docs (diagrams + ADRs)

---

## 🏗️ Architecture

Clean Architecture across all three apps, with a shared `core_ui` design system package and shared infrastructure (networking, DI, security) once the monorepo lands in PR #2.

---

## 🧡 Multi-Environment Setup (Flavors)

The Store app ships with three build flavors — `dev`, `stg`, and `prod` — configured via [`flutter_flavorizr`](https://pub.dev/packages/flutter_flavorizr), which automates the Android/iOS native setup.

### Why flavors?

Running dev, staging, and production builds side-by-side on the same device (different bundle IDs, app names, and icons) is essential for any real-world app — no more manually switching API URLs or overwriting your test build with prod.

### What's included

- **3 flavors**: `dev`, `stg`, `prod` — each with its own:
  - Application ID / Bundle ID suffix (`.dev`, `.stg`)
  - App display name
  - App icon (color-coded so they're distinguishable on your home screen)
- **`flavorizr.yaml`** — a dedicated config file (kept separate from `pubspec.yaml` for clarity) defining the 3 flavors declaratively; running the generator reads this and produces all native Android/iOS boilerplate automatically
- **Single `lib/main.dart`** — `flutter_flavorizr` only manages native build config, not Dart entry points, so there's one shared entry point for all flavors

### Setup

```yaml
# flavorizr.yaml
flavors:
  dev:
    app:
      name: "(DEV) Aura"
    android:
      applicationId: "com.aura.store.dev"
    ios:
      bundleId: "com.aura.store.dev"
  stg:
    app:
      name: "(STG) Aura"
    android:
      applicationId: "com.aura.store.stg"
    ios:
      bundleId: "com.aura.store.stg"
  prod:
    app:
      name: "Aura"
    android:
      applicationId: "com.aura.store"
    ios:
      bundleId: "com.aura.store"
```

Generate the native config:
```bash
flutter pub run flutter_flavorizr
```

### Running

Since there's a single `main.dart`, the flavor is passed via `--flavor` and resolved at runtime into the matching `AppConfig`:

```bash
flutter run --flavor dev
flutter run --flavor stg
flutter run --flavor prod
```

### Building

```bash
flutter build apk --flavor prod
flutter build ipa --flavor prod
```

---

## 📜 Progress Log

- **PR #1** — Multi-environment flavors (dev/staging/prod) for the Store app, via `flutter_flavorizr`

---

## 🔜 Next up

PR #2 will convert this into a Melos monorepo and add the Courier and Partner apps alongside Store.
