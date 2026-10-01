# Milestone 9 — MET Norway Official Weather Alerts

Status: implementation complete; automated verification complete; manual simulator verification recorded below. Milestone 10 was not started.

## Official source and contract

- Production endpoint: `https://api.met.no/weatherapi/metalerts/2.0/current.json`
- API/product version: MetAlerts 2.0 (production since 2024-05-07).
- Official documentation: https://api.met.no/weatherapi/metalerts/2.0/documentation
- GeoJSON schema: https://docs.api.met.no/doc/metalerts/geojson.html
- CAP v2 lifecycle profile: https://docs.api.met.no/doc/metalerts/CAP-v2-profile.html
- Terms: https://api.met.no/doc/TermsOfService
- License: Creative Commons Attribution 4.0 / Norwegian Licence for Open Government Data 2.0; attribution is shown as MET Norway.
- Format used: GeoJSON FeatureCollection. Each feature contains official properties, Polygon/MultiPolygon geometry and a validity interval.
- Query: `lang=no|en&geographicDomain=land`. No user coordinates are included.
- User-Agent: `DisasterReady/1.1 (+https://github.com/terjemoe1954/Disaster-Ready)`. The public project URL was verified accessible and provides the repository owner and issue/contact route; no contact address was invented.
- Cache validation uses `Expires`, `Cache-Control`, `Last-Modified` and `If-Modified-Since`. MET's immutable CAP messages are not scraped or repeatedly downloaded.
- MET supports `lang=no|en`, event/domain/county filters and positional `lat`/`lon` filtering. Disaster Ready deliberately downloads the current land-warning collection and performs point-in-polygon matching on-device.

## Architecture

### Files modified

- `Disaster Ready/Models/OfficialAlert.swift`
- `Disaster Ready/Data/METWeatherAlertService.swift`
- `Disaster Ready/Data/GuidanceSourceRegistry.swift`
- `Disaster Ready/Views/OfficialWeatherAlertsSection.swift`
- `Disaster Ready/DisasterDashboardView.swift`
- `Disaster ReadyTests/Disaster_ReadyTests.swift`

### Files added

- `MILESTONE_9_REPORT.md`

### Model and decoder

`OfficialAlert` is an additive Codable/Identifiable/Equatable/Sendable value model. It stores the stable CAP identifier; source; event; official risk-matrix colour; original CAP severity; optional headline, description, instruction and consequences; separate effective, onset, expiry, sent and update timestamps; geographic description; source ID; message type/status/references; official URL; and normalized geometry. Unavailable GeoJSON values remain `nil` and are not fabricated.

`METAlertsDecoder` is separate from networking. It decodes optional fields, Polygon/MultiPolygon geometry and the validity interval. `riskMatrixColor` is preserved as Green/Yellow/Orange/Red/Unknown; CAP `severity` is retained separately and is never reinterpreted.

### Lifecycle

- `Alert` is admitted only when status is Actual, it has begun and has not expired.
- `Update` replaces referenced identifiers when references exist in normalized fixture/CAP-derived data. The production `current.json` endpoint already supplies MET's current server-side snapshot and omits superseded messages.
- `Cancel` removes its referenced alert and is never displayed. A same-ID fallback is retained for deterministic fixtures.
- Every live and cached read re-evaluates onset/effective and expiry against current device time. Expired or future alerts are not presented as active.
- A successful current-snapshot refresh replaces the cache, so alerts removed by MET (including cancellations) do not survive a known refresh.

### Geography and privacy

- Official geometry is matched deterministically on-device, including MultiPolygon and polygon holes.
- Location permission is requested only by the explicit **Use My Location** button through the existing one-shot location provider.
- Manual MapKit area search works without location permission.
- No continuous location updates are started.
- Coordinates are kept only in transient view state. They are not written to cache, preferences, SwiftData, logs, a Disaster Ready server, or MET.
- Cache entries contain only normalized MET reference data and cache metadata (`fetchedAt`, `checkedAt`, language, `Expires`, `Cache-Control`, `Last-Modified` and internal diagnostics). No location history exists.

### Cache and timestamps

- The cache stores the complete normalized national land-warning snapshot by language.
- Successful responses persist the server's `Expires`, `Cache-Control` and `Last-Modified` metadata. `Cache-Control: max-age` takes precedence when supplied. Before server expiry, both automatic and user-initiated reads use the local snapshot and make no network request.
- After expiry, a conditional request sends the previous `Last-Modified` unchanged as `If-Modified-Since`.
- HTTP 304 retains the normalized snapshot and original data-fetch time, records a new successful check time, applies new cache headers, and re-evaluates alert onset/expiry against current device time. It cannot resurrect an expired alert.
- HTTP 203 with usable data is decoded safely and records the internal `deprecatedProduct` diagnostic for maintenance. This technical diagnostic is not shown as an emergency warning.
- HTTP 429 performs no immediate retry. With cache it returns a prominently cached snapshot and records an internal throttling diagnostic; without cache it produces the normal unavailable state.
- Network failure with cache is prominently labelled `CACHED INFORMATION` and shows the last successful fetch time.
- Network failure without cache produces a clear unavailable state without blocking the rest of the app.
- Alert onset/effective/expiry/sent/updated, API fetch time and `GuidanceSource.lastReviewed` remain distinct. `lastReviewed` continues to mean editorial guidance review only.
- There is no timer, background task or polling loop. Data is requested only from explicit in-use UI actions, and server expiry is respected for those actions.

### Source registry

The approved `met-weather-warnings` guidance entry remains unchanged. A separate `met-norway-metalerts-2` API dataset source points to the official API documentation; its guidance review date is not used as alert freshness.

### UI, plans and safety

- The Overview includes an Official Weather Warnings card, visually separate from preparedness guidance.
- The card shows MET Norway attribution, explicit refreshed/cached status and time, official warning level as text and colour, official content without translation or strengthening, an official-source link, and a licence acknowledgement linking to MET's CC BY 4.0 / NLOD 2.0 policy. Nothing suggests MET endorses Disaster Ready.
- A successful zero-result refresh says no active official warning was found and explicitly does not guarantee safety.
- `rainFlood` and `stormSurge` may open the existing flood plan; clear weather events may open the existing extreme-weather plan; `forestFire` may open the wildfire plan. Unknown events remain visible without a shortcut.
- A shortcut only changes the selected existing plan/tab. It does not create or mutate a plan, change warning data or infer danger/evacuation.
- No notifications were added.
- MET failure cannot block plans, supplies, contacts, Payment Preparedness, shelters or offline guidance.

## Localization and accessibility

- App-owned warning UI/status copy is supplied in English, Norwegian Bokmål and Thai.
- MET content is requested in Norwegian for Bokmål and English for English/Thai. It is never machine-translated or represented as an official Thai translation.
- Layout uses `ViewThatFits` and vertical fallbacks, semantic text styles and scrollable dashboard content for Dynamic Type.
- Search, Use My Location, status and plan controls have human-readable labels/identifiers.
- Severity is always exposed as text and does not rely on colour.
- Refresh/cache status and expiry are meaningful spoken text.

## Automated verification

- API-compliance hardening tests: 9 run, 9 passed, 0 failed, 0 skipped. They cover Expires/Cache-Control parsing, no request before expiry, refresh after expiry, 304 preservation and expiry re-evaluation, safe observable 203 handling, 429 with/without cache, single-request/no-tight-retry behavior, conditional `If-Modified-Since`, and absence of user coordinates in requests.
- Focused MetAlerts tests: 11 run, 11 passed, 0 failed, 0 skipped.
- Complete suite initial run: 96 run, 95 passed, 1 failed, 0 skipped.
- The one failure was the pre-existing supply-search UI assertion `testSupplySearchShowsEmptyState`; immediate isolated rerun: 1 run, 1 passed. This is treated as a transient UI-test timing failure unrelated to Milestone 9.
- All MetAlerts decoder, lifecycle, expiry/future, severity, identity, cache timestamp, privacy/request, coordinate validation, geometry and conservative plan-mapping tests passed.
- Existing compatibility tests for HouseholdPlan, HouseholdProfile, Smart Supply, Payment Preparedness, shelters and 1.0.1 backup/import passed in the complete run.

## Build

- Complete project build: succeeded.
- Compiler errors: 0.
- Compiler warnings: 1 pre-existing, unrelated warning in `GeonorgeShelterService.swift:14` (`Immutable property will not be decoded because it is declared with an initial value which cannot be overwritten`). No warning was emitted by the MetAlerts hardening files.

## Manual UI verification

- PASS: app opened without requesting location permission.
- PASS: manual Oslo search worked while location was unavailable.
- PASS: successful zero-result state used the explicit no-warning/non-guarantee wording.
- PASS: refreshed official-data state and refresh time were explicit.
- PASS: MET attribution and official link were visible.
- PASS: Search and Use My Location had meaningful accessibility labels in the UI hierarchy.
- PASS: English, Norwegian Bokmål and Thai showed no clipping, overlap or raw localization keys in the tested standard-size layouts.
- Two defects found in the first pass were fixed: an existing no-alert result now relocalizes immediately when the app language changes, and denied/unavailable location now returns controls to enabled state and shows the localized manual-search fallback. Narrow recheck: PASS/PASS.
- Not manually exercised because no real relevant warning was available: active severity row, mapped plan shortcut and unknown/unmapped alert. These paths are covered by deterministic schema-derived test fixtures and unit tests.
- Not manually completed: airplane-mode cache presentation, largest Dynamic Type and spoken VoiceOver traversal. Cache expiry/freshness and accessibility structure are covered by automated tests/static inspection, but these remain physical/manual release checks.
- No test fixture is compiled into or shipped with production. Deterministic JSON strings live only in the test target.

## Remaining risks / TODOs

- GeoJSON is documented by MET as supplemental/beta in version 2.0, although MET states it does not plan further v2 format changes. Decoder optionality and unknown-value handling reduce this risk.
- GeoJSON does not expose CAP `references`, `sent` or per-message `updated` fields. Production lifecycle authority therefore comes from MET's `/current` snapshot; unavailable timestamps remain nil. Tests exercise normalized reference handling without fabricating production values.
- A stale offline cache cannot know about a cancellation that occurred after the last successful refresh; it is therefore explicitly labelled cached and never called live. Known cancellations are removed on the next successful snapshot replacement.
- Real active-alert availability varies. Test-only fixtures cover active, update, cancel, expiry, future and unmapped UI/data paths.
- The current deployment is direct client → MET API; therefore MET receives the user's IP address. Disaster Ready sends no user coordinates because it downloads national land alerts and matches official geometry on-device.
- MET recommends a caching proxy for mobile applications as traffic grows. No proxy was introduced in this hardening pass. Before significant production scale, total traffic volume and a shared caching-proxy architecture must be reviewed, especially against MET's aggregate request-rate guidance.
