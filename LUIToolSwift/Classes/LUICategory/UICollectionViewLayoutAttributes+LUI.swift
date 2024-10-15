//
//  UICollectionViewLayoutAttributes+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/15.
//

import UIKit

public extension UICollectionViewLayoutAttributes {
    var l_frameSafety: CGRect {
        get {
            var frame = self.frame
            if !CGAffineTransformIsIdentity(self.transform) || CATransform3DIsIdentity(self.transform3D) {
                frame.size = self.size
                frame.origin.x = self.center.x - self.size.width / 2
                frame.origin.y = self.center.y - self.size.height / 2
            }
            return frame
        }
        set {
            if !CGAffineTransformIsIdentity(self.transform) || CATransform3DIsIdentity(self.transform3D) {
                self.size = newValue.size
                self.center = CGPoint(x: newValue.midX, y: newValue.midY)
            } else {
                self.frame = newValue
            }
        }
    }
}
