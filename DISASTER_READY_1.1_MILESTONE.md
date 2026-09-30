# Disaster Ready 1.1 -- Milestone & Implementation Specification

**Project:** Disaster Ready\
**Target:** iOS / SwiftUI, version 1.1\
**Goal:** Turn the current generic preparedness checklist into an
event-aware, locally relevant preparedness planner, with Norway as the
first deeply adapted country.

## Core safety principle

The app must separate **preparedness planning** from **live official
instructions**. Official instructions always take priority. Disaster
Ready must never invent or present an AI-generated location as an
official evacuation point, shelter, or safe location.

Suggested wording: *"Suggested type of location for preparedness
planning. Follow current instructions from local authorities during an
actual emergency."*

## Milestone 1 -- Audit 1.0.1

-   Review existing Models, Views, Services, persistence and
    localization.
-   Preserve all existing user data during migration.
-   Identify current gas shutoff, meeting place, safe place, contacts,
    supplies and evacuation fields.
-   Keep working functionality; do not perform a broad rewrite.
-   Add/update folders: `Models`, `Views`, `Services`, `Data`, `Config`,
    `Resources`.
-   Add unit-test target if missing.
-   Verify that 1.0.1 data opens correctly in the 1.1 development build.

## Milestone 2 -- Household Profile

Create a lightweight profile:

``` swift
struct HouseholdProfile: Codable {
    var countryCode: String
    var municipality: String?
    var householdSize: Int
    var hasChildren: Bool
    var hasPets: Bool
    var hasElectricHeating: Bool
    var hasWoodStove: Bool
    var hasGasInstallation: Bool
    var hasAlternativeHeating: Bool
    var hasCar: Bool
    var hasEV: Bool
    var hasSpecialAssistanceNeeds: Bool
}
```

Requirements: - Default country from locale, but allow manual change. -
Gas guidance only when `hasGasInstallation == true`. - For Norway, gas
shutoff is not a universal/default task. - Add knowledge of water
stopcock and main electrical panel. - Profile remains editable in
Settings. - Do not collect unnecessary personal information.

## Milestone 3 -- Emergency Types

Initial types:

``` swift
enum EmergencyType: String, Codable, CaseIterable, Identifiable {
    case powerOutage
    case flood
    case extremeWeather
    case landslide
    case wildfire
    case houseFire
    case waterOutage
    case evacuation
    case hazardousRelease
    case warOrSecurityIncident
}
```

Use structured offline templates:

``` swift
struct EmergencyPlanTemplate: Codable, Identifiable {
    let id: String
    let type: EmergencyType
    let titleKey: String
    let summaryKey: String
    let actions: [PreparednessAction]
    let shelterGuidance: [ShelterGuidance]
    let supplyPriorities: [SupplyItem]
    let evacuationItems: [SupplyItem]
    let sourceIDs: [String]
}
```

Every important recommendation should be traceable to an official
source.

## Milestone 4 -- Event-aware "My Plan"

Flow:

**Select emergency → What to do → Where to shelter/go → Meeting place →
Supplies → Contacts → Save**

Replace generic empty "safe place" fields with contextual planning
guidance.

Examples: - Flood: plan a location outside the affected/risk area and
follow evacuation instructions. - Extreme weather: robust indoor shelter
appropriate to the official warning. - Fire: predetermined outdoor
meeting place at a safe distance. - Evacuation: family/friends/cabin, or
an official evacuation centre if authorities establish one. -
War/security incident: follow official instructions; shelter-in-place or
civil-defence shelter only when appropriate.

Allow users to save household meeting point, alternative accommodation,
family/friend location, cabin/secondary home and a personal safe-place
note. Never label a user-entered place as officially approved.

## Milestone 5 -- Smart Supply Lists

Create separate **home preparedness** and **grab/evacuation** lists.

Norwegian home-preparedness categories: - water - shelf-stable food -
cooking method - warmth/clothing/blankets - lighting - radio -
batteries - power banks - medicines - first aid - hygiene - pet supplies
when applicable - payment preparedness

Evacuation priorities: - identification - necessary medicines -
assistive devices - phone and charger/power bank - warm
clothing/blanket - food and drink - bank cards and cash - essential
child/pet supplies - critical documents where appropriate

Implement:

``` swift
func prioritizedSupplies(
    for emergency: EmergencyType,
    household: HouseholdProfile
) -> [SupplyItem]
```

Event-specific additions must supplement, not silently replace, the base
list.

## Milestone 6 -- Payment Preparedness

Add a dedicated card/checklist for Norway: - some cash available -
useful smaller denominations - more than one payment card where
practical - physical card suitable for Norwegian payment
infrastructure - consider more than one payment option/bank

Do not prescribe a fixed cash amount unless a current authoritative
source does so. Never request/store card numbers, PINs, BankID secrets
or banking credentials.

## Milestone 7 -- Official Source Architecture

``` swift
struct GuidanceSource: Codable, Identifiable {
    let id: String
    let authority: String
    let title: String
    let url: URL
    let countryCode: String
    let lastReviewed: Date
}
```

Prioritize: - DSB -- preparedness, evacuation, sheltering, civil-defence
shelters - MET Norway -- official weather warnings - NVE --
authoritative flood/landslide information where appropriate -
municipalities -- only where reliable structured data exists

UI should support: **Source**, **Reviewed date**, and **View official
advice**.

## Milestone 8 -- Public Civil-Defence Shelters

Use only authoritative/open official data.

-   Show public shelters on map/list where reliable data is available.
-   Show source and update information.
-   Distinguish civil-defence shelters from ordinary meeting/safe
    places.
-   Never tell the user to travel to a shelter merely because it is
    nearby.
-   Explain that authority instructions determine when shelters should
    be used.
-   Location permission is optional; manual area search must be
    possible.
-   Cache reference data where licensing and size permit.

``` swift
protocol ShelterService {
    func nearbyShelters(latitude: Double, longitude: Double) async throws -> [Shelter]
}
```

## Milestone 9 -- MET Norway Alerts

Integrate MetAlerts 2.0 after static preparedness functionality is
stable.

``` swift
protocol WeatherAlertService {
    func activeAlerts(latitude: Double, longitude: Double) async throws -> [OfficialAlert]
}
```

Requirements: - HTTPS and correct MET User-Agent/terms. - Responsible
caching. - Handle Alert / Update / Cancel. - Respect validity and
expiry. - Preserve official warning severity. - Clearly attribute MET
Norway. - Never present expired cached alerts as live. - Offline UI
shows last-update timestamp.

Architecture: **Official API → decoder → normalized OfficialAlert →
local cache → UI**.

Do not put AI between the official warning and the safety instruction.

## Milestone 10 -- Offline First

Offline: - household profile - saved plans - core preparedness
guidance - supply lists - contacts - meeting locations - source
metadata - downloaded reference data where permitted

Dynamic cached data must show **Last updated**. Stale information must
not be presented as current.

## Milestone 11 -- Emergency Contacts

Use country-specific official configuration and user-created trusted
contacts.

``` swift
struct EmergencyContact: Codable, Identifiable {
    var id: UUID
    var name: String
    var relationship: String?
    var phoneNumber: String
}
```

Do not hard-code Norwegian emergency numbers globally.

## Milestone 12 -- Localization

Preserve existing supported languages. At minimum maintain English,
Norwegian and Thai if already supported.

All new UI strings go through localization resources. Do not
machine-translate safety-critical official advice at runtime and present
it as an official translation.

## Milestone 13 -- Suggested Home Screen

``` text
DISASTER READY

Preparedness status
████████░░ 78%

[ Build My Emergency Plan ]

My plans
• Power outage
• Flood
• Evacuation

Home preparedness
• Water
• Food
• Heat
• Power & communication
• Medicines
• Payment preparedness

Official information
• Weather warnings
• Civil-defence shelters
• Sources

My household
Settings
```

Failure of an online service must never make the offline preparedness
features unusable.

## Milestone 14 -- Mandatory Safety Rules

1.  Official instructions override templates.
2.  Never invent an evacuation centre.
3.  Never invent an official shelter.
4.  Never call a user-selected location "officially safe."
5.  Never use AI to decide that a location is safe during an active
    emergency.
6.  Clearly attribute sources.
7.  Show freshness timestamps for dynamic data.
8.  Handle API failures safely.
9.  Never turn cached expired alerts into current alerts.
10. Never claim preparedness guarantees safety.

Suggested About/Settings text:

> Disaster Ready is a preparedness planning tool and does not replace
> instructions from emergency services or public authorities.

## Milestone 15 -- Testing

Unit tests: - event → correct template - event → correct supplies - no
gas installation → no gas-specific tasks - gas enabled → relevant gas
preparedness appears - pets → pet supplies added - MET decoding -
Alert/Update/Cancel - expired alerts not active - cache timestamps -
source mapping - migration from 1.0.1

Manual scenarios: 1. Norwegian apartment, no gas, electric heating. 2.
Home with gas explicitly enabled. 3. Flood plan. 4. Airplane mode/no
internet. 5. Active/update/cancelled weather warning. 6. Upgrade from
App Store 1.0.1 (2) with existing data.

## Milestone 16 -- Privacy

-   Ask for location only for a user-requested location feature.
-   Explain why it is needed.
-   Prefer on-device storage for preparedness plans.
-   Review App Store Privacy answers and Privacy Policy if data handling
    changes.
-   Do not send precise location to a server unless necessary and
    disclosed.

## Milestone 17 -- TestFlight and App Store

Before submission: - increment version/build - migration test from 1.0.1
(2) - physical iPhone test - airplane-mode test - fresh-install test -
existing-user upgrade test - localization and accessibility test -
verify every official link and source review date - verify API terms -
update screenshots/description/privacy where needed - archive →
TestFlight → regression test → App Store Review

# Codex implementation order

Codex must stop for build/test verification after each phase:

1.  Audit 1.0.1.
2.  Add/migrate models without losing data.
3.  Household Profile.
4.  Emergency Types and offline templates.
5.  Event-aware My Plan.
6.  Smart supply lists.
7.  Payment Preparedness.
8.  Source registry/UI.
9.  Civil-defence-shelter service.
10. MetAlerts.
11. Offline/cache completion.
12. Localization.
13. Unit/UI regression tests.
14. TestFlight preparation.

**Do not broadly rewrite the existing app. Prefer small, compilable
changes.**

# Codex starter prompt

``` text
Read DISASTER_READY_1.1_MILESTONE.md completely before changing code.

First inspect the existing Disaster Ready 1.0.1 codebase and compare its architecture and functionality with the specification.

Do not start a large rewrite.

Create a short implementation report containing:
1. Existing models, views, services and persistence.
2. Which 1.1 requirements already exist.
3. Which existing data requires migration.
4. Proposed files to add or modify.
5. Risks that could cause existing user data to be lost.
6. A phased implementation plan matching the milestone order.

Then implement Milestone 1 only.
Build/test after the changes and report any errors before proceeding to Milestone 2.
```

# Authoritative development references

Recheck these before release because public guidance and APIs can
change:

-   DSB -- Oppholdssteder i kriser:
    https://www.dsb.no/sikkerhverdag/egenberedskap/oppholdssteder-i-kriser/
-   DSB -- Egenberedskap:
    https://www.dsb.no/sikkerhverdag/egenberedskap/
-   MET Norway -- MetAlerts 2.0:
    https://api.met.no/weatherapi/metalerts/2.0/documentation
-   MET Weather API docs: https://docs.api.met.no/doc/

For NVE flood/landslide functionality, verify the current authoritative
API/data source and terms before implementation rather than hard-coding
an assumed endpoint.

# Release definition of done

1.  Norwegian users no longer receive irrelevant gas guidance by
    default.
2.  Plans adapt to the selected emergency.
3.  Safe-place guidance is contextual but never falsely presented as
    official.
4.  Home and evacuation supplies are prioritized.
5.  Cash/payment preparedness is included.
6.  Core planning works offline.
7.  Dynamic official information is sourced and timestamped.
8.  Existing 1.0.1 user data survives upgrade.
9.  Safety-critical flows have tests.
10. Build passes and the TestFlight regression checklist is complete.
