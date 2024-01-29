//
//  UIViewController+Extension.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit
import Toast

extension UIViewController {
    
    /// Adds a tap gesture recognizer to the view to dismiss the keyboard when tapped outside of a text input.
    func addOutsideTapToCloseKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    /// Handles the tap gesture by dismissing the keyboard.
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    /// Displays a toast notification with an error message.
    ///
    /// - Parameter message: The error message to display. If nil, a default error message is used.
    func showErrorToast(_ message: String?) {
        var message = message
        if message == nil {
            message = R.string.localizable.errorSomethingWentWrong()
        }
        self.view.makeToast(message)
    }
    
    /// Handles API-related errors and displays appropriate error messages.
    ///
    /// - Parameter error: The error to be handled.
    func handleAPIError(_ error: Error) {
        // Check for specific API errors
        if let apiError = error as? APIError {
            switch apiError {
            case .noConnection:
                showErrorToast(R.string.localizable.errorNoConnection())
            case .timeout:
                showErrorToast(R.string.localizable.errorRequestTimedOut())
            case .errorResponse(message: let message):
                showErrorToast(message)
            }
        } else {
            // Handle other non-API errors
            showErrorToast(R.string.localizable.errorSomethingWentWrong())
        }
    }
}

