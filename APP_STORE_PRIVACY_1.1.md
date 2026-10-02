# Disaster Ready 1.1 — App Store Privacy Reference

Release candidate: **1.1 (3)**  
Privacy baseline: `MILESTONE_16_REPORT.md` — **PRIVACY GATE: PASS**

## Proposed App Store Connect answer

| App Store Connect question | Proposed answer |
|---|---|
| Does this app or its third-party partners collect data from this app? | **No — Data Not Collected** |
| Is data used to track users? | **No** |
| Privacy Policy URL | `https://terjemoe1954.github.io/app-page/disaster-ready/privacy/` |
| User Privacy Choices URL | Leave blank unless the owner adds a relevant mechanism |

No individual App Privacy data-type categories are proposed because verified production code sends no user data to the developer or a developer-controlled backend and contains no advertising, analytics, tracking, account, or crash-reporting SDK.

## What stays local

The Household Profile, household plans and personal planning notes, Family Contacts, Important Numbers, supplies, Payment Preparedness checklist completion, preferences, and local reminder schedules are processed in the app's local container. One-shot location is processed transiently and is not persisted.

Locally processed information should not be marked as developer-collected solely because it exists on the device.

## User-controlled export

A backup leaves the app only after explicit export through Apple's Files interface. The user selects the destination, which may be local or a configured cloud/file provider. The file contains the user-created data listed in `PRIVACY_POLICY_1.1.md`; it contains no location history, reference caches, or banking credentials.

## Important qualification: network use exists

Do **not** describe the app as “no data leaves the device.” During user-requested interactions:

- MET Norway receives a direct HTTPS request for national warning data and normal request metadata such as public IP address, app User-Agent, language/domain parameters, and cache validators. Disaster Ready adds no user coordinates.
- DSB/Geonorge receives a fixed national WFS shelter-register request, app User-Agent, and normal network metadata such as public IP address. Disaster Ready adds no user coordinates or manual shelter query.
- Apple MapKit receives the place text entered for a manual MET area search, with “Norway” added.
- Apple Maps receives the selected shelter's coordinate and displayed name/address after **View on Map**. Disaster Ready does not add the user's current coordinate.
- Official websites receive ordinary browser requests when the user opens their links.
- A selected Files/cloud provider receives an exported backup only after the user chooses that destination.

These are public-authority, Apple-service, browser, or user-selected file-provider interactions—not developer advertising or tracking services. Disaster Ready does not have access to or control over their server logs.

## Before saving App Privacy answers

- [ ] Confirm the hosted Privacy Policy has been updated to match `PRIVACY_POLICY_1.1.md`.
- [ ] Re-read the current App Store Connect question wording.
- [ ] Confirm current MET, Geonorge, Apple, and selected-provider terms do not make their retained service logs data collection by a third-party partner on the developer's behalf.
- [ ] If a new backend, SDK, diagnostics service, analytics service, advertising service, cloud-sync feature, or push provider was added after this audit, stop and reassess every answer.
- [ ] Save the answers, review the product-page privacy preview, and publish manually.

This document is a manual submission reference. It does not submit or publish any App Store Connect data.
