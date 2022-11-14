//
//  SceneDelegate.swift
//  ITinder
//
//  Created by Mary Matichina on 29.07.2021.
//

import Firebase
import Kingfisher
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties

    var window: UIWindow?
    static var fromLoginScreen = false

    // MARK: - Configure

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            if user == nil { // Если пользователь не вошел в аккаунт
                self.showLoginScreen(scene: scene)
            } else { // Если пользователь вошел в аккаунт
                if !SceneDelegate.fromLoginScreen {
                    self.showTabBarScreen(scene: scene)
                }
            }
        }
    }

    func showLoginScreen(scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        guard let rootVC = storyboard.instantiateViewController(identifier: "HomeViewController") as? HomeViewController else {
            print("\(String(describing: HomeViewController.self)) not found")
            return
        }

        let rootNC = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = rootNC
        window?.makeKeyAndVisible()
    }

    func showTabBarScreen(scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
        guard let rootVC = storyboard.instantiateViewController(identifier: "TabBarViewController") as? TabBarViewController else {
            print("\(String(describing: TabBarViewController.self)) not found")
            return
        }

        let rootNC = UINavigationController(rootViewController: rootVC)
        rootNC.isNavigationBarHidden = true
        window?.rootViewController = rootNC
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
