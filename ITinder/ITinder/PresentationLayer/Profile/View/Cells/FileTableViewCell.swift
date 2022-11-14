//
//  FileTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 01.09.2021.
//

import UIKit

final class FileTableViewCell: UITableViewCell {
    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var backView: UIView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        backgroundColor = .clear
        backView.layer.cornerRadius = 10
    }

    func configure(_ title: String) {
        titleLabel.text = title
    }
}
