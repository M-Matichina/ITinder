//
//  TabBarViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 21.08.2021.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - Properties

    var selectedIndexOfTab = 2

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureControllers()
        configureTabs()
        selectedIndex = selectedIndexOfTab
    }

    // MARK: - Configure

    private func configureControllers() {
        guard let storyboard = storyboard else {
            return
        }

        let search = storyboard.instantiateViewController(withIdentifier: "SearchNavigationController")
        let chat = storyboard.instantiateViewController(withIdentifier: "ChatNavigationController")
        let profile = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController")

        setViewControllers([search, chat, profile], animated: false)
    }

    private func configureTabs() {
        let topBorder = CALayer()
        topBorder.backgroundColor = UIColor.darkGray.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1.0 / UIScreen.main.scale)
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.systemGray
        tabBar.backgroundColor = UIColor.systemGray

        if let items = tabBar.items {
            items[0].title = "Поиск"
            items[1].title = "Чат"
            items[2].title = "Профиль"
        }
        tabBar.inActiveTintColor()
    }
}

// MARK: - Bar tint

extension UITabBar {
    func inActiveTintColor() {
        if let items = items {
            for item in items {
                item.image = item.image?.withRenderingMode(.alwaysTemplate)
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemGray], for: .normal)
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .selected)
            }
        }
    }
}

// MARK: - Navigation

extension TabBarViewController {
    class func instance() -> TabBarViewController {
        return TabBarViewController.instantiateFromStoryboard(storyboardName: "TabBar")
    }
}
