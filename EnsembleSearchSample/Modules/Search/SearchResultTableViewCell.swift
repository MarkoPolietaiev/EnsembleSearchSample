//
//  SearchResultTableViewCell.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import UIKit
import SDWebImage

protocol SearchResultTableViewCellDelegate: AnyObject {
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
    
    func configure(with movie: Movie) {
        self.movie = movie
        titleLabel.text = movie.title
        typeLabel.text = movie.type.localizedValue
        yearLabel.text = movie.year
        posterImageView.sd_setImage(with: URL(string: movie.poster), placeholderImage: UIImage(systemName: "photo.fill"))
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        guard let movie else { return }
        delegate?.didTapButton(movie: movie)
    }
}
