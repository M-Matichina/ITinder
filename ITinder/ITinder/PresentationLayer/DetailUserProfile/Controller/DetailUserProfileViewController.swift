//
//  DetailUserProfileViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 17.08.2021.
//

import Firebase
import FirebaseStorage
import MessageUI
import UIKit

final class DetailUserProfileViewController: BaseViewController {
    
    override class var storyboardName: String { return "DetailUserProfile" }

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Firebase properties

    private let currentUser = Auth.auth().currentUser

    // MARK: - Properties

    var userId: String?
    private var profile = Profile()
    private var isMatch = false
    private var selectedIndex = 0
    private var lastContentOffset = CGPoint.zero

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBackButton()
    }

    // MARK: - Data

    private func getData() {
        /// Получение данных профиля
        guard let userId = userId ?? currentUser?.uid else {
            return
        }

        showLoader()
        ProfileDatabaseManager.shared.getProfile(for: userId) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let profile):
                self.profile = profile

                SearchDatabaseManager.shared.checkMatch(otherProfileId: profile.id) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    self.hideLoader()

                    switch result {
                    case .success(let isMatch):
                        self.isMatch = isMatch
                        self.tableView.reloadData()
                    case .failure(let error):
                        self.hideLoader()
                        self.isMatch = false
                        print("Ошибка: \(error)")
                    }
                }
                self.tableView.reloadData()

            case .failure(let error):
                self.hideLoader()
                print("Ошибка: \(error)")
            }
        }
    }
}

extension DetailUserProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isAboutCollegueSelected = selectedIndex == 0
        let isAboutExperienceSelected = selectedIndex == 1

        switch section {
        /// STATIC SECTIONS
        case 0, 1:
            return 1

        /// SECTIONS FOR ABOUT COLLEAGUE SEGMENT
        case 2, 3, 4, 5:
            return isAboutCollegueSelected ? 1 : 0

        /// SECTIONS FOR ABOUT EXPERIENCE SEGMENT
        case 6, 8:
            return isAboutExperienceSelected ? 1 : 0
        case 7:
            return isAboutExperienceSelected ? 2 : 0
        case 9:
            return (isAboutExperienceSelected && profile.file != nil) ? 1 : 0

        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        /// STATIC SECTIONS
        case 0:
            let cell = AvatarTableViewCell.createForTableView(tableView) as! AvatarTableViewCell
            cell.data(profile: profile, isMatch: isMatch)
            cell.actionHandler = { [weak self] in
                guard let self = self else { return }
                self.sendEmail()
            }
            return cell
        case 1:
            let cell = MenuSegmentedTableViewCell.createForTableView(tableView) as! MenuSegmentedTableViewCell
            cell.menuSegmented.selectedSegmentIndex = selectedIndex
            cell.selectHandler = { [weak self] index in
                guard let self = self else { return }
                self.selectedIndex = index
                self.tableView.reloadData()
            }
            return cell

        /// SECTIONS FOR ABOUT COLLEAGUE SEGMENT
        case 2:
            return createCellDesc(profile.description)
        case 3:
            return createCellDesc(profile.education)
        case 4:
            return createCellDesc(profile.city)
        case 5:
            return createCellDesc(profile.interests, 10)

        /// SECTIONS FOR ABOUT  EXPERIENCE SEGMENT
        case 6:
            return createCellDesc(profile.skills)
        case 7:
            if indexPath.row == 0 {
                return createStarRating("Русский", 12, profile.levelOfRussianLanguage)
            } else {
                return createStarRating("Английский", 0, profile.levelOfEnglishLanguage)
            }
        case 8:
            return createCellDesc(profile.workExperience)
        case 9:
            let cell = LeftImageLabelTableViewCell.createForTableView(tableView) as! LeftImageLabelTableViewCell
            cell.configure("Document.pdf")
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension DetailUserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let isAboutCollegueSelected = selectedIndex == 0
        let isAboutExperienceSelected = selectedIndex == 1

        switch section {
        /// SECTIONS FOR ABOUT COLLEAGUE SEGMENT
        case 2:
            return isAboutCollegueSelected ? "О себе" : nil
        case 3:
            return isAboutCollegueSelected ? "Образование" : nil
        case 4:
            return isAboutCollegueSelected ? "Город" : nil
        case 5:
            return isAboutCollegueSelected ? "Интересы" : nil

        /// SECTIONS FOR ABOUT EXPERIENCE SEGMENT
        case 6:
            return isAboutExperienceSelected ? "Навыки" : nil
        case 7:
            return isAboutExperienceSelected ? "Языки" : nil
        case 8:
            return isAboutExperienceSelected ? "Опыт работы" : nil
        case 9:
            return (isAboutExperienceSelected && profile.file != nil) ? "Файлы" : nil
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            return nil
        }

        let headerLabel = UILabel(frame: CGRect(x: 16, y: 20, width: view.frame.width - 32, height: 30))
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()

        let headerView = UIView()
        headerView.addSubview(headerLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let isAboutCollegueSelected = selectedIndex == 0
        let isAboutExperienceSelected = selectedIndex == 1

        switch section {
        case 2, 3, 4, 5:
            return isAboutCollegueSelected ? 50 : 0.001
        case 6, 7, 8, 9:
            return isAboutExperienceSelected ? 50 : 0.001
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0.0 {
            tableView.contentOffset.y = 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 9:
            profile.open()
        default:
            break
        }
    }
}

// MARK: - Cell Builder

extension DetailUserProfileViewController {
    private func createCellDesc(_ text: String, _ bottomMargin: CGFloat = 0) -> UITableViewCell {
        let cell = DescriptionTableViewCell.createForTableView(tableView) as! DescriptionTableViewCell
        cell.configure(text, bottomMargin)
        return cell
    }

    private func createStarRating(_ title: String, _ bottomMargin: CGFloat = 0, _ rating: Int) -> UITableViewCell {
        let cell = TitleWithButtonTableViewCell.createForTableView(tableView) as! TitleWithButtonTableViewCell
        cell.configure(title, bottomMargin, rating)
        return cell
    }
}

// MARK: - Send email

extension DetailUserProfileViewController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([profile.email])
            mail.setMessageBody("Привет, отправляю приглашение", isHTML: true)

            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Произошла ошибка", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
