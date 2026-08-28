# 🐾 Tamagotchi style widget 

> A tiny interactive macOS widget that reacts, blinks and keeps you going.

## Introduction

It is an interactive macOS widget built with **SwiftUI and WidgetKit**. It combines customizable quotes with a small animated character that responds to user interaction through different facial states.

The project explores how to create responsive interactions within WidgetKit's system-managed rendering model, using **App Intents, WidgetKit timelines, App Groups, UserDefaults, and predefined visual states**.

The quotes are **self-fed and customizable**, so there is no external API or network dependency for the quote system.

---

## ✨ Features

- **Custom quotes** — Add and manage your own collection of quotes.
- **Interactive widget** — User interactions are handled through `AppIntent`.
- **Multiple facial states** — The pet switches between predefined expressions.
- **Lightweight animation** — Uses rendered facial states instead of continuous SwiftUI animation.
- **Interaction tracking** — Stores interaction state using shared `UserDefaults`.
- **System-aware rendering** — Designed around WidgetKit's timeline-based architecture.
- **No external API** — Quotes are stored locally and can be fully customized.

---

## 🏗 Architecture

```text
                         ┌──────────────────┐
                         │    User Tap      │
                         └────────┬─────────┘
                                  │
                                  ▼
                      ┌──────────────────────┐
                      │  AdvanceQuoteIntent  │
                      └──────────┬───────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
             Update State              Select Quote
                    │                         │
                    └────────────┬────────────┘
                                 │
                                 ▼
                         Request Reload
                                 │
                                 ▼
                       ┌──────────────────┐
                       │  QuoteProvider   │
                       │    Timeline      │
                       └────────┬─────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   TimelineEntry  │
                       └────────┬─────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   QuotePetView   │
                       │     SwiftUI      │
                       └──────────────────┘
```

### Project structure

```text
QuotePetWidget
│
├── PetExpression
│   └── Predefined facial / visual states
│
├── SharedStore
│   └── App Group + UserDefaults state management
│
├── AdvanceQuoteIntent
│   └── Handles widget interaction
│
├── QuoteBank
│   └── Local, customizable quote collection
│
├── QuoteProvider
│   └── Generates WidgetKit timeline entries
│
├── QuotePetView
│   └── SwiftUI presentation layer
│
└── QuotePetWidget
    └── Widget configuration and entry point
```

---

## ⚙️ Working

The widget uses **App Intents** to handle user interaction.

When the user interacts with the widget:

```text
Tap
 ↓
AdvanceQuoteIntent
 ↓
Update shared state
 ↓
Change facial state
 ↓
Request WidgetKit reload
 ↓
QuoteProvider generates next entry
 ↓
QuotePetView renders updated state
```

### Facial-state animation

Instead of relying on a traditional continuous animation, the widget uses **predefined facial states**.

```text
Normal Face
     ↓
Blink Face
     ↓
New Expression
```

Each state is already defined and can be rendered directly.

This approach is intentional. With WidgetKit, the system controls rendering and the widget isn't continuously running like a normal SwiftUI application. A more conventional animation can introduce rendering/loading delays, making a short interaction such as a blink feel less responsive.

By switching between lightweight, predefined faces, the animation stays **fast, predictable, and visually seamless** while working within WidgetKit's constraints.

The animation is therefore treated as a **state transition rather than a continuously rendered animation**.

---

## 🛠 Stack

**SwiftUI** — UI and facial-state rendering  
**WidgetKit** — Widget lifecycle, timelines, and rendering  
**App Intents** — Interactive widget actions  
**App Groups** — Shared data between app and widget targets  
**UserDefaults** — Lightweight local state persistence  
**OSLog** — Structured logging and debugging  

---

## 💡 Motivation to Build

## 💡 Motivation to Build

Quote Pet started as a **vibe-coding venture** to get hands-on with macOS widgets and understand the architecture behind **WidgetKit, SwiftUI, App Intents, timelines, and shared state**.

The idea was simple: take a small, fun concept and use it to explore how interactive widgets actually work under the hood.

Instead of another static quote widget, I wanted to build something that **responds, changes expression, and feels a little alive**.

A small experiment in learning by building.

---

## 🚀 What Could Be Done More?

The current architecture leaves room for several extensions:

- **More expressions** — Expand the facial-state system.
- **Multiple characters** — Support different pets using the same widget architecture.
- **Quote categories** — Organize quotes by focus, motivation, study, work, etc.
- **Daily themes** — Change expressions and quotes based on the day.
- **Streaks** — Track interaction consistency over time.
- **Time-based states** — Different expressions depending on the time of day.
- **Custom character system** — Allow users to define their own visual states.
- **More complex interactions** — Build additional App Intents around the same state-management layer.

---

## ⭐

If you find the project useful, interesting, or it gives you an idea for your own widget, consider giving it a ⭐.

**Built with SwiftUI, WidgetKit, and a little bit of creative engineering. 🐾**
