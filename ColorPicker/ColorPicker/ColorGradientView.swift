//
//  ColorGradientView.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/8.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit

public class ColorGradientView: UIView {

    public enum GradientDirection {
        case horizontal
        case vertical
    }

    public var gradientDirection: GradientDirection = .vertical {
        didSet {
            layoutIfNeeded()
        }
    }

    public var gradientColors: [CGColor]? {
        didSet {
            gradientLayer.colors = gradientColors
        }
    }

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)

        layoutGradient(direction: gradientDirection)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func layoutGradient(direction: GradientDirection) {
        switch direction {
        case .horizontal:
            // Gradient from left to right
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .vertical:
            // Gradient from top to bottom
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
    }
}
