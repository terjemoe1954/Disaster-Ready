# Disaster Ready 1.1 — iPhone Screenshot Plan

## Capture rules

- Capture native-resolution iPhone screenshots accepted by the current App Store Connect media manager.
- Prepare localized sets for Norwegian Bokmål, English (U.S.), and Thai.
- Use a clean release build with representative fictional test data only. Never show a real person's name, phone number, address, planning location, exported filename, or notification.
- Keep system alerts, keyboards, debug overlays, location indicators, Safari, and unrelated status banners out of final captures unless a screenshot explicitly demonstrates a system permission flow. This sequence does not require permission-alert screenshots.
- Do not imply that preparedness guarantees safety or that a nearby shelter is recommended.
- Do not fabricate a live MET warning. Prefer a neutral “no active warning” or clearly labeled cached/demo state. If demonstration content is composited or seeded, label it visibly as demonstration content and confirm it is acceptable under current Apple screenshot policy before upload.
- Use only official-source names and data already presented by the production app. Do not add authority logos or endorsement claims.

## Recommended sequence

### 1. Home / preparedness overview

**Headline:** Your household preparedness at a glance  
**Screen/state:** Home after onboarding, with a representative Household Profile and partially completed preparedness status.  
**Must be visible:** Disaster Ready title/navigation, preparedness status, primary emergency-plan action, Home Preparedness, and at least part of Official Information or My Household.  
**Must not be visible:** Real household details, permission dialogs, failure alerts, development labels, or a claim that the percentage measures safety.  
**Test data:** Fictional test data is recommended.  
**Safety:** Frame the status as checklist progress, not readiness certification or a guarantee.

### 2. My Emergency Plan

**Headline:** Plan clear actions for different emergencies  
**Screen/state:** My Plan with a representative emergency type selected and one or two guided sections visible.  
**Must be visible:** Emergency selector, contextual action/shelter guidance, and the statement that official instructions take priority.  
**Must not be visible:** A real address, actual family password, invented evacuation centre, or user-entered location described as officially safe.  
**Test data:** Use neutral fictional text such as “Family meeting point.”  
**Safety:** The composition must preserve the official-instructions disclaimer and must not imply the app selects a safe destination.

### 3. Smart Supplies

**Headline:** Prioritize supplies for home and evacuation  
**Screen/state:** Supplies showing smart recommendations and representative home/evacuation categories.  
**Must be visible:** Separate home and evacuation priorities, packed/missing state, and household-aware recommendations such as child/pet items only when the test profile supports them.  
**Must not be visible:** Real medicine details, excessive quantities presented as official mandates, stale search text, or an open editor/keyboard.  
**Test data:** Fictional supply entries are acceptable; bundled recommendations are preferred.  
**Safety:** Avoid suggesting that completing a list guarantees safety.

### 4. Official Weather Warnings

**Headline:** Check official MET Norway warnings  
**Screen/state:** Official Weather Warnings with source attribution, location/manual search controls, and either no active warnings or a legitimate current production response.  
**Must be visible:** MET Norway attribution, freshness/cached state where applicable, manual search, **Use My Location**, and the no-guarantee wording if no alerts are shown.  
**Must not be visible:** Fabricated live alert content, a misleading “all safe” state, location permission dialog, a real entered home address, or an unexplained stale warning.  
**Test data:** Do not use fabricated live data. Clearly labeled demo content is acceptable only after current Apple policy confirmation.  
**Safety:** Preserve official severity and instructions exactly; do not imply that absence of a displayed warning guarantees safety.

### 5. Public Civil-Defence Shelters

**Headline:** Explore official public shelter reference data  
**Screen/state:** Public Shelters after a generic manual search or a location lookup, showing one or more official records and approximate distance where available.  
**Must be visible:** DSB/Geonorge attribution, manual search, **Use My Location**, official-data marker, and the message that nearby does not mean recommended.  
**Must not be visible:** A real lookup origin, a route, “go here” language, a selected shelter labeled safe/open, or an active permission alert.  
**Test data:** An official shelter record may be shown; use a generic city/municipality query and avoid exposing the user's actual location.  
**Safety:** Nearby shelter information is neutral reference information. Authority instructions determine whether and when shelters should be used.

### 6. Payment Preparedness

**Headline:** Prepare more than one way to pay  
**Screen/state:** Norwegian Payment Preparedness checklist with a mix of completed and incomplete items.  
**Must be visible:** Checklist-only design and source/disclaimer language.  
**Must not be visible:** Cash amounts, account/card numbers, PINs, BankID information, balances, credentials, or a prescribed amount.  
**Test data:** Checklist completion is acceptable; no financial test data is needed or permitted.  
**Safety:** Do not present checklist completion as financial advice or a guarantee that payment will work.

### 7. Emergency Contacts

**Headline:** Keep official numbers and trusted contacts ready  
**Screen/state:** Contacts showing the official Norwegian numbers and one or two obviously fictional household contacts.  
**Must be visible:** 110, 112, 113, and 116 117 with correct service labels; separation between official numbers and user-created contacts.  
**Must not be visible:** Real phone numbers or names, an active call-confirmation alert, a completed call, medical triage claims, or non-Norwegian official numbers presented as universal.  
**Test data:** Fictional names/numbers are acceptable for user-created contacts; official numbers must remain exact.  
**Safety:** Emergency call handoff requires explicit action. Screenshots must not encourage test calls to emergency services.

## Capture completion checklist

- [ ] Final accepted iPhone display sizes confirmed in App Store Connect.
- [ ] Norwegian Bokmål sequence captured and reviewed.
- [ ] English sequence captured and reviewed.
- [ ] Thai sequence captured and reviewed by a fluent speaker.
- [ ] Every image checked for personal data and stale/live safety information.
- [ ] Headlines checked against App Store screenshot text limits and legibility.
- [ ] No screenshot overclaims official endorsement, shelter suitability, or guaranteed safety.
- [ ] Uploaded images previewed in App Store Connect in final order.
