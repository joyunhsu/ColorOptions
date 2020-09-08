//
//  UIColor+Extension.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/4.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit

extension UIColor {

    public var hexString: String {
        hexStringFromColor(color: self) ?? "#FFFFFF"
    }

    public func hexStringFromColor(color: UIColor) -> String? {
        guard let colorSpace: CGColorSpace = color.cgColor.colorSpace else { return nil }
        let colorSpaceModel: CGColorSpaceModel = colorSpace.model
       let components = color.cgColor.components
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if colorSpaceModel == .monochrome {
            r = components?[0] ?? 0.0
            g = components?[0] ?? 0.0
            b = components?[0] ?? 0.0
            a = components?[1] ?? 0.0
        } else if colorSpaceModel == .rgb {
            r = components?[0] ?? 0.0
            g = components?[1] ?? 0.0
            b = components?[2] ?? 0.0
            a = components?[3] ?? 0.0
        }

       let hexString = String.init(
        format: "#%02lX%02lX%02lX",
        lroundf(Float(r * 255)),
        lroundf(Float(g * 255)),
        lroundf(Float(b * 255)),
        lroundf(Float(a * 255)))
       return hexString
    }

    public convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }

    // MARK: - Getting the RGBA Components

    /**
     Returns the RGBA (red, green, blue, alpha) components.

     - returns: The RGBA components as a tuple (r, g, b, a).
     */
    final func toRGBAComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

      #if os(iOS) || os(tvOS) || os(watchOS)
        getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
      #elseif os(OSX)
        guard let rgbaColor = self.usingColorSpace(.deviceRGB) else {
          fatalError("Could not convert color to RGBA.")
        }

        rgbaColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        return (r, g, b, a)
      #endif
    }
}
