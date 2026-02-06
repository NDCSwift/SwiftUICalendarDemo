//
        //
    //  Project: SwiftUICalendarDemo
    //  File: import.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    


// EventEditBridge.swift
// Bridges UIKit's EKEventEditViewController into SwiftUI
// Gives users the full native calendar editing experience
// Required because EventKitUI was built for UIKit, not SwiftUI

import SwiftUI      // For UIViewControllerRepresentable protocol
import EventKit     // For EKEventStore and EKEvent types
import EventKitUI   // For EKEventEditViewController and its delegate

// UIViewControllerRepresentable lets us wrap any UIKit view controller
// and use it inside a SwiftUI view hierarchy (e.g., in a .sheet)
struct EventEditBridge: UIViewControllerRepresentable {
    
    // MARK: - The event store and event to edit
    // Must be the SAME event store instance used throughout the app
    let eventStore: EKEventStore
    // The specific event to edit — nil would create a new event
    let event: EKEvent?
    
    // MARK: - Callback when editing completes
    // Called whether the user saves, deletes, or cancels
    // Parent view uses this to dismiss the sheet and refresh data
    var onComplete: () -> Void
    
    // MARK: - Create the UIKit view controller
    // Called once when SwiftUI first displays this representable
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        // Instantiate Apple's built-in event editing controller
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore            // Connect to our shared store
        controller.event = event                       // Pass the event to edit
        controller.editViewDelegate = context.coordinator  // Wire up the delegate via Coordinator
        return controller
    }
    
    // MARK: - Required by protocol — no updates needed
    // Called when SwiftUI state changes — we don't need to react to updates
    func updateUIViewController(
        _ uiViewController: EKEventEditViewController,
        context: Context
    ) { }
    
    // MARK: - Coordinator handles delegate callbacks
    // SwiftUI uses Coordinators to bridge UIKit delegate patterns
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }
    
    // Coordinator conforms to EKEventEditViewDelegate
    // This is how we get notified when the user finishes editing
    class Coordinator: NSObject, EKEventEditViewDelegate {
        let onComplete: () -> Void
        
        init(onComplete: @escaping () -> Void) {
            self.onComplete = onComplete
        }
        
        // MARK: - Called when user saves or cancels the edit
        // action tells us what happened: .saved, .canceled, or .deleted
        // We call onComplete for all cases — the parent handles the rest
        func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            onComplete()
        }
    }
}