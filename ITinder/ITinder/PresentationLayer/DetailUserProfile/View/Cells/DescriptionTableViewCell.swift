//
//  DescriptionTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 17.08.2021.
//

import UIKit

final class DescriptionTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    // MARK: - Configure

    func configure(_ text: String, _ bottomMargin: CGFloat = 0) {
        descLabel.text = text
        bottomConstraint.constant = bottomMargin
    }
}
