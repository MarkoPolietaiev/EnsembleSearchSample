//
//  UIView+Extension.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit

extension Int {
    static let noDataViewTag = 100
    static let activityIndicatorTag = 101
}

extension UIView {
    
    /// Adds a "No Data" view with an optional message.
    ///
    /// - Parameter message: An optional message to display in the "No Data" view.
    func addNoDataView(_ message: String? = nil) {
        removeNoDataView()
        let noDataView = NoDataView()
        if let message = message {
            noDataView.messageLabel.text = message
        }
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.tag = .noDataViewTag
        addSubview(noDataView)
        
        NSLayoutConstraint.activate([
            noDataView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noDataView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    /// Removes the "No Data" view if it exists.
    func removeNoDataView() {
        if let noDataView = viewWithTag(.noDataViewTag) {
            noDataView.removeFromSuperview()
        }
    }
    
    /// Adds an activity indicator with a loading overlay.
    func addActivityIndicator() {
        removeActivityIndicator()
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        containerView.layer.cornerRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .lightGray
        containerView.alpha = 0.5
        containerView.tag = .activityIndicatorTag
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(activityIndicator)
        containerView.isHidden = true
        addSubview(containerView)
        
        // Add a delay for the loader so it doesn't show for fast requests
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak containerView] in
            containerView?.isHidden = false
        }
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            containerView.widthAnchor.constraint(equalToConstant: 30),
            containerView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        activityIndicator.startAnimating()
    }
    
    /// Removes the activity indicator if it exists.
    func removeActivityIndicator() {
        if let activityIndicator = viewWithTag(.activityIndicatorTag) {
            activityIndicator.removeFromSuperview()
        }
    }
    
    /// Rounds specific corners of the view with a given radius.
    ///
    /// - Parameters:
    ///   - corners: The corners to round.
    ///   - radius: The radius of the rounded corners.
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
