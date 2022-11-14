//
//  UserItemCollectionViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 18.08.2021.
//

import UIKit

final class UserItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets

    @IBOutlet private weak var photoView: UIImageView!

    var user: Profile? {
        didSet {
            guard let user = user else {
                return
            }
            photoView.layer.borderWidth = 3.0
            photoView.layer.borderColor = ProfileManager.shared.chatTappedUserIds.contains(user.id) ? UIColor.clear.cgColor : UIColor.systemBlue.cgColor
            photoView.kf.setImage(with: user.imageUrl, placeholder: UIImage(named: "user"), options: nil)
        }
    }

    // MARK: - LifeCycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureElements()
    }

    // MARK: - Configure

    private func configureElements() {
        photoView.layer.cornerRadius = photoView.frame.size.width / 2
        photoView.layer.masksToBounds = true
    }
}
