//
//  SuccessfulRegistrationViewController.swift
//  ITinder
//
//  Created by KirRealDev on 13.08.2021.
//

import UIKit

final class SuccessfulRegistrationViewController: BaseViewController {
    
    override class var storyboardName: String { return "Authorization" }

    // MARK: - Outlets

    @IBOutlet private weak var continueButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        continueButton.layer.cornerRadius = 10
    }

    // MARK: - Actions

    @IBAction private func continueAction(_ sender: Any) {
        navigator.navigate(to: .tabBar(selectedIndexOfTab: 2))
    }
}
