# core_di

Shared dependency-injection setup for the Aura Marketplace apps.

- `get_it` + `injectable`, organised as a micro package: each app pulls in this package's generated module
- `AppConfig`, registered once per environment (`dev` / `stg` / `prod`)
- `Dio`, built from the active `AppConfig`

After changing an annotated class, regenerate from the repo root:

```bash
melos run generate
```
