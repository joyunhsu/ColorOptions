//
//  GradientSlider.swift
//  PicCollage
//
//  Created by Jo Hsu on 2020/8/6.
//

import UIKit
//import SnapKit

class GradientSlider: UIControl {

    let gradientView = ColorGradientView()
    var gradientSliderHeight: CGFloat = 14 {
        didSet {
            setNeedsLayout()
        }
    }

    var gradientColors: [CGColor] = [] {
        didSet {
            setNeedsLayout()
        }
    }

    var containerSize: CGSize {
        CGSize(
            width: gradientView.bounds.size.width +
                   thumbImageSize.width +
                   touchAreaInset,
            height: thumbImageSize.height + touchAreaInset * 2
        )
    }

    private let touchAreaInset: CGFloat = 5
    private let thumbnailInset: CGFloat = 14 // use the same inset to keep sliders aligned
    var containerInset: CGFloat {
        touchAreaInset + thumbnailInset
    }

    var minimumValue: CGFloat = 0.01
    var maximumValue: CGFloat = 0.99
    var value: CGFloat = 0.5 {
        didSet {
            updateLayerFrames()
        }
    }

    var reversedPercentage: Bool = false

    var thumbImageSize: CGSize {
        CGSize(width: gradientSliderHeight + 10, height: gradientSliderHeight + 10)
    }

    let thumbImageView = UIImageView()

    private var previousLocation = CGPoint()

    override init(frame: CGRect) {
        super.init(frame: frame)

        gradientView.isUserInteractionEnabled = false
        gradientView.gradientColors = gradientColors
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)

        let thumbnailImage = createThumbImage(color: UIColor.white)
        thumbImageView.layer.shadowColor = UIColor(hexString: "#00000033").cgColor
        thumbImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        thumbImageView.layer.shadowRadius = 1
        thumbImageView.layer.shadowOpacity = 1
        thumbImageView.image = thumbnailImage
        addSubview(thumbImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            gradientView.heightAnchor.constraint(equalToConstant: gradientSliderHeight),
            gradientView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: (-(thumbnailInset + touchAreaInset) * 2)),
            gradientView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        gradientView.gradientColors = gradientColors
        updateCornerRadius()
        updateLayerFrames()
    }

    private func updateLayerFrames() {
        thumbImageView.frame = CGRect(origin: thumbOriginForValue(value),
                                      size: thumbImageSize)
    }

    private func positionForValue(_ value: CGFloat) -> CGFloat {
        gradientView.bounds.width * value
    }

    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = gradientView.frame.origin.x + positionForValue(value) - thumbImageSize.width / 2.0
      return CGPoint(x: x, y: (bounds.height - thumbImageSize.height) / 2.0)
    }

    // MARK: - UIControlEvents
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)

        let touchArea = thumbImageView.frame.enlarge(by: CGSize(width: touchAreaInset * 2, height: touchAreaInset * 2))
        if touchArea.contains(previousLocation) {
            thumbImageView.isHighlighted = true
        }

        return thumbImageView.isHighlighted
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width

        previousLocation = location

        if thumbImageView.isHighlighted {
            value += deltaValue
            value = min(max(value, minimumValue), maximumValue)
        }

        sendActions(for: .valueChanged)

        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbImageView.isHighlighted = false
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let touchArea = bounds.enlarge(by: CGSize(width: 10, height: 10))
        return touchArea.contains(point)
    }

    private func createThumbImage(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(thumbImageSize, false, 0)
        color.set()
        let context = UIGraphicsGetCurrentContext()
        context?.fillEllipse(in: CGRect(x: 0,
                                        y: 0,
                                        width: thumbImageSize.width,
                                        height: thumbImageSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func updateCornerRadius() {
        gradientView.layer.masksToBounds = true
        gradientView.layer.cornerRadius = gradientSliderHeight / 2
    }
}

extension CGRect {
    func enlarge(by size: CGSize) -> CGRect {
        let newX = minX - size.width / 2
        let newY = minY - size.height / 2
        let newWidth = width + size.width
        let newHeight = height + size.height
        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
}
