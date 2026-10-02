# Disaster Ready 1.1 — App Review Notes

Disaster Ready is a household-preparedness planning tool. It helps users prepare plans, supplies, contacts, and reference information before an emergency. It does not replace instructions from emergency services or public authorities and does not claim that preparedness guarantees safety.

No account or login is required. The app has no subscription, In-App Purchase, advertising, tracking, or analytics integration.

## Privacy and system access

- Household profiles, plans, contacts, supplies, Payment Preparedness completion, and preferences are stored locally on the device.
- Location is optional and is requested only after the reviewer taps **Use My Location** in Public Shelters or Official Weather Warnings.
- The app uses a one-shot When In Use location request. It does not continuously track location, request background location, store coordinates, or create location history.
- User coordinates are not sent to MET Norway or DSB/Geonorge.
- MET national official warning geometry is downloaded, and geographic matching occurs on-device.
- DSB/Geonorge provides the official public civil-defence-shelter reference register. Shelter proximity is calculated on-device. A nearby result is neutral proximity information, not a recommendation to use or travel to a shelter.
- Manual MET area search uses Apple MapKit to resolve the entered Norwegian place. **View on Map** explicitly hands the selected shelter coordinate/name to Apple Maps.
- Official Norwegian emergency numbers are bundled, country-specific reference information. Emergency call handoff requires explicit confirmation; reviewers should not complete an emergency call.
- Supply reminders use local notifications only. There is no APNs registration, push token, or push-notification service.
- Backup export/import is user initiated through Apple's Files interface.

Direct requests to public services and Apple services carry normal network/request metadata such as public IP address. The app does not claim that no data leaves the device.

## Suggested review flow

1. Complete or dismiss the introductory flow to reach Home.
2. **My Plan:** Open My Plan, select an emergency type, review the contextual actions and shelter/go guidance, enter fictional planning text, and save. Official-instructions disclaimers remain visible in the flow.
3. **Public Shelters — manual search:** Open Public Shelters from Home's Official Information tools or the Supplies area. Enter a Norwegian address fragment or municipality and tap Search. The query is matched locally against the downloaded DSB/Geonorge register.
4. **Public Shelters — Use My Location:** Tap **Use My Location**. Grant When In Use access if prompted. Nearby records and approximate distances are calculated on-device. The UI states that proximity is not a shelter recommendation.
5. **MET — manual area search:** Open Official Weather Warnings, enter a Norwegian municipality, town, or address, and tap Search. Apple MapKit resolves the place; Disaster Ready downloads national MET geometry and matches it locally.
6. **MET — Use My Location:** Tap **Use My Location** to exercise the optional one-shot location path. No coordinate is placed in the MET request.
7. **Payment Preparedness:** Open Supplies and review the Norwegian Payment Preparedness checklist. It stores completion only and asks for no financial credentials or amounts.
8. **Official Emergency Contacts:** Open Contacts and review 110 (fire), 112 (police), 113 (medical emergency), and 116 117 (out-of-hours medical). Selecting Call presents explicit confirmation. Cancel without placing a call.
9. **Backup and local reminders:** In Settings, the reviewer may export/import a fictional JSON backup and optionally enable a local supply reminder. No server account is involved.

Core planning remains available offline. Online public data and external source pages require connectivity; cached reference information is labeled with freshness/cache status.

## Review contact

Terje Moe  
terjemoe54@hotmail.com  
+47 99594576

The contact details above are taken from the repository's existing App Store metadata and must be confirmed by the owner before submission.
