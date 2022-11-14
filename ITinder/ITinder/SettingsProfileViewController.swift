//
//  SettingsViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 13.08.2021.
//

import Firebase
import FirebaseStorage
import UIKit

final class SettingsProfileViewController: BaseViewController {
    
    // MARK: - Instance

    override class var storyboardName: String { return "Profile" }

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Firebase properties

    private let currentUser = Auth.auth().currentUser

    // MARK: - Properties

    private var profile = Profile()
    private var group = DispatchGroup()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        setAttachmentHandler()
        isEnableKeyboardHelper = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
    }

    // MARK: - Data

    private func getData() {
        // Получение данных профиля
        guard let user = currentUser else {
            return
        }

        if profile.email == "" {
            profile.email = user.email ?? ""
            tableView.reloadData()
        }

        showLoader()
        ProfileDatabaseManager.shared.getProfile(for: user.uid) { [weak self] result in
            guard let self = self else {
                return
            }
            self.hideLoader()

            switch result {
            case .success(let profile):
                self.profile = profile
                self.checkActiveButton()
                self.tableView.reloadData()
            case .failure(let error):
                print("Ошибка: \(error)")
            }
        }
    }

    /// Загрузка файла
    private func uploadFile() {
        guard let userId = currentUser?.uid else {
            return
        }

        if let localFile = profile.localFile {
            group.enter()
            StorageDatabaseManager.shared.uploadFile(currentUserId: userId, file: localFile) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let url):
                    self.profile.file = url
                case .failure(let error):
                    print("Ошибка при загрузке файла", error)
                }
                self.group.leave()
            }
        }
    }

    /// Загрузка фото
    private func uploadImage() {
        guard let userId = currentUser?.uid else {
            return
        }

        if let localImage = profile.localImage {
            group.enter()
            StorageDatabaseManager.shared.uploadImage(currentUserId: userId, image: localImage) { [weak self] result in
                guard let self = self else {
                    return
                }

                switch result {
                case .success(let url):
                    self.profile.imageUrl = url
                case .failure(let error):
                    print("Ошибка при загрузке фото", error)
                }
                self.group.leave()
            }
        }
    }

    private func saveData() {
        showLoader()
        uploadImage()
        uploadFile()

        group.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }
            // Обновление данных профиля
            ProfileDatabaseManager.shared.updateUser(self.profile)
            NotificationView.instance()?.showNotificationView()
            self.hideLoader()
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Configure

    private func configureNavBar() {
        addBackButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(rightAction))
        checkActiveButton()
    }

    private func checkActiveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = profile.isFullData
    }

    // MARK: - Actions

    override func rightAction(_ sender: Any) {
        saveData()
    }
}

extension SettingsProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 13
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 9:
            return 2
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = ProfilePhotoTableViewCell.createForTableView(tableView) as! ProfilePhotoTableViewCell
            if let file = profile.localImage {
                cell.photoView.image = file
                return cell
            } else if profile.imageUrl != nil {
                cell.setPhoto(profile.imageUrl)
                return cell
            } else {
                return cell
            }
        case 1:
            return createTextFieldCell(profile.name, "Укажите полное имя", indexPath.section)
        case 2:
            return createTextFieldCell(profile.phoneNumber, "Укажите телефон", indexPath.section, .decimalPad)
        case 3:
            return createTextFieldCell(profile.email, "Укажите почту", indexPath.section, .default, false)
        case 4:
            return createTextFieldCell(profile.position, "Укажите должность", indexPath.section)
        case 5:
            return createTextFieldCell(profile.education, "Укажите образование", indexPath.section)
        case 6:
            return createTextFieldCell(profile.city, "Укажите город", indexPath.section)
        case 7:
            let cell = EmptyTextViewTableViewCell.createForTableView(tableView) as! EmptyTextViewTableViewCell
            cell.configure(profile.description, "Расскажите о себе")
            cell.textHandler = { [weak self] text in
                guard let self = self else { return }
                self.profile.description = text
                self.checkActiveButton()
            }
            return cell
        case 8:
            return createTextFieldCell(profile.skills, "Укажите навыки", indexPath.section)
        case 9:
            if indexPath.row == 0 {
                return createStarRating("Русский", 12, profile.levelOfRussianLanguage, indexPath.row)
            } else {
                return createStarRating("Английский", 0, profile.levelOfEnglishLanguage, indexPath.row)
            }
        case 10:
            return createTextFieldCell(profile.interests, "Укажите интересы", indexPath.section)
        case 11:
            return createTextFieldCell(profile.workExperience, "Укажите опыт работы", indexPath.section)
        case 12:
            let cell = FileTableViewCell.createForTableView(tableView) as! FileTableViewCell
            if let fileUrl = profile.localFile {
                cell.configure("Document." + fileUrl.pathExtension)
                return cell
            } else if profile.file != nil {
                cell.configure("Document.pdf" + (profile.file?.pathExtension ?? ""))
                return cell
            } else {
                return createAddButton("Добавить файл")
            }
        default:
            return UITableViewCell()
        }
    }
}

extension SettingsProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Имя и фамилия"
        case 2:
            return "Номер телефона"
        case 3:
            return "Почта"
        case 4:
            return "Должность"
        case 5:
            return "Образование"
        case 6:
            return "Город"
        case 7:
            return "Обо мне"
        case 8:
            return "Навыки"
        case 9:
            return "Языки"
        case 10:
            return "Интересы"
        case 11:
            return "Опыт работы"
        case 12:
            return "Файл"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 8:
            return "Например: Swift, MVC, UIKit"
        case 12:
            return "Допустимые форматы: PDF"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 18, y: 0, width: 0, height: 0))
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()

        let headerView = UIView()
        headerView.addSubview(headerLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            AlertSheetViewController.shared.showAlertSheet(items: [.photo, .photoLibrary], controller: self)
        case 12:
            AlertSheetViewController.shared.showAlertSheet(items: [.file], controller: self)
        default:
            break
        }
    }
}

// MARK: - Cell builder

extension SettingsProfileViewController {
    private func createTextFieldCell(_ text: String, _ placeholder: String, _ section: Int, _ keyboard: UIKeyboardType = .default, _ isEnabled: Bool = true) -> UITableViewCell {
        let cell = EmptyTextFieldTableViewCell.createForTableView(tableView) as! EmptyTextFieldTableViewCell
        cell.configure(text, placeholder, keyboard, isEnabled)
        cell.textHandler = { [weak self] text in
            guard let self = self else { return }

            switch section {
            case 1:
                self.profile.name = text
            case 2:
                self.profile.phoneNumber = text
            case 3:
                self.profile.email = text
            case 4:
                self.profile.position = text
            case 5:
                self.profile.education = text
            case 6:
                self.profile.city = text
            case 8:
                self.profile.skills = text
            case 10:
                self.profile.interests = text
            case 11:
                self.profile.workExperience = text
            default:
                break
            }
            self.checkActiveButton()
        }
        return cell
    }

    private func createAddButton(_ title: String) -> UITableViewCell {
        let cell = ButtonTableViewCell.createForTableView(tableView) as! ButtonTableViewCell
        cell.configure(title)
        return cell
    }

    private func createStarRating(_ title: String, _ bottomMargin: CGFloat = 0, _ rating: Int, _ indexPath: Int) -> UITableViewCell {
        let cell = StarRatingTableViewCell.createForTableView(tableView) as! StarRatingTableViewCell
        cell.configure(title, bottomMargin, rating)
        cell.actionHandler = { [weak self] rating in
            guard let self = self else { return }
            switch indexPath {
            case 0:
                self.profile.levelOfRussianLanguage = rating
            case 1:
                self.profile.levelOfEnglishLanguage = rating
            default:
                break
            }
        }
        return cell
    }
}

// MARK: - Set photo

extension SettingsProfileViewController {
    func setAttachmentHandler() {
        // Image
        AlertSheetViewController.shared.imagePickedBlock = { [weak self] image in
            guard let self = self else {
                return
            }
            self.profile.localImage = image
            self.tableView.reloadData()
            self.checkActiveButton()
        }

        // File
        AlertSheetViewController.shared.filePickedBlock = { [weak self] url in
            guard let self = self else {
                return
            }
            self.profile.localFile = url
            self.tableView.reloadData()
        }
    }
}
