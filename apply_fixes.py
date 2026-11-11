#!/usr/bin/env python3
"""
Aura Marketplace - applies the remaining repo fixes.

Run from the repo root:   python3 apply_fixes.py
Then review with:         git status && git diff

It does NOT run Flutter. Generation/analysis steps are printed at the end.
"""
import pathlib
import subprocess
import sys

ROOT = pathlib.Path.cwd()
if not (ROOT / "pubspec.yaml").exists() or not (ROOT / "apps").is_dir():
    sys.exit("Run this from the repo root (the folder that contains apps/ and packages/).")

APPS = {
    "store": ("Aura", "Customer-facing shopping app of Aura Marketplace."),
    "courier": ("Aura Courier", "Delivery/courier app of Aura Marketplace."),
    "partner": ("Aura Partner", "Vendor/seller app of Aura Marketplace."),
}


def write(rel, text):
    p = ROOT / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text, encoding="utf-8")
    print(f"  wrote   {rel}")


def edit(rel, old, new):
    p = ROOT / rel
    text = p.read_text(encoding="utf-8")
    if old not in text:
        print(f"  SKIPPED {rel} (text not found - already changed?)")
        return
    p.write_text(text.replace(old, new), encoding="utf-8")
    print(f"  edited  {rel}")


def remove(rel):
    p = ROOT / rel
    if p.exists():
        p.unlink()
        print(f"  removed {rel}")


# 1. Root .gitignore ----------------------------------------------------------
print("1. .gitignore")
write(
    ".gitignore",
    """# IDE / tooling
.dart_tool/
.idea/
.vscode/
*.iml
.DS_Store
.flutter-plugins-dependencies
pubspec_overrides.yaml

# Build output
build/

# Generated at the workspace root by the IDE's Flutter plugin
# (the real apps live in apps/)
/android/
/ios/
/macos/

# Per-machine / generated native files (any app)
local.properties
GeneratedPluginRegistrant.*
Generated.xcconfig
**/ephemeral/
flutter_export_environment.sh
""",
)

# 2. Untrack everything that is now ignored ------------------------------------
print("2. Untracking files that are now ignored")
tracked_ignored = subprocess.run(
    ["git", "ls-files", "-ci", "--exclude-standard"],
    capture_output=True, text=True, check=True,
).stdout.splitlines()
for i in range(0, len(tracked_ignored), 100):
    subprocess.run(
        ["git", "rm", "--cached", "-q", "--"] + tracked_ignored[i:i + 100],
        check=True,
    )
print(f"  untracked {len(tracked_ignored)} files (they stay on your disk)")

# 3. Tests ---------------------------------------------------------------------
print("3. Replacing template tests")
write(
    "packages/core_di/test/core_di_test.dart",
    """import 'package:core_di/core_di.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppConfig keeps the values it is created with', () {
    const config = AppConfig(
      flavorName: 'dev',
      baseUrl: 'https://example.test',
      enableLogging: true,
    );

    expect(config.flavorName, 'dev');
    expect(config.baseUrl, 'https://example.test');
    expect(config.enableLogging, isTrue);
  });

  test('AppConfig has logging disabled by default', () {
    const config = AppConfig(flavorName: 'prod', baseUrl: 'https://example.test');

    expect(config.enableLogging, isFalse);
  });
}
""",
)

for app, (title, _) in APPS.items():
    write(
        f"apps/{app}/test/widget_test.dart",
        f"""import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{app}/flavors.dart';
import 'package:{app}/pages/my_home_page.dart';

void main() {{
  // F.appFlavor is `late final`, so it can only be assigned once per test file.
  setUpAll(() => F.appFlavor = Flavor.dev);

  testWidgets('home page shows the flavor title', (tester) async {{
    await tester.pumpWidget(
      MaterialApp(theme: AuraTheme.light(), home: const MyHomePage()),
    );

    expect(find.text('Hello (DEV) {title}'), findsOneWidget);
  }});
}}
""",
    )

# 4. Staging flavor name consistency -------------------------------------------
print("4. AppConfig staging name")
edit(
    "packages/core_di/lib/src/modules/app_config_module.dart",
    "flavorName: 'staging',",
    "flavorName: 'stg',",
)

# 5. Root README ---------------------------------------------------------------
print("5. Root README")
edit(
    "README.md",
    "├── melos.yaml\n└── pubspec.yaml\n",
    "└── pubspec.yaml     # workspace root + Melos config (Melos 7+ has no melos.yaml)\n",
)
edit("README.md", "F.appFlavor!.name", "F.appFlavor.name")

# 6. Template placeholders -------------------------------------------------------
print("6. Removing template placeholders")
for pkg in ("core_di", "core_ui"):
    remove(f"packages/{pkg}/LICENSE")
    remove(f"packages/{pkg}/CHANGELOG.md")

write(
    "packages/core_di/README.md",
    """# core_di

Shared dependency-injection setup for the Aura Marketplace apps.

- `get_it` + `injectable`, organised as a micro package: each app pulls in this package's generated module
- `AppConfig`, registered once per environment (`dev` / `stg` / `prod`)
- `Dio`, built from the active `AppConfig`

After changing an annotated class, regenerate from the repo root:

```bash
melos run generate
```
""",
)
write(
    "packages/core_ui/README.md",
    """# core_ui

Shared design system for the Aura Marketplace apps: brand colors (orange) and the light/dark `AuraTheme`.

```dart
MaterialApp(
  theme: AuraTheme.light(),
  darkTheme: AuraTheme.dark(),
)
```
""",
)

for app, (title, blurb) in APPS.items():
    write(
        f"apps/{app}/README.md",
        f"""# {title}

{blurb}

```bash
flutter run --flavor dev   # or stg / prod
```

See the [root README](../../README.md) for the full project overview.
""",
    )
    edit(
        f"apps/{app}/pubspec.yaml",
        'description: "A new Flutter project."',
        f'description: "{blurb}"',
    )

print(
    """
Done. Now run these from the repo root, in order:

  melos bootstrap
  melos run generate
  melos run analyze
  melos run test

Then commit everything, including the generated files:
  packages/core_di/lib/src/micro_package.module.dart
  apps/store/lib/core/di/injection.config.dart
  apps/courier/lib/core/di/injection.config.dart
  apps/partner/lib/core/di/injection.config.dart

  git add -A
  git commit -m "chore: tests, gitignore, placeholders, generated DI files"
"""
)
