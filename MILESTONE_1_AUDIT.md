# Disaster Ready 1.1 — Milestone 1 Audit

Audit baseline: Disaster Ready 1.0.1. This phase intentionally makes no production-model or UI rewrite.

## 1. Existing architecture

- **Models:** SwiftData `FamilyContact`, `ImportantNumber`, `HouseholdPlan`, `HouseholdRole`, and `SupplyItem`; supporting `PreparednessScenario`, supply status/location types, drills, offline resources, and message templates.
- **Views:** `DisasterDashboardView` coordinates a four-tab SwiftUI interface. `DashboardSections.swift` contains overview, scenario, plan, contacts, supplies, guide, drill, resource, and editor sections. `ReleasePrepSections.swift` contains settings, onboarding, manual, and release-readiness UI.
- **Services:** `SupplyReminderScheduler` manages local notification authorization and supply-review reminders. `BackupSupport` provides JSON export/import and schema validation. `LocalizationSupport` selects English, Norwegian Bokmål, or Thai resources.
- **Persistence:** SwiftData stores the five user-data models. `@AppStorage` stores language, appearance, onboarding, messaging, supply filtering, offline-mode, household-size, and reminder preferences. Backup schema version 1 exports all five SwiftData collections plus household size.

Current 1.0.1 fields identified by the specification:

- Gas shutoff: `HouseholdPlan.gasShutoffNote`
- Meeting place: `HouseholdPlan.reunionPoint`
- Safe/shelter place: `HouseholdPlan.shelterZone`
- Evacuation destination: `HouseholdPlan.evacuationDestination`
- Contacts: `FamilyContact` and `ImportantNumber`
- Supplies: `SupplyItem` with home/car location, quantity, packed state, and review date

## 2. Requirements already present

- Offline on-device persistence for plans, contacts, roles, and supplies.
- Scenario-aware guidance and scenario-specific plan records, though the scenario set and content do not yet match 1.1.
- Editable meeting, evacuation, shelter, gas, medical, pet, and family-message fields.
- Home/car supply lists, basic prioritization, quantities, review dates, reminders, and missing-item filtering.
- JSON backup/import with version validation and legacy optional-field decoding.
- English, Norwegian Bokmål, and Thai localization.
- Settings, onboarding, accessibility identifiers, unit tests, and UI tests.
- A unit-test target already exists and uses Swift Testing; UI tests use XCUIAutomation.

## 3. Data requiring migration

- Existing `HouseholdPlan` records must map `PreparednessScenario` identifiers to the future `EmergencyType` values without changing or discarding user-entered fields. The current launch migration assigns an untyped legacy plan to `storm` and creates missing scenario plans by copying a template plan.
- `householdMemberCount` must become or seed `HouseholdProfile.householdSize`; new profile flags need safe defaults. Gas must not be inferred merely because a gas note exists.
- Existing `reunionPoint`, `evacuationDestination`, and `shelterZone` need explicit mapping to the future contextual location fields.
- Existing `FamilyContact` data should map to the future contact shape while retaining role/notes until a deliberate compatibility decision is made.
- Existing home/car supplies need mapping to future home/grab-list categorization without changing names, quantities, completion state, or review dates.
- Backup schema version 1 must remain importable after later schema versions are introduced.

## 4. Proposed file changes by later phase

- Keep current files intact during Milestone 1; add only compatibility tests and this audit.
- Add `Models/HouseholdProfile.swift`, `Models/EmergencyType.swift`, and later source/shelter/alert models.
- Add `Data/` for offline templates, country configuration, source registry, and migration mapping.
- Add `Services/` for shelter, weather-alert, and cache implementations; move existing services only when that can be done without behavioral changes.
- Add focused `Views/` for profile, event-aware plan, sources, shelters, and alerts; progressively extract from the dashboard instead of rewriting it.
- Add `Config/` for country-specific official contacts and feature configuration, and `Resources/` for bundled offline data where appropriate.
- Modify `Disaster_ReadyApp.swift`, backup support, localization catalog, dashboard composition, and tests incrementally as each milestone requires.

## 5. User-data loss risks

- Renaming/removing SwiftData models or stored properties without a versioned migration plan.
- Changing persisted enum/raw string identifiers without an explicit mapping table.
- Adding non-optional SwiftData properties without defaults.
- Replacing the model container or store location/bundle identity.
- Backup import currently replaces local collections; a future schema mismatch or incomplete mapping could erase fields despite transaction rollback protection.
- Seed/relocalization logic can accidentally overwrite user-edited values if default-content detection is broadened.
- Converting the single legacy plan into multiple event plans can duplicate values or assign them to the wrong event.
- Removing old backup fields before at least one released migration path has consumed them.

## 6. Phased implementation plan

1. Audit 1.0.1, freeze the persistence baseline, add legacy compatibility coverage, then build/test.
2. Add versioned/additive models and explicit mappings; test opening 1.0.1-shaped data before UI adoption.
3. Add and persist the household profile, seeded from existing household size with conservative defaults.
4. Add the new emergency types, traceable offline templates, and identifier migration.
5. Introduce the event-aware My Plan flow while retaining mapped plan content.
6. Add base plus event-specific home/grab supply prioritization.
7. Add Norway payment-preparedness content without sensitive financial data.
8. Add source registry, reviewed dates, attribution, and official-advice links.
9. Add the authoritative civil-defence shelter service and optional/manual location UI.
10. Add MET Alerts decoding, normalization, caching, lifecycle handling, freshness, and attribution.
11. Complete offline/cache behavior and stale-data presentation rules.
12. Localize all additions in English, Norwegian Bokmål, and Thai.
13. Complete migration, safety, unit, UI, accessibility, and offline regression coverage.
14. Increment release metadata and complete physical-device, TestFlight, privacy, link, and API-terms checks.
