//
//  UIView+Extension.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit

extension UIView {
    func addNoDataView(_ message: String? = nil) {
        removeNoDataView()
        let noDataView = NoDataView()
        if let message = message {
            noDataView.messageLabel.text = message
        }
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.tag = 100
        addSubview(noDataView)
        
        NSLayoutConstraint.activate([
            noDataView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noDataView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func removeNoDataView() {
        if let noDataView = viewWithTag(100) {
            noDataView.removeFromSuperview()
        }
    }
    
    func addActivityIndicator() {
        removeActivityIndicator()
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        containerView.layer.cornerRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .lightGray
        containerView.alpha = 0.5
        containerView.tag = 101
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(activityIndicator)
        addSubview(containerView)
        
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
    
    func removeActivityIndicator() {
        if let activityIndicator = viewWithTag(101) {
            activityIndicator.removeFromSuperview()
        }
    }
    
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
