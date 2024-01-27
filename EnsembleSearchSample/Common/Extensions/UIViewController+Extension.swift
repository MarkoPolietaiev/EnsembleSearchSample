//
//  UIViewController+Extension.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit
import Toast

extension UIViewController {
    func addOutsideTapToCloseKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    func showErrorToast(_ message: String?) {
        var message = message
        if message == nil {
            message = R.string.localizable.errorSomethingWentWrong()
        }
        self.view.makeToast(message)
    }
    
    func handleAPIError(_ error: Error) {
        // Check for specific errors, such as network connectivity issues
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
