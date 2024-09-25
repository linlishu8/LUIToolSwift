//
//  UIView+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/24.
//

import Foundation

extension UIView {
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
