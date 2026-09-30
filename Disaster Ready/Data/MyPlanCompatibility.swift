import Foundation

struct MyPlanLocationDraft: Equatable {
    var householdMeetingPoint: String
    var existingEvacuationDestination: String
    var existingShelterZone: String
    var alternativeAccommodation: String
    var familyFriendLocation: String
    var secondaryHome: String
    var personalSafePlaceNote: String

    init(plan: HouseholdPlan) {
        householdMeetingPoint = plan.reunionPoint
        existingEvacuationDestination = plan.evacuationDestination
        existingShelterZone = plan.shelterZone
        alternativeAccommodation = plan.alternativeAccommodation ?? ""
        familyFriendLocation = plan.familyFriendLocation ?? ""
        secondaryHome = plan.secondaryHome ?? ""
        personalSafePlaceNote = plan.safePlaceNote ?? ""
    }

    func apply(to plan: HouseholdPlan) {
        plan.reunionPoint = householdMeetingPoint
        plan.evacuationDestination = existingEvacuationDestination
        plan.shelterZone = existingShelterZone
        plan.alternativeAccommodation = alternativeAccommodation.nilIfEmpty
        plan.familyFriendLocation = familyFriendLocation.nilIfEmpty
        plan.secondaryHome = secondaryHome.nilIfEmpty
        plan.safePlaceNote = personalSafePlaceNote.nilIfEmpty
    }

    var containsOnlyPersonalPlanningLocations: Bool { true }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
