//
//  ButtonStackView.swift
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

import DeviceKit
import PopBounceButton

protocol ButtonStackViewDelegate: AnyObject {
    func didTapButton(button: ITinderButton)
}

class ButtonStackView: UIStackView {
    
    // MARK: - Properties

    weak var delegate: ButtonStackViewDelegate?

    let dislikeButton: ITinderButton = {
        let button = ITinderButton()
        button.setImage(UIImage(named: "dislike"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 1
        return button
    }()

    let likeButton: ITinderButton = {
        let button = ITinderButton()
        button.setImage(UIImage(named: "like"), for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.tag = 2
        return button
    }()

    // MARK: - Methods

    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .equalSpacing
        alignment = .center
        configureButtons()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureButtons() {
        let largeMultiplier: CGFloat = 80.0 / getCurrentScreenWidth()
        addArrangedSubview(from: dislikeButton, diameterMultiplier: largeMultiplier)
        addArrangedSubview(from: likeButton, diameterMultiplier: largeMultiplier)
    }

    private func getCurrentScreenWidth() -> CGFloat {
        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            return ButtonsSizeSearchView.iPhone5Family.rawValue
        case DeviceDiagonals.iPhone6Family.rawValue:
            return ButtonsSizeSearchView.iPhone6Family.rawValue
        default:
            return BottomHomeViewConstraintValue.standard.rawValue
        }
    }

    private func addArrangedSubview(from button: ITinderButton, diameterMultiplier: CGFloat) {
        let container = ButtonContainer()
        container.addSubview(button)
        button.anchorToSuperview()
        addArrangedSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: diameterMultiplier).isActive = true
        container.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }

    @objc
    private func handleTap(_ button: ITinderButton) {
        delegate?.didTapButton(button: button)
    }
}

private class ButtonContainer: UIView {
    override func draw(_ rect: CGRect) {
        applyShadow(radius: 0.2 * bounds.width, opacity: 0.05, offset: CGSize(width: 0, height: 0.15 * bounds.width))
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
