//
//  LUILayoutConstraintItemAttributeBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/28.
//

import Foundation

protocol LUILayoutConstraintItemAttributeProtocol: AnyObject {
    var layoutFrame: CGRect { get set }
    func setLayoutFrame(_ frame: CGRect)
}

class LUILayoutConstraintItemAttributeBase: LUILayoutConstraintItemAttributeProtocol {
    var layoutFrame: CGRect = .zero {
            didSet {
                size = layoutFrame.size
                origin = layoutFrame.origin
            }
        }

        var size: CGSize {
            get { return layoutFrame.size }
            set { layoutFrame.size = newValue }
        }

        var origin: CGPoint {
            get { return layoutFrame.origin }
            set { layoutFrame.origin = newValue }
        }

        func setLayoutFrame(_ frame: CGRect) {
            layoutFrame = frame
        }
}

class LUILayoutConstraintItemAttribute: LUILayoutConstraintItemAttributeBase {
    var item: LUILayoutConstraintItemAttributeProtocol?
    
    init(item: LUILayoutConstraintItemAttributeProtocol) {
        self.item = item
        super.init()
    }
    
    func applyAttribute() {
        self.item?.layoutFrame = self.layoutFrame
    }
    
    func applyAttributeWithResizeItems(resizeItems: Bool) {
        if let item = self.item as? LUILayoutConstraint {

        }
    }
}
