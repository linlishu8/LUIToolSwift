//
//  LUILayoutConstraintItemWrapper.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/28.
//

import Foundation

typealias LUILayoutConstraintItemWrapperBlock = (LUILayoutConstraintItemWrapper, CGSize, Bool) -> CGSize

class LUILayoutConstraintItemWrapper: NSObject, LUILayoutConstraintItemProtocol {
    
    var originItem: LUILayoutConstraintItemProtocol
    var fixedSize: CGSize = .zero
    var sizeThatFitsBlock: LUILayoutConstraintItemWrapperBlock?
    var margin: UIEdgeInsets = .zero
    var paddingSize: CGPoint = .zero
    
    public static func wrapItem(_ originItem: LUILayoutConstraintItemProtocol) -> LUILayoutConstraintItemWrapper {
        return LUILayoutConstraintItemWrapper(originItem: originItem)
    }
    
    public static func wrapItem(_ originItem: LUILayoutConstraintItemProtocol, fixedSize: CGSize) -> LUILayoutConstraintItemWrapper {
        let wrapper = LUILayoutConstraintItemWrapper(originItem: originItem)
        wrapper.fixedSize = fixedSize
        return wrapper
    }
    
    public static func wrapItem(_ originItem: LUILayoutConstraintItemProtocol, sizeThatFitsBlock: @escaping LUILayoutConstraintItemWrapperBlock) -> LUILayoutConstraintItemWrapper {
        let wrapper = LUILayoutConstraintItemWrapper(originItem: originItem)
        wrapper.sizeThatFitsBlock = sizeThatFitsBlock
        return wrapper
    }
    
    private init(originItem: LUILayoutConstraintItemProtocol) {
        self.originItem = originItem
    }
    
    // MARK: LUILayoutConstraintItemProtocol
    var isHidden: Bool {
        return self.originItem.isHidden
    }
    
    func sizeOfLayout() -> CGSize {
        var size = self.originItem.sizeOfLayout()
        size.width += margin.left + margin.right
        size.height += margin.top + margin.bottom
        return size
    }
    
    func setLayoutTransform(transform: CGAffineTransform) {
        
    }
    
    var layoutFrame: CGRect {
        var f = self.originItem.layoutFrame
        f.origin.x -= margin.left
        f.origin.y -= margin.top
        f.size.width += margin.left + margin.right
        f.size.height += margin.top + margin.bottom
        return f
    }
    
    func setLayoutFrame(_ frame: CGRect) {
        self.originItem.setLayoutFrame(UIEdgeInsetsInsetRect(frame, self.margin))
    }
    //
    func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeFits = size
        if let sizeThatFitsBlock = self.sizeThatFitsBlock {
            sizeFits = sizeThatFitsBlock(self, size, false)
        } else {
            let fixedSize = self.fixedSize
            let margin = self.margin
            let paddingSize = self.paddingSize
            if CGSizeEqualToSize(fixedSize, CGSizeMake(CGFloat(Int.max), CGFloat(Int.max))) {
                sizeFits = size
            } else if fixedSize.width > 0 && fixedSize.width != CGFloat(Int.max) && fixedSize.height > 0 && fixedSize.height != CGFloat(Int.max) {
                
            }
        }
        return sizeFits
    }
}
