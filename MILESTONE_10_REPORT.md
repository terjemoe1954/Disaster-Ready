# Milestone 10 — Offline First Audit and Hardening

Status: implementation, automated verification and build complete. Manual verification results are recorded below. Milestone 11 was not started.

## Offline architecture audit

| Feature | Classification | Offline behavior and storage |
|---|---|---|
| Household Profile | A — fully offline | Read/edit/save through local UserDefaults-backed `HouseholdProfileStore`. |
| My Emergency Plans / saved plans | A — fully offline | SwiftData records remain navigable and editable without network. |
| Emergency selection and templates | A — fully offline | `EmergencyType`, `EmergencyTemplateCatalog` and Norway templates are bundled code/data. |
| Preparedness actions and guidance | A — fully offline | Bundled localized content; no request gates navigation. |
| Personal meeting/safe locations | A — fully offline | User-authored plan fields stored locally in SwiftData and included in backup. |
| Smart Supplies recommendations | A — fully offline | Deterministic local `SupplyPrioritizer`; no service call. |
| Saved `SupplyItem` records | A — fully offline | SwiftData persistence. |
| Payment Preparedness | A — fully offline | Local checklist/UserDefaults persistence; no banking credentials are requested or stored. |
| `FamilyContact` / `ImportantNumber` / emergency contacts | A — fully offline | SwiftData/bundled emergency numbers. `tel:` and message handoff availability is controlled by iOS/carrier, not required for viewing data. |
| Local reminders | A — fully offline | UserNotifications calendar/time triggers scheduled on-device. |
| Settings, appearance and localization | A — fully offline | AppStorage and bundled English, Norwegian Bokmål and Thai resources. |
| Backup/export/import | A — fully offline | Local JSON `FileDocument`; the chosen Files destination may itself be cloud-backed, but local export/import needs no app network service. |
| Official source metadata | A — fully offline | Bundled `GuidanceSourceRegistry`, including authority, title, URL and review date. |
| DSB/Geonorge public shelters | B — cache-dependent offline | Cached official national reference records remain searchable; without cache, clear unavailable state and bundled safety/source guidance remain. |
| MET weather warnings | B — cache-dependent offline | Cached official alerts are geographically matched and lifecycle-filtered on-device; without cache, clear unavailable state. |
| Fresh shelter dataset download | C — requires network | HTTPS WFS request to Geonorge. Failure cannot block core features. |
| Fresh MET alert refresh/check | C — requires network | HTTPS MetAlerts request after server cache expiry. Failure cannot block core features. |
| Manual weather-area geocoding | C — requires network in practice | MapKit search may need Apple network services; one-shot device location remains an alternative and cached alert matching is local. |
| Official-source web pages | D — optional external link | Metadata remains visible offline; opening the linked page naturally requires network. |
| Apple Maps shelter handoff | D — optional external link/app handoff | Cached coordinate remains available; map tiles/services may require network. |

Classification: A must work fully offline; B works from cache offline; C requires network; D is an optional external link or system handoff.

## Hardening changes

- Corrected the Geonorge cache compiler warning without changing its encoded keys, schema version, source identity or compatibility. `schemaVersion` is now an immutable value supplied by an initializer with the same default value `2`, allowing `Codable` to decode and validate it correctly.
- Added a replaceable `ShelterHTTPClient` boundary so offline success/failure paths can be tested without changing production behavior.
- No connectivity monitor, background polling, timer or retry loop was added.
- MET's existing server-expiry policy remains authoritative: an unexpired cached snapshot is used without a request; after expiry only one request is attempted and failures fall back to cache.

## Cache contents and privacy

### Shelter cache (`public-shelters-cache.json`)

- Normalized official `CivilDefenceShelter` reference fields: official ID, optional name/room/address/municipality/registered capacity, official coordinate, source ID and optional official dataset timestamp.
- Local cache refresh timestamp (`updatedAt`) and cache schema version.
- Does **not** store lookup origin, user location, location history, credentials, contacts, plans or financial data.

Shelter coordinates are official dataset coordinates, not the user's lookup location. Registered capacity remains reference metadata and is not represented as current availability.

### MET cache (`met-alerts-cache-v2.json`)

- Normalized official alert content and official Polygon/MultiPolygon geometry.
- Language code, API data-fetch time, successful check time, `Last-Modified`, server expiry, `Cache-Control` and internal 203/429 maintenance diagnostics.
- Does **not** store lookup origin, user coordinates, location history, credentials, contacts, plans or financial data.

Official geometry coordinates describe warning areas and are not user location history. Disaster Ready downloads national land alerts and performs matching on-device.

## Timestamp semantics

| Timestamp | Meaning |
|---|---|
| Shelter `dataUpdatedAt` | Official record/dataset timestamp supplied by Geonorge. |
| Shelter `lastUpdated` / cache `updatedAt` | Time Disaster Ready successfully refreshed its local shelter reference cache. |
| Alert `sentAt`, `effectiveAt`, `onsetAt`, `expiresAt`, `updatedAt` | Official alert lifecycle times when supplied; unavailable GeoJSON values remain nil. |
| MET cache `fetchedAt` | Time alert content bytes were successfully fetched. |
| MET cache `checkedAt` | Time a successful API check, including 304, was completed. |
| MET cache server expiry | Earliest API-compliant time a new check may occur. |
| `GuidanceSource.lastReviewed` | Editorial review date for bundled guidance/source metadata only. Never alert or dataset freshness. |

## Dynamic data offline behavior

### Public shelters

- Network failure with cache returns official cached records, `isCached = true`, the last refresh time, dataset attribution and bundled explanatory guidance.
- Network failure without cache throws once; the UI stops loading and shows the localized unavailable state. No shelter is fabricated.
- Search and proximity calculations run locally over cached official fields. No user lookup origin is persisted.
- Cached data is explicitly described as cached and never live/current.

### MET warnings

- Network failure with cache returns `isCached = true` and the last successful fetch/check presentation.
- Every cache read re-evaluates effective/onset/expiry against current device time. Expired and future alerts are excluded.
- Known Cancel/Update lifecycle state remains in the normalized cache and prevents cancelled/superseded alerts from reappearing.
- Network failure without cache makes one request attempt, stops loading and shows localized unavailable text. All other tabs remain usable.
- Cached information is prominently labelled and never called live.

## Backup and restore

- Backup contains only user-created preparedness data: household profile/count, contacts, important numbers, plans, roles and supplies plus schema/export metadata.
- Shelter and MET reference caches are not members of `DisasterBackupPayload` and are not exported or imported.
- Reference caches are disposable and independently recreated/refreshed.
- Existing legacy and 1.0.1 compatibility tests pass; optional later fields retain safe defaults.

## Localization

- Offline, cached and unavailable shelter states are complete in English, Norwegian Bokmål and Thai through the String Catalog.
- Weather cached/unavailable/fallback status is supplied in all three supported app languages.
- Bundled source metadata remains readable offline; external link controls do not claim the destination page is offline.
- Automated and prior manual checks found no raw localization keys.

## Accessibility audit

### VoiceOver verdict: PASS

- Shelter search, Use My Location, map handoff and source links are standard labelled controls or have explicit human-readable labels.
- Weather search, Use My Location, freshness status, severity text, plan shortcut and official links expose readable text.
- Cached/unavailable state is conveyed by text, not colour alone.
- Result rows retain individually accessible actions; status timestamps are spoken text.

### Dynamic Type verdict: PASS

- Offline/dynamic-data views use semantic SwiftUI text styles rather than fixed font sizes.
- Weather controls use `ViewThatFits` to fall back from horizontal to vertical layout.
- Shelter and weather cards live inside the dashboard's scrollable content and use wrapping/minimum tappable dimensions rather than fixed text heights.

## Automated verification

- Milestone 10 focused offline tests: 7 run, 7 passed, 0 failed, 0 skipped.
- Complete suite: 110 run, 109 passed, 1 failed, 0 skipped on the first pass.
- The sole failure was `testHouseholdProfileCanBeOpenedFromSettings`, where the UI-test runner reported that the app process had no PID. Immediate isolated rerun: 1 run, 1 passed. No product assertion failed on rerun.
- Compatibility coverage includes Household Profile, plans/templates, Smart Supplies, Payment Preparedness, contacts/data snapshots, saved supplies, source registry, shelters, MET lifecycle/cache, and 1.0.1 backup/import.

## Build

- Complete project build: succeeded.
- Compiler errors: 0.
- Compiler warnings: 0.
- The pre-existing `GeonorgeShelterService.swift:14` Codable warning is resolved.

## Manual verification

- Environment: available iPhone simulator. No physical iPhone was connected to the automated device session, and simulator network controls were not considered reliable enough to claim airplane-mode coverage.
- PASS: app launch and core tab navigation remained stable.
- PASS: My Plan, emergency selection, bundled guidance and scrolling remained usable.
- PASS: Smart Supplies, Payment Preparedness and contacts were accessible; explicit offline wording remained visible.
- PASS: Household Profile screen and controls were exposed in the accessibility hierarchy.
- PASS: live switching among English, Norwegian Bokmål and Thai produced readable UI with no observed raw localization keys.
- PASS: offline/cache state is communicated through readable text in the accessibility hierarchy, not colour alone.
- PASS: largest accessibility Dynamic Type remained readable, tappable, reflowed and scrollable with no observed clipping or overlap.
- NOT TESTED manually: physical-iPhone airplane mode; shelter and MET cache/no-cache runtime states; last-refresh and expired-cache presentation; spoken VoiceOver traversal. These paths have deterministic automated coverage where applicable.
- NOT VERIFIED manually: Household Profile edit/save. Two hierarchy-derived synthesized taps did not change the standard SwiftUI `Toggle` value. Source inspection shows a normal enabled `Toggle`, persistence tests pass, and no product defect was established; a brief human tappability/save check remains before release sign-off.

## Remaining risks / TODOs

- Physical-iPhone airplane-mode testing remains preferable because simulator network controls can be unreliable.
- Complete the remaining human checks on a physical iPhone: Household Profile toggle/save, spoken VoiceOver, and the shelter/MET online-to-airplane-mode transitions.
- Manual no-cache testing requires removing the disposable reference cache or a clean install; it must not remove user-created data.
- MapKit geocoding, Apple Maps content, telephone/message delivery and official web pages depend on external system/network availability, but their failure does not mutate or block Disaster Ready's local state.
- MET direct-client scaling/proxy considerations remain documented in the Milestone 9 report and are unchanged.
