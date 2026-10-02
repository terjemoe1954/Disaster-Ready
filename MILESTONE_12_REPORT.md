# Milestone 12 — Localization Audit and Hardening

Date: 1 October 2026

## Result

The production localization catalogs and all user-visible localization call sites were audited for English, Norwegian Bokmål, and Thai. No product functionality was added. The audit corrected the English source-language fallback, one Norwegian singular form, one language-change status defect, and locale-aware count formatting.

Milestone 13 has not been started.

## Files modified

- Disaster Ready/Localizable.xcstrings
- Disaster Ready/LocalizationSupport.swift
- Disaster Ready/Resources/EmergencyContactsLocalizationResources.swift
- Disaster Ready/DashboardSections.swift
- Disaster Ready/Views/HouseholdProfileEditor.swift
- Disaster Ready/ReleasePrepSections.swift
- Disaster Ready/Views/OfficialWeatherAlertsSection.swift
- Disaster ReadyTests/Disaster_ReadyTests.swift
- Disaster ReadyUITests/Disaster_ReadyUITests.swift
- MILESTONE_12_REPORT.md

## Localization architecture

- Localizable.xcstrings is the production UI catalog. English is the source language; Bokmål (nb) and Thai (th) are supported translations.
- Disaster Ready-InfoPlist.xcstrings localizes the app name and location permission purpose.
- L10n.text remains the common dynamic-key lookup. English now uses the String Catalog source value rather than treating the semantic key as fallback text.
- The 22 Milestone 11 official-contact strings retain explicit English source fallbacks because dynamically constructed lookups for those manually registered resources are not emitted as normal English runtime lookups by the catalog compiler.
- Official MET alert content is not machine-translated or represented as official Thai content. App-owned labels around it remain localized.

## Catalog health

| Metric | Result |
|---|---:|
| Localizable catalog entries | 395 |
| Non-empty runtime keys audited by tests | 394 |
| Info.plist catalog entries | 2 |
| Total production catalog entries | 397 |
| Missing English values | 0 |
| Missing Bokmål values | 0 |
| Missing Thai values | 0 |
| Keys marked needs review | 0 |
| Raw semantic keys found after hardening | 0 |

The Localizable catalog reports 221 reviewed machine-origin entries and 174 human-translated entries for each translated locale. The final review item, supply.radio, was corrected to:

- Bokmål: “Batteridrevet radio eller sveiveradio”
- Thai: “วิทยุแบบใช้แบตเตอรี่หรือมือหมุน”

Potential legacy keys were not deleted. No safely provable stale key was removed. Legacy and newer namespaced keys coexist for compatibility; no conflicting user-visible meaning was found in the audited call sites.

## Language audit

### English

The audit reproduced the source-language failure for the new official_contacts.* family: dynamic lookup could return the semantic key even though the catalog had a readable source value. The shared lookup now returns readable source-language text, with the existing explicit official-contact English values used for that manually registered family. The complete runtime-key matrix passes in English.

### Norwegian Bokmål

- All catalog keys resolve.
- “1 personer” was corrected to “1 person”; plural household summaries retain “personer.”
- Emergency, shelter, warning, cache, source-review, and medical-service terminology remain distinct and neutral.
- Official Norwegian names and phone numbers are unchanged.

### Thai

- All catalog keys resolve.
- The final radio term was reviewed and corrected.
- Official MET content remains in an official supplied language when Thai is unavailable; app-owned status and controls are Thai.
- No app-owned raw semantic key remains.

## Terminology and official content

The audit retained the distinction between official warnings, preparedness guidance, cached information, public civil-defence shelters, evacuation planning, non-emergency medical service, registered capacity, refresh time, and source-review time. No wording was strengthened into an order or recommendation.

DSB, MET Norway, NVE, Helsenorge, Politiet, and Geonorge remain proper authority names. Official phone numbers remain exactly 110, 112, 113, and 116 117.

## Plurals, counts, dates, times, and numbers

- Household summary now selects the correct English and Bokmål singular/plural term.
- Household size and readiness counts use the selected app locale for number formatting.
- Supply completion uses the localized catalog format instead of string concatenation.
- Shelter distances use locale-aware Measurement formatting.
- Shelter refresh/dataset dates, source review dates, and MET refresh/validity times use the selected app locale.
- Fixed ISO/HTTP dates remain protocol/storage formats and are not presented as localized UI.

## Accessibility localization

Source inspection confirmed localized labels/values for shelter search, location use, map handoff, weather search, source links, supply status, official emergency call actions, cached/offline state, and settings controls. The emergency call label communicates service, exact number, and call action. Severity and cached/unavailable states use text and do not rely on colour alone.

## Dynamic Type and layout

Static layout audit found:

- no one-line limits on safety-critical text;
- no fixed text-height frames;
- scaled metrics for the audited icon sizing;
- adaptive horizontal/vertical control layouts where labels are long;
- scroll containers on long screens.

Manual simulator verification on iPhone 17 Pro / iOS 27.0 at normal Dynamic Type covered:

| Language | Screens verified |
|---|---|
| English | Dashboard/weather card, My Plan, Contacts, Settings |
| Norwegian Bokmål | Dashboard/weather card, My Plan, Household Profile, Smart Supplies, Payment Preparedness, Contacts, Settings |
| Thai | Dashboard/weather card |

On completed screens, scrolling and visible controls were usable, accessibility hierarchies exposed localized labels, and no raw keys, clipping, overlap, or safety-critical truncation was observed.

The iOS 27 simulator process exited twice during language/tab interaction. Simulator logs showed no app exception or backtrace, but did show a duplicated UIAccessibilityLoaderWebShared WebKit/WebCore warning. This prevented a reliable final pass of Thai secondary screens, explicit shelter/full-weather screens, largest Dynamic Type, and full VoiceOver traversal. This is recorded below rather than claimed as passed.

## Automated tests

Added coverage verifies:

- all 394 non-empty Localizable keys resolve in English, Bokmål, and Thai;
- semantic keys never resolve to themselves;
- emergency titles, My Plan safety text, Smart Supplies, Payment Preparedness, shelters, weather, official contacts, sources, and offline/cache strings resolve;
- all prior data/model, official-number, backup/import, shelter, MET, privacy, and compatibility tests remain in the complete suite.

The UI test setup now resets the simulator to portrait before every UI test, preventing orientation inherited from another test from placing the supply search field outside the hittable region.

Final complete test result:

- Tests run: 125
- Passed: 125
- Failed: 0
- Skipped: 0
- Expected failures: 0
- Not run: 0

## Build

Xcode build-for-testing: **passed**

- Compiler errors: 0
- Compiler warnings reported by Xcode build: 0

## Remaining risks / TODOs

- Repeat the incomplete Thai, explicit Public Shelters/full Weather Warnings, largest Dynamic Type, and full VoiceOver manual pass on a stable simulator or physical iPhone before release sign-off.
- Investigate only if reproducible on a physical device: the iOS 27 simulator accessibility/WebKit process-exit behavior observed during this audit.
- Do not remove legacy localization keys until compatibility-safe usage analysis proves they are no longer needed.
