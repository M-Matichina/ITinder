//
//  MatchViewController.swift
//  ITinder
//
//  Created by KirRealDev on 22.08.2021.
//

import DeviceKit
import UIKit

class MatchViewController: BaseViewController {
    
    override class var storyboardName: String { return "Search" }

    // MARK: - Constraints

    @IBOutlet private weak var upperMatchViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var upperGroupConstraint: NSLayoutConstraint!
    @IBOutlet private weak var middleGroupConstraint: NSLayoutConstraint!
    @IBOutlet private weak var lowGroupConstraint: NSLayoutConstraint!

    // MARK: - Outlets

    @IBOutlet private weak var appLogoImageView: UIImageView!
    @IBOutlet private weak var currentPersonImageView: UIImageView!
    @IBOutlet private weak var colleaguePersonImageView: UIImageView!
    @IBOutlet private weak var currentPersonLabel: UILabel!
    @IBOutlet private weak var colleaguePersonLabel: UILabel!
    @IBOutlet private weak var writeMessageButton: UIButton!

    // MARK: - Properties

    var currentPersonProfile: Profile?
    var colleaguePersonProfile: Profile?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
        configureElements()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        setConstraints()
        imageSettings()
    }

    // MARK: - Methods

    private func configureElements() {
        currentPersonLabel.text = currentPersonProfile?.name
        colleaguePersonLabel.text = colleaguePersonProfile?.name
        setPhotos(currentPersonUrl: currentPersonProfile?.imageUrl, colleaguePersonUrl: colleaguePersonProfile?.imageUrl)
    }

    private func setPhotos(currentPersonUrl: URL?, colleaguePersonUrl: URL?) {
        if let currentPersonUrl = currentPersonUrl, let colleaguePersonUrl = colleaguePersonUrl {
            currentPersonImageView.kf.setImage(
                with: currentPersonUrl,
                placeholder: nil,
                options: [.transition(.fade(0.2)), .backgroundDecode]
            )
            colleaguePersonImageView.kf.setImage(
                with: colleaguePersonUrl,
                placeholder: nil,
                options: [.transition(.fade(0.2)), .backgroundDecode]
            )
        } else {
            currentPersonImageView.image = UIImage(named: "user")
            colleaguePersonImageView.image = UIImage(named: "user")
        }
    }

    private func imageSettings() {
        appLogoImageView.layer.cornerRadius = 10
        appLogoImageView.layer.masksToBounds = true

        currentPersonImageView.layer.cornerRadius = currentPersonImageView.frame.size.width / 2
        currentPersonImageView.layer.masksToBounds = true

        colleaguePersonImageView.layer.cornerRadius = colleaguePersonImageView.frame.size.width / 2
        colleaguePersonImageView.layer.masksToBounds = true
    }
}

extension MatchViewController {
    private func setConstraints() {
        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            upperGroupConstraint.constant = GroupsMatchViewConstraintValue.iPhone5Family.rawValue
            middleGroupConstraint.constant = GroupsMatchViewConstraintValue.iPhone5Family.rawValue
            lowGroupConstraint.constant = GroupsMatchViewConstraintValue.iPhone5Family.rawValue
        case DeviceDiagonals.iPhone6Family.rawValue:
            upperGroupConstraint.constant = GroupsMatchViewConstraintValue.iPhone6Family.rawValue
            middleGroupConstraint.constant = GroupsMatchViewConstraintValue.iPhone6Family.rawValue
            lowGroupConstraint.constant = GroupsMatchViewConstraintValue.iPhone6Family.rawValue
        default:
            upperGroupConstraint.constant = GroupsMatchViewConstraintValue.standard.rawValue
            middleGroupConstraint.constant = GroupsMatchViewConstraintValue.standard.rawValue
            lowGroupConstraint.constant = GroupsMatchViewConstraintValue.standard.rawValue
        }

        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            upperMatchViewConstraint.constant = UpperMatchViewConstraintValue.iPhone5Family.rawValue
        case DeviceDiagonals.iPhone6Family.rawValue:
            upperMatchViewConstraint.constant = UpperMatchViewConstraintValue.iPhone6Family.rawValue
        case DeviceDiagonals.iPhone6PlusFamily.rawValue:
            upperMatchViewConstraint.constant = UpperMatchViewConstraintValue.iPhone6PlusFamily.rawValue
        default:
            upperMatchViewConstraint.constant = UpperMatchViewConstraintValue.standard.rawValue
        }
    }
}
