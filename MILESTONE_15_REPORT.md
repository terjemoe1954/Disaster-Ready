# Milestone 15 — Release Testing and Regression

Date: 2026-10-02  
Release candidate: **Disaster Ready 1.1 (3)**  
Release decision: **PASS**. Milestone 16 was not started.

## Scope

Milestone 15 was treated as a release gate. No product feature, persistence model, cache format, backup schema, or safety behavior was added as part of recording the final acceptance results.

## Final acceptance summary

All release-blocking automated and manual acceptance checks completed successfully for Disaster Ready 1.1 (3).

| Acceptance area | Result |
|---|---:|
| Existing-user upgrade and data preservation | PASS |
| Physical airplane-mode and offline behavior | PASS |
| Public Shelters location | PASS |
| Emergency phone handoff | PASS |
| Maximum Dynamic Type | PASS |
| Spoken VoiceOver | PASS |
| Backup, export, and import | PASS |
| Fresh install | PASS |
| Unit/compatibility tests | 130 passed, 0 failed, 0 skipped, 0 not run |
| UI tests | 13 passed, 0 failed, 0 skipped, 0 not run |
| Final device-compatible build | PASS |
| Compiler diagnostics | 0 errors, 0 warnings |

## Existing-user upgrade and data preservation

Manual acceptance passed on the physical **iPhone 15 Pro running iOS 27.0.1** with the Disaster Ready 1.1 (3) release candidate installed over the existing installation.

- Existing user data remained present.
- Settings and Household Profile values were changed.
- The changes remained after the app was terminated and restarted.

Result: **PASS**.

## Airplane mode and offline behavior

Manual airplane-mode acceptance passed on the physical iPhone.

- Disaster Ready remained usable in airplane mode.
- Previously downloaded Public Civil-Defence Shelter records remained available offline.
- The external MET official web link correctly failed through Safari while no internet connection was available.
- Core local functionality remained usable.

Result: **PASS**.

## Public Shelters location

`Use My Location` returned nearby public shelters on the physical iPhone, and the approximate distances appeared reasonable. This information remains neutral proximity information and is not a shelter recommendation.

Result: **PASS**.

## Emergency phone handoff

Manual handoff acceptance verified all supported numbers:

- 110
- 112
- 113
- 116 117

Each flow displayed the expected service and number and required explicit confirmation before handing off to Phone. No emergency call was completed.

Result: **PASS**.

## Accessibility

Representative critical screens remained readable, scrollable, and usable at the maximum accessibility text size. Representative critical flows were also manually checked with spoken VoiceOver and were understandable.

- Maximum Dynamic Type: **PASS**.
- Spoken VoiceOver: **PASS**.

## Backup, export, and import

Manual backup acceptance passed.

- Backup export succeeded.
- The backup file was available in Files.
- Import and restore succeeded.
- Representative contacts, supplies, plan/location, and household data remained present.
- Restored data persisted after the app was restarted.

Result: **PASS**.

## Fresh install

A fresh-install acceptance was completed successfully on the simulator without deleting or disturbing the physical iPhone's migrated user data.

Result: **PASS**.

## Automated verification

| Scope | Passed | Failed | Skipped | Not run |
|---|---:|---:|---:|---:|
| Unit/compatibility executed cases | 130 | 0 | 0 | 0 |
| UI tests | 13 | 0 | 0 | 0 |

The final device-compatible build succeeded with **0 compiler errors and 0 compiler warnings**.

## Simulator infrastructure note

Earlier XCUIAutomation failures were resolved after manually booting the existing iPhone 17 Pro simulator and starting/restarting Device Hub. The final UI suite then passed completely.

Known working simulator:

- Device: iPhone 17 Pro
- UUID: `CC9AEBFC-BD22-4DCA-A3F5-19FCBDE90D92`
- OS: iOS 27.0

This was an Xcode/Simulator environment workaround and is not a Disaster Ready product defect.

## Final blocker review

The previous release blockers and verification gaps are closed by the final results:

1. Physical-iPhone release acceptance was completed on iPhone 15 Pro / iOS 27.0.1.
2. Existing-user upgrade/data preservation, physical offline behavior, Public Shelters location, emergency Phone handoff, maximum Dynamic Type, spoken VoiceOver, and manual backup/restore all passed.
3. Fresh-install runtime acceptance passed on the simulator without disturbing migrated physical-device data.
4. The recovered complete UI suite passed, as did all unit/compatibility cases and the final device-compatible build.

No release-blocking issue remains for Disaster Ready 1.1 (3).

RELEASE GATE: PASS
