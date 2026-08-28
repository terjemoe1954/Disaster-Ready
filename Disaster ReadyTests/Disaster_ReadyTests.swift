//
//  Disaster_ReadyTests.swift
//  Disaster ReadyTests
//
//  Created by Terje Moe on 28/08/2026.
//

import Testing
@testable import Disaster_Ready

struct Disaster_ReadyTests {

    @Test func stormScenarioRecommendsEvacuationEvaluation() async throws {
        #expect(PreparednessScenario.storm.recommendedAction(in: .english) == "Evaluate evacuation")
        #expect(PreparednessScenario.storm.goRule(in: .english).contains("road closures"))
    }

}
