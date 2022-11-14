//
//  NotificationView.swift
//  ITinder
//
//  Created by Mary Matichina on 25.08.2021.
//

import Foundation
import SwiftMessages

final class NotificationView: MessageView {
    
    // MARK: - Outlets

    @IBOutlet private weak var backView: UIView!

    // MARK: - Builder

    class func instance() -> NotificationView? {
        return Bundle.main.loadNibNamed("NotificationView", owner: nil)?.first as? NotificationView
    }

    // MARK: - Configure

    func showNotificationView() {
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.duration = .seconds(seconds: TimeInterval(3.0))
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)

        backView.layer.cornerRadius = 10

        SwiftMessages.show(config: config, view: self)
    }
}
