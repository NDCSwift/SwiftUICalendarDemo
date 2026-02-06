//
        //
    //  Project: SwiftUICalendarDemo
    //  File: EventRowView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    


// EventRowView.swift
// Displays a single event in the list with calendar color indicator
// Extracted as its own view for reusability and clean code organization

import SwiftUI   // UI framework
import EventKit  // Needed for EKEvent type access

struct EventRowView: View {
    
    // MARK: - The event to display
    // let = immutable — this view only reads event data, never modifies it
    let event: EKEvent
    
    var body: some View {
        // Horizontal stack: color dot on the left, text details on the right
        HStack(spacing: 12) {
            // Calendar color indicator dot
            // Each calendar (Work, Personal, etc.) has a unique cgColor
            // We convert it to SwiftUI Color to use as the fill
            Circle()
                .fill(Color(cgColor: event.calendar.cgColor))
                .frame(width: 10, height: 10) // Small dot — 10x10 points
            
            // Vertical stack for the text content — left-aligned
            VStack(alignment: .leading, spacing: 4) {
                // Event title — bold headline weight
                Text(event.title)
                    .font(.headline)
                
                // Formatted start and end time — secondary color for hierarchy
                Text(formatEventTime(event))
                    .font(.subheadline)
                    .foregroundStyle(.secondary) // Gray text — visual hierarchy
                
                // Which calendar this event belongs to — lightest weight
                Text(event.calendar.title)
                    .font(.caption)
                    .foregroundStyle(.tertiary) // Lightest gray — least important info
            }
        }
        .padding(.vertical, 4) // Small vertical padding between rows
    }
    
    // MARK: - Format the event time range into a readable string
    // Private because only this view needs this formatting logic
    private func formatEventTime(_ event: EKEvent) -> String {
        // All-day events don't have meaningful start/end times
        // Show "All Day" instead of "12:00 AM — 12:00 AM"
        if event.isAllDay {
            return "All Day"
        }
        // Create a formatter for human-readable date + time strings
        let formatter = DateFormatter()
        formatter.dateStyle = .medium   // e.g., "Jan 15, 2026"
        formatter.timeStyle = .short    // e.g., "2:30 PM"
        // Combine start and end into a range string with em dash
        return "\(formatter.string(from: event.startDate)) — \(formatter.string(from: event.endDate))"
    }
}