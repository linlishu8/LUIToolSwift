//
//  UIImageView+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/1/11.
//

import Foundation

public extension UIImageView {
    func l_sizeThatFits(size: CGSize) -> CGSize {
        guard let image = self.image else { return .zero }
        let imageSize = image.size
        var superSize = size
        if superSize.width <= 0 {
            superSize.width = imageSize.width
        }
        if superSize.height <= 0 {
            superSize.height = imageSize.height
        }
        if imageSize.width <= superSize.width && imageSize.height <= superSize.height {
            return imageSize
        }
        let r1 = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        let m = LUICGRect.transformRect(fromRect: r1, scaleTo: CGRect(x: 0, y: 0, width: superSize.width, height: superSize.height), contentMode: self.contentMode)
        let r2 = CGRectApplyAffineTransform(r1, m)
        let sizeFits = r2.size
        let s1 = LUICGRect.scaleSize(sizeFits, aspectFitToMaxSize: superSize)
        return s1
    }
}
