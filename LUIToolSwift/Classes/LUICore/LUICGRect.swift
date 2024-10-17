//
//  LUICGRect.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/1/11.
//

import Foundation

public class LUICGRect {
    
}

extension LUICGRect {
    static func scaleSize(_ originSize: CGSize, aspectFitToMaxSize maxSize: CGSize) -> CGSize {
        var scaledSize = originSize

        if scaledSize.width > maxSize.width || scaledSize.height > maxSize.height {
            let widthRatio = maxSize.width / scaledSize.width
            let heightRatio = maxSize.height / scaledSize.height
            let minRatio = min(widthRatio, heightRatio)

            scaledSize.width *= minRatio
            scaledSize.height *= minRatio
        }

        return scaledSize
    }
    
    static func transformRect(fromRect: CGRect, scaleTo toRect: CGRect, contentMode: UIView.ContentMode) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
            switch contentMode {
            case .scaleAspectFit:
                let scaleWidth = toRect.width / fromRect.width
                let scaleHeight = toRect.height / fromRect.height
                let scale = min(scaleWidth, scaleHeight)
                transform = transform.translatedBy(x: -fromRect.midX, y: -fromRect.midY)
                transform = transform.scaledBy(x: scale, y: scale)
                transform = transform.translatedBy(x: toRect.midX, y: toRect.midY)
                
            case .scaleAspectFill:
                let scaleWidth = toRect.width / fromRect.width
                let scaleHeight = toRect.height / fromRect.height
                let scale = max(scaleWidth, scaleHeight)
                transform = transform.translatedBy(x: -fromRect.midX, y: -fromRect.midY)
                transform = transform.scaledBy(x: scale, y: scale)
                transform = transform.translatedBy(x: toRect.midX, y: toRect.midY)
                
            case .scaleToFill:
                let scaleWidth = toRect.width / fromRect.width
                let scaleHeight = toRect.height / fromRect.height
                transform = transform.translatedBy(x: -fromRect.midX, y: -fromRect.midY)
                transform = transform.scaledBy(x: scaleWidth, y: scaleHeight)
                transform = transform.translatedBy(x: toRect.midX, y: toRect.midY)
                
            case .center:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 0.5, y: 0.5))
            case .left:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 0, y: 0.5))
            case .right:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 1, y: 0.5))
            case .top:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 0.5, y: 0))
            case .bottom:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 0.5, y: 1))
            case .topLeft:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 0, y: 0))
            case .topRight:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 1, y: 0))
            case .bottomLeft:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 0, y: 1))
            case .bottomRight:
                transform = transformRect(fromRect: fromRect, moveTo: toRect, alignPoint: CGPoint(x: 1, y: 1))
            default:
                break
            }
            return transform
    }
    
    static func transformRect(fromRect: CGRect, moveTo toRect: CGRect, alignPoint point: CGPoint) -> CGAffineTransform {
        let p1 = CGPoint(x: fromRect.origin.x + fromRect.width * point.x,
                         y: fromRect.origin.y + fromRect.height * point.y)
        let p2 = CGPoint(x: toRect.origin.x + toRect.width * point.x,
                         y: toRect.origin.y + toRect.height * point.y)
        return CGAffineTransform(translationX: p2.x - p1.x, y: p2.y - p1.y)
    }
}
