//
//  HomeViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 29.07.2021.
//

import DeviceKit
import Firebase
import UIKit

final class HomeViewController: BaseViewController {
    
    // MARK: - Outlets

    @IBOutlet private weak var loginButton: UIButton!

    // MARK: - Constraints

    @IBOutlet private weak var constraintBetweenAppNameAndDescription: NSLayoutConstraint!
    @IBOutlet private weak var constraintBetweenLoginButtonAndButtonDescription: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginButton.layer.cornerRadius = 10
        setConstraints()
    }

    // MARK: - Actions

    @IBAction private func loginAction(_ sender: Any) {
        navigator.navigate(to: .logIn(false))
    }
}

// MARK: Constraints

extension HomeViewController {
    private func setConstraints() {
        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            constraintBetweenAppNameAndDescription.constant = ConstraintBetweenHomeViewAttributesValue.iPhone5Family.rawValue
            constraintBetweenLoginButtonAndButtonDescription.constant = constraintBetweenAppNameAndDescription.constant
        case DeviceDiagonals.iPhone6Family.rawValue:
            constraintBetweenAppNameAndDescription.constant = ConstraintBetweenHomeViewAttributesValue.iPhone6Family.rawValue
            constraintBetweenLoginButtonAndButtonDescription.constant = constraintBetweenAppNameAndDescription.constant
        default:
            constraintBetweenAppNameAndDescription.constant = ConstraintBetweenHomeViewAttributesValue.standard.rawValue
            constraintBetweenAppNameAndDescription.constant = constraintBetweenLoginButtonAndButtonDescription.constant
        }
    }
}
