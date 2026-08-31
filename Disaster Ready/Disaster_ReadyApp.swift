//
//  Disaster_ReadyApp.swift
//  Disaster Ready
//
//  Created by Terje Moe on 28/08/2026.
//

import SwiftData
import SwiftUI

@main
struct Disaster_ReadyApp: App {
    @AppStorage("preferredAppearance") private var preferredAppearance = AppAppearance.system.rawValue

    var body: some Scene {
        WindowGroup {
            DisasterDashboardView()
                .preferredColorScheme(appAppearance.preferredColorScheme)
        }
        .modelContainer(for: [
            FamilyContact.self,
            ImportantNumber.self,
            HouseholdPlan.self,
            HouseholdRole.self,
            SupplyItem.self
        ])
    }

    private var appAppearance: AppAppearance {
        AppAppearance(rawValue: preferredAppearance) ?? .system
    }
}
