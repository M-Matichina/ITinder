//
//  UserMessageTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 20.08.2021.
//

import UIKit

final class UserMessageTableViewCell: UITableViewCell {
    
    // MARK: Outlets

    @IBOutlet private weak var photoView: UIImageView!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        photoView.layer.cornerRadius = photoView.frame.size.width / 2
        photoView.layer.masksToBounds = true

        backView.layer.cornerRadius = 10
    }

    func configure(_ chat: Chat) {
        subtitleLabel.text = chat.latestMessage.text
        titleLabel.text = chat.name
        setPhoto(chat.imageUrl)
    }

    private func setPhoto(_ url: URL?) {
        if let url = url {
            photoView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "user"),
                options: nil
            )
        } else {
            photoView.image = nil
        }
    }
}
