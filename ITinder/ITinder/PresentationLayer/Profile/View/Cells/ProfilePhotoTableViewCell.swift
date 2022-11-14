//
//  ProfilePhotoTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 13.08.2021.
//

import UIKit

final class ProfilePhotoTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet private weak var changeButton: UIButton!
    @IBOutlet private weak var lineView: UIView!

    // MARK: - Handlers

    var actionHandler: (() -> Void)?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        photoView.layer.cornerRadius = photoView.frame.size.width / 2
        photoView.layer.masksToBounds = true
    }

    func setPhoto(_ url: URL?) {
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

    // MARK: - Actions

    @IBAction private func changeAction(_ sender: Any) {
        actionHandler?()
    }
}
