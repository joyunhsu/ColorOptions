//
//  UIImage+Extension.swift
//  ColorOptionsExplore
//
//  Created by Jo Hsu on 2020/9/2.
//  Copyright © 2020 Jo Hsu. All rights reserved.
//

import UIKit

extension UIImage {
    public func getPixelColor(at point: CGPoint) -> UIColor? {
        var x = point.x
        var y = point.y
        if x < 0 {
            x = 0
        } else if x >= size.width {
            x = size.width - 1
        }
        if y < 0 {
            y = 0
        } else if y >= size.height {
            y = size.height - 1
        }

        guard let cgImage = cgImage else { return .white}
        let pixelData = cgImage.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let unit = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        let pixelInfo: Int = cgImage.bytesPerRow * Int(y) + Int(x) * unit

        let colorMaxValue = CGFloat(powf(2, Float(cgImage.bitsPerComponent))) - 1
        let b = CGFloat(data[pixelInfo]) / colorMaxValue
        let g = CGFloat(data[pixelInfo+1]) / colorMaxValue
        let r = CGFloat(data[pixelInfo+2]) / colorMaxValue
        let a = CGFloat(data[pixelInfo+3]) / colorMaxValue

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    public func resize(to newSize: CGSize, mode: UIView.ContentMode = .scaleToFill) -> UIImage {
        var outputSize: CGSize = newSize
        var drawSize: CGSize!
        var drawOrigin: CGPoint!
        switch mode {
        case .top:
            drawSize = self.size
            drawOrigin = CGPoint(x: (outputSize.width - drawSize.width) / 2.0, y: 0)
        case .topLeft:
            drawSize = self.size
            drawOrigin = .zero
        case .topRight:
            drawSize = self.size
            drawOrigin = CGPoint(x: outputSize.width - drawSize.width, y: 0)
        case .bottom:
            drawSize = self.size
            drawOrigin = CGPoint(x: (outputSize.width - drawSize.width) / 2.0, y: outputSize.height - drawSize.height)
        case .bottomLeft:
            drawSize = self.size
            drawOrigin = CGPoint(x: 0, y: outputSize.height - drawSize.height)
        case .bottomRight:
            drawSize = self.size
            drawOrigin = CGPoint(x: outputSize.width - drawSize.width, y: outputSize.height - drawSize.height)
        case .center:
            drawSize = self.size
            drawOrigin = CGPoint(x: (outputSize.width - drawSize.width) / 2.0, y: (outputSize.height - drawSize.height) / 2.0)
        case .left:
            drawSize = self.size
            drawOrigin = CGPoint(x: 0, y: (outputSize.height - drawSize.height) / 2.0)
        case .right:
            drawSize = self.size
            drawOrigin = CGPoint(x: outputSize.width - drawSize.width, y: (outputSize.height - drawSize.height) / 2.0)
        case .redraw:
            outputSize = self.size
            drawSize = self.size
            drawOrigin = .zero
        case .scaleAspectFit:
            let scaledHeight = (self.size.height * newSize.width / self.size.width)
            if scaledHeight < newSize.height {
                drawSize = CGSize(width: newSize.width, height: scaledHeight)
                drawOrigin = CGPoint(x: 0, y: (newSize.height - scaledHeight) / 2.0)
            } else {
                let scaledWidth = self.size.width * newSize.height / self.size.height
                drawSize = CGSize(width: scaledWidth, height: newSize.height)
                drawOrigin = CGPoint(x: (newSize.width - scaledWidth) / 2.0, y: 0)
            }
        case .scaleAspectFill:
            let scaledHeight = (self.size.height * newSize.width / self.size.width)
            if scaledHeight > newSize.height {
                drawSize = CGSize(width: newSize.width, height: scaledHeight)
                drawOrigin = CGPoint(x: 0, y: (newSize.height - scaledHeight) / 2.0)
            } else {
                let scaledWidth = self.size.width * newSize.height / self.size.height
                drawSize = CGSize(width: scaledWidth, height: newSize.height)
                drawOrigin = CGPoint(x: (newSize.width - scaledWidth) / 2.0, y: 0)
            }
        case .scaleToFill:
            drawSize = outputSize
            drawOrigin = .zero
        @unknown default:
            drawSize = self.size
            drawOrigin = .zero
        }

        UIGraphicsBeginImageContextWithOptions(outputSize, false, 1.0)
        draw(in: CGRect(origin: drawOrigin, size: drawSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
