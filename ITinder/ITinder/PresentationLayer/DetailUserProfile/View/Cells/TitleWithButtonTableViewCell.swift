//
//  TitleWithButtonTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 17.08.2021.
//

import UIKit

final class TitleWithButtonTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: StarRatingView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    // MARK: - Configure

    func configure(_ text: String, _ bottomMargin: CGFloat = 0, _ rating: Int) {
        stackView.setStarsRating(rating: rating)
        titleLabel.text = text
        bottomConstraint.constant = bottomMargin
    }
}
