# Disaster Ready Privacy Policy

Effective date: 2026-10-02  
Applies to: Disaster Ready 1.1

Disaster Ready is a household-preparedness planning app designed to keep user-created preparedness information available locally on an iPhone. This policy explains what the app stores, how optional online features work, and the choices available to the user.

## 1. Information stored locally

Disaster Ready stores preparedness information in the app's private container on the device. The developer does not operate an account system or backend for this information.

Locally stored information may include:

- Household Profile settings such as country, optional municipality, household size, children or pets, heating and gas configuration, vehicle information, special-assistance needs, and whether the household knows the water stopcock and electrical panel locations;
- household plans, role assignments, meeting points, evacuation destinations, alternative accommodation, family/friend or secondary-home locations, safe-place notes, utility notes, and a user-entered family password/code;
- Family Contacts and Important Numbers entered directly in Disaster Ready, including names, roles or labels, phone numbers, and notes;
- supply names, details, quantities, storage categories, completion state, and review dates;
- Payment Preparedness checklist completion;
- app preferences such as language, appearance, onboarding state, filters, and reminder settings.

Personal planning locations are free-text notes. Disaster Ready does not certify them as safe or official locations.

## 2. Location use

Location access is optional. Disaster Ready requests When In Use location permission only after the user chooses **Use My Location** in Public Shelters or Official Weather Warnings.

The app requests a one-time location reading. It does not continuously track location, request background location updates, store the user's coordinate, or create a location history.

Manual alternatives are available without granting location permission.

## 3. Public Civil-Defence Shelters

Disaster Ready downloads the official public civil-defence-shelter reference register from DSB/Geonorge. The request downloads the national reference dataset and does not include the user's latitude or longitude.

When **Use My Location** is selected, Disaster Ready calculates approximate shelter distances and filters nearby results on the device. The user's lookup origin is not written to the shelter cache or backup. A nearby shelter is neutral proximity information, not a recommendation to travel there. Users must follow current instructions from public authorities.

Manual shelter search is performed locally against downloaded official register fields.

## 4. MET Norway weather warnings

Disaster Ready makes direct HTTPS requests from the device to MET Norway to download national official warning content and geographic warning boundaries. Disaster Ready does not add the user's latitude or longitude to the MET request.

When a location is selected, Disaster Ready compares it with the downloaded official warning geometry on the device. The coordinate is not stored in the MET cache and no location history is created.

MET receives normal network/request information needed to serve an HTTPS request, including the device's public IP address, request time, the Disaster Ready User-Agent, selected response language, cache-validation information, and the requested national land domain. MET's handling of its service logs is governed by MET's own terms and privacy practices.

## 5. DSB/Geonorge network requests

The Geonorge service receives a fixed request for the official national shelter register, the Disaster Ready User-Agent, and normal HTTPS network information such as the device's public IP address. Disaster Ready does not include the user's location, household data, contacts, plans, or supplies in this request.

DSB/Geonorge controls its own service infrastructure and privacy practices.

## 6. Apple MapKit manual area search

If the user manually searches for a municipality, town, or address in Official Weather Warnings, Disaster Ready sends the entered search text, with “Norway” added for context, to Apple's MapKit service. Apple returns a coordinate that Disaster Ready uses transiently for on-device warning matching. Disaster Ready does not keep a MapKit search history.

Apple processes MapKit requests according to Apple's terms and privacy practices.

## 7. Apple Maps and other external links

When the user chooses **View on Map** for a shelter, Disaster Ready opens Apple Maps with the selected official shelter's coordinate and displayed name or address. Disaster Ready does not add the user's current coordinate or request a route. Apple Maps may use other information available to Apple's service under Apple's terms.

Official source, licence, and alert links open external authority websites after the user selects them. Those sites receive normal browser/network information and apply their own privacy practices. Disaster Ready does not store the resulting browsing history.

Phone and message actions hand a user-selected number to iOS using the system Phone or Messages interface. Disaster Ready does not store the resulting call or message history.

## 8. Backup, export, and import

Backup export and import are initiated by the user through Apple's Files interface.

An exported JSON backup contains the export date, household member count and Household Profile, user-created contacts and important numbers, household plans and personal planning notes, role assignments, and supply information. The backup may contain personal information entered by the user, including phone numbers and a family password/code field.

The backup does not contain device-location history, shelter or MET reference caches, pending notifications, banking credentials, or Payment Preparedness checklist completion in the version 1 backup format.

The user chooses where to save the file. The destination may be on the device or with a Files/cloud provider selected and configured by the user. Disaster Ready does not control that provider's privacy, security, or retention practices. Exported files remain at the chosen destination until the user deletes them.

An imported file is read only after the user selects it. Disaster Ready validates supported backup structure and asks for confirmation before replacing the covered local records.

## 9. Notifications

Supply-review reminders are optional local notifications. Notification permission is requested only when the user enables reminders. Reminder content, identifiers, and schedules are created on the device.

Disaster Ready 1.1 has no push-notification service, does not register an APNs device token, and does not send reminder data to a notification server.

## 10. Payment Preparedness

Payment Preparedness stores only which checklist items have been marked complete and a country code. It does not request or store account numbers, card numbers, PINs, BankID credentials, banking passwords, balances, or cash amounts.

Users should not enter banking credentials in general free-text fields.

## 11. Contacts

Family Contacts and Important Numbers are created inside Disaster Ready. The app does not request Contacts permission, read the system address book, or upload these records. They leave the app only if the user explicitly exports a backup or uses an iOS call/message handoff.

## 12. Advertising, analytics, and tracking

Disaster Ready 1.1 contains no advertising SDK, analytics SDK, tracking SDK, cross-app tracking, advertising-identifier access, or App Tracking Transparency request. It does not show advertising.

The app does contact public information services and Apple services for user-requested features as described above. This network use must not be interpreted as a claim that no data ever leaves the device.

## 13. Retention and deletion

Local data remains in the app container until the user edits or deletes it, uses a reset action that covers that category, or deletes the app. The current reset action replaces contacts, plans, roles, and supplies with app defaults and removes pending supply reminders; it does not clear every preference, Household Profile value, or Payment Preparedness completion state.

The operating system may remove cache files when storage is needed. Deleting the app removes its local container subject to normal iOS backup/restore behavior. Exported backups are separate files and must be deleted separately from every local or cloud destination where the user saved them.

## 14. Children's privacy

Disaster Ready has no child account, login, or child-directed upload pipeline. A Household Profile may record a `hasChildren` preparedness flag, and user-entered plans or contacts may concern household members. That information remains in local app storage unless the user explicitly exports a backup.

This policy does not make an unverified claim about a legal age threshold or whether the app is directed to children.

## 15. Changes to this policy

This policy may be updated when Disaster Ready's features or data practices change. The effective date at the top identifies the current version. Material changes should be published at the Privacy Policy URL before or with the app update they describe.

## 16. Support and privacy contact

Support: https://terjemoe1954.github.io/app-page/disaster-ready/support/  
Privacy policy: https://terjemoe1954.github.io/app-page/disaster-ready/privacy/  
Email: terjemoe54@hotmail.com

These contact details were taken from the repository's existing App Store metadata and must be confirmed by the owner before publication.
