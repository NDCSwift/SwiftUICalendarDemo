//
        //
    //  Project: SwiftUICalendarDemo
    //  File: CalendarManager.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    


// CalendarManager.swift
// Single source of truth for all calendar operations
// Uses @Observable for clean SwiftUI integration (iOS 17+)

import EventKit
import Observation

@Observable
@MainActor
class CalendarManager {
    
    // MARK: - Single EKEventStore instance — reuse this everywhere
    let eventStore = EKEventStore()
    
    // MARK: - Published state for SwiftUI views to observe
    var events: [EKEvent] = []
    var authorizationStatus: EKAuthorizationStatus = .notDetermined
    var errorMessage: String?
    // MARK: - Expose store for EventKitUI bridges
    // EventKitUI controllers need direct access to the store
    var eventStoreAccess: EKEventStore { eventStore }
    
    // MARK: - Request Full Calendar Access (iOS 17+)
    // This triggers the system permission dialog on first call
    // Subsequent calls return the stored permission state
    func requestAccess() async {
        do {
            // requestFullAccessToEvents() is the iOS 17+ API
            // It replaces the deprecated requestAccess(to:) method
            let granted = try await eventStore.requestFullAccessToEvents()
            
            if granted {
                // Permission granted — update status and fetch events
                authorizationStatus = .fullAccess
                fetchEvents()
            } else {
                // User denied — update status so UI can respond
                authorizationStatus = .denied
                errorMessage = "Calendar access denied. Enable in Settings."
            }
        } catch {
            // Handle any system errors during the request
            errorMessage = "Failed to request access: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Check current authorization without prompting
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - FETCH: Get all events for the next 30 days
    // Uses a predicate to filter events by date range
    func fetchEvents() {
        // Define the date range — now through 30 days from now
        let startDate = Date()
        guard let endDate = Calendar.current.date(
            byAdding: .day,
            value: 30,
            to: startDate
        ) else { return }
        
        // Get all calendars the user has on their device
        let calendars = eventStore.calendars(for: .event)
        
        // Build a predicate — this is EventKit's way of filtering
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )
        
        // Fetch matching events and sort by start date
        let fetchedEvents = eventStore.events(matching: predicate)
        events = fetchedEvents.sorted { $0.startDate < $1.startDate }
    }
    
    // MARK: - CREATE: Add a new event to the default calendar
    // Returns true if the event was saved successfully
    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        notes: String? = nil
    ) -> Bool {
        // Initialize a new event tied to our event store
        let newEvent = EKEvent(eventStore: eventStore)
        
        // Set the event properties
        newEvent.title = title
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.notes = notes
        
        // Assign to the user's default calendar
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            // Save to the calendar database
            // commit: true writes immediately to the store
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
            
            // Refresh our local events list
            fetchEvents()
            return true
        } catch {
            errorMessage = "Failed to save event: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - UPDATE: Modify an existing event's details
    // Accepts optional params — only updates fields that are provided
    // Returns true on success, false on failure
    func updateEvent(
        event: EKEvent,        // The existing event object to modify (reference type)
        newTitle: String?,     // New title, or nil to keep the current one
        newStartDate: Date?,   // New start date, or nil to keep current
        newEndDate: Date?,     // New end date, or nil to keep current
        newNotes: String?      // New notes, or nil to keep current
    ) -> Bool {
        // Conditionally update only the fields that have new values
        // EKEvent is a reference type — changes apply directly to the object
        if let title = newTitle { event.title = title }
        if let start = newStartDate { event.startDate = start }
        if let end = newEndDate { event.endDate = end }
        if let notes = newNotes { event.notes = notes }
        
        do {
            // Save the modified event back to the calendar database
            // span: .thisEvent = only this occurrence (not future recurring events)
            // commit: true = write to disk immediately
            try eventStore.save(event, span: .thisEvent, commit: true)
            // Refresh the local list to reflect the changes in the UI
            fetchEvents()
            return true
        } catch {
            // Store the error message so the UI can display it
            errorMessage = "Failed to update event: \(error.localizedDescription)"
            return false
        }
    }
    // MARK: - DELETE: Remove an event from the calendar
    // Permanently removes the event from the user's calendar database
    // Returns true on success, false on failure
    func deleteEvent(_ event: EKEvent) -> Bool {
        do {
            // Remove the event from the calendar database
            // span: .thisEvent = only delete this single occurrence
            //   (for recurring events, use .futureEvents to delete all future ones)
            // commit: true = write the deletion to disk immediately
            try eventStore.remove(event, span: .thisEvent, commit: true)
            
            // Refresh the local events array so the UI updates
            fetchEvents()
            return true
        } catch {
            // Store the error message for UI display
            errorMessage = "Failed to delete event: \(error.localizedDescription)"
            return false
        }
    }
}
