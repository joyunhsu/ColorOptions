//
//  UIView+Extension.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/4.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit

extension UIView {

    func addShadowWithOffset(_ offset: CGSize = CGSize(width: 0, height: 5)) {
        self.clipsToBounds = false
        let layer: CALayer = self.layer
        layer.shadowOffset = offset
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
    }
}
