//
//  SearchResultTableViewCell.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit
import SDWebImage

/// Protocol for the delegate to handle button tap events in the SearchResultTableViewCell.
protocol SearchResultTableViewCellDelegate: AnyObject {
    /// Notifies the delegate when the button in the cell is tapped with the associated movie.
    func didTapButton(movie: Movie)
}

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    weak var delegate: SearchResultTableViewCellDelegate?
    
    private var movie: Movie?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Configures the cell with the provided movie information.
    ///
    /// - Parameter movie: The movie object to populate the cell.
    func configure(with movie: Movie) {
        self.movie = movie
        titleLabel.text = movie.title
        typeLabel.text = movie.type.localizedValue
        yearLabel.text = movie.year
        posterImageView.sd_setImage(with: URL(string: movie.poster), placeholderImage: UIImage.posterPlaceholderImage)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        guard let movie else { return }
        delegate?.didTapButton(movie: movie)
    }
}
