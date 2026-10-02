# Milestone 16 — Privacy Review

Date: 2026-10-02  
Release candidate: **Disaster Ready 1.1 (3)**  
Milestone 15 release gate: **PASS**

## Privacy audit summary

The production source, project configuration, privacy manifest, persistence models, caches, backup schema, permissions, dependencies, and network paths were reviewed for Disaster Ready 1.1 (3).

Preparedness data is stored in the app's local container using SwiftData and UserDefaults. Disaster Ready has no developer-operated account system, backend, analytics pipeline, advertising integration, or tracking integration. The app does make direct network requests from the device to public information services, uses Apple MapKit for a user-requested MET area search, hands shelter details to Apple Maps only after the user selects **View on Map**, and opens user-selected official web links externally. Those external interactions carry normal network metadata such as the device's public IP address even though Disaster Ready does not add the user's coordinates to MET or Geonorge requests.

One privacy disclosure defect was found and corrected: the location usage description mentioned shelter distances but omitted on-device MET warning matching. The corrected description covers both one-shot uses without broadening the requested permission or changing functionality.

No release-blocking privacy issue remains after that correction.

## On-device data inventory

### SwiftData

The following user-created or user-edited records are persisted in the app's local SwiftData store:

| Model | Stored fields |
|---|---|
| `FamilyContact` | Identifier, name, role, phone number, notes |
| `ImportantNumber` | Identifier, label, phone number, notes |
| `HouseholdPlan` | Emergency/scenario identifier; reunion point; evacuation destination; shelter-zone note; gas-shutoff note; medical and pet leads; family password/code text; alternative accommodation; family/friend location; secondary home; personal safe-place note; water-stopcock note; main-electrical-panel note |
| `HouseholdRole` | Identifier, role title, assigned person's text, task, system-image name |
| `SupplyItem` | Identifier, item name and detail, packed/completion state, home/car storage category, quantity text, review date |

Personal planning locations are free-text notes. They are not geocoded, validated as safe, or uploaded by Disaster Ready.

### UserDefaults and app preferences

The app stores:

- `HouseholdProfile`, encoded under `householdProfile.v1`: country code, optional municipality text, household size, children/pets flags, heating and gas flags, car/EV flags, special-assistance flag, and water-stopcock/electrical-panel knowledge flags.
- The legacy synchronized household-size integer.
- `PaymentPreparednessChecklist`, encoded under `paymentPreparedness.checklist.v1`: country code and the identifiers of completed checklist items only.
- Language, appearance, onboarding completion, plan-summary sharing preference, missing-supplies filter, offline-first preference, household-member count, and supply-reminder enabled state.

The app may migrate older payment checklist booleans from legacy UserDefaults keys. It does not create an account or associate these preferences with a developer-side identity.

### Transient memory only

- A one-shot device coordinate and the last coordinate used by the currently presented shelter or weather-warning view may exist temporarily in memory.
- Shelter result snapshots may temporarily carry the lookup origin so distances can be displayed.
- Manual shelter and MET search text exists in view state while the view is active.

None of these lookup origins or search histories is written by Disaster Ready to SwiftData, UserDefaults, the shelter cache, the MET cache, or the JSON backup.

### Data not collected or stored by Disaster Ready

The production app has no developer account identifier, email/login collection, address-book import, advertising identifier, ATT status collection, analytics event stream, diagnostic SDK upload, purchase history, financial account data, or continuous/background location history.

## Transmitted-data inventory

### A. Developer/app collection

No production code transmits household profiles, plans, personal planning locations, contacts, important numbers, supplies, payment checklist state, reminder data, or backups to the developer or to a developer-controlled service. No developer backend is configured.

### B. Data processed locally

SwiftData and UserDefaults content, supply reminder scheduling, shelter proximity calculation, and MET warning-geometry matching are processed locally on the device. Local processing alone is not treated as developer collection in the proposed App Store Privacy answer.

### C. External service requests and network metadata

Network use is not equivalent to “no data leaves the device.” When the device contacts MET, Geonorge, Apple, or an official website, the destination service normally receives request-level network information such as public IP address, TLS/HTTP metadata, date/time, and service-specific request fields. Disaster Ready does not receive or store those services' server logs and does not control their privacy or retention practices.

Specific request data is documented in the external-service inventory below.

## Location behavior

Location permission is optional. Manual shelter search remains available without it, and manual MET area search is available through MapKit.

`ShelterLocationProvider` creates a `CLLocationManager` configured to kilometer-level desired accuracy. It asks for When In Use authorization and calls `requestLocation()` only after the user explicitly chooses **Use My Location**. It does not call `startUpdatingLocation()`, enable background location updates, or implement continuous tracking.

### Public Shelters

- Permission is requested only after **Use My Location**.
- The request is one-shot.
- The returned coordinate is held transiently; it is not persisted and no history is created.
- Geonorge receives a fixed national WFS `GetFeature` request. User latitude and longitude are absent from its URL, query items, and headers.
- The national public-shelter reference dataset is decoded and cached.
- Distance sorting and the 25 km proximity filter are calculated on-device from the transient origin.
- Manual shelter search downloads/uses the same official register and searches its official fields locally; the manual query is not sent to Geonorge.

### MET weather warnings

- Permission is requested only after **Use My Location**.
- The request is one-shot and optional.
- The MET request downloads national land-domain warning geometry from `current.json`.
- User latitude and longitude are absent from the MET URL, query items, and headers.
- Geographic containment matching between the user-selected/transient coordinate and official warning geometry occurs on-device.
- The user coordinate is not written to the MET cache and no location history is created.
- A manual municipality/town/address search uses `MKLocalSearch`; the entered query, suffixed with “Norway,” is sent to Apple's MapKit service to obtain a coordinate. The query and result are not persisted by Disaster Ready.

### Apple Maps handoff

When a user explicitly chooses **View on Map**, Disaster Ready opens an Apple Maps HTTPS URL containing the selected official shelter's coordinates and displayed name/address. This is an external iOS/web handoff. Disaster Ready does not add the user's current location, request a route, or store a Maps interaction history. Apple Maps may process the shelter destination and normal network/device context under Apple's terms; that processing is distinct from collection by Disaster Ready.

## External-service inventory

| Service | Purpose | Data/request sent | User location sent? | Initiation | Stored by Disaster Ready |
|---|---|---|---|---|---|
| MET Norway MetAlerts 2.0 | Download official national weather-warning geometry and content | HTTPS GET for `current.json`; `lang`; `geographicDomain=land`; app User-Agent; Accept header; optional `If-Modified-Since`; normal network metadata including public IP | **No coordinates are added to the MET request** | A user performs area search or chooses **Use My Location**; cached data can avoid a new request until expiry | Official alerts/geometry plus language, fetch/check timestamps, HTTP cache metadata, diagnostics, and `Last-Modified` |
| DSB / Geonorge WFS | Download the official public civil-defence-shelter reference register | Fixed HTTPS WFS `GetFeature` parameters, app User-Agent, and normal network metadata including public IP | **No** | A user performs shelter search or chooses **Use My Location** | Official shelter records plus cache refresh/schema metadata |
| Apple MapKit local search | Resolve a manually entered MET area into a coordinate | User-entered municipality/town/address query plus “Norway,” and normal Apple service metadata | Disaster Ready does not add the device's Core Location coordinate; the entered place may itself identify a location | Explicit **Search** action | No persistent MapKit query or result history |
| Apple Maps | Display a selected official shelter | Shelter coordinate and displayed name/address in a `maps.apple.com` URL, plus normal external-service metadata | The shelter destination is sent; the user's current location is not added by Disaster Ready | Explicit **View on Map** action | No Maps history stored by Disaster Ready |
| Official authority websites | Show official guidance, source pages, licences, or alert web pages | Selected URL and normal browser/network metadata, including public IP | Not added by Disaster Ready | Explicit link selection | No browsing history stored by Disaster Ready |
| Phone and Messages handoff | Call or message a number selected in the app | Sanitized selected phone number in `tel:` or `sms:` URL; emergency calls require explicit confirmation | No | Explicit user action | No call/message history stored by Disaster Ready |
| Apple Files and selected file provider | Export or import a JSON backup | The backup document or selected import file | No location history is included | Explicit export/import action | Only transient in-app transfer state; the destination retains the exported file |

These public-authority integrations are official information services, not third-party tracking services.

## MET network privacy

MET requests are direct HTTPS requests from the device to `api.met.no`. MET necessarily receives normal network information, including the device's public IP address, to serve the HTTPS request. The request also identifies `DisasterReady/1.1` in its User-Agent, requests Norwegian or English national land-domain warning data, and may send `If-Modified-Since` for cache revalidation.

Disaster Ready does **not** put the user's latitude, longitude, personal planning data, household data, contact data, or payment checklist into the MET request. The downloaded national geometry is matched against the transient coordinate on-device.

## Backup and privacy behavior

Backup export and import are user initiated through SwiftUI's Apple file exporter/importer interfaces.

The JSON backup contains:

- schema version and export date;
- household member count and full `HouseholdProfile`;
- user-created family contacts and important numbers;
- household plans, including personal location notes and family password/code text;
- household role assignments;
- supply names/details, packed state, storage category, quantity text, and review dates.

The version 1 backup schema does **not** include:

- Payment Preparedness checklist completion;
- general app preferences;
- pending local notifications;
- current or historical device coordinates;
- shelter or MET caches;
- banking credentials or sensitive banking fields.

The user selects the destination through Apple's Files interface. The destination can be local storage or a file provider/cloud service chosen and configured by the user. Once exported, the file is outside Disaster Ready's sandbox and is retained until the user deletes it from that destination. Disaster Ready does not control or make claims for the privacy, security, retention, or policy of the chosen Files/cloud provider.

Imports use a user-selected security-scoped file, validate the supported schema and basic constraints, and require confirmation before replacing the covered local records.

## Cache privacy

### Shelter cache

`public-shelters-cache.json` is stored in the app's Caches directory. It contains:

- official shelter ID, room number, address, capacity, coordinates, source ID, and official data-update date where supplied;
- cache refresh date;
- cache schema version.

The coordinates in this file belong to official shelter records. The cache does not contain the user's lookup coordinate, manual search query, lookup origin, or location history. Legacy development cache data with the old coordinate-bound schema is rejected and removed.

### MET cache

`met-alerts-cache-v2.json` is stored in the app's Caches directory. It contains:

- official normalized alert text, status/lifecycle, severity, validity, source IDs, warning geometry, and official web URL where supplied;
- fetch/check dates and selected response language;
- `Last-Modified`, expiry, and cache-control metadata;
- limited service diagnostics such as throttling/deprecation state.

It does not contain the user's lookup coordinate, manual MapKit search query, lookup origin, or location history.

Both caches contain official/reference data and cache metadata only. They are excluded from the app's user-created JSON backup.

## Payment privacy

Payment Preparedness persists only the country code and which of five preparedness checklist items are complete. Production models and stores contain no fields for:

- account numbers;
- card numbers;
- PINs;
- BankID credentials;
- passwords;
- balances;
- cash amounts.

The `HouseholdPlan.familyPassword` field is preparedness-plan text and is unrelated to banking credentials; it can be included in a user-exported backup. Users should not put banking passwords or credentials into free-text fields.

## Contacts privacy

The app does not import `Contacts` or `ContactsUI`, has no Contacts usage-description key, requests no address-book permission, and contains no address-book import flow. `FamilyContact` and `ImportantNumber` records are created or edited inside Disaster Ready and stored in SwiftData. They are not uploaded by Disaster Ready. They are included only when the user explicitly exports a backup.

Call and message buttons hand the selected number to iOS through `tel:` or `sms:` after user action; Disaster Ready stores no resulting communication history.

## Notification behavior

Supply review reminders are local notifications scheduled with `UNUserNotificationCenter` on the device. Authorization is requested only when the user enables reminders. Pending notification identifiers are derived locally from supply UUIDs, and reminder content uses the local supply name and review date. A test notification can be scheduled locally after permission exists.

No production entitlement or source path for APNs was found. The project has no `aps-environment` entitlement, no remote-notification background mode, no remote-notification registration call, no device-token handling, and no push-provider or messaging SDK. Disaster Ready therefore has local reminders only and no push notification service/token in 1.1 (3).

## Tracking, advertising, and analytics audit

Production source, target configuration, linked frameworks, package dependencies, entitlements, and privacy manifest were checked.

- Advertising SDKs: **none**.
- Analytics SDKs: **none**.
- Tracking SDKs: **none**.
- Third-party Swift packages/products: **none**.
- ATT request or AppTrackingTransparency import: **none**.
- Cross-app tracking code: **none**.
- Advertising identifier/AdSupport use: **none**.
- Tracking domains declared by the app: **none**.

Apple-provided frameworks in use include SwiftUI, SwiftData, Foundation/URLSession, Core Location, MapKit, UserNotifications, UIKit, and UniformTypeIdentifiers/FileDocument. Their use does not introduce a developer advertising or tracking integration.

## Privacy Manifest result

The root `PrivacyInfo.xcprivacy` is included in the app target's Resources build phase. It declares:

- `NSPrivacyTracking = false`;
- no tracking domains;
- no developer-collected data types;
- UserDefaults required-reason API category with reason `CA92.1`.

Static review found UserDefaults access and no other production use of a required-reason API category needing an additional declaration. There are no third-party SDKs and therefore no third-party SDK privacy manifests to merge or audit. No Privacy Manifest change is required for 1.1 (3).

The manifest's empty collected-data declaration is consistent with the proposed developer collection answer below; external public-service/Apple request behavior is still documented separately and must not be described as “no data leaves the device.”

## Info.plist permission result

Only When In Use location permission is configured. No Always/background location capability is present. There is no Contacts permission string and no tracking permission string.

The previous location string was incomplete because it described only shelter distance calculation. It was corrected in the generated Info.plist build setting and English, Norwegian Bokmål, and Thai InfoPlist string-catalog entries.

Final English text:

> Disaster Ready uses one location reading when you choose Use My Location to calculate shelter distances or match official weather warnings. Your location is not stored.

This wording accurately describes the optional, explicit, one-shot behavior and does not imply continuous/background use.

## Proposed App Store Connect App Privacy answers

This proposal is based on verified production behavior and separates developer collection from local processing and external service network traffic.

### App Privacy questionnaire

**Does this app or its third-party partners collect data from this app? — No / Data Not Collected.**

Rationale:

- No user or device data is transmitted to the developer or a developer-controlled server.
- Household/profile, plan, contact, supply, payment-completion, and reminder data remains in the local app container unless the user explicitly exports a backup to a destination they select.
- Disaster Ready has no analytics, advertising, tracking, account, or crash-reporting SDK.
- One-shot Core Location results are processed locally and are not persisted.
- User coordinates are not sent to MET or Geonorge.

Accordingly, no App Store data-type category is proposed as developer-collected and no data is used for tracking.

### Important submission qualification

The app nevertheless performs user-requested off-device service calls:

- MET and Geonorge receive normal request/network metadata such as public IP address.
- Apple MapKit receives a manual MET area-search query.
- Apple Maps receives the selected shelter destination after **View on Map**.
- External official websites receive ordinary browser requests when opened.
- A user-selected Files/cloud provider receives a backup only when the user exports it there.

These flows are not developer-controlled collection and are not evidence that the locally stored preparedness fields are “collected” by the developer. Before submission, the App Store Connect account holder should confirm the then-current Apple questionnaire wording and the applicable service terms/retention practices. If Apple or a service contract treats retained service logs as collection by a third-party partner on the developer's behalf, the answer must be adjusted to the applicable category; this code audit found no evidence of developer access to or control over such logs.

## Existing Privacy Policy review and required changes

No standalone privacy-policy document or hosted policy content is present in the repository. The app does contain an in-app `PrivacyDetailsView`, which currently states that personal data is not sent to the developer, lists plans/contacts/roles/supplies/preferences as local, notes user-initiated JSON backup, local reminders, and external website privacy practices.

For a release-ready 1.1 policy, the in-app content and the hosted policy used by App Store Connect should be expanded with these exact changes:

1. Add Household Profile fields and Payment Preparedness completion to the local-storage inventory.
2. Explain optional one-shot When In Use location, the two **Use My Location** entry points, no continuous/background tracking, no persistence, and no location history.
3. Explain that shelter distance calculation and MET geometry matching occur on-device and that user coordinates are not sent to Geonorge or MET.
4. State that direct HTTPS requests to MET and Geonorge expose normal network metadata, including public IP address, to those services.
5. Disclose manual MET area lookup through Apple MapKit, including transmission of the entered place query to Apple.
6. Explain the explicit Apple Maps handoff and that the selected shelter coordinate/name—not the user's current coordinate—is placed in the Maps URL by Disaster Ready.
7. Enumerate the JSON backup contents and exclusions, including the fact that Payment Preparedness completion is not in schema version 1.
8. State that the user chooses the Files destination, which may be local or a cloud provider, and that the provider has its own privacy/retention practices outside Disaster Ready's control.
9. Explain local-only notification scheduling and the absence of a push service/token.
10. State that FamilyContact and ImportantNumber are entered in-app, no Contacts permission/import is used, and contacts are not uploaded by Disaster Ready.
11. State that Payment Preparedness stores checklist completion only and does not request/store banking identifiers, credentials, balances, or cash amounts.
12. Identify the absence of advertising, analytics, tracking, ATT, and advertising-identifier use.
13. Add precise retention/deletion wording: app-container data remains until edited, reset where the reset function covers it, or the app is deleted; caches may be purged by the OS; exported backups must be deleted separately from their chosen destination. Do not claim that the current reset action clears every UserDefaults value, because it does not clear Household Profile or Payment Preparedness state.
14. Add a children's-privacy section stating only verified facts: no child account or child-directed data pipeline exists; the profile can store a `hasChildren` flag and user-entered plans/contacts may concern household members; this content stays local unless exported. Do not invent an age threshold or legal representation without product-owner/legal confirmation.
15. Add policy effective date/version, how material changes will be communicated, and a real support/privacy contact supplied by the product owner. No company or contact details were invented in this report.

### Release-ready Privacy Policy outline

1. **Information stored on device** — SwiftData records, Household Profile, preferences, and Payment Preparedness completion.
2. **Location use** — optional user action, one-shot request, on-device calculation/matching, no storage/history.
3. **Official/public data services** — why MET and DSB/Geonorge are contacted and normal HTTPS metadata.
4. **MET weather-warning requests** — national geometry, request fields, no user coordinate in request, local matching, cache.
5. **Public shelter data** — national reference download, local manual/proximity search, cache contents.
6. **Apple Maps and external links** — explicit handoffs, data placed in URLs, separate provider policies.
7. **Backups** — user initiation, exact contents/exclusions, Files destination and provider responsibility, imported-file handling.
8. **Notifications** — local authorization and scheduling; no push token/service.
9. **Payment Preparedness** — checklist completion only; prohibited banking data not requested/stored.
10. **Tracking, advertising, and analytics** — none in 1.1 (3).
11. **Data retention and deletion** — local retention, scope of reset, uninstall, cache lifecycle, separately retained exports.
12. **Children's privacy** — limited verified household-child flag behavior; no account/upload pipeline.
13. **Changes to this policy** — effective date/version and notification approach supplied by the owner.
14. **Contact/support** — owner-provided support/privacy contact; placeholder must not ship.

## Tests and static checks

### Targeted automated privacy regression

Ten selected tests passed: **10 passed, 0 failed, 0 skipped, 0 not run**.

They verified:

- MET HTTPS request identification without coordinate disclosure;
- conditional MET refresh without coordinates;
- Geonorge shelter requests without user coordinates;
- no lookup origin/location history or financial credentials in reference caches;
- shelter cache has no lookup location history;
- no sensitive Payment Preparedness fields;
- user backup excludes reference caches and retains compatibility;
- backup payload round-trip integrity;
- no Contacts permission/upload behavior;
- stable local reminder identifiers.

### Static checks

| Required check | Result | Evidence summary |
|---|---:|---|
| 1. No location persistence | PASS | Coordinate exists only in transient provider/view/snapshot state; not in persisted user models/stores |
| 2. No location history | PASS | No history model/store; both cache schemas exclude lookup origin/history |
| 3. No coordinates in shelter request | PASS | Fixed national WFS request and passing regression test |
| 4. No coordinates in MET request | PASS | National `current.json` request with language/domain only and passing regression tests |
| 5. No sensitive banking fields | PASS | Checklist stores completed IDs/country only; test forbids account/card/PIN/BankID/password/balance/amount fields |
| 6. No Contacts permission | PASS | No Contacts imports, usage key, address-book flow, or permission request |
| 7. No tracking SDK | PASS | Source, target dependencies, frameworks, and manifest checked |
| 8. No advertising SDK | PASS | No packages/products or advertising frameworks/APIs |
| 9. No analytics SDK | PASS | No packages/products or analytics imports/calls |
| 10. Caches excluded from backup | PASS | Backup schema has no cache fields; passing regression test |
| 11. User backup contains expected user data only | PASS | Schema and export construction inspected; round-trip passed; exact inclusions/exclusions documented above |
| 12. Local notification behavior documented | PASS | `UNUserNotificationCenter` local scheduling inspected; no push entitlement/registration/token path |
| 13. External service inventory complete | PASS | All production network URLs, URLSession calls, MapKit search, Maps handoff, official links, Files, phone, and SMS handoffs reviewed |

## Build result

After the location disclosure correction, the Xcode project built successfully in **21.483 seconds**.

- Compiler errors: **0**.
- Compiler warnings: **0**.
- Xcode build-log warnings: **0**.

## Files changed in Milestone 16

- `Disaster Ready.xcodeproj/project.pbxproj` — corrected generated Info.plist location purpose string for Debug and Release.
- `Disaster Ready/Disaster Ready-InfoPlist.xcstrings` — corrected English, Norwegian Bokmål, and Thai location disclosure text.
- `MILESTONE_16_REPORT.md` — final privacy audit and release documentation.

No product functionality was added or changed.

## Release-blocking privacy issues

None. The incomplete location purpose disclosure was corrected and verified by a successful build.

## Remaining TODOs

- Publish or update the hosted Privacy Policy used by App Store Connect using the required changes and outline above.
- Supply the real policy owner/contact, support channel, effective date, and change-notification language; none were invented here.
- Enter and review the proposed **Data Not Collected** App Privacy response in App Store Connect against the questionnaire wording shown at submission time and current external-service terms.
- Keep the Privacy Manifest, privacy answers, purpose strings, and policy synchronized if a future release adds a backend, cloud sync, diagnostics, analytics, advertising, push notifications, new permissions, or new SDKs.

Milestone 17 was not started.

PRIVACY GATE: PASS
