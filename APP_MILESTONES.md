# Disaster Ready Milestones

## Milestone 1: Local Offline Core

Status: In progress

Goal:
Ship a strong single-device preparedness app that works without internet and helps a household make decisions quickly.

Scope:
- Scenario guidance for earthquake, invasion, flood/tsunami, storm, brownout, and volcano
- Local `SwiftData` storage for contacts, supplies, and household plan
- Offline-first design with no cloud dependency
- Emergency supply tracking for home and car
- One-tap family update sharing
- English, Norwegian, and Thai support

Exit criteria:
- Core flows work on-device with no network connection
- Data survives app relaunch
- UI is stable on iPhone sizes you plan to support

## Milestone 2: App Store Release Preparation

Status: Next

Goal:
Prepare the local-first app for a public App Store release.

Scope:
- First-launch onboarding
- Settings for language and local behavior
- App Store readiness polish and release messaging
- Accessibility pass
- Privacy review and user-facing copy cleanup
- App icon, screenshots, metadata, and final QA

Exit criteria:
- Release build is polished enough for store submission
- Copy and flows clearly explain offline value
- Basic testing is complete across supported devices

## Milestone 3: Local-First Hardening

Status: Future

Goal:
Improve trust and resilience for offline use before adding collaboration.

Scope:
- Backup/export and import for local data
- Safer reset and recovery flows
- Data migration strategy for future versions
- More complete offline guides and cached references

Exit criteria:
- Users can recover or move their local data
- Upgrades do not risk silent data loss

## Milestone 4: Optional iCloud Sync

Status: Future

Goal:
Introduce sharing and sync without breaking offline-first behavior.

Scope:
- Optional iCloud sync for household data
- Sync retries when connectivity returns
- Clear local-vs-shared state in the UI
- Conflict handling for concurrent edits

Exit criteria:
- The app still works fully offline on one device
- Sync is additive, not required

## Milestone 5: Household Admin Roles

Status: Future

Goal:
Allow one person to manage shared household data for others.

Scope:
- Owner/admin/member roles
- Admin can add and update plans, contacts, and supplies
- Per-user editing permissions
- Change history for important updates

Exit criteria:
- Shared households can safely manage one source of truth
- Admin actions are visible and auditable

## Milestone 6: Collaboration and Operations

Status: Future

Goal:
Turn the product into a robust shared preparedness system.

Scope:
- Invitations and household joining flow
- Read receipts or acknowledgements for updates
- Shared drills and assignment tracking
- Better operational alerts and review workflows

Exit criteria:
- Multi-person coordination works reliably
- Household updates remain usable in low-connectivity situations

## Product Principles

- Local-first is the default architecture.
- Offline use must remain possible at every milestone.
- iCloud sharing should be optional, not required.
- Admin capabilities should layer on top of local data, not replace it.
