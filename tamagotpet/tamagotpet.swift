
import SwiftUI
import WidgetKit
import AppIntents
import os

//Logger

nonisolated private let log = Logger(
    subsystem: "com.yourteam.quotepet",
    category: "QuotePet"
)

//Facial Expressions

enum PetExpression: String, CaseIterable {
    case blinkOpen
    case blinkClosed
    case sleepy
    case surprised
    case proud
}

// MARK: - Shared Store
//
// Uses an App Group so the AppIntent and Widget timeline provider can exchange state.
//

nonisolated enum SharedStore {

    // Replace with your real App Group identifier.
    static let suiteName = "group.yourteam.quotepet"

    static let quoteKey = "lastTappedQuote"
    static let dateKey = "lastTappedDate"
    static let expressionKey = "lastTappedExpression"
    static let tapCountKey = "totalTaps"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func recordTap(
        quote: String,
        expression: PetExpression
    ) {
        defaults?.set(quote, forKey: quoteKey)
        defaults?.set(expression.rawValue, forKey: expressionKey)
        defaults?.set(Date(), forKey: dateKey)
    }

    static func recentTap(
        within seconds: TimeInterval = 5
    ) -> (quote: String, expression: PetExpression)? {

        guard
            let date = defaults?.object(forKey: dateKey) as? Date,
            Date().timeIntervalSince(date) < seconds,
            let quote = defaults?.string(forKey: quoteKey)
        else {
            return nil
        }

        let expression = (defaults?.string(forKey: expressionKey))
            .flatMap { PetExpression(rawValue: $0) } ?? .blinkOpen

        return (
            quote: quote,
            expression: expression
        )
    }

    @discardableResult
    static func incrementTapCount() -> Int {

        let count = (defaults?.integer(forKey: tapCountKey) ?? 0) + 1

        defaults?.set(count, forKey: tapCountKey)

        return count
    }

    static func currentTapCount() -> Int {
        defaults?.integer(forKey: tapCountKey) ?? 0
    }
}

// MARK: - App Intent

struct AdvanceQuoteIntent: AppIntent {

    static var title: LocalizedStringResource = "Next Quote"

    static var description = IntentDescription(
        "Shows a new motivational quote."
    )

    func perform() async throws -> some IntentResult {

        log.debug("Widget tapped")

        let quote = QuoteBank.randomQuote()

        let tapCount = SharedStore.incrementTapCount()

        // expression transition
        SharedStore.recordTap(quote: quote, expression: .blinkClosed)
        WidgetCenter.shared.reloadTimelines(ofKind: "QuotePetWidget")

        try? await Task.sleep(nanoseconds: 220_000_000) // ~0.22s


        let newExpression: PetExpression
        if tapCount == 10 {
            newExpression = .proud
        } else {
            let pool: [PetExpression] = [.blinkOpen, .sleepy, .surprised]
            newExpression = pool.randomElement() ?? .blinkOpen
        }

        SharedStore.recordTap(quote: quote, expression: newExpression)
        WidgetCenter.shared.reloadTimelines(ofKind: "QuotePetWidget")

        return .result()
    }
}

// MARK: - Quote Bank

nonisolated enum QuoteBank {

    static let quotes: [String] = [

        "small steps still move you forward",
        "you don't have to see the whole staircase",
        "done is better than perfect, today",
        "rest is part of the work too",
        "you're allowed to grow slowly",
        "the mess is proof you're trying",
        "quiet days build strong roots",
        "you are not behind, you are becoming",
        "one honest step beats ten perfect plans",
        "your pace is still progress",

        "make today kind to yourself",
        "the idea is worth starting badly",
        "no is a full sentence, use it",
        "future you is already proud",
        "curiosity counts as productivity",
        "you get to define what enough means",
        "small wins add up quietly",
        "showing up counts more than you think",
        "you're closer than it feels",
        "let today be enough",

        "progress hides inside boring days",
        "you're built for this, breathe",
        "trust the version of you that started",
        "not every day needs to be your best",
        "a slow yes beats a rushed no",
        "you can rest without quitting",
        "doubt is loud, keep going anyway",
        "you're allowed to change the plan",
        "today's effort still counts tomorrow",
        "you don't need permission to begin",

        "the draft doesn't have to be good",
        "small habits outlast big motivation",
        "you're doing better than you think",
        "one page today is still a book someday",
        "confusion means you're learning",
        "it's okay to move at your own rhythm",
        "you already survived every hard day so far",
        "the boring middle is where growth happens",
        "you don't owe anyone a finished plan yet",
        "your effort is not invisible",

        "gentle progress is still progress",
        "start messy, refine later",
        "you're allowed to be proud of small things",
        "the work doesn't have to feel easy to be worth it",
        "keep the promise you made to yourself",
        "today is a fine day to try again",
        "you can be tired and still capable",
        "the plan can bend, you don't have to break",
        "you're not late, you're on your own timeline",
        "small consistent effort beats big rare bursts",

        "your curiosity is a compass, follow it",
        "it's fine to not have it figured out yet",
        "the attempt already means something",
        "you get to choose what today looks like",
        "quiet confidence beats loud doubt",
        "you're learning even when it doesn't feel like it",
        "one good decision can shift the whole week",
        "rest now, return steadier",
        "the work you avoid often teaches the most",
        "you're allowed to outgrow old goals",

        "today's discomfort is tomorrow's ease",
        "a little clarity goes a long way",
        "you don't need a perfect start, just a start",
        "small brave choices build a big life",
        "you can want more and still be grateful now",
        "the hard part means you're growing",
        "let curiosity lead more than fear",
        "you're the only one keeping score anyway",
        "steady beats fast most days",
        "you can pause without losing your place",

        "your effort today is a gift to future you",
        "it's okay if today was just okay",
        "you don't have to earn rest",
        "small circles of effort still add up",
        "the version of you a year ago would be proud",
        "you can start over as many times as you need",
        "trying counts even when it's clumsy",
        "you are more capable than your worst day",
        "let today be a rough draft, not a verdict",
        "the goal can wait, breathe first",

        "you're not stuck, you're gathering strength",
        "a calm no protects a future yes",
        "you don't need to justify your pace",
        "small joy is still joy",
        "you can be proud and still want more",
        "the work is quiet, keep going",
        "you're allowed to take the long way",
        "today's effort is a seed, not a harvest",
        "you are not your to-do list",
        "the plan will adjust, you don't have to be perfect",

        "your patience with yourself is a skill",
        "you can rest and still be on track",
        "small clarity beats big confusion",
        "you're allowed to be new at this",
        "the hard days still count as days you showed up",
        "your softness is not weakness",
        "you get to redefine success as you go",
        "one small honest step is still a step",
        "you don't have to have it all figured out today",
        "quiet progress is still progress",
        "you are exactly where you need to be to keep going"
    ]

    static func randomQuote(excluding last: String? = nil) -> String {

        guard quotes.count > 1 else {
            return quotes.first ?? "You're doing great."
        }

        guard let last else {
            return quotes.randomElement()!
        }

        var quote = quotes.randomElement()!

        while quote == last {
            quote = quotes.randomElement()!
        }

        return quote
    }
}

// MARK: - Timeline Entry

struct QuoteEntry: TimelineEntry {

    let date: Date
    let quote: String
    let expression: PetExpression
    let tapCount: Int
}

// MARK: - Timeline Provider

struct QuoteProvider: TimelineProvider {

    func placeholder(in context: Context) -> QuoteEntry {

        QuoteEntry(
            date: .now,
            quote: "small steps still move you forward",
            expression: .blinkOpen,
            tapCount: 0
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (QuoteEntry) -> Void
    ) {

        completion(
            QuoteEntry(
                date: .now,
                quote: QuoteBank.randomQuote(),
                expression: .blinkOpen,
                tapCount: SharedStore.currentTapCount()
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<QuoteEntry>) -> Void
    ) {

        let now = Date()

        var entries: [QuoteEntry] = []

        let tapCount = SharedStore.currentTapCount()

        var previousQuote: String?

        if let tapped = SharedStore.recentTap() {

            log.debug(
                "Recent tap detected. Expression: \(tapped.expression.rawValue)"
            )

            entries.append(
                QuoteEntry(
                    date: now,
                    quote: tapped.quote,
                    expression: tapped.expression,
                    tapCount: tapCount
                )
            )

            previousQuote = tapped.quote
        }
        else {

            let quote = QuoteBank.randomQuote()

            entries.append(
                QuoteEntry(
                    date: now,
                    quote: quote,
                    expression: .blinkOpen,
                    tapCount: tapCount
                )
            )

            previousQuote = quote
        }


        let passiveExpressions: [PetExpression] = [
            .blinkOpen, .blinkClosed, .sleepy,
            .blinkOpen, .surprised, .blinkClosed,
            .blinkOpen, .sleepy, .surprised
        ]

    
        let refreshInterval = 1

        for (index, expression) in passiveExpressions.enumerated() {

            let date = Calendar.current.date(
                byAdding: .minute,
                value: refreshInterval * (index + 1),
                to: now
            )!

            let quote = QuoteBank.randomQuote(
                excluding: previousQuote
            )

            previousQuote = quote

            entries.append(
                QuoteEntry(
                    date: date,
                    quote: quote,
                    expression: expression,
                    tapCount: tapCount
                )
            )
        }

        completion(
            Timeline(
                entries: entries,
                policy: .atEnd
            )
        )
    }
}

// MARK: - Color Helper

extension Color {

    init(hex: String) {

        let scanner = Scanner(string: hex)

        var rgb: UInt64 = 0

        scanner.scanHexInt64(&rgb)

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

// MARK: - Widget View

struct QuotePetView: View {

    let entry: QuoteEntry

    // MARK: Colors

    private let screen = Color(hex: "FBEFEF")
    private let screenEdge = Color(hex: "D9B9BE")
    private let ink = Color(hex: "5B4650")
    private let blush = Color(hex: "F0A8AE")

    var body: some View {

        Button(intent: AdvanceQuoteIntent()) {

            VStack(spacing: 2) {

                ZStack {

                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                    .fill(screen)
                    .overlay {

                        RoundedRectangle(
                            cornerRadius: 14,
                            style: .continuous
                        )
                        .strokeBorder(
                            screenEdge,
                            lineWidth: 2.2
                        )
                    }

                    VStack(spacing: 5) {

                        ZStack {

                            HStack(spacing: 26) {

                                Circle()
                                    .fill(blush.opacity(0.55))
                                    .frame(width: 10, height: 7)

                                Circle()
                                    .fill(blush.opacity(0.55))
                                    .frame(width: 10, height: 7)
                            }
                            .offset(y: 10)

                            VStack(spacing: 4) {

                                HStack(spacing: 14) {

                                    eyeView(for: entry.expression)

                                    eyeView(for: entry.expression)
                                }

                                mouthView(for: entry.expression)
                            }
                        }
                        .padding(.top, 10)
                        .animation(.easeInOut(duration: 0.18), value: entry.expression)

                        Text(entry.quote)
                            .font(
                                .custom(
                                    "Bradley Hand",
                                    size: 15
                                )
                            )
                            .foregroundColor(ink)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .minimumScaleFactor(0.75)
                            .padding(.horizontal, 10)
                            .id(entry.quote)

                        if entry.tapCount > 0 {

                            Text("✨ \(entry.tapCount)")
                                .font(
                                    .system(
                                        size: 9,
                                        weight: .semibold,
                                        design: .rounded
                                    )
                                )
                                .foregroundColor(
                                    ink.opacity(0.55)
                                )
                        }
                    }
                    .padding(.bottom, 6)
                }
                .padding(3)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Facial Components

private extension QuotePetView {

    @ViewBuilder
    func eyeView(
        for expression: PetExpression
    ) -> some View {

        switch expression {

        case .blinkOpen:

            RoundedRectangle(cornerRadius: 1.5)
                .fill(ink)
                .frame(width: 9, height: 9)

        case .blinkClosed:

            RoundedRectangle(cornerRadius: 1.5)
                .fill(ink)
                .frame(width: 9, height: 2)

        case .sleepy:

            RoundedRectangle(cornerRadius: 1.5)
                .fill(ink)
                .frame(width: 9, height: 3.5)
                .rotationEffect(.degrees(6))

        case .surprised:

            Ellipse()
                .fill(ink)
                .frame(width: 9, height: 11)

        case .proud:

            Capsule()
                .fill(ink)
                .frame(width: 9, height: 2.4)
                .rotationEffect(.degrees(-14))
        }
    }

    @ViewBuilder
    func mouthView(
        for expression: PetExpression
    ) -> some View {

        switch expression {

        case .blinkOpen:

            Capsule()
                .fill(ink.opacity(0.85))
                .frame(width: 12, height: 5)

        case .blinkClosed:

            Capsule()
                .fill(ink.opacity(0.85))
                .frame(width: 8, height: 3)

        case .sleepy:

            Capsule()
                .fill(ink.opacity(0.85))
                .frame(width: 6, height: 2.4)

        case .surprised:

            Ellipse()
                .fill(ink.opacity(0.85))
                .frame(width: 6, height: 8)

        case .proud:

            Capsule()
                .fill(ink.opacity(0.85))
                .frame(width: 14, height: 6)
        }
    }
}

// MARK: - Widget

struct QuotePetWidget: Widget {

    let kind = "QuotePetWidget"

    var body: some WidgetConfiguration {

        StaticConfiguration(
            kind: kind,
            provider: QuoteProvider()
        ) { entry in

            QuotePetView(entry: entry)
                .containerBackground(
                    for: .widget
                ) {

                    ZStack {

                        LinearGradient(
                            colors: [
                                Color(hex: "DCCFEA"),
                                Color(hex: "B29CCB")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        RoundedRectangle(
                            cornerRadius: 24,
                            style: .continuous
                        )
                        .strokeBorder(
                            Color(hex: "9A80B8")
                                .opacity(0.6),
                            lineWidth: 1.5
                        )
                        .padding(3)
                    }
                }
        }
        .configurationDisplayName("Quote Pet")
        .description(
            "A little motivational companion for your desktop."
        )
        .supportedFamilies([
            .systemSmall
        ])
    }
}

// MARK: - Preview

#Preview(
    as: .systemSmall
) {

    QuotePetWidget()

} timeline: {

    QuoteEntry(
        date: .now,
        quote: "small steps still move you forward",
        expression: .blinkOpen,
        tapCount: 0
    )

    QuoteEntry(
        date: .now,
        quote: "you're doing better than you think",
        expression: .sleepy,
        tapCount: 12
    )

    QuoteEntry(
        date: .now,
        quote: "whoa, didn't see that coming",
        expression: .surprised,
        tapCount: 13
    )

    QuoteEntry(
        date: .now,
        quote: "ten taps! proud of you",
        expression: .proud,
        tapCount: 10
    )
}
