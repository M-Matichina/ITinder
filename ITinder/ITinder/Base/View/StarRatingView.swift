//
//  StarRatingView.swift
//  ITinder
//
//  Created by Mary Matichina on 17.08.2021.
//

import Foundation
import UIKit

final class StarRatingView: UIStackView {
    
    // MARK: - Handler

    var actionHandler: ((_ rating: Int) -> Void)?

    // MARK: - Properties

    private var starsRating = 0

    override func draw(_ rect: CGRect) {
        let starButtons = subviews.filter { $0 is UIButton }
        var starTag = 1
        for button in starButtons {
            if let button = button as? UIButton {
                button.setImage(UIImage(systemName: "star"), for: .normal)
                button.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
                button.tag = starTag
                starTag = (starTag + 1)
            }
        }
        setStarsRating(rating: starsRating)
    }

    // MARK: - Configure

    func setStarsRating(rating: Int) {
        starsRating = rating
        let stackSubViews = subviews.filter { $0 is UIButton }
        for subView in stackSubViews {
            if let button = subView as? UIButton {
                if button.tag > starsRating {
                    button.setImage(UIImage(systemName: "star"), for: .normal)
                } else {
                    button.setImage(UIImage(systemName: "star.fill"), for: .normal)
                }
            }
        }
    }

    // MARK: - Actions

    @objc func pressed(sender: UIButton) {
        setStarsRating(rating: sender.tag)
        actionHandler?(sender.tag)
    }
}
