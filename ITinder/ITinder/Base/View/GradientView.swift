//
//  GradientView.swift
//  ITinder
//
//  Created by Mary Matichina on 17.08.2021.
//

import Foundation
import UIKit

final class GradientView: UIView {
    
    // MARK: - Properties
    
    @IBInspectable public var startColor: UIColor = UIColor.black.withAlphaComponent(0.2) { didSet { updateColors() }}
    @IBInspectable public var medium: UIColor = UIColor.black.withAlphaComponent(0.2) { didSet { updateColors() }}
    @IBInspectable public var endColor: UIColor = UIColor.black { didSet { updateColors() }}
    @IBInspectable var startLocation: Double = 0.0 { didSet { updateLocations() }}
    @IBInspectable var mediumLocation: Double = 0.5 { didSet { updateLocations() }}
    @IBInspectable var endLocation: Double = 1.0 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode: Bool = false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode: Bool = false { didSet { updatePoints() }}

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    // MARK: - Configure

    private func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }

    private func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, mediumLocation as NSNumber, endLocation as NSNumber]
    }

    private func updateColors() {
        gradientLayer.colors = [startColor.cgColor, medium.cgColor, endColor.cgColor]
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
