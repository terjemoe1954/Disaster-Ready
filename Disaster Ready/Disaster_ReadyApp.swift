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
    var body: some Scene {
        WindowGroup {
            DisasterDashboardView()
        }
        .modelContainer(for: [
            FamilyContact.self,
            ImportantNumber.self,
            HouseholdPlan.self,
            SupplyItem.self
        ])
    }
}
