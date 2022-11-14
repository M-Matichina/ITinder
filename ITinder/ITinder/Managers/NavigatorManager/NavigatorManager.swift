//
//  NavigatorManager.swift
//  ITinder
//
//  Created by Mary Matichina on 15.08.2021.
//

import UIKit

final class NavigatorManager {
    
    // MARK: - Types

    enum Destination {
        // MARK: - Authorization

        case logIn(_ pressedReg: Bool)
        case successful

        // MARK: - Profile

        case settingsUserProfile
        case detailUserProfile(_ userId: String)

        // MARK: - Chat

        case createdChat(_ chat: Chat)
        case chat(user: Profile)

        // MARK: - TabrBar

        case tabBar(selectedIndexOfTab: Int)

        // MARK: - Search

        case search
        case match(currentPerson: Profile, colleaguePerson: Profile)
    }

    // MARK: - Init

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    // MARK: - Properties

    private weak var navigationController: UINavigationController?

    // MARK: - Configure

    func navigate(to destination: Destination) {
        let viewController = makeViewController(for: destination)

        switch destination {
        case .tabBar:

            guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
                return
            }

            let rootNC = UINavigationController(rootViewController: viewController)
            rootNC.isNavigationBarHidden = true
            window.rootViewController = rootNC
            window.makeKeyAndVisible()

        case .chat, .createdChat, .settingsUserProfile, .detailUserProfile:
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)

        default:
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func makeViewController(for destination: Destination) -> UIViewController {
        switch destination {
        
        // MARK: - Authorization

        case .logIn(let pressedReg):
            let controller = LoginViewController.instance()
            controller.pressedReg = pressedReg
            return controller
        case .successful:
            return SuccessfulRegistrationViewController.instance()

        // MARK: - Profile

        case .settingsUserProfile:
            return SettingsProfileViewController.instance()
        case .detailUserProfile(let userId):
            let controller = DetailUserProfileViewController.instance()
            controller.userId = userId
            return controller

        // MARK: - Chat

        case .createdChat(let chat):
            return ChatViewController(chat: chat)
        case .chat(let user):
            return ChatViewController(user: user)

        // MARK: - TabBar

        case .tabBar(let selectedIndexOfTab):
            let controller = TabBarViewController.instance()
            controller.selectedIndexOfTab = selectedIndexOfTab
            return controller

        // MARK: - Search

        case .search:
            return SearchViewController.instance()
        case .match(let currentPersonProfile, let colleaguePersonProfile):
            let controller = MatchViewController.instance()
            controller.currentPersonProfile = currentPersonProfile
            controller.colleaguePersonProfile = colleaguePersonProfile
            return controller
        }
    }
}
