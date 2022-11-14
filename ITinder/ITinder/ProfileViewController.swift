//
//  ProfileViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 13.08.2021.
//

import DeviceKit
import Firebase
import UIKit

final class ProfileViewController: BaseViewController {
    // MARK: - Outlets

    @IBOutlet private weak var photoView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var positionLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!

    // MARK: - Constraints

    @IBOutlet private weak var upperConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    // MARK: - Firebase properties

    private let currentUser = Auth.auth().currentUser

    // MARK: - Properties

    private var profile = Profile()

    // MARK: - Lifecyccle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureElements()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        getData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setConstraints()
    }

    // MARK: - Data

    private func getData() {
        // Получение данных профиля
        guard let user = currentUser else {
            return
        }

        if profile.email == "" {
            profile.email = user.email ?? ""
        }
        showLoader()
        ProfileManager.shared.fetchProfile { [weak self] result in
            guard let self = self else {
                return
            }
            self.hideLoader()

            switch result {
            case .success(let profile):
                self.profile = profile
                self.getDataElements()
            case .failure(let error):
                print("Ошибка: \(error)")
            }
        }
    }

    private func getDataElements() {
        phoneLabel.isHidden = profile.phoneNumber == ""
        positionLabel.isHidden = profile.position == ""

        nameLabel.text = profile.name == "" ? "Это ваш профиль заполните свои данные" : profile.name
        positionLabel.text = profile.position
        phoneLabel.text = profile.phoneNumber
        emailLabel.text = currentUser?.email ?? ""

        setPhoto(profile.imageUrl)
    }

    // MARK: - Configure

    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Настройки", style: .plain, target: self, action: #selector(rightAction))
    }

    private func configureElements() {
        photoView.layer.cornerRadius = photoView.frame.size.width / 2
        photoView.layer.masksToBounds = true

        logoutButton.layer.cornerRadius = 10
        logoutButton.layer.masksToBounds = true

        getDataElements()
    }

    private func setPhoto(_ url: URL?) {
        if let url = url {
            photoView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "user"),
                options: nil
            )
        } else {
            photoView.image = UIImage(named: "user")
        }
    }

    private func showLogoutAlert() {
        let alert = UIAlertController(title: nil, message: "Вы уверены, что хотите выйти из профиля?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let logout = UIAlertAction(title: "Выйти", style: .default) { [weak self] _ in
            guard let _ = self else { return }
            do {
                try Auth.auth().signOut()
                ProfileManager.shared.clear()
            } catch {
                print(error)
            }
        }
        alert.addAction(cancel)
        alert.addAction(logout)
        alert.preferredAction = logout
        alert.view.tintColor = .systemBlue
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction private func logoutAction(_ sender: Any) {
        showLogoutAlert()
    }

    override func rightAction(_ sender: Any) {
        navigator.navigate(to: .settingsUserProfile)
    }
}

// MARK: Constraints

extension ProfileViewController {
    private func setConstraints() {
        // upper constraint
        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            upperConstraint.constant = UpperProfileViewConstraintValue.iPhone5Family.rawValue
        case DeviceDiagonals.iPhone6Family.rawValue:
            upperConstraint.constant = UpperProfileViewConstraintValue.iPhone6Family.rawValue
        case DeviceDiagonals.iPhone6PlusFamily.rawValue:
            upperConstraint.constant = UpperProfileViewConstraintValue.iPhone6PlusFamily.rawValue
        default:
            upperConstraint.constant = UpperProfileViewConstraintValue.standard.rawValue
        }

        // bottom constraint
        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            bottomConstraint.constant = BottomProfileViewConstraintValue.iPhone5Family.rawValue
        case DeviceDiagonals.iPhone6Family.rawValue:
            bottomConstraint.constant = BottomProfileViewConstraintValue.iPhone6Family.rawValue
        case DeviceDiagonals.iPhone6PlusFamily.rawValue:
            bottomConstraint.constant = BottomProfileViewConstraintValue.iPhone6PlusFamily.rawValue
        default:
            bottomConstraint.constant = BottomProfileViewConstraintValue.standard.rawValue
        }
    }
}
