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
