//
//  StarRatingTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 15.08.2021.
//

import UIKit

final class StarRatingTableViewCell: UITableViewCell {
    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: StarRatingView!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    // MARK: - Handlers

    var actionHandler: ((_ rating: Int) -> Void)?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        backgroundColor = .clear
        backView.layer.cornerRadius = 10

        stackView.actionHandler = { [weak self] rating in
            self?.actionHandler?(rating)
        }
    }

    func configure(_ title: String, _ bottomMargin: CGFloat = 0, _ rating: Int) {
        stackView.setStarsRating(rating: rating)
        titleLabel.text = title
        bottomConstraint.constant = bottomMargin
    }
}
