//
        //
    //  Project: SwiftUICalendarDemo
    //  File: CreateEventView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    


// CreateEventView.swift
// Form for creating a new calendar event
// Presented as a modal sheet from ContentView

import SwiftUI  // Only need SwiftUI here — CalendarManager handles EventKit

struct CreateEventView: View {
    
    // MARK: - Dependencies
    // Reference to our shared CalendarManager — passed in from ContentView
    var calendarManager: CalendarManager
    // Environment dismiss action — lets us close this sheet programmatically
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form state
    // Each @State property maps to one form field
    @State private var title = ""                                        // Event title text
    @State private var startDate = Date()                                // Defaults to right now
    @State private var endDate = Date().addingTimeInterval(3600)         // Defaults to +1 hour from now
    @State private var notes = ""                                        // Optional notes text
    @State private var showingError = false                              // Controls error alert visibility
    
    var body: some View {
        // Wrap in NavigationStack to get a nav bar with Cancel/Save buttons
        NavigationStack {
            // Form provides automatic iOS-style grouped sections
            Form {
                // MARK: - Event Details Section
                // Groups the core event fields together visually
                Section("Event Details") {
                    // Text field bound to the title state variable
                    TextField("Event Title", text: $title)
                    
                    // Date picker for the event start time
                    // displayedComponents controls what the picker shows
                    // [.date, .hourAndMinute] = full date + time, no seconds
                    DatePicker(
                        "Start",
                        selection: $startDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    
                    // Date picker for the event end time
                    // "in: startDate..." constrains the minimum selectable date
                    // This prevents the user from picking an end BEFORE the start
                    DatePicker(
                        "End",
                        selection: $endDate,
                        in: startDate...,  // Range operator — end must be >= start
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                // MARK: - Notes Section
                // Optional multiline text input for event notes
                Section("Notes") {
                    // axis: .vertical makes the TextField expand vertically
                    // lineLimit(3...6) sets min 3 lines, max 6 before scrolling
                    TextField("Add notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Event")                   // Sheet title
            .navigationBarTitleDisplayMode(.inline)          // Small centered title — standard for sheets
            .toolbar {
                // MARK: - Cancel button (top-left)
                ToolbarItem(placement: .topBarLeading) {
                    // Dismiss the sheet without saving anything
                    Button("Cancel") { dismiss() }
                }
                // MARK: - Save button (top-right)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveEvent() }        // Calls our save function below
                        .fontWeight(.semibold)              // Bold to indicate primary action
                        // Disable the button if the title is empty or just whitespace
                        // Prevents creating events with blank titles
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            // Error alert — shown when saving fails
            .alert("Could Not Save Event", isPresented: $showingError) {
                // Single OK button to dismiss the alert
                Button("OK", role: .cancel) { }
            } message: {
                // Display the error message from CalendarManager, or a fallback
                Text(calendarManager.errorMessage ?? "An unknown error occurred.")
            }
        }
    }
    
    // MARK: - Save the event and dismiss
    // Private because only this view's Save button calls it
    private func saveEvent() {
        // Call CalendarManager's create method with trimmed inputs
        let success = calendarManager.createEvent(
            title: title.trimmingCharacters(in: .whitespaces),  // Remove leading/trailing spaces
            startDate: startDate,
            endDate: endDate,
            notes: notes.isEmpty ? nil : notes  // Pass nil if notes are empty — cleaner data
        )
        
        if success {
            // Event saved — close the sheet and return to the list
            dismiss()
        } else {
            // Save failed — show the error alert
            showingError = true
        }
    }
}