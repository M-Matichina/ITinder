//
//  UsersTableViewCell.swift
//  ITinder
//
//  Created by Mary Matichina on 18.08.2021.
//

import UIKit

final class UsersTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Handlers

    public var actionHandler: ((_ user: Profile) -> Void)?

    // MARK: - Properties

    private let widthCell: CGFloat = 86
    private let heightCell: CGFloat = 96
    private let identifierCell = "UserItemCollectionViewCell"
    private var profileManager = ProfileManager.shared

    var users: [Profile] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    // MARK: - Configure

    private func configureCell() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: identifierCell, bundle: nil), forCellWithReuseIdentifier: identifierCell)
    }
}

extension UsersTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !users.isEmpty ? users.count : 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierCell, for: indexPath) as! UserItemCollectionViewCell
        if !users.isEmpty {
            cell.user = users[indexPath.item]
        }
        return cell
    }
}

extension UsersTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !users.isEmpty {
            let user = users[indexPath.item]
            if !profileManager.chatTappedUserIds.contains(user.id) {
                profileManager.chatTappedUserIds.append(user.id)
            }
            actionHandler?(user)
        }
    }
}

extension UsersTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthCell, height: heightCell)
    }
}
