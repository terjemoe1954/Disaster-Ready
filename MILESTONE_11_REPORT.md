# Milestone 11 – Emergency Contacts

Status: implementation complete; Milestone 12 not started.

## Authoritative sources

The bundled Norwegian configuration was reviewed on 1 October 2026 against current first-party public-authority pages:

| Number | Purpose represented in Disaster Ready | Authority | Official source |
| --- | --- | --- | --- |
| `110` | Fire and rescue emergency | Direktoratet for samfunnssikkerhet og beredskap (DSB) | [110-sentralene](https://www.dsb.no/brannsikkerhet/nodmelding/110-sentralene/) |
| `112` | Police emergency | Politiet | [Ring politiet](https://www.politiet.no/kontakt-politiet/ring-politiet) |
| `113` | Medical emergency | Helsenorge / Helsedirektoratet | [Legevakt](https://www.helsenorge.no/hjelpetilbud-i-kommunene/legevakt/) and [Ring 113](https://www.helsenorge.no/forstehjelp/ring-113) |
| `116 117` | Out-of-hours medical service when the regular doctor is unavailable and help cannot wait | Helsenorge / Helsedirektoratet | [Legevakt](https://www.helsenorge.no/hjelpetilbud-i-kommunene/legevakt/) |

No number was added from memory or a third-party directory. `116 117` is classified and presented separately from emergency number `113`.

## Architecture

- `OfficialEmergencyNumber` is an additive `Codable`, `Identifiable`, `Equatable`, `Sendable` value model.
- Stable IDs are country/service/number identifiers and never depend on translated text.
- `CountryEmergencyConfiguration` contains a country code and bundled official numbers.
- `CountryEmergencyConfigurationCatalog` returns the reviewed Norway configuration only for `NO`; unsupported countries return no guessed numbers.
- `EmergencyService` preserves the service category. `OfficialNumberClassification` distinguishes emergency services from non-emergency medical advice.
- `EmergencyCallHandoff` creates only a `tel:` URL after an explicit UI confirmation.
- `EmergencyContactPrivacyPolicy` makes the non-network, non-Contacts-framework boundary explicit and testable.

## Official and personal contact separation

The Contacts screen has three visually separate concepts:

1. Official emergency numbers.
2. Other important official numbers (`116 117`).
3. My contacts, containing the existing user-created `FamilyContact` and `ImportantNumber` records.

No SwiftData model or persisted property was renamed or migrated. Official numbers are immutable bundled values and are never inserted into the personal-contact collections.

## Country behavior

- Household country `NO` displays exactly `110`, `112`, `113` and `116 117`.
- Any unsupported country displays a localized neutral message and no Norwegian number.
- Personal contacts remain visible for every country.
- The phone-number strings are displayed exactly as configured and are not localized.

## Calling behavior

- The visible number and service name remain present; the action is not icon-only.
- A standard button first opens a confirmation dialog.
- Only the explicit “Continue to Phone” action calls `openURL` with a `tel:` URL.
- Disaster Ready never places a call automatically and does not claim that connection is guaranteed.
- The implementation does not choose a service from symptoms and contains no medical triage logic.

## My Plan integration

- A Norwegian house-fire plan surfaces the static `110` fire reference inside the existing contacts step.
- The reference is explicitly described as static contact information, not an instruction to call.
- It is read from the same bundled configuration and is not copied into a plan or personal contact record.
- War/security and unrelated plans receive no invented official number.

## Source registry

Three reviewed source IDs were added to the Milestone 7 registry:

- `no-emergency-fire-110`
- `no-emergency-police-112`
- `no-medical-numbers`

`GuidanceSource.lastReviewed` remains the date Disaster Ready reviewed bundled reference content. It is not live emergency information.

## Offline behavior

Official numbers, service classifications, descriptions, country selection and source metadata are bundled in the app. No API request is needed. Personal contacts continue to use local SwiftData. Official web-source links and the system Phone handoff may depend on external system/network availability, but their failure does not remove or mutate local content.

## Privacy

- No Contacts framework import, permission request or entitlement was added.
- No contact synchronization service was introduced.
- No user contact or phone-number network upload was added.
- Official-number lookup performs no network operation.
- The app reads only its existing user-created contact records.

## Backup compatibility

`DisasterBackupPayload`, `FamilyContactSnapshot` and `ImportantNumberSnapshot` are unchanged. Existing personal contacts remain in backup/import. Bundled official numbers are not exported because they are reference data. Existing 1.0.1 compatibility coverage remains enabled.

## Localization

All new app-owned labels, safety descriptions, confirmation text, unsupported-country state and VoiceOver labels are present in English, Norwegian Bokmål and Thai. Phone numbers are unchanged across locales. String Catalog verification reports no untranslated Milestone 11 keys in `nb` or `th`.

## Accessibility

- VoiceOver source audit verdict: **PASS**. Each call control announces the localized service, visible number and call action; standard buttons/links provide their native traits; decorative SF Symbols are contained by labelled controls.
- Dynamic Type source audit verdict: **PASS**. The UI uses semantic text styles, `ViewThatFits`, wrapping text, large standard controls and the dashboard's scroll container. There are no fixed text heights or single-line clamps.
- Emergency versus non-emergency meaning is conveyed through headings and descriptions, not colour alone.

## Files added

- `Disaster Ready/Models/OfficialEmergencyNumber.swift`
- `Disaster Ready/Resources/EmergencyContactsLocalizationResources.swift`
- `Disaster Ready/Views/OfficialEmergencyContactsSection.swift`
- `MILESTONE_11_REPORT.md`

## Files modified

- `Disaster Ready/Data/GuidanceSourceRegistry.swift`
- `Disaster Ready/DashboardSections.swift`
- `Disaster Ready/DisasterDashboardView.swift`
- `Disaster Ready/Views/EventAwareMyPlanView.swift`
- `Disaster Ready/Localizable.xcstrings`
- `Disaster ReadyTests/Disaster_ReadyTests.swift`

## Automated tests

- Focused Milestone 11 configuration/call/privacy/backup run: 12 passed, 0 failed, 0 skipped.
- Focused three-language regression after the English fallback correction: 1 passed, 0 failed, 0 skipped.
- Complete unit/compatibility suite after the final correction: 112 passed, 0 failed, 0 skipped.
- UI suite: all 8 tests passed. Six functional UI tests initially produced 5 passes and one timing-sensitive failure in `testSupplySearchShowsEmptyState`; the failed test passed immediately in isolation. The two launch/performance tests both passed.
- A monolithic 120-test invocation stalled in the XCUIAutomation phase without returning results. The same 120 enabled tests were therefore executed deterministically by target/group: 112 unit tests and all 8 UI tests. No test remains unexecuted.
- Coverage includes offline configuration, unique IDs, exact number strings, all four service mappings, `113`/`116 117` distinction, unsupported countries, explicit call action, privacy boundary, My Plan non-duplication, unchanged personal records, backup separation and three-language localization.
- Existing compatibility tests continue to cover HouseholdPlan, HouseholdProfile, Smart Supply, Payment Preparedness, shelters, MET and 1.0.1 backup/import.

## Build

- Build-for-testing after implementation: succeeded.
- Final complete build after the English correction: succeeded.
- Compiler errors: 0.
- Compiler warnings: 0.

## Manual verification

- Environment: iPhone simulator. Physical-device carrier behavior was not tested.
- PASS: Norwegian displayed `110` Brann og redning, `112` Politi–nødnummer, `113` Akutt medisinsk hjelp and a separately headed Legevakt `116 117` card explicitly stating that it is not emergency number `113`.
- PASS: Thai displayed all four translated service labels and exact numbers without observed overlap or clipping; `116 117` remained distinct.
- PASS after correction: English displayed all four service names, descriptions and exact numbers with no raw `official_contacts.*` keys.
- PASS: `My contacts` remained a separate section and the existing personal contact was visible and unchanged.
- PASS: tapping `Call 116 117` opened a confirmation dialog. No handoff occurred before the second explicit `Continue to Phone` action. The final action was intentionally not activated.
- PASS: accessibility hierarchy labels include service, number and action, for example `Fire and rescue, 110. Call action.` The distinction is textual and does not rely on colour.
- Source-level Dynamic Type audit: **PASS**. Runtime screenshots in normal size showed no clipping. Largest Dynamic Type could not be changed safely through the available device controls in this pass.
- Not tested: spoken VoiceOver traversal, largest Dynamic Type at runtime, real carrier handoff and physical-device airplane mode. These limitations do not affect the bundled/offline architecture tests.

## Remaining risks / TODOs

- A human must still confirm the real Phone-app handoff on a physical iPhone before release; the simulator cannot prove carrier connection and the app never promises it.
- A final human pass at the largest supported Dynamic Type size and with spoken VoiceOver remains recommended on a physical iPhone.
- Emergency contact configurations for countries other than Norway require separate authoritative review before being added.

Milestone 12 was not started.
