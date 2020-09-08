//
//  HSBColor.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/3.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit
import CoreGraphics

public class HSBColor: NSObject {
    /// Hue value in interval <0, 1>
    @objc
    public let hue: CGFloat
    /// Saturation value in interval <0, 1>
    @objc
    public let saturation: CGFloat
    /// Brightness value in interval <0, 1>
    public let brightness: CGFloat
    /// Alpha value in interval <0, 1>
    public let alpha: CGFloat

    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1) {
        self.hue = max(0, min(1, hue))
        self.saturation = max(0, min(1, saturation))
        self.brightness = max(0, min(1, brightness))
        self.alpha = max(0, min(1, alpha))
    }
}

extension HSBColor {
    public convenience init(color: UIColor) {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    /// Returs `UIColor` that represents equivalent color as this instance.
    ///
    /// - Returns: `UIColor` equivalent to this `HSBColor`.
    @objc
    public func toUIColor() -> UIColor {
        UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    public func withHue(_ hue: CGFloat) -> HSBColor {
        HSBColor(hue: hue, saturation: saturation, brightness: brightness)
    }

    public func withSaturation(_ saturation: CGFloat) -> HSBColor {
        HSBColor(hue: hue, saturation: saturation, brightness: brightness)
    }

    public func withBrightness(_ brightness: CGFloat) -> HSBColor {
        HSBColor(hue: hue, saturation: saturation, brightness: brightness)
    }

    public func withHue(_ hue: CGFloat, andSaturation saturation: CGFloat) -> HSBColor {
        HSBColor(hue: hue, saturation: saturation, brightness: brightness)
    }

    public func withSaturation(_ saturation: CGFloat, andBrightness brightness: CGFloat) -> HSBColor {
        HSBColor(hue: hue, saturation: saturation, brightness: brightness)
    }

    public func withHue(_ hue: CGFloat, andBrightness brightness: CGFloat) -> HSBColor {
        HSBColor(hue: hue, saturation: saturation, brightness: brightness)
    }
}

extension UIColor {

    public var hsbColor: HSBColor {
        HSBColor(color: self)
    }
}

