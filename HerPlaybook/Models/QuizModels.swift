//
//  QuizModels.swift
//  HerPlaybook
//
//  Quiz, Question, and QuizBank extracted from IQHubView
//  so QuizRunnerView can reference them without a circular dependency.
//

import Foundation

struct Quiz: Identifiable, Hashable {
    let id: String
    let title: String
    let questions: [Question]
}

struct Question: Identifiable, Hashable {
    let id: String
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

enum QuizBank {
    static let miniQuizzes: [Quiz] = [
        Quiz(
            id: "iq-1",
            title: "Downs & First Downs",
            questions: [
                Question(
                    id: "iq-1-q1",
                    prompt: "How many downs does the offense get to gain 10 yards?",
                    options: ["2", "3", "4", "5"],
                    correctIndex: 2,
                    explanation: "The offense gets 4 downs to gain 10 yards. Gaining 10+ yards earns a first down."
                ),
                Question(
                    id: "iq-1-q2",
                    prompt: "A first down means…",
                    options: ["You score 3 points", "You reset to a new set of 4 downs", "The defense gets the ball", "The quarter ends"],
                    correctIndex: 1,
                    explanation: "A first down gives the offense a new set of 4 downs."
                )
            ]
        ),
        Quiz(
            id: "iq-2",
            title: "Scoring Basics",
            questions: [
                Question(
                    id: "iq-2-q1",
                    prompt: "How many points is a touchdown worth?",
                    options: ["3", "6", "7", "2"],
                    correctIndex: 1,
                    explanation: "A touchdown is worth 6 points."
                ),
                Question(
                    id: "iq-2-q2",
                    prompt: "How many points is a field goal worth?",
                    options: ["1", "2", "3", "6"],
                    correctIndex: 2,
                    explanation: "A field goal is worth 3 points."
                )
            ]
        )
    ]

    static let dailyIQ: Quiz = Quiz(
        id: "daily",
        title: "Daily IQ: Quick Flag Check",
        questions: [
            Question(
                id: "daily-q1",
                prompt: "Offsides happens when…",
                options: [
                    "A player crosses the line early before the snap",
                    "A receiver steps out of bounds",
                    "The QB throws the ball away",
                    "A kicker misses wide"
                ],
                correctIndex: 0,
                explanation: "Offsides is called when a player is over the line early at the snap (or causes a reaction in the neutral zone)."
            )
        ]
    )
}
