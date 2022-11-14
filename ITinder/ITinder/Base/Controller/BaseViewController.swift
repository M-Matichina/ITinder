//
//  BaseViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 15.08.2021.
//

import IQKeyboardManagerSwift
import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Properties

    lazy var navigator = NavigatorManager(navigationController: navigationController)

    var activityIndicator = ActivityIndicatorViewController()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        isEnableKeyboardHelper = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarColor()
        addKeyboardHideHanlder()
        IQKeyboardManager.shared.enable = true
    }

    // MARK: - Create StoryBoard

    public class var storyboardName: String {
        fatalError("Storyboard not defined:\(String(describing: self))")
    }

    public class func instance() -> Self {
        return instantiateFromStoryboardHelper(type: self, storyboardName: storyboardName)
    }

    // MARK: - Configure Nav Bar

    func addBackButton() {
        navigationItem.hidesBackButton = false
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = "Назад"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
    }

    func navigationBarColor() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.view.backgroundColor = .clear
    }

    // MARK: - Configure

    var isEnableKeyboardHelper: Bool = false {
        didSet {
            let keyboard = IQKeyboardManager.shared

            keyboard.enabledToolbarClasses.removeAll { $0 == type(of: self) }
            keyboard.disabledToolbarClasses.removeAll { $0 == type(of: self) }

            if isEnableKeyboardHelper {
                keyboard.enabledToolbarClasses.append(type(of: self))
            } else {
                keyboard.disabledToolbarClasses.append(type(of: self))
            }
        }
    }

    // MARK: - Actions

    @objc func rightAction(_ sender: Any) {}

    @objc func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Keyboard

    func addKeyboardHideHanlder() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard(_ gesture: UITapGestureRecognizer) {
        let view = gesture.view
        let loc = gesture.location(in: view)
        let subview = view?.hitTest(loc, with: nil)

        if subview?.tag != 100 {
            view?.endEditing(true)
        }
    }

    // MARK: - Activity Indicator

    func showLoader() {
        view.addSubview(activityIndicator.view)
    }

    func hideLoader() {
        activityIndicator.view.removeFromSuperview()
    }
}
