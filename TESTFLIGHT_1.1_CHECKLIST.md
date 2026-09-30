# Disaster Ready 1.1 TestFlight checklist

Prepared: 30 September 2026

## Automated preflight completed

- [x] Marketing version updated to `1.1`.
- [x] Build number updated from `2` to `3`.
- [x] Bundle identifier remains `com.terjemoe.Disaster-Ready`.
- [x] Project builds successfully with the active iPhone scheme.
- [x] 36 unit tests pass.
- [x] 8 UI tests pass when run separately.
- [x] Migration tests cover legacy 1.0.1 backup data and household-profile migration.
- [x] MET Alert/Update/Cancel, expiry, cache timestamp and source mapping are tested.
- [x] Norwegian Bokmål and Thai String Catalogs have no untranslated or review-pending entries.
- [x] Privacy manifest declares no tracking or collected-data categories and declares UserDefaults access reason `CA92.1`.

## Official-link review

- [x] DSB preparedness: `https://www.dsb.no/sikkerhverdag/egenberedskap/`
- [x] MET weather and warning information: `https://www.met.no/en/weather-and-climate`
- [x] NVE natural hazards: `https://www.nve.no/naturfare/`
- [x] DSB official map: `https://kart.dsb.no/`
- [x] MET MetAlerts documentation: `https://api.met.no/weatherapi/metalerts/2.0/documentation`

The three app website URLs respond over HTTPS, but their published text currently describes a home-assets and maintenance app rather than Disaster Ready's emergency-preparedness functionality. Correct these pages before submitting build 3:

- [ ] Privacy policy: `https://terjemoe1954.github.io/app-page/disaster-ready/privacy/`
- [ ] Support page: `https://terjemoe1954.github.io/app-page/disaster-ready/support/`
- [ ] Marketing page: `https://terjemoe1954.github.io/app-page/disaster-ready/`

The privacy policy must disclose that a manual place search is geocoded by Apple Maps and that the resulting coordinates are sent to MET Norway or Geonorge to retrieve warnings or nearby public shelters. The app does not request the device's current location.

## Manual device and upgrade checks required

- [ ] Install App Store version 1.0.1 (2) on a physical iPhone with representative existing contacts, plans, roles and supplies.
- [ ] Install 1.1 (3) over it and confirm all existing data remains intact.
- [ ] Confirm the migrated household size and newly created emergency-type plans.
- [ ] Test a fresh installation and complete onboarding.
- [ ] Test core plans, contacts and supplies in airplane mode.
- [ ] While online, test weather-warning and public-shelter searches for a Norwegian place.
- [ ] Return to airplane mode and confirm saved reference data shows its timestamp and saved-copy label.
- [ ] Verify Norwegian, English and Thai UI on a physical iPhone.
- [ ] Check VoiceOver, large Dynamic Type and sufficient contrast on safety-critical screens.
- [ ] Confirm notification permission is requested only after the user requests a reminder.

## App Store Connect and TestFlight

- [ ] Update App Store description and screenshots to include the 1.1 household profile, event-aware plans, weather warnings, public shelters and payment preparedness.
- [ ] Confirm availability remains Norway-only.
- [ ] Reconfirm App Privacy answers after publishing the corrected privacy policy.
- [ ] Complete the current age-rating questionnaire.
- [ ] Create a Release archive for a generic iOS device.
- [ ] Run Xcode archive validation and resolve every error before upload.
- [ ] Upload build 1.1 (3) to App Store Connect.
- [ ] Wait for processing and review export-compliance status.
- [ ] Add internal TestFlight testing notes, including the manual scenarios above.
- [ ] Complete the physical-device regression before submitting for App Review.

Do not submit build 3 while any website-content, migration, physical-device or archive-validation item above remains unchecked.
