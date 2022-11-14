//
//  ListChatViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 18.08.2021.
//

import DeviceKit
import Firebase
import UIKit

final class ListChatViewController: BaseViewController {
    
    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stackElementsView: UIStackView!

    // MARK: - Contraints

    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    // MARK: - Propeties

    private var chats = [Chat]()
    private var users = [Profile]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 26, left: 0, bottom: 0, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Data

    private func getData() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        getConnectUsers()

        print("Начинаю получать данные чатов")

        showLoader()
        ChatDatabaseManager.shared.getAllChats(for: currentUserId, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let chats):
                print("Успешно")
                self.chats = chats
                self.stackElementsView.isHidden = !chats.isEmpty
                self.getUsers()
            case .failure(let error):
                self.getUsers()
                self.hideLoader()
                print("Ошибка: \(error)")
            }
        })
    }

    private func getUsers() {
        ProfileDatabaseManager.shared.getAllUsers { [weak self] result in
            guard let self = self else {
                return
            }
            self.hideLoader()

            switch result {
            case .success(let users):
                for index in 0..<self.chats.count {
                    self.chats[index].imageUrl = users.first(where: { $0.id == self.chats[index].otherUserId })?.imageUrl
                }
                self.tableView.reloadData()
            case .failure(let error):
                self.hideLoader()
                print("Ошибка: \(error)")
            }
        }
    }

    private func getConnectUsers() {
        SearchDatabaseManager.shared.fetchConnectUser { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let profiles):
                self.users = profiles
                self.tableView.reloadSections([0], with: .none)
            case .failure(let error):
                self.hideLoader()
                print("Ошибка: \(error)")
            }
        }
    }
}

extension ListChatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return chats.count
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UsersTableViewCell.createForTableView(tableView) as! UsersTableViewCell
            cell.users = users.sorted(by: { $0.name < $1.name })
            cell.actionHandler = { [weak self] user in
                self?.navigator.navigate(to: .chat(user: user))
            }
            return cell
        case 1:
            let cell = UserMessageTableViewCell.createForTableView(tableView) as! UserMessageTableViewCell
            cell.configure(chats[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension ListChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Все коллеги"
        case 1:
            return "Сообщения"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 18, y: 0, width: 0, height: 0))
        headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()

        let headerView = UIView()
        headerView.addSubview(headerLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            navigator.navigate(to: .createdChat(chats[indexPath.row]))
        }
    }
}

// MARK: Constraints

extension ListChatViewController {
    private func setConstraints() {
        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            bottomConstraint.constant = BottomListChatViewConstraintValue.iPhone5Family.rawValue
        case DeviceDiagonals.iPhone6Family.rawValue:
            bottomConstraint.constant = BottomListChatViewConstraintValue.iPhone6Family.rawValue
        case DeviceDiagonals.iPhone6PlusFamily.rawValue:
            bottomConstraint.constant = BottomListChatViewConstraintValue.iPhone6PlusFamily.rawValue
        default:
            bottomConstraint.constant = BottomListChatViewConstraintValue.standard.rawValue
        }
    }
}
