//
//  NoDataView.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit

/// NoDataView is a subclass of UIView that is used to display a message when there is no data to display.
///
/// This view can be used to display custom messages to the user.
/// It supports the following features:
/// - Customizable message
///
/// Example usage:
/// ```swift
/// let noDataView = NoDataView()
/// noDataView.messageLabel.text = "No data to display"
/// tableView.backgroundView = noDataView
/// ```
class NoDataView: UIView {
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.noSearchResults()
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(messageLabel)
        
        // Add constraints to position the message label in the center
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
