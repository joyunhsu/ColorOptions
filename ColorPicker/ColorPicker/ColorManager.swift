//
//  ColorManager.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/7.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit

public enum ColorShade: CaseIterable {
    case original
    case lighter
    case darker
    case saturated
    case desaturated

    public var title: String {
        switch self {
        case .original:
            return "ORIGINAL"
        case .lighter:
            return "LIGHTER"
        case .darker:
            return "DARKER"
        case .saturated:
            return "SATURATED"
        case .desaturated:
            return "DESATURATED"
        }
    }
}

public enum ColorMode: CaseIterable {
    case solid
    case gradient

    public var title: String {
        switch self {
        case .solid:
            return "SOLID"
        case .gradient:
            return "GRADIENT"
        }
    }

    public var numberOfColors: Int {
        switch self {
        case .solid: return 1
        case .gradient: return 2
        }
    }
}

extension UIColor {

    public func applyColorShade(_ colorShade: ColorShade) -> UIColor {
        switch colorShade {
        case .original:
            return self
        case .lighter:
            return self.lighter()
        case .darker:
            return self.darkened()
        case .saturated:
            return self.saturated()
        case .desaturated:
            return self.desaturated()
        }
    }

    public func lighter(amount: CGFloat = 0.2) -> UIColor {
        return HSLColor(color: self).lighter(amount: amount).toUIColor()
    }

    public func darkened(amount: CGFloat = 0.2) -> UIColor {
        return HSLColor(color: self).darkened(amount: amount).toUIColor()
    }

    public func saturated(amount: CGFloat = 0.3) -> UIColor {
        return HSLColor(color: self).saturated(amount: amount).toUIColor()
    }

    public func desaturated(amount: CGFloat = 0.3) -> UIColor {
        return HSLColor(color: self).desaturated(amount: amount).toUIColor()
    }
}

