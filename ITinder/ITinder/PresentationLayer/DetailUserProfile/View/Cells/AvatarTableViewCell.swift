//
//  AvatarTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 17.08.2021.
//

import Firebase
import UIKit

final class AvatarTableViewCell: UITableViewCell {
    
    // MARK: - Handlers

    var actionHandler: (() -> Void)?

    // MARK: - Outlets

    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var photoView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.isHidden = true
    }

    func data(profile: Profile?, isMatch: Bool) {
        nameLabel.text = profile?.name
        titleLabel.text = profile?.position
        if isMatch {
            button.isHidden = false
        } else {
            button.isHidden = true
        }
        setPhoto(profile?.imageUrl)
    }

    func setPhoto(_ url: URL?) {
        if let url = url {
            photoView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [.transition(.fade(0.2)), .backgroundDecode]
            )
        } else {
            photoView.image = UIImage(named: "largeUser")
        }
    }

    // MARK: - Actions

    @IBAction func buttonAction(_ sender: Any) {
        actionHandler?()
    }
}
