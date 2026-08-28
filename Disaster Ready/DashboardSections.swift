//
//  DashboardSections.swift
//  Disaster Ready
//

import SwiftUI

struct HeroCardSection: View {
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(L10n.text("works_without_internet", language: language), systemImage: "wifi.slash")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.18), in: Capsule())

            Text(L10n.text("hero_title", language: language))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(L10n.text("hero_subtitle", language: language))
                .font(.callout)
                .foregroundStyle(.white.opacity(0.9))

            HStack(spacing: 12) {
                metricCard(value: L10n.text("live", language: language), title: L10n.text("scenarios_metric", language: language))
                metricCard(value: L10n.text("assigned", language: language), title: L10n.text("roles_metric", language: language))
                metricCard(value: L10n.text("ready", language: language), title: L10n.text("offline_metric", language: language))
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.black.opacity(0.32))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 42))
                        .foregroundStyle(.white.opacity(0.14))
                        .padding()
                }
        )
    }

    private func metricCard(value: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ScenarioSelectorSection: View {
    @Binding var selectedScenario: PreparednessScenario
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.text("scenario", language: language))
                .font(.title3.weight(.bold))

            HStack(spacing: 14) {
                Image(systemName: selectedScenario.icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(selectedScenario.tint)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedScenario.localizedName(in: language))
                        .font(.headline)
                    Text(selectedScenario.recommendedAction(in: language))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Picker(L10n.text("scenario", language: language), selection: $selectedScenario) {
                    ForEach(PreparednessScenario.allCases) { scenario in
                        Label(scenario.localizedName(in: language), systemImage: scenario.icon)
                            .tag(scenario)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.88))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(selectedScenario.tint.opacity(0.5), lineWidth: 1.5)
                    }
            )
        }
    }
}

struct DecisionCardSection: View {
    let scenario: PreparednessScenario
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(scenario.localizedName(in: language), systemImage: scenario.icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(scenario.tint)
                Spacer()
                Text(scenario.recommendedAction(in: language).uppercased())
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(scenario.tint.opacity(0.16), in: Capsule())
            }

            Text(scenario.summary(in: language))
                .font(.body)

            ruleRow(title: L10n.text("go", language: language), text: scenario.goRule(in: language), color: .green)
            ruleRow(title: L10n.text("no_go", language: language), text: scenario.noGoRule(in: language), color: .red)

            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.text("immediate_checklist", language: language))
                    .font(.headline)
                ForEach(scenario.checklist(in: language), id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(scenario.tint)
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private func ruleRow(title: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct HouseholdPlanSection: View {
    @Bindable var plan: HouseholdPlan
    let summary: String
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.text("household_plan", language: language))
                .font(.title3.weight(.bold))

            Text(L10n.text("household_plan_subtitle", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(L10n.text("reunion_point", language: language), text: $plan.reunionPoint)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("evacuation_destination", language: language), text: $plan.evacuationDestination)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("shelter_zone", language: language), text: $plan.shelterZone)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("gas_shutoff_note", language: language), text: $plan.gasShutoffNote, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
            TextField(L10n.text("medical_lead", language: language), text: $plan.medicalLead)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("pet_lead", language: language), text: $plan.petLead)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("family_password", language: language), text: $plan.familyPassword)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.text("plan_summary", language: language))
                    .font(.headline)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(20)
        .background(DashboardCardBackground())
    }
}

struct ContactsSection: View {
    let familyContacts: [FamilyContact]
    let importantNumbers: [ImportantNumber]
    let language: AppLanguage
    let addFamily: () -> Void
    let addImportant: () -> Void
    let deleteFamily: (FamilyContact) -> Void
    let deleteImportant: (ImportantNumber) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(L10n.text("contacts", language: language))
                    .font(.title3.weight(.bold))
                Spacer()
                Text(L10n.text("offline", language: language))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.green.opacity(0.12), in: Capsule())
            }

            Text(L10n.text("contacts_subtitle", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            contactGroup(
                title: L10n.text("family", language: language),
                addTitle: L10n.text("add_family", language: language),
                addAction: addFamily
            ) {
                ForEach(familyContacts) { contact in
                    FamilyContactEditor(
                        contact: contact,
                        language: language,
                        deleteAction: { deleteFamily(contact) }
                    )
                }
            }

            contactGroup(
                title: L10n.text("important_numbers", language: language),
                addTitle: L10n.text("add_number", language: language),
                addAction: addImportant
            ) {
                ForEach(importantNumbers) { number in
                    ImportantNumberEditor(
                        number: number,
                        language: language,
                        deleteAction: { deleteImportant(number) }
                    )
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }

    private func contactGroup<Content: View>(
        title: String,
        addTitle: String,
        addAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button(addTitle, action: addAction)
                    .font(.caption.weight(.semibold))
            }
            content()
        }
    }
}

struct MessageTemplatesSection: View {
    let templates: [FamilyMessageTemplate]
    let shareText: (FamilyMessageTemplate) -> String
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.text("one_tap_family_updates", language: language))
                .font(.title3.weight(.bold))

            Text(L10n.text("message_templates_subtitle", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(templates) { template in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "paperplane.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.title)
                            .font(.headline)
                        Text(shareText(template))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    ShareLink(
                        item: shareText(template),
                        preview: SharePreview(template.title, image: Image(systemName: "paperplane.circle.fill"))
                    ) {
                        Text(L10n.text("share", language: language))
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.blue.opacity(0.12), in: Capsule())
                    }
                }
                .padding(14)
                .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }
}

struct RolesSection: View {
    let roles: [HouseholdRole]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.text("household_roles", language: language))
                .font(.title3.weight(.bold))

            ForEach(roles) { role in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: role.systemImage)
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(role.title) • \(role.person)")
                            .font(.headline)
                        Text(role.task)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }
}

struct SuppliesSection: View {
    let homeSupplies: [SupplyItem]
    let carSupplies: [SupplyItem]
    let completionCount: Int
    let totalCount: Int
    let language: AppLanguage
    let addItem: (SupplyLocation) -> Void
    let deleteItem: (SupplyItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(L10n.text("emergency_supplies", language: language))
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(completionCount)/\(totalCount) \(L10n.text("ready", language: language).lowercased())")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.indigo.opacity(0.12), in: Capsule())
            }

            Text(L10n.text("supplies_subtitle", language: language))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            SupplyGroupSection(
                title: L10n.text("home", language: language),
                storageLocation: .home,
                items: homeSupplies,
                accent: .indigo,
                language: language,
                addAction: addItem,
                deleteAction: deleteItem
            )

            SupplyGroupSection(
                title: L10n.text("car", language: language),
                storageLocation: .car,
                items: carSupplies,
                accent: .mint,
                language: language,
                addAction: addItem,
                deleteAction: deleteItem
            )
        }
        .padding(20)
        .background(DashboardCardBackground())
    }
}

struct DrillsSection: View {
    let drills: [Drill]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.text("scenario_drills", language: language))
                .font(.title3.weight(.bold))

            ForEach(drills) { drill in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(drill.title)
                            .font(.headline)
                        Text("\(drill.frequency) • \(drill.duration)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "timer")
                        .foregroundStyle(.purple)
                }
                .padding(14)
                .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }
}

struct OfflineResourcesSection: View {
    let resources: [OfflineResource]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.text("offline_kit", language: language))
                .font(.title3.weight(.bold))

            ForEach(resources) { resource in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: resource.systemImage)
                        .font(.title3)
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(resource.title)
                            .font(.headline)
                        Text(resource.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(DashboardCardBackground())
    }
}

struct PricingSection: View {
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.text("business_model", language: language))
                .font(.title3.weight(.bold))

            Text(L10n.text("business_model_body", language: language))
                .font(.body)

            VStack(alignment: .leading, spacing: 10) {
                Label(L10n.text("business_bullet_1", language: language), systemImage: "wifi.slash")
                Label(L10n.text("business_bullet_2", language: language), systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                Label(L10n.text("business_bullet_3", language: language), systemImage: "person.2.fill")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.23, blue: 0.28),
                            Color(red: 0.32, green: 0.23, blue: 0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .foregroundStyle(.white)
    }
}

private struct FamilyContactEditor: View {
    @Bindable var contact: FamilyContact
    let language: AppLanguage
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header(title: L10n.text("family_contact", language: language), deleteAction: deleteAction)
            TextField(L10n.text("name", language: language), text: $contact.name)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("role", language: language), text: $contact.role)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("phone_number", language: language), text: $contact.phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            TextField(L10n.text("notes", language: language), text: $contact.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            HStack(spacing: 10) {
                if let phoneURL = phoneURL(for: contact.phoneNumber) {
                    Link(destination: phoneURL) {
                        actionChip(title: L10n.text("call", language: language), systemImage: "phone.fill", tint: .green)
                    }
                }
                if let messageURL = messageURL(for: contact.phoneNumber) {
                    Link(destination: messageURL) {
                        actionChip(title: L10n.text("text", language: language), systemImage: "message.fill", tint: .blue)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct ImportantNumberEditor: View {
    @Bindable var number: ImportantNumber
    let language: AppLanguage
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header(title: L10n.text("important_number", language: language), deleteAction: deleteAction)
            TextField(L10n.text("label", language: language), text: $number.label)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.text("phone_number", language: language), text: $number.phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            TextField(L10n.text("notes", language: language), text: $number.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            HStack(spacing: 10) {
                if let phoneURL = phoneURL(for: number.phoneNumber) {
                    Link(destination: phoneURL) {
                        actionChip(title: L10n.text("call", language: language), systemImage: "phone.fill", tint: .green)
                    }
                }
                if let messageURL = messageURL(for: number.phoneNumber) {
                    Link(destination: messageURL) {
                        actionChip(title: L10n.text("text", language: language), systemImage: "message.fill", tint: .blue)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct SupplyGroupSection: View {
    let title: String
    let storageLocation: SupplyLocation
    let items: [SupplyItem]
    let accent: Color
    let language: AppLanguage
    let addAction: (SupplyLocation) -> Void
    let deleteAction: (SupplyItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(title, systemImage: storageLocation == .home ? "house.fill" : "car.fill")
                    .font(.headline)
                    .foregroundStyle(accent)
                Spacer()
                Button(storageLocation == .home ? L10n.text("add_home_item", language: language) : L10n.text("add_car_item", language: language)) {
                    addAction(storageLocation)
                }
                .font(.caption.weight(.semibold))
            }

            ForEach(items) { item in
                SupplyItemEditor(
                    item: item,
                    storageLocation: storageLocation,
                    accent: accent,
                    language: language,
                    deleteAction: { deleteAction(item) }
                )
            }
        }
    }
}

private struct SupplyItemEditor: View {
    @Bindable var item: SupplyItem
    let storageLocation: SupplyLocation
    let accent: Color
    let language: AppLanguage
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header(
                title: storageLocation == .home ? L10n.text("home_item", language: language) : L10n.text("car_item", language: language),
                deleteAction: deleteAction
            )

            Toggle(isOn: $item.isPacked) {
                HStack(spacing: 10) {
                    Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.isPacked ? accent : .secondary)
                    Text(item.isPacked ? L10n.text("stocked", language: language) : L10n.text("missing", language: language))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(item.isPacked ? accent : .secondary)
                }
            }
            .toggleStyle(.switch)

            TextField(L10n.text("item_name", language: language), text: $item.name)
                .textFieldStyle(.roundedBorder)

            TextField(L10n.text("what_to_keep_notes", language: language), text: $item.detail, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
        }
        .padding(14)
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct DashboardCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.white.opacity(0.92))
    }
}

private func header(title: String, deleteAction: @escaping () -> Void) -> some View {
    HStack {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        Spacer()
        Button(role: .destructive, action: deleteAction) {
            Image(systemName: "trash")
        }
        .buttonStyle(.plain)
    }
}

private func actionChip(title: String, systemImage: String, tint: Color) -> some View {
    Label(title, systemImage: systemImage)
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.12), in: Capsule())
        .foregroundStyle(tint)
}

private func phoneURL(for phoneNumber: String) -> URL? {
    let sanitized = sanitizedPhoneNumber(phoneNumber)
    guard !sanitized.isEmpty else { return nil }
    return URL(string: "tel:\(sanitized)")
}

private func messageURL(for phoneNumber: String) -> URL? {
    let sanitized = sanitizedPhoneNumber(phoneNumber)
    guard !sanitized.isEmpty else { return nil }
    return URL(string: "sms:\(sanitized)")
}

private func sanitizedPhoneNumber(_ phoneNumber: String) -> String {
    let filtered = phoneNumber.filter { $0.isNumber || $0 == "+" }
    if filtered.first == "+" {
        return "+" + filtered.dropFirst().filter(\.isNumber)
    }
    return filtered.filter(\.isNumber)
}
