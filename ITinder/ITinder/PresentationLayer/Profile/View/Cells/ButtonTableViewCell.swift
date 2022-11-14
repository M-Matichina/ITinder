//
//  ButtonTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 15.08.2021.
//

import UIKit

final class ButtonTableViewCell: UITableViewCell {
    // MARK: - Outlets

    @IBOutlet var button: UIButton!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        button.layer.cornerRadius = 10
    }

    func configure(_ title: String) {
        button.setTitle(title, for: .normal)
    }
}
