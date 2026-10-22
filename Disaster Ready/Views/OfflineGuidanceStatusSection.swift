import SwiftUI

struct OfflineGuidanceStatusSection: View {
    let sourceIDs: [String]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(savedTitle)
                    .foregroundStyle(Color.primary)
            } icon: {
                Image(systemName: "iphone.and.arrow.forward")
                    .foregroundStyle(.green)
            }
            .font(.headline)

            LabeledContent(versionTitle, value: OfflineGuidanceCatalog.contentVersion)
                .font(.caption)
                .accessibilityElement(children: .combine)

            HStack(spacing: 4) {
                Text(reviewedTitle)
                Text(OfflineGuidanceCatalog.bundled.reviewedAt, format: .dateTime.day().month().year())
            }
            .font(.caption)
            .foregroundStyle(Color.primary)
            .environment(\.locale, AppLanguage.locale(for: language))

            if !sourceNames.isEmpty {
                Text(sourceTitle)
                    .font(.caption.weight(.semibold))
                Text(sourceNames.formatted(.list(type: .and).locale(AppLanguage.locale(for: language))))
                    .font(.caption)
                    .foregroundStyle(Color.primary)
            }

            Text(statusDetail)
                .font(.caption)
                .foregroundStyle(Color.primary)
        }
        .emergencyModeStatusCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("offlineGuidanceStatus")
    }

    private var sourceNames: [String] {
        var seen = Set<String>()
        return GuidanceSourceRegistry.resolvedSources(for: sourceIDs)
            .map(\.authority)
            .filter { seen.insert($0).inserted }
    }

    private var savedTitle: String {
        L10n.pick(language: language, english: "Saved on this phone", norwegian: "Lagret på telefonen", thai: "บันทึกไว้ในโทรศัพท์นี้")
    }

    private var versionTitle: String {
        L10n.pick(language: language, english: "Guidance version", norwegian: "Veiledningsversjon", thai: "เวอร์ชันคำแนะนำ")
    }

    private var reviewedTitle: String {
        L10n.pick(language: language, english: "Last reviewed:", norwegian: "Sist kontrollert:", thai: "ตรวจสอบล่าสุด:")
    }

    private var sourceTitle: String {
        L10n.pick(language: language, english: "Sources", norwegian: "Kilder", thai: "แหล่งข้อมูล")
    }

    private var statusDetail: String {
        L10n.pick(
            language: language,
            english: "This is bundled guidance, not live status and not a ‘last fetched’ time. The app does not infer the state of power, mobile networks, satellites, or broadcasting.",
            norwegian: "Dette er innebygd veiledning, ikke sanntidsstatus eller et tidspunkt for «sist hentet». Appen fastslår ikke tilstanden til strøm, mobilnett, satellitter eller kringkasting.",
            thai: "นี่คือคำแนะนำที่รวมอยู่ในแอป ไม่ใช่สถานะแบบสดหรือเวลา ‘ดึงข้อมูลล่าสุด’ แอปไม่ได้อนุมานสถานะของไฟฟ้า เครือข่ายมือถือ ดาวเทียม หรือการกระจายเสียง"
        )
    }
}

private extension View {
    func emergencyModeStatusCard() -> some View {
        padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.green.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
    }
}
