# Disaster Ready 1.1 — Manual App Store Submission Checklist

Release candidate: **1.1 (3)**  
Bundle ID: `com.terjemoe.Disaster-Ready`

This checklist is manual. No upload, App Store Connect change, review action, or submission has been performed automatically.

## Build and record

- [ ] Confirm the App Store Connect version record is **1.1**.
- [ ] Create a fresh Release archive in Xcode Organizer from the final reviewed commit/worktree.
- [ ] Validate the archive in Organizer with 0 blocking issues.
- [ ] Upload build **3** manually and wait for processing.
- [ ] Confirm build **3** reports the expected bundle ID, version, device family, privacy manifest, export-compliance value, and signing team.
- [ ] Select build **3** for version 1.1.
- [ ] If any binary-affecting change is made after build 3 is uploaded, increment the build number, repeat release testing, and update all documents that identify the build.

## URLs and privacy

- [ ] Publish `PRIVACY_POLICY_1.1.md` at the configured Privacy Policy URL.
- [ ] Confirm `https://terjemoe1954.github.io/app-page/disaster-ready/privacy/` shows the final 1.1 policy over HTTPS.
- [ ] Confirm the Support URL works: `https://terjemoe1954.github.io/app-page/disaster-ready/support/`.
- [ ] Confirm the support/privacy owner name, email, phone, and URLs are current and authorized for publication.
- [ ] Review App Privacy using `APP_STORE_PRIVACY_1.1.md`.
- [ ] Set **Data Not Collected** only after reviewing the current questionnaire wording and service terms.
- [ ] Confirm tracking is **No**.
- [ ] Save/publish the App Privacy answers manually and inspect the product-page preview.

## Product-page metadata

- [ ] Enter the localized What's New text from `APP_STORE_WHATS_NEW_1.1.md`.
- [ ] Review the existing description and apply the 1.1 changes listed in `MILESTONE_17_REPORT.md`.
- [ ] Remove outdated claims that imply no network data leaves the device.
- [ ] Review subtitle and promotional text in Norwegian Bokmål, English (U.S.), and Thai.
- [ ] Review keywords in every localization and confirm current character/byte limits.
- [ ] Have a fluent Thai reviewer approve Thai marketing copy.
- [ ] Review primary category **Lifestyle** and secondary category **Utilities**.
- [ ] Review age-rating answers; confirm the final rating in App Store Connect.
- [ ] Review pricing and availability; keep Free/Norway-only only if still deliberate.
- [ ] Review release method; do not assume the historical automatic-release selection is still desired.

## Screenshots

- [ ] Confirm required iPhone screenshot sizes in App Store Connect.
- [ ] Capture/review the sequence in `APP_STORE_SCREENSHOT_PLAN_1.1.md`.
- [ ] Upload final native-resolution Norwegian Bokmål screenshots.
- [ ] Upload final native-resolution English screenshots.
- [ ] Upload final native-resolution Thai screenshots.
- [ ] Check every screenshot for personal data, fabricated warnings, stale emergency information, and safety overclaims.
- [ ] Preview final order and localization on the product page.

## Compliance and rights

- [ ] Review export compliance; project currently declares `ITSAppUsesNonExemptEncryption = NO`.
- [ ] Review content-rights answers for linked/attributed DSB, Geonorge, MET, NVE, Helsenorge, and Politiet material.
- [ ] Confirm current MET and Geonorge API/data licence and attribution requirements.
- [ ] Manually open the six DSB production pages in Safari; automated verification was blocked by Cloudflare, not a confirmed broken link.
- [ ] Recheck every official URL immediately before submission.
- [ ] Confirm no unexpected entitlement, capability, framework, SDK, subscription, or In-App Purchase was added.

## App Review

- [ ] Confirm review contact information is current.
- [ ] Paste/review `APP_REVIEW_NOTES_1.1.md` in App Review Notes.
- [ ] Confirm sign-in required is **No** and demo account is not applicable.
- [ ] Ensure the reviewer can exercise location on the uploaded build and that no emergency call must be completed.
- [ ] Add an attachment only if App Review specifically needs one.

## Final technical confirmation

- [ ] Confirm Milestone 15 remains `RELEASE GATE: PASS`.
- [ ] Confirm Milestone 16 remains `PRIVACY GATE: PASS`.
- [ ] Resolve the local command-line Swift macro-plugin/Device Hub environment issue and complete a clean Release build/archive in Xcode Organizer.
- [ ] Confirm final archive diagnostics: 0 compiler errors and 0 compiler warnings.
- [ ] Confirm the selected build is produced from the reviewed 1.1 (3) source and privacy disclosure.

## App Store Connect final actions

- [ ] Review version 1.1 record.
- [ ] Review description.
- [ ] Review keywords.
- [ ] Review category.
- [ ] Review age rating.
- [ ] Review export compliance.
- [ ] Review content rights.
- [ ] Review pricing/availability.
- [ ] Review Privacy Policy URL and Support URL.
- [ ] Review App Privacy.
- [ ] Review screenshots.
- [ ] Review What's New.
- [ ] Review contact information.
- [ ] Review App Review Notes.
- [ ] Confirm final build selected.
- [ ] Click **Save**.
- [ ] Click **Add for Review** only when every item above is complete.
- [ ] Click **Submit for Review** only after the owner performs a final product-page and binary review.
