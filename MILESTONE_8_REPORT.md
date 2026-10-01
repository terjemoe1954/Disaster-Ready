# Milestone 8 Report — Norwegian Public Civil-Defence Shelters

Date: 2026-10-01

Status: Implemented. Milestone 9 has not been started.

## Authoritative dataset

| Item | Verified value |
|---|---|
| Authority/provider | Direktoratet for samfunnssikkerhet og beredskap (DSB), distributed through Geonorge |
| Dataset | `Tilfluktsrom – Offentlige` |
| Dataset metadata | https://kartkatalog.geonorge.no/Metadata/uuid/dbae9aae-10e7-4b75-8d67-7f0e8828f3d8 |
| Official WFS | https://wfs.geonorge.no/skwms1/wfs.tilfluktsrom_offentlige?request=GetCapabilities&service=WFS |
| WFS metadata | https://kartkatalog.geonorge.no/Metadata/uuid/06da6e96-544c-467d-8329-5ca25a11328b |
| Format used | OGC WFS 2.0, GML/XML 3.2.1, EPSG:4258 |
| Update information | Geonorge states `etter behov` (as needed). The catalog metadata seen during verification was updated 2026-09-24. Each GML record can also carry `datauttaksdato`. This is shown separately from app refresh time and guidance review time. |
| Access | Public/open data |
| Licence | Norwegian Licence for Open Government Data (NLOD) 1.0 |
| Local caching | Permitted. NLOD 1.0 permits copying, use and distribution with attribution and licence compliance. Disaster Ready caches only the official structured records, not DSB web pages. |

The implementation does not use scraped pages, Apple/Google points of interest, or fabricated shelter records as shelter data. DSB's guidance page remains a separate explanatory source.

## Dataset fields used

| App field | Official GML field | Handling |
|---|---|---|
| `id` | `identifikasjon/Identifikasjon/lokalId` | Required; records without it are rejected; duplicates are removed deterministically. |
| `roomNumber` | `romnr` | Optional. |
| `address` | `adresse` | Optional. |
| `capacity` | `plasser` | Optional registered capacity; never described as live availability. |
| `latitude`, `longitude` | `posisjon/gml:Point/gml:pos` | Required and coordinate-validated. |
| `dataUpdatedAt` | `datauttaksdato` | Optional dataset extraction value. |
| `sourceID` | App attribution | Always `dsb-geonorge-public-shelters-wfs`. |
| `name` | Not supplied | Remains `nil`; not fabricated. |
| `municipality` | Not supplied | Remains `nil`; not inferred or fabricated. |

## Files added

- `Disaster Ready/Services/ShelterLocationProvider.swift`
- `Disaster Ready/Resources/ShelterLocalizationResources.swift`
- `MILESTONE_8_REPORT.md`

## Files modified

- `Disaster Ready.xcodeproj/project.pbxproj`
- `Disaster Ready/Models/Shelter.swift`
- `Disaster Ready/Data/GeonorgeShelterService.swift`
- `Disaster Ready/Data/GuidanceSourceRegistry.swift`
- `Disaster Ready/Views/PublicSheltersSection.swift`
- `Disaster Ready/Views/EventAwareMyPlanView.swift`
- `Disaster Ready/DisasterDashboardView.swift`
- `Disaster Ready/Localizable.xcstrings`
- `Disaster Ready/Disaster Ready-InfoPlist.xcstrings`
- `Disaster ReadyTests/Disaster_ReadyTests.swift`

## Service architecture

- `CivilDefenceShelter` is an additive Codable/Equatable/Sendable value model, not SwiftData. The temporary development name `Shelter` remains as a source-compatible type alias.
- `ShelterService.nearbyShelters(latitude:longitude:)` is the replaceable/testable boundary requested by the milestone.
- `GeonorgeShelterService` downloads the national official WFS reference set without including user coordinates in the request.
- `ShelterGMLDecoder` normalizes official GML records and rejects invalid coordinates, missing stable IDs and duplicate IDs.
- `ShelterProximity` performs deterministic straight-line distance calculation, filtering and sorting on-device.
- `ShelterRegisterSearch` performs manual matching only against official address, room number, name or municipality fields. Because this dataset has no name/municipality fields, those remain absent rather than being inferred.
- No route calculation is performed.

## Location and privacy behavior

- Location is optional and requested only after `Use my location` is pressed.
- The app requests a single, kilometre-accuracy location update; it does not continuously track.
- The full official reference dataset is fetched without a coordinate/BBOX parameter. Proximity is calculated on-device.
- Precise lookup coordinates are not written to cache, SwiftData, backup, logs or an app server.
- Manual official-register search works without location permission.
- The rest of Disaster Ready has no location dependency.
- The localized Info.plist explanation states the one-shot distance purpose and that location is not stored.

## Cache and offline behavior

- The structured DSB/Geonorge reference data is stored in the system Caches directory.
- A cache entry contains official shelter records, refresh time and cache schema version only; it contains no lookup origin or location history.
- The UI distinguishes `Shelter information refreshed` from `Cached shelter information — last refreshed`.
- `datauttaksdato`, cache refresh time and `GuidanceSource.lastReviewed` are separate values with separate meanings.
- If refresh fails and a cache exists, the cached reference is used and explicitly labelled cached.
- If no cache exists, the UI shows a localized unavailable/offline state and does not pretend data is available.
- An incompatible pre-Milestone-8 development cache is discarded because it contained a coordinate-bound subset; this cache is non-user reference data, not user content.

## Source-registry integration

The existing guidance ID `dsb-civil-defence-shelters` still resolves to DSB's explanatory guidance. A separate verified dataset ID was added:

| Source ID | Authority | URL | Meaning |
|---|---|---|---|
| `dsb-civil-defence-shelters` | DSB | https://www.dsb.no/sikkerhverdag/egenberedskap/verdt-a-vite-om-tilfluktsrom/ | Explanatory guidance reviewed by Disaster Ready. |
| `dsb-geonorge-public-shelters-wfs` | DSB / Geonorge | https://kartkatalog.geonorge.no/Metadata/uuid/dbae9aae-10e7-4b75-8d67-7f0e8828f3d8 | Official machine-readable shelter dataset. |

The source-card review date still means the date Disaster Ready compared bundled information with a source. It is not used as WFS freshness or a live authority-update timestamp.

## User experience and My Plan integration

- The Norway-only shelter card offers two separate paths: manual official-register search and optional one-shot location lookup.
- Nearby results show approximate straight-line distance and are sorted deterministically.
- The mandatory notice says that a nearby shelter is not automatically the correct place to go and that current Norwegian authority instructions determine use.
- Result rows use neutral labels: official shelter data, registered capacity, approximate distance and view on map.
- No row is selected as a destination and no wording says recommended, best, safest, go here or evacuate here.
- The map action opens the official coordinate in Maps without calculating a route.
- Only the Norway + War/security incident My Plan combination surfaces the neutral `View public civil-defence shelters` reference action.
- The existing authority-first war/security guidance is unchanged. Other emergency types do not automatically surface this action.

## Localization

- Added 27 shelter-reference keys with explicit English, Norwegian Bokmål and Thai values.
- Added localized English, Norwegian Bokmål and Thai location-permission text.
- String Catalog verification after editing: 0 new/untranslated shelter keys in Bokmål and Thai.
- A simulator check initially exposed raw English semantic keys. Explicit English catalog values were then added; the recheck found 0 raw `shelter_reference.*` keys and confirmed readable safety, non-live, manual-search, location-privacy and source-review copy.
- Official names DSB and Geonorge are retained.

## Accessibility

- Dynamic Type-compatible system text styles are used throughout.
- Headings use accessibility heading traits.
- Search, location and map actions have meaningful labels/identifiers.
- Important action content and the manual search field are at least 44 points high after the simulator review identified smaller initial targets.
- Result rows preserve separate interactive map controls instead of combining the full row into one ambiguous action.

## Automated tests

- Complete active test plan: 89 tests run; 88 passed and 1 UI test initially failed because the existing onboarding button was not hittable after four simulator swipes.
- Isolated rerun of that same onboarding test: 1 passed, 0 failed. This was a simulator/scroll flake; no onboarding code was changed.
- Unit-test portion of the complete run: 81 passed, 0 failed, 0 skipped.
- UI-test portion after the isolated rerun: all 8 test cases passed at least once.
- Final focused Milestone 8 rerun after cache/privacy/localization corrections: 15 passed, 0 failed, 0 skipped.

Milestone 8 coverage includes stable/unique authoritative IDs, invalid coordinates, deterministic distance and sorting, missing optional values, mandatory source identity, no recommendation classification, manual no-permission search, no location history, cached/live distinction, separate timestamps, Norway/war-only My Plan exposure, coordinate-free WFS requests, and existing decoder/cache compatibility.

Existing tests also passed for 1.0.1 backup import, HouseholdPlan preservation, HouseholdProfile, Smart Supply and Payment Preparedness. No SwiftData model or backup schema was changed for Milestone 8.

## Build result

- Final complete project build: passed.
- App compiler errors: 0.
- App compiler warnings: 0.

## Manual simulator results

| Check | Result |
|---|---|
| A. Open without location permission | Passed. The feature opened without a permission prompt. |
| B. Manual-area path | Passed. Search for official room number `16127` returned the DSB record at `Nils Leuchsvei 40` without location permission. |
| C. Permission only after explicit button | Partly verified: no prompt occurred before the button. The permission sheet itself was not completed in the first pass because the keyboard covered the control. Code and localized purpose-string inspection confirm the request exists only in the explicit button action. |
| D. Neutral distance/results | Passed for the displayed register result; no recommended/best/safest/go-here wording appeared. Distance-specific display is additionally covered by deterministic tests. |
| E. No recommendation wording | Passed in visible UI/hierarchy and automated policy checks. |
| F. Shelter/map presentation | Map button and accessible coordinate link were present. External Maps opening was not conclusively observed because the keyboard/tab area intercepted the first-pass tap. |
| G. War/security My Plan link | Implemented and automated policy-tested; manual traversal was not completed in the first pass. |
| H. Other scenarios | Automated policy test confirms all other EmergencyTypes return false; manual traversal was not completed in the first pass. |
| I. Offline/cache state | Automated cache behavior passed. Airplane-mode visual verification remains outstanding. |
| J. English/Bokmål/Thai | All catalog entries verified. English simulator recheck found 0 raw shelter keys and readable safety/source/privacy copy; Bokmål and Thai layout traversal remains outstanding. |
| K. VoiceOver/Dynamic Type | Hierarchy exposed the controls and identifiers. Tap targets were increased to 44 points after inspection. Spoken VoiceOver and an accessibility-size visual pass remain outstanding. |

No crash or runtime exit occurred during simulator verification.

## Remaining risks and TODOs

- The official register is reference data, not a complete or live statement that a room is open, prepared or has free capacity. This limitation is prominent in the UI.
- WFS availability and metadata quality are controlled by DSB/Geonorge. Cached data is labelled and never called live/current.
- Manual search is intentionally limited to fields supplied by the official dataset. Municipality search cannot be claimed until an authoritative municipality field or separately verified official boundary mapping is added.
- Complete the remaining simulator-only matrix: explicit permission sheet, external Maps handoff, airplane-mode cached state, Bokmål/Thai layouts, spoken VoiceOver and largest Dynamic Type sizes.
- No production shelter data is bundled or invented. Records appear only after an official WFS download or from its attributed local cache.

Stop point: Milestone 8 only. Milestone 9 has not been started.
