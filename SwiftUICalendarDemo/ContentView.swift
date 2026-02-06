//
        //
    //  Project: SwiftUICalendarDemo
    //  File: ContentView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    

// ContentView.swift
// Main view displaying the list of upcoming calendar events
// This is the root view — it handles auth state and routes to the correct sub-view

import SwiftUI   // UI framework
import EventKit  // Calendar framework — needed for EKAuthorizationStatus type

struct ContentView: View {
    
    // MARK: - Our single CalendarManager instance
    // @State because @Observable replaces @StateObject in iOS 17+
    @State private var calendarManager = CalendarManager()
    
    // MARK: - Sheet presentation state
    // Controls whether the "create event" form is showing
    @State private var showingCreateEvent = false
    
    // Tracks which event the user tapped — nil means nothing selected
    @State private var selectedEvent: EKEvent?
    // Controls whether the edit sheet is visible
    @State private var showingEditEvent = false
    
    var body: some View {
        // NavigationStack gives us a nav bar, title, and toolbar support
        NavigationStack {
            // Group lets us conditionally switch between two views
            // while keeping shared modifiers below
            Group {
                if calendarManager.authorizationStatus == .fullAccess {
                    // MARK: - Authorized: Show event list
                    // User granted permission — show their events
                    eventListView
                } else {
                    // MARK: - Not authorized: Show permission prompt
                    // Either not asked yet or denied — show appropriate prompt
                    permissionView
                }
            }
            .navigationTitle("My Calendar") // Top bar title
            .toolbar {
                // Only show the add button when we have calendar access
                // No point showing "+" if we can't write events
                if calendarManager.authorizationStatus == .fullAccess {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            // Toggle the sheet to present CreateEventView
                            showingCreateEvent = true
                        } label: {
                            // System SF Symbol for the add button
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            // Present the create event form as a modal sheet
            .sheet(isPresented: $showingCreateEvent) {
                // Pass our manager so the form can call createEvent()
                CreateEventView(calendarManager: calendarManager)
            }
            // .task runs async work when the view first appears
            .task {
                // Step 1: Check what permission state we're in right now
                calendarManager.checkAuthorizationStatus()
                
                if calendarManager.authorizationStatus == .notDetermined {
                    // Step 2a: Never asked before — trigger the system dialog
                    await calendarManager.requestAccess()
                } else if calendarManager.authorizationStatus == .fullAccess {
                    // Step 2b: Already authorized — load events immediately
                    calendarManager.fetchEvents()
                }
                // If .denied — do nothing here, permissionView handles it
            }
        }
        .sheet(isPresented: $showingEditEvent) {
            // Safely unwrap — only present if we have a selected event
            if let event = selectedEvent {
                EventEditBridge(
                    eventStore: calendarManager.eventStore,  // Pass the shared store
                    event: event                              // The event to edit
                ) {
                    // onComplete closure — runs when user finishes editing
                    showingEditEvent = false        // Dismiss the sheet
                    calendarManager.fetchEvents()   // Refresh the list to show changes
                }
            }
        }
    }
    
    // MARK: - Event List: Shows all upcoming events
    // Computed property returning the list view — keeps body clean
    private var eventListView: some View {
        List {
            // Check if we have any events to display
            if calendarManager.events.isEmpty {
                // iOS 17+ empty state view — shows icon, title, and description
                // Much cleaner than building a custom empty state
                ContentUnavailableView(
                    "No Upcoming Events",
                    systemImage: "calendar",
                    description: Text("Events in the next 30 days will appear here.")
                )
            } else {
                // Loop through events using eventIdentifier as the unique ID
                // eventIdentifier is a stable string ID provided by EventKit
                ForEach(calendarManager.events, id: \.eventIdentifier) { event in
                    // Each row displays one calendar event
                    EventRowView(event: event)
                        .onTapGesture {
                            selectedEvent = event        // Remember which event was tapped
                            showingEditEvent = true      // Trigger the edit sheet
                        }
                    // Swipe from right to reveal delete action
                    // allowsFullSwipe: false prevents accidental full-swipe deletion
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // Destructive role gives the button a red background
                            Button(role: .destructive) {
                                // Call our manager's delete method
                                // Discard the Bool return — swipe already provides feedback
                                _ = calendarManager.deleteEvent(event)
                            } label: {
                                // Label combines text and icon for the swipe button
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        // Pull-to-refresh gesture — fetches latest events from the store
        .refreshable {
            calendarManager.fetchEvents()
        }
    }
    
    // MARK: - Permission View: Prompts user to grant access
    // Shows different content based on whether user denied or hasn't been asked
    private var permissionView: some View {
        // ContentUnavailableView with custom label, description, and action buttons
        ContentUnavailableView {
            // Header with SF Symbol icon
            Label("Calendar Access Required", systemImage: "calendar.badge.exclamationmark")
        } description: {
            // Explanation text shown below the icon
            Text("This app needs access to your calendar to display and manage events.")
        } actions: {
            if calendarManager.authorizationStatus == .denied {
                // User previously denied — can't re-trigger the system dialog
                // Only option is to deep-link them into the Settings app
                Button("Open Settings") {
                    // UIApplication.openSettingsURLString navigates directly
                    // to THIS app's settings page where they can toggle access
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent) // Prominent blue button style
            } else {
                // Status is .notDetermined — we can trigger the system dialog
                Button("Grant Access") {
                    // Wrap in Task because requestAccess is async
                    Task { await calendarManager.requestAccess() }
                }
                .buttonStyle(.borderedProminent) // Prominent blue button style
            }
        }
    }
}

#Preview {
    ContentView()
}

