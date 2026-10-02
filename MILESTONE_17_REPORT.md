# Milestone 17 — App Store Release Preparation

Date: 2026-10-02  
Release candidate: **Disaster Ready 1.1 (3)**  
Milestone 15: **RELEASE GATE: PASS**  
Milestone 16: **PRIVACY GATE: PASS**

No App Store Connect upload, metadata change, review action, or submission was performed.

## Release candidate configuration

| Item | Verified value | Result |
|---|---|---:|
| Marketing version | 1.1 | PASS |
| Build | 3 | PASS |
| Bundle identifier | `com.terjemoe.Disaster-Ready` | PASS — unchanged from repository metadata |
| Product/display name | Disaster Ready | PASS |
| Device family | iPhone (`TARGETED_DEVICE_FAMILY = 1`) | PASS |
| Deployment target | iOS 26.5 | PASS with owner confirmation noted below |
| Supported platforms | iPhoneOS and iPhone Simulator | PASS |
| Signing style | Automatic | PASS |
| Development team | Configured | PASS |
| Installable app target | `SKIP_INSTALL = NO` | PASS |
| Export compliance | `ITSAppUsesNonExemptEncryption = NO` | PASS against current HTTPS-only behavior |

The iOS 26.5 deployment target is consistent with the app's current toolchain/API baseline and the already tested iOS 27 release candidate. It intentionally excludes devices that cannot run iOS 26.5 or newer. The owner should confirm that this audience constraint remains deliberate before submission; lowering it would require a separate compatibility review and is not part of Milestone 17.

## Signing and capabilities

The app target uses automatic signing and has a configured development team. A fresh generic-device Xcode build produced a signed application that:

- is valid on disk;
- satisfies its designated code-signing requirement;
- contains the expected version, build, bundle ID, and bundle name.

There is no custom code-signing-entitlements file. The project has no App Groups, iCloud/CloudKit, push-notification, HealthKit, Contacts, background-location, background-mode, advertising, tracking, or associated-domain capability. No third-party package product is linked.

The inspected Debug device product has the expected development-only `get-task-allow` entitlement. A final App Store archive must still be validated to confirm its distribution signing/provisioning and final entitlement set.

## Final build result

### Successful device-compatible build

After switching Xcode to **Any iOS Device (arm64)**, Xcode's project build completed successfully in **75.124 seconds** with no reported errors. This reconfirmed that the production source and the Milestone 16 location disclosure compile for a generic physical iOS device.

The most recent successful Xcode device build reported:

- Compiler errors: **0**.
- Compiler warnings: **0**.
- Signing verification: **valid** for the produced development-signed device app.

### Clean Release/archive-compatible attempt

The command-line clean phase succeeded, but the Release device compilation could not complete because the local Xcode environment's Swift macro-plugin server returned malformed responses for Apple macros including SwiftData `@Model`, Observation `@Observable`, and SwiftUI state macros. CoreSimulatorService also disconnected at the beginning of the first command-line attempt.

All later type/member errors were cascading consequences of those Apple macro implementations not loading. The same source subsequently built successfully through Xcode's generic-device build action. No production-code workaround was made because this is an Xcode tool/runtime environment failure, not evidence of a Disaster Ready source defect.

Nevertheless, the required clean Release build and Organizer archive validation have not received a successful final result in this Milestone 17 run. This is a release-package blocker until the owner restarts/repairs the local Xcode macro-plugin/Device Hub environment and completes a clean Release archive in Xcode Organizer with 0 errors and 0 warnings.

## Files produced

- `PRIVACY_POLICY_1.1.md`
- `APP_STORE_PRIVACY_1.1.md`
- `APP_STORE_WHATS_NEW_1.1.md`
- `APP_STORE_SCREENSHOT_PLAN_1.1.md`
- `APP_REVIEW_NOTES_1.1.md`
- `APP_STORE_SUBMISSION_CHECKLIST_1.1.md`
- `MILESTONE_17_REPORT.md`

No production functionality was added.

## Privacy Policy readiness

`PRIVACY_POLICY_1.1.md` is release-ready source content based on the verified Milestone 16 behavior. It covers:

- local Household Profile, plans, planning locations, contacts, supplies, roles, preferences, and Payment Preparedness completion;
- optional one-shot location and absence of persistence/history;
- on-device shelter proximity and MET warning matching;
- MET/Geonorge normal network metadata without coordinate transmission;
- Apple MapKit manual area search and Apple Maps handoff;
- external official links;
- user-initiated backup/export/import and selected Files providers;
- local notifications and absence of push notification service/token;
- absence of advertising, analytics, tracking, and ATT;
- retention/deletion limitations and separately retained exports;
- children's privacy using verified facts only;
- policy changes and contact details.

The repository already contains a support URL, privacy URL, owner name, review email, and phone. The policy uses the existing support/privacy URLs and email rather than inventing a contact. The owner must confirm these details are authorized and current.

The configured hosted Privacy Policy URL returned HTTP 200, but its content must be replaced or reconciled with `PRIVACY_POLICY_1.1.md` before submission. Publication was not performed automatically.

## In-app privacy review

`PrivacyDetailsView` was compared with the final policy. Its concise statements remain materially compatible:

- local plans/contacts/roles/supplies/preferences;
- no developer tracking or personal-data upload;
- explicit JSON export;
- on-device reminders;
- separate external-site privacy practices.

It is incomplete compared with the legal policy but does not state that no network requests occur or that external services receive no network metadata. No in-app change was necessary to prevent a material contradiction, so the full legal policy was not duplicated into the product UI.

## App Privacy recommendation

`APP_STORE_PRIVACY_1.1.md` proposes:

- **Data Not Collected**;
- Tracking: **No**;
- no individual developer-collected data categories.

The reference explicitly distinguishes locally processed data from user-requested off-device traffic. It does not claim that no data leaves the device. MET, Geonorge, Apple MapKit, Apple Maps, external websites, and a user-selected Files provider can receive the request/file information necessary for their interactions plus normal network metadata.

The account holder must recheck the current App Store Connect wording and applicable service terms before saving/publishing the answer.

## What's New readiness

`APP_STORE_WHATS_NEW_1.1.md` contains concise English (U.S.), Norwegian Bokmål, and Thai release notes covering:

- event-aware plans;
- smarter household and evacuation supplies;
- payment preparedness;
- official Norwegian emergency numbers;
- public civil-defence-shelter reference information;
- official MET Norway warnings;
- improved offline behavior and attribution;
- accessibility and localization improvements.

The copy describes preparedness support without guaranteeing safety. Thai marketing copy should receive a final fluent-speaker review before entry.

## Existing App Store description review

`APP_STORE_METADATA.md` contains existing English, Norwegian Bokmål, and Thai descriptions. It is available as a baseline, but its 1.0-era copy needs these 1.1 changes before submission:

1. Add the Household Profile and household-aware behavior.
2. Replace the legacy scenario list with the supported event-aware emergency-plan types or describe them at a higher level without omissions.
3. Add smart home/evacuation supply prioritization and Payment Preparedness.
4. Add official country-specific emergency contacts.
5. Add DSB/Geonorge public-shelter reference data and clarify that proximity is not a recommendation.
6. Add official MET Norway warning data, cached freshness labeling, and on-device geographic matching.
7. Add clearer official-source attribution and offline/reference-cache behavior.
8. Update the privacy paragraph: personal preparedness data is not sent to the developer, but user-requested public/Apple service calls use the network and expose normal request metadata.
9. Preserve the safety disclaimer that official instructions take priority and preparedness does not guarantee safety.
10. Keep Norway-only availability deliberate while Norway-specific official integrations are the supported release scope.

The existing historical App Review notes contain two materially incorrect statements for 1.1: they say the app does not request current location and that resulting coordinates are sent to MET/Geonorge. They must not be copied into App Store Connect. `APP_REVIEW_NOTES_1.1.md` contains the corrected review text.

Subtitle, promotional text, keywords, category, age rating, price, availability, and release method should be reviewed manually rather than assumed unchanged from the older record.

## Screenshot readiness

`APP_STORE_SCREENSHOT_PLAN_1.1.md` defines a seven-image iPhone story:

1. Home / preparedness overview.
2. My Emergency Plan.
3. Smart Supplies.
4. Official Weather Warnings.
5. Public Civil-Defence Shelters.
6. Payment Preparedness.
7. Emergency Contacts.

Every image has a proposed headline, required/forbidden content, test-data guidance, and safety constraints. The plan prohibits unlabeled fabricated MET warnings, real personal data, shelter recommendations, and safety guarantees.

Final localized native-resolution screenshot assets were not created or uploaded in this milestone. Existing repository metadata says Norwegian drafts exist, including a 6.9-inch draft that still needed replacement/positioning cleanup, while English and Thai sets had not been captured. Screenshot capture and upload remain manual pre-submission actions.

## App Review Notes readiness

`APP_REVIEW_NOTES_1.1.md` is ready for owner review and manual entry. It accurately documents:

- preparedness-only purpose and safety limits;
- optional one-shot location;
- no coordinate persistence or MET/Geonorge coordinate transmission;
- on-device MET geometry matching and shelter proximity;
- DSB/Geonorge source attribution and neutral shelter results;
- bundled official Norwegian emergency numbers;
- local-only reminders;
- no account, subscription, IAP, advertising, tracking, or analytics;
- user-initiated backup;
- concise exercise instructions for all requested review flows.

The existing review contact details are included and require owner confirmation.

## Official source and public URL verification

Production URLs were taken directly from `GuidanceSourceRegistry` and relevant production views. Verification was performed on 2026-10-02.

| Authority/service | Production links checked | Automated result | Redirects |
|---|---:|---|---:|
| DSB | 6 | Cloudflare JavaScript challenge returned HTTP 403 to the automated client | 0 observed |
| Geonorge | 1 | HTTP 200 | 0 |
| MET Norway | 2 | HTTP 200 | 0 |
| NVE | 1 | HTTP 200 | 0 |
| Politiet | 1 | HTTP 200 | 0 |
| Helsenorge | 1 | HTTP 200 | 0 |
| Configured Privacy Policy | 1 | HTTP 200 | 0 |
| Configured Support URL | 1 | HTTP 200 | 0 |
| Configured Marketing URL | 1 | HTTP 200 | 0 |

No verified broken link or redirect was found. DSB's response body was a Cloudflare “Just a moment…” challenge requiring JavaScript/cookies, not a not-found page. Because an automated client could not reach the underlying content, the six DSB links require a final manual Safari verification before submission. No source was silently replaced.

The DSB pages requiring manual confirmation are:

- Egenberedskap.
- Flood preparedness.
- Oppholdssteder i kriser.
- Public civil-defence-shelter guidance.
- Payment preparedness.
- Fire/110 emergency guidance.

## Final approved test summary

Milestone 15 remains the final release-acceptance baseline:

- 130 unit/compatibility cases passed, 0 failed, 0 skipped, 0 not run.
- 13 UI tests passed, 0 failed, 0 skipped, 0 not run.
- Physical iPhone acceptance passed.
- Airplane-mode/offline acceptance passed.
- Backup/export/import acceptance passed.
- Maximum Dynamic Type acceptance passed.
- Spoken VoiceOver acceptance passed.
- Fresh-install acceptance passed.
- `RELEASE GATE: PASS`.

Milestone 16 completed the privacy audit and targeted privacy regression:

- Location disclosure corrected.
- Privacy tests passed.
- `PRIVACY GATE: PASS`.

## App Store metadata readiness

The repository now contains manual reference documents for the policy, privacy questionnaire, localized What's New, screenshot capture, review notes, and final submission workflow. Nothing was entered into App Store Connect.

The metadata package is ready for owner review, but the App Store record is not ready to submit until the hosted policy, description changes, localizations, screenshots, final archive, link check, and App Store Connect fields are completed.

## Remaining manual owner actions

1. Restart/repair Xcode's Swift macro-plugin and Device Hub/CoreSimulator environment, then create and validate a clean Release archive in Organizer with 0 compiler errors and 0 compiler warnings.
2. Confirm the archive is signed for distribution, contains only expected entitlements, and reports version 1.1 build 3.
3. Publish/reconcile `PRIVACY_POLICY_1.1.md` at the configured Privacy Policy URL and confirm the contact details.
4. Apply the suggested 1.1 description changes in every supported App Store localization.
5. Have a fluent speaker review Thai What's New, description, promotional copy, and screenshots.
6. Capture, review, and upload final native-resolution localized iPhone screenshots.
7. Manually open all six DSB links in Safari and confirm their authority, title/content, and destination.
8. Recheck API/data licence, content-rights, age-rating, export-compliance, categories, keywords, price, Norway-only availability, and release method.
9. Upload/select the final build and complete every checkbox in `APP_STORE_SUBMISSION_CHECKLIST_1.1.md`.
10. Review, save, add for review, and submit only through deliberate owner actions.

## Release blockers

1. A clean Release build and Organizer archive/validation did not complete because the local Xcode Swift macro-plugin server returned malformed responses. The successful generic-device build does not replace the required final Release archive result.
2. The hosted Privacy Policy has not been updated with the verified 1.1 policy content.
3. Final localized App Store screenshots are incomplete and have not been uploaded.
4. Automated verification could not pass DSB's Cloudflare challenge; the six DSB production links still need manual Safari verification.

These blockers require owner/environment actions and do not justify changing production functionality or incrementing build 3 yet. If the final binary changes, increment the build and rerun the relevant gates.

## Final recommendation

Do not submit Disaster Ready 1.1 yet. The written release package is complete and ready for owner use, but the final Release archive, hosted policy publication, screenshots, and DSB manual link verification must be completed first. After those items pass without a binary change, build 3 can proceed through the manual App Store Connect checklist.

Milestone 18 was not started. Work stops after Milestone 17.

APP STORE PACKAGE: NOT READY
