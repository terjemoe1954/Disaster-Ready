# Milestone 5 Report — Smart Supply Lists

Date: 2026-10-01

## Scope and result

Milestone 5 adds deterministic, offline smart supply recommendations for home preparedness and grab/evacuation planning. The feature is additive: the existing `SupplyItem` SwiftData model and all persisted fields remain unchanged. Milestone 6 has not been started.

## Files added

- `Disaster Ready/Models/SmartSupplyModels.swift`
  - `SupplyRecommendationPriority`
  - `SmartSupplyListKind`
  - `SupplyRecommendation`
  - `SmartSupplyPlan`
  - conservative exact-name `SupplyOwnershipMatcher`
- `Disaster Ready/Resources/SmartSupplyLocalizationResources.swift`
  - stable English source strings and String Catalog extraction keys

## Files modified

- `Disaster Ready/Data/SupplyPrioritizer.swift`
- `Disaster Ready/DisasterDashboardView.swift`
- `Disaster Ready/Views/EventAwareMyPlanView.swift`
- `Disaster Ready/Views/SmartSupplyRecommendationsSection.swift`
- `Disaster Ready/Localizable.xcstrings`
- `Disaster ReadyTests/Disaster_ReadyTests.swift`

## Supply recommendation architecture

`SupplyPrioritizer.recommendations(for:household:)` is a pure, deterministic rule engine. It starts with separate base arrays for home preparedness and grab/evacuation, applies event rules, applies household rules, removes duplicate IDs while retaining the highest priority, and sorts by priority and stable ID. It performs no network or AI calls and writes no persistence data.

The earlier `prioritizedSupplies` and `prioritizedEvacuationSupplies` APIs remain as compatibility wrappers returning `TemplateSupplyItem`, so existing callers are not broken.

## Priority model

The stable priority levels are:

| Priority | Meaning |
|---|---|
| `critical` | Highest advance-planning priority for the selected event/profile |
| `high` | Important preparedness priority |
| `normal` | Useful base preparedness item |

The same `EmergencyType` and `HouseholdProfile` always produce the same ordered output.

## Event-specific rules

| Emergency | Main adaptations |
|---|---|
| Power outage | Lighting, batteries, radio, power banks, cooking without normal power; warmth is critical with electric heating |
| Flood | Grab readiness, documents, medicines, communication, water/food, warm clothing |
| Extreme weather | Warmth, lighting, radio, batteries, charging, food and water |
| Landslide / wildfire | Identification, medicine, communications, documents, clothing and evacuation basics |
| House fire | Advance-planning list only; active-fire notice says to leave immediately and never delay to collect belongings |
| Water outage | Drinking water and hygiene |
| Evacuation | ID, medicines, communication, water/food, clothing, payment options, documents and assistive devices |
| Hazardous release | Authority information, radio, communication and medicines |
| War/security incident | Authority-first wording; the engine does not decide whether to shelter or evacuate |

## Household adaptation

- Pets add distinct home and evacuation pet supplies.
- Children add distinct home and evacuation child supplies.
- Special-assistance needs add essential support supplies, assistance information, assistive devices and medicine priority.
- Electric heat, wood stove and alternative heating adjust relevant home priorities.
- EV adds charging/route preparedness without stating that an EV is preferred evacuation transport.
- Gas content requires country `NO`, explicit `hasGasInstallation == true`, and a relevant event.
- A Norwegian profile with `hasGasInstallation == false` receives no gas recommendation. Legacy `gasShutoffNote` is never inspected.

## Existing SupplyItem integration and data protection

The existing `SupplyItem` SwiftData model was not renamed, removed or modified. The engine accepts only `EmergencyType` and `HouseholdProfile`; it cannot mutate saved supplies.

My Plan now displays two clearly separate areas:

1. **Recommended** — computed home and grab/evacuation suggestions.
2. **My supplies** — the user's actual persisted records, shown read-only with saved quantity and packed state.

No recommendation is automatically added, packed, completed, or marked as owned. An optional “Recorded” indicator uses only normalized exact-name equality; fuzzy matching is intentionally not used. Existing names, details, storage locations, quantities, packed states and review dates remain untouched. Existing backup schema/version handling was not changed, so 1.0.1 imports retain their existing compatibility path.

## My Plan integration

The Milestone 4 template-only preview was replaced by the smart plan output. The selected emergency and current household profile drive the presentation. Both lists show localized priority labels and the event-specific safety notice. Saved supplies are passed into My Plan for read-only comparison/display.

## Offline behavior

Recommendation generation is synchronous local code over bundled enums/profile values. It has no URL/session/service dependency. Existing offline emergency templates and persistence remain independent of network availability.

## Localization status

- English source strings added through `LocalizedStringResource` declarations.
- Norwegian Bokmål: all 52 new Milestone 5 keys translated.
- Thai: all 52 new Milestone 5 keys translated.
- String Catalog verification: `newCount == 0` and `needsReviewCount == 0` for both `nb` and `th` after editing.
- User-visible supply names now resolve through semantic String Catalog keys instead of the earlier Swift switch.

## Safety behavior

- Recommendations are described as planning guidance, not a guarantee of safety.
- Active house-fire text says to leave immediately and never delay evacuation to collect supplies or belongings.
- War/security output is authority-first and does not choose shelter versus evacuation.
- Current emergency-service/public-authority instructions explicitly take priority.
- No fixed water quantity or other safety-critical quantity was introduced.

## Automated tests

Nine new Swift Testing tests were added, covering:

- deterministic/offline output
- every `EmergencyType` and distinct list kinds
- power-outage priorities
- flood and evacuation priorities
- house-fire and authority-first safety notices
- children, pets and special-assistance adaptation
- no-gas versus explicit-gas behavior
- preservation of every existing `SupplyItem` field, including quantity, packed state and review date
- conservative exact-name ownership matching

Existing evacuation expectations were updated for the new separate phone/charger, food/water and cards/cash categories. The full test plan contains 64 tests: 56 unit tests and 8 UI tests.

### Test execution result

- Build-for-testing: **passed** in 54.239 seconds; test sources compiled.
- After restarting Xcode and Simulator, the separate unit-test suite completed successfully.
- Unit tests: **56 passed, 0 failed, 0 skipped, 0 not run**.
- This includes all new Milestone 5 tests plus the existing migration, backup, HouseholdProfile and My Plan compatibility tests.
- The eight UI automation tests were not rerun as a suite; the requested Milestone 5 flows were instead checked through the manual simulator session below.

## Build result

- Build-for-testing after implementation: **passed**, no errors.
- Final complete project build after localization: **passed** in 19.512 seconds, no errors.
- Xcode build warning query: **0 warnings**.

## Manual simulator checks

After restarting Xcode and Simulator, the app installed and ran successfully on the iPhone 17 Pro simulator. Results:

| Check | Result | Observation |
|---|---|---|
| A. Power outage | Pass | Critical battery lighting, batteries, power banks and battery/crank radio were visible. The current profile had gas enabled, so this was not a strict no-gas variant. |
| B. Flood | Pass | Flood selection showed critical evacuation water, food, medicines and mobile-phone recommendations, separately from the home list. |
| C. Evacuation with children | Partial | Enabling children immediately added the high-priority child item. Evacuation was selected, but the final evacuation list was not recaptured before ending the session. Engine behavior is covered by passing unit tests. |
| D. Evacuation with pet | Partial | Enabling pets immediately added the high-priority pet item. The final evacuation view was not recaptured. Engine behavior is covered by passing unit tests. |
| E. Special assistance | Pass | Enabling special assistance added critical essential support equipment. |
| F. House fire | Pass | With `Boligbrann` selected, the banner stated: `Forlat stedet umiddelbart ved en pågående brann. Utsett aldri evakueringen for å hente forsyninger eller eiendeler.` |
| G. No gas versus gas | Partial | Gas enabled showed the gas-installation recommendation. Gas was turned off, but the complete no-gas list was not rescanned before the session ended. No-gas absence is covered by passing unit tests. |
| H. Existing supplies | Pass | Saved items remained under `Mine forsyninger`; quantities and packed indicators stayed unchanged through scenario/profile navigation. |

The UI visibly separated `Anbefalt`, `Hjemmeberedskap`, `Ta med / evakuering`, and `Mine forsyninger`. Scenario changes updated recommendations. The exact-match `Registrert` indicator appeared for a matching saved item. No crash, overlap, clipping or unreadable text was observed.

Temporary profile changes used for testing were restored and verified before closing the session: children off, pets off, special assistance off, and gas installation on. No saved supply data was changed.

## Warnings, errors and remaining risks/TODOs

- Source diagnostics and both builds reported no compiler errors or warnings.
- Manual checks C, D and G remain partial because their final scenario/list states were not recaptured; their underlying rule behavior passed automated tests.
- Exact-name matching is deliberately conservative. A saved item with a different name is not claimed as satisfying a recommendation; this can create false negatives but avoids unsafe false ownership claims.
- Country-specific smart rules currently deeply adapt Norway, matching the milestone scope. Additional countries require explicit future rule/content review.
- No Milestone 6 work has been performed.
