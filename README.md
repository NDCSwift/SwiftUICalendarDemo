# 📅 Calendar — EventKit + SwiftUI Demo

A SwiftUI demo showing how to read and create calendar events using the EventKit framework — with a custom event list, a create-event sheet, and the native `EKEventEditViewController` bridge.

---

## 🤔 What this is

This project connects your SwiftUI app to the user's native Calendar via `EventKit`. It shows how to request calendar access, fetch upcoming events, display them in a list, and create new events — both with a custom SwiftUI form and via the native system event editor. An `EventEditBridge` wraps the `UIViewControllerRepresentable` so the system sheet drops cleanly into SwiftUI.

## ✅ Why you'd use it

- **Two creation paths** — custom `CreateEventView` and the native `EKEventEditViewController` via `EventEditBridge`
- **`CalendarManager` included** — `@Observable` class handles auth, fetch, and save in one place
- **`EventRowView`** — clean list row with date, time, and calendar colour dot, ready to reuse
- **Covers the gotchas** — authorization flow, calendar selection, and time zone handling all addressed

## 📺 Watch on YouTube

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20the%20Tutorial-red?style=for-the-badge&logo=youtube)](https://youtu.be/5bZUVNO6rxo)

> This project was built for the [NoahDoesCoding YouTube channel](https://www.youtube.com/@noahdoescoding). Subscribe for weekly SwiftUI tutorials.

---

## 🚀 Getting Started

### 1. Clone the Repo
```bash
git clone https://github.com/NDCSwift/SwiftUICalendarDemo.git
cd SwiftUICalendarDemo
```

### 2. Open in Xcode
Double-click `SwiftUICalendarDemo.xcodeproj`.

### 3. Set Your Development Team
**TARGET → Signing & Capabilities → Team**

### 4. Update the Bundle Identifier
Change `com.example.MyApp` to a unique identifier.

### 5. Run
Calendar access requires accepting the permission prompt on first launch.

---

## 🛠️ Notes

- Add `NSCalendarsUsageDescription` and `NSCalendarsWriteOnlyAccessUsageDescription` to `Info.plist`
- Requires iOS 17+ for the write-only calendar access API
- If you see a code signing error, check that Team and Bundle ID are set

## 📦 Requirements

- Xcode 15+
- iOS 17+
- No third-party dependencies
