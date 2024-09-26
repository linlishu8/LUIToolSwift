//
//  UIView+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/24.
//

import Foundation

extension UIView {
    func l_screenshotsImageWithSize(_ size: CGSize, scale: CGFloat) -> UIImage {
        
    }
    
    func l_screenshotsImageWithScale(_ scale: CGFloat) -> UIImage? {
        return self.l_screenshotsImageWithScale(scale, opaque: false)
    }
    
    func l_screenshotsImageWithScale(_ scale: CGFloat, opaque: Bool) -> UIImage? {
        let bounds = self.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func l_screenshotsImage() -> UIImage? {
        return self.l_screenshotsImageWithScale(0.0)
    }
    
    var l_frameSafety: CGRect {
        get {
            var f = self.bounds
            f.origin.x = self.center.x - f.size.width / 2
            f.origin.y = self.center.y - f.size.height / 2
            return f
        } set {
            var bounds = self.bounds
            bounds.size = newValue.size
            let center = CGPoint(x: newValue.midX, y: newValue.midY)
            self.bounds = bounds
            self.center = center
        }
    }
    
    var l_frameOfBoundsCenter: CGRect {
        get {
            var frame = self.bounds
            let center = self.center
            let point = self.layer.anchorPoint
            frame.origin.x = center.x - frame.size.width * point.x
            frame.origin.y = center.y - frame.size.height * point.y
            return frame
        } set {
            self.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            let point = self.layer.anchorPoint
            var center = CGPoint()
            center.x = frame.origin.x + frame.size.width * point.x
            center.y = frame.origin.y + frame.size.height * point.y
            self.center = center
        }
    }
    
    func l_maskRectClear(clearRect: CGRect) {
        //todo
    }
    
    func l_firstSuperViewWithClass(_ clazz: AnyClass) -> UIView? {
        var target = self.superview
        while let current = target {
            if current.isKind(of: clazz) {
                return current
            }
            target = current.superview
        }
        return nil
    }
    
    var l_firstResponder: UIView? {
        if self.canBecomeFirstResponder && self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let responder = subview.l_firstResponder {
                return responder
            }
        }
        return nil
    }
}
