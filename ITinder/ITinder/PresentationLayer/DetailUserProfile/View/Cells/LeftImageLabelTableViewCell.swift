//
//  LeftImageLabelTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 01.09.2021.
//

import UIKit

final class LeftImageLabelTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconeView: UIImageView!

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    // MARK: - Configure

    func configure(_ text: String) {
        titleLabel.text = text
    }
}
