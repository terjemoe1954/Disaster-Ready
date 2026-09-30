import SwiftUI

struct EventAwareMyPlanView: View {
    @Binding var selectedEmergencyType: EmergencyType
    @Bindable var plan: HouseholdPlan
    let household: HouseholdProfile
    let familyContacts: [FamilyContact]
    let importantNumbers: [ImportantNumber]
    let language: AppLanguage
    let openContacts: () -> Void
    let savePlan: () -> Bool

    @State private var saveSucceeded: Bool?

    var body: some View {
        VStack(spacing: 16) {
            EmergencyTypePickerSection(
                selection: $selectedEmergencyType,
                language: language
            )

            SafetyContextSection(language: language)

            if let template {
                MyPlanActionsStep(template: template, language: language)
                MyPlanShelterStep(template: template, language: language)
                MyPlanLocationsStep(
                    plan: plan,
                    emergencyType: selectedEmergencyType,
                    language: language
                )
                MyPlanSuppliesPreviewStep(template: template, language: language)
                MyPlanContactsStep(
                    familyContacts: familyContacts,
                    importantNumbers: importantNumbers,
                    language: language,
                    openContacts: openContacts
                )
                MyPlanSaveStep(
                    saveSucceeded: saveSucceeded,
                    language: language,
                    save: {
                        saveSucceeded = savePlan()
                    }
                )
            } else {
                ContentUnavailableView(
                    L10n.text("myplan.country_template_unavailable.title", language: language),
                    systemImage: "globe",
                    description: Text(L10n.text("myplan.country_template_unavailable.detail", language: language))
                )
                .padding(20)
                .background(DashboardCardBackground())
            }
        }
    }

    private var template: EmergencyPlanTemplate? {
        EmergencyTemplateCatalog
            .provider(for: household.countryCode)?
            .template(for: selectedEmergencyType, household: household)
    }
}

private struct SafetyContextSection: View {
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text("myplan.safety_context.title", language: language))
                .font(.title3.weight(.bold))
                .accessibilityHeading(.h2)

            contextRow(
                icon: "mappin.and.ellipse",
                titleKey: "myplan.context.personal.title",
                detailKey: "myplan.context.personal.detail",
                color: .blue
            )
            contextRow(
                icon: "book.closed.fill",
                titleKey: "myplan.context.preparedness.title",
                detailKey: "myplan.context.preparedness.detail",
                color: .green
            )
            contextRow(
                icon: "antenna.radiowaves.left.and.right",
                titleKey: "myplan.context.official.title",
                detailKey: "myplan.context.official.detail",
                color: .orange
            )
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private func contextRow(
        icon: String,
        titleKey: String,
        detailKey: String,
        color: Color
    ) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.text(titleKey, language: language))
                    .font(.headline)
                Text(L10n.text(detailKey, language: language))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(color)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MyPlanActionsStep: View {
    let template: EmergencyPlanTemplate
    let language: AppLanguage

    var body: some View {
        MyPlanStepCard(number: 1, titleKey: "myplan.actions.title", icon: "checklist", language: language) {
            Text(L10n.text(template.summaryKey, language: language))
                .foregroundStyle(.secondary)

            actionGroup(
                titleKey: "myplan.actions.now.title",
                detailKey: "myplan.actions.now.detail",
                actions: template.actions.filter { !$0.id.contains("followOfficial") },
                color: .green
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.text("myplan.actions.during.title", language: language))
                    .font(.headline)
                Text(L10n.text("myplan.actions.during.detail", language: language))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.blue.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .combine)

            actionGroup(
                titleKey: "myplan.actions.official.title",
                detailKey: "myplan.actions.official.detail",
                actions: template.actions.filter { $0.id.contains("followOfficial") },
                color: .orange
            )
        }
    }

    private func actionGroup(
        titleKey: String,
        detailKey: String,
        actions: [PreparednessAction],
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.text(titleKey, language: language))
                .font(.headline)
            Text(L10n.text(detailKey, language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ForEach(actions) { action in
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.text(action.titleKey, language: language))
                            .font(.headline)
                        Text(L10n.text(action.detailKey, language: language))
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(color)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(12)
        .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct MyPlanShelterStep: View {
    let template: EmergencyPlanTemplate
    let language: AppLanguage

    var body: some View {
        MyPlanStepCard(number: 2, titleKey: "myplan.shelter.title", icon: "building.2.crop.circle", language: language) {
            ForEach(template.shelterGuidance) { guidance in
                VStack(alignment: .leading, spacing: 6) {
                    Label(L10n.text(guidance.titleKey, language: language), systemImage: "signpost.right.fill")
                        .font(.headline)
                    Text(L10n.text(guidance.detailKey, language: language))
                    Text(L10n.text(guidance.safetyNoticeKey, language: language))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

private struct MyPlanLocationsStep: View {
    @Bindable var plan: HouseholdPlan
    let emergencyType: EmergencyType
    let language: AppLanguage

    var body: some View {
        MyPlanStepCard(number: 3, titleKey: "myplan.locations.title", icon: "mappin.and.ellipse", language: language) {
            Text(L10n.text("myplan.locations.personal_notice", language: language))
                .font(.footnote)
                .foregroundStyle(.secondary)

            locationField("myplan.location.meeting_point", text: $plan.reunionPoint, identifier: "householdMeetingPointField")

            if emergencyType == .evacuation {
                locationField("myplan.location.family_friend", text: optionalBinding(for: \HouseholdPlan.familyFriendLocation), identifier: "familyFriendLocationField")
                locationField("myplan.location.secondary_home", text: optionalBinding(for: \HouseholdPlan.secondaryHome), identifier: "secondaryHomeField")
                locationField("myplan.location.alternative", text: optionalBinding(for: \HouseholdPlan.alternativeAccommodation), identifier: "alternativeAccommodationField")
            }

            locationField("myplan.location.evacuation_legacy", text: $plan.evacuationDestination, identifier: "evacuationDestinationField")
            locationField("myplan.location.shelter_legacy", text: $plan.shelterZone, identifier: "shelterZoneField")
            locationField("myplan.location.personal_note", text: optionalBinding(for: \HouseholdPlan.safePlaceNote), identifier: "personalSafePlaceNoteField", axis: .vertical)
        }
    }

    private func optionalBinding(
        for keyPath: ReferenceWritableKeyPath<HouseholdPlan, String?>
    ) -> Binding<String> {
        Binding(
            get: { plan[keyPath: keyPath] ?? "" },
            set: { value in plan[keyPath: keyPath] = value.isEmpty ? nil : value }
        )
    }

    private func locationField(
        _ titleKey: String,
        text: Binding<String>,
        identifier: String,
        axis: Axis = .horizontal
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.text(titleKey, language: language))
                .font(.headline)
            TextField(
                L10n.text(titleKey, language: language),
                text: text,
                axis: axis
            )
            .textFieldStyle(.roundedBorder)
            .accessibilityIdentifier(identifier)
        }
    }
}

private struct MyPlanSuppliesPreviewStep: View {
    let template: EmergencyPlanTemplate
    let language: AppLanguage

    var body: some View {
        MyPlanStepCard(number: 4, titleKey: "myplan.supplies.title", icon: "shippingbox.fill", language: language) {
            Text(L10n.text("myplan.supplies.preview_notice", language: language))
                .font(.footnote)
                .foregroundStyle(.secondary)

            supplyGroup(titleKey: "myplan.supplies.home", items: template.supplyPriorities)
            supplyGroup(titleKey: "myplan.supplies.evacuation", items: template.evacuationItems)
        }
    }

    private func supplyGroup(titleKey: String, items: [TemplateSupplyItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.text(titleKey, language: language))
                .font(.headline)
            ForEach(items) { item in
                Label(item.localizedName(in: language), systemImage: "circle.fill")
                    .font(.subheadline)
            }
        }
    }
}

private struct MyPlanContactsStep: View {
    let familyContacts: [FamilyContact]
    let importantNumbers: [ImportantNumber]
    let language: AppLanguage
    let openContacts: () -> Void

    var body: some View {
        MyPlanStepCard(number: 5, titleKey: "myplan.contacts.title", icon: "person.2.fill", language: language) {
            Text(L10n.text("myplan.contacts.reuse_notice", language: language))
                .font(.footnote)
                .foregroundStyle(.secondary)

            ForEach(familyContacts.prefix(3)) { contact in
                Label(contact.name.isEmpty ? L10n.text("myplan.contacts.unnamed", language: language) : contact.name, systemImage: "person.fill")
            }
            ForEach(importantNumbers.prefix(3)) { number in
                Label(number.label.isEmpty ? L10n.text("myplan.contacts.unnamed", language: language) : number.label, systemImage: "phone.fill")
            }

            Button(action: openContacts) {
                Label(L10n.text("myplan.contacts.manage", language: language), systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .accessibilityIdentifier("openMyPlanContactsButton")
        }
    }
}

private struct MyPlanSaveStep: View {
    let saveSucceeded: Bool?
    let language: AppLanguage
    let save: () -> Void

    var body: some View {
        MyPlanStepCard(number: 6, titleKey: "myplan.save.title", icon: "checkmark.circle.fill", language: language) {
            Button(action: save) {
                Label(L10n.text("myplan.save.button", language: language), systemImage: "square.and.arrow.down.fill")
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier("saveMyPlanButton")

            if let saveSucceeded {
                Text(L10n.text(saveSucceeded ? "myplan.save.success" : "myplan.save.failure", language: language))
                    .font(.footnote)
                    .foregroundStyle(saveSucceeded ? .green : .red)
                    .accessibilityIdentifier("myPlanSaveStatus")
            }
        }
    }
}

private struct MyPlanStepCard<Content: View>: View {
    let number: Int
    let titleKey: String
    let icon: String
    let language: AppLanguage
    @ViewBuilder let content: Content

    init(
        number: Int,
        titleKey: String,
        icon: String,
        language: AppLanguage,
        @ViewBuilder content: () -> Content
    ) {
        self.number = number
        self.titleKey = titleKey
        self.icon = icon
        self.language = language
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                HStack(spacing: 6) {
                    Text(number, format: .number)
                    Text(L10n.text(titleKey, language: language))
                }
                .font(.title3.weight(.bold))
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
            }
            .accessibilityHeading(.h2)
            .accessibilityElement(children: .combine)

            content
        }
        .padding(20)
        .background(DashboardCardBackground())
    }
}
