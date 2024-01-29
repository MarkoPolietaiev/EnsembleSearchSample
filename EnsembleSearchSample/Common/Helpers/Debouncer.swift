//
//  Debouncer.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import Foundation

/// `Debouncer` is a utility class for managing debouncing of actions, ensuring that a specified action is executed only after a certain time interval has elapsed since the last invocation.
class Debouncer {
    
    /// The time interval for debouncing.
    private let interval: TimeInterval
    
    /// The timer instance responsible for scheduling the delayed execution of the action.
    private var timer: Timer?
    
    /// Initializes the `Debouncer` with a specified time interval.
    ///
    /// - Parameter interval: The time interval for debouncing.
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    /// Debounces the provided action, ensuring it is executed only after the specified time interval has passed since the last invocation.
    ///
    /// If this method is called again within the specified time interval (`interval`), the previous timer is invalidated, and a new timer is scheduled to execute the provided action after the specified interval has passed.
    ///
    /// - Parameter action: A closure representing the action to be debounced.
    func debounce(action: @escaping () -> Void) {
        // Invalidate the previous timer if it exists
        timer?.invalidate()
        
        // Schedule a new timer to execute the action after the specified interval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            action()
        }
    }
}

