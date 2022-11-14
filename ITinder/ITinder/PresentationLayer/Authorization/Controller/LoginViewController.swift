//
//  LoginViewController.swift
//  ITinder
//
//  Created by KirRealDev on 12.08.2021.
//

import DeviceKit
import Firebase
import UIKit

final class LoginViewController: BaseViewController {
    
    override class var storyboardName: String { return "Authorization" }

    // MARK: - Outlets

    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var registrationButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var emailInput: UITextField!
    @IBOutlet private weak var passwordInput: UITextField!
    @IBOutlet private weak var loader: UIActivityIndicatorView!

    // MARK: - Constraints

    @IBOutlet private var upperConstraint: NSLayoutConstraint!

    // MARK: - Properties

    var pressedReg: Bool = false // Нажал кнопку "Зарегестрироваться"?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        emailInput.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        passwordInput.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        configureElements()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        addBackButton()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        continueButton.layer.cornerRadius = 10
        setConstraints()
    }

    // MARK: - Data

    private func createUser() {
        guard let email = emailInput.text,
              let password = passwordInput.text
        else {
            return
        }

        showButtonLoader()
        SceneDelegate.fromLoginScreen = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else {
                return
            }
            self.hideButtonLoader()

            if error == nil {
                if let result = result {
                    self.navigator.navigate(to: .successful)
                    print("id нового юзера: ", result.user.uid)
                }
            } else {
                self.configureError(error)
            }
        }
    }

    private func userExists() {
        guard let email = emailInput.text,
              let password = passwordInput.text
        else {
            return
        }

        showButtonLoader()
        SceneDelegate.fromLoginScreen = false
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else {
                return
            }
            self.hideButtonLoader()

            if let error = error {
                self.configureError(error)
            }
        }
    }

    private func configureError(_ error: Error?) {
        errorLabel.isHidden = false
        errorLabel.text = "\(String(describing: error.unsafelyUnwrapped.localizedDescription))"
    }

    // MARK: - Configure

    private func configureElements() {
        loader.isHidden = true
        errorLabel.isHidden = true
        registrationButton.isHidden = pressedReg == true
        passwordLabel.text = pressedReg == true ? "Придумайте пароль:" : "Введите пароль"
        titleLabel.text = pressedReg == true ? "Регистрация:" : "Вход:"

        if emailInput.hasText, passwordInput.hasText {
            if !continueButton.isEnabled {
                continueButton.isEnabled = true
                continueButton.backgroundColor = .systemBlue
                continueButton.setTitleColor(.white, for: .normal)
            }
        } else {
            if continueButton.isEnabled {
                continueButton.isEnabled = false
                continueButton.backgroundColor = .systemGray5
                continueButton.setTitleColor(.systemGray2, for: .disabled)
            }
        }
    }

    private func showButtonLoader() {
        loader.isHidden = false
        loader.startAnimating()
        continueButton.setTitle("", for: .normal)
    }

    private func hideButtonLoader() {
        continueButton.setTitle("Далее", for: .normal)
        loader.isHidden = true
        loader.stopAnimating()
    }

    // MARK: - Actions

    @IBAction private func continueAction(_ sender: Any) {
        if pressedReg {
            createUser()
        } else {
            userExists()
        }
    }

    @IBAction func registrationAction(_ sender: Any) {
        navigator.navigate(to: .logIn(true))
    }

    @objc func textFieldDidChange(textField: UITextField) {
        configureElements()
    }
}

// MARK: Constraints

extension LoginViewController {
    private func setConstraints() {
        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            upperConstraint.constant = UpperLoginViewConstraintValue.iPhone5Family.rawValue
        case DeviceDiagonals.iPhone6Family.rawValue:
            upperConstraint.constant = UpperLoginViewConstraintValue.iPhone6Family.rawValue
        case DeviceDiagonals.iPhone6PlusFamily.rawValue:
            upperConstraint.constant = UpperLoginViewConstraintValue.iPhone6PlusFamily.rawValue
        default:
            upperConstraint.constant = UpperLoginViewConstraintValue.standard.rawValue
        }
    }
}
