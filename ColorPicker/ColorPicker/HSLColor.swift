//
//  HSLColor.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/4.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit

public class HSLColor: NSObject {
    /// Hue value in interval <0, 1>
    @objc
    public var h: CGFloat
    /// Saturation value in interval <0, 1>
    @objc
    public var s: CGFloat
    /// Lightness value in interval <0, 1>
    @objc
    public var l: CGFloat
    /// Alpha value in interval <0, 1>
    @objc
    public var a: CGFloat

    public init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1) {
        h = max(0, min(1, hue))
        s = max(0, min(1, saturation))
        l = max(0, min(1, lightness))
        a = max(0, min(1, alpha))
    }

    /**
    Initializes and creates a HSL (hue, saturation, lightness) color from a DynamicColor object.

    - parameter color: A DynamicColor object.
    */
    public init(color: UIColor) {
      let rgba = color.toRGBAComponents()

      let maximum   = max(rgba.r, max(rgba.g, rgba.b))
      let minimum = min(rgba.r, min(rgba.g, rgba.b))

      let delta = maximum - minimum

      h = 0.0
      s = 0.0
      l = (maximum + minimum) / 2.0

      if delta != 0.0 {
        if l < 0.5 {
          s = delta / (maximum + minimum)
        }
        else {
          s = delta / (2.0 - maximum - minimum)
        }

        if rgba.r == maximum {
          h = ((rgba.g - rgba.b) / delta) + (rgba.g < rgba.b ? 6.0 : 0.0)
        }
        else if rgba.g == maximum {
          h = ((rgba.b - rgba.r) / delta) + 2.0
        }
        else if rgba.b == maximum {
          h = ((rgba.r - rgba.g) / delta) + 4.0
        }
      }

      h /= 6.0
      a = rgba.a
    }

    // MARK: - Transforming HSL Color

    /**
    Returns the DynamicColor representation from the current HSV color.

    - returns: A DynamicColor object corresponding to the current HSV color.
    */
    public func toUIColor() -> UIColor {
      let  (r, g, b, a) = rgbaComponents()

      return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// Returns the RGBA components  from the current HSV color.
    func rgbaComponents() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
      let m2 = l <= 0.5 ? l * (s + 1.0) : (l + s) - (l * s)
      let m1 = (l * 2.0) - m2

      let r = hueToRGB(m1: m1, m2: m2, h: h + (1.0 / 3.0))
      let g = hueToRGB(m1: m1, m2: m2, h: h)
      let b = hueToRGB(m1: m1, m2: m2, h: h - (1.0 / 3.0))

      return (r, g, b, CGFloat(a))
    }

    /// Hue to RGB helper function
    private func hueToRGB(m1: CGFloat, m2: CGFloat, h: CGFloat) -> CGFloat {
      let hue = moda(h, m: 1)

      if hue * 6 < 1.0 {
        return m1 + ((m2 - m1) * hue * 6.0)
      }
      else if hue * 2.0 < 1.0 {
        return m2
      }
      else if hue * 3.0 < 1.9999 {
        return m1 + ((m2 - m1) * ((2.0 / 3.0) - hue) * 6.0)
      }

      return m1
    }

    internal func moda(_ x: CGFloat, m: CGFloat) -> CGFloat {
      return (x.truncatingRemainder(dividingBy: m) + m).truncatingRemainder(dividingBy: m)
    }
}

extension HSLColor {

    func lighter(amount: CGFloat) -> HSLColor {
        return HSLColor(hue: h, saturation: s, lightness: l + amount)
    }

    func darkened(amount: CGFloat) -> HSLColor {
        return lighter(amount: amount * -1.0)
    }

    func saturated(amount: CGFloat) -> HSLColor {
        return HSLColor(hue: h, saturation: s + amount, lightness: l)
    }

    func desaturated(amount: CGFloat) -> HSLColor {
        return saturated(amount: amount * -1.0)
    }
}
