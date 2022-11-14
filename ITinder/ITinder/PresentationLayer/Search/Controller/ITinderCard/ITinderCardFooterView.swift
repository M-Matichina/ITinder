//
//  TinderCardFooterView.swift
//  ITinder
//
//  Created by KirRealDev on 22.08.2021.
///
/// MIT License
///
/// Copyright (c) 2020 Mac Gallagher
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///

import Foundation

import UIKit

class ITinderCardFooterView: UIView {
    
    // MARK: - Properties

    private var label = UILabel()
    private var gradientLayer: CAGradientLayer?

    // MARK: - Methods

    init(withTitle title: String?, subtitle: String?) {
        super.init(frame: CGRect.zero)
        backgroundColor = .systemGray6
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 10
        clipsToBounds = true
        isOpaque = false
        initialize(title: title, subtitle: subtitle)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func initialize(title: String?, subtitle: String?) {
        let attributedText = NSMutableAttributedString(
            string: (title ?? "") + "\n",
            attributes: NSAttributedString.Key.titleAttributes
        )
        if let subtitle = subtitle, !subtitle.isEmpty {
            attributedText.append(NSMutableAttributedString(
                string: subtitle,
                attributes: NSAttributedString.Key.subtitleAttributes
            ))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.lineBreakMode = .byTruncatingTail
            attributedText.addAttributes(
                [NSAttributedString.Key.paragraphStyle: paragraphStyle],
                range: NSRange(location: 0, length: attributedText.length)
            )
            label.numberOfLines = 2
        }

        label.attributedText = attributedText
        addSubview(label)
    }

    override func layoutSubviews() {
        let padding: CGFloat = 20
        label.frame = CGRect(
            x: padding,
            y: bounds.height - label.intrinsicContentSize.height - padding,
            width: bounds.width - 2 * padding,
            height: label.intrinsicContentSize.height
        )
    }
}

extension NSAttributedString.Key {
    static var titleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22),
        NSAttributedString.Key.foregroundColor: UIColor.black
    ]

    static var subtitleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
        NSAttributedString.Key.foregroundColor: UIColor.systemGray
    ]
}
