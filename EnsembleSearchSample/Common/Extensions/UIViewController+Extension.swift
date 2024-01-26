//
//  UIViewController+Extension.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit
import Toast

extension UIViewController {
    func showErrorToast(_ message: String?) {
        var style = ToastStyle()
        style.messageColor = .white
        // present the toast with the new style
        var message = message
        if message == nil {
            message = R.string.localizable.errorSomethingWentWrong()
        }
        self.view.makeToast(message, point: CGPoint(x: view.center.x, y: view.frame.maxY - 160), title: nil, image: nil, completion: nil)
    }
    
    func handleAPIError(_ error: Error) {
        // Check for specific errors, such as network connectivity issues
        if let apiError = error as? NetworkError {
            switch apiError {
            case .noConnection:
                showErrorToast(R.string.localizable.errorNoConnection())
            case .timeout:
                showErrorToast(R.string.localizable.errorRequestTimedOut())
            }
        } else {
            // Handle other non-API errors
            showErrorToast(R.string.localizable.errorSomethingWentWrong())
        }
    }
}
