//
//  LUILayoutConstraintItemWrapper.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/28.
//

import Foundation

public typealias LUILayoutConstraintItemWrapperBlock = (LUILayoutConstraintItemWrapper, CGSize, Bool) -> CGSize

public class LUILayoutConstraintItemWrapper: NSObject, LUILayoutConstraintItemProtocol {
    
    public var originItem: LUILayoutConstraintItemProtocol
    public var fixedSize: CGSize = .zero
    public var sizeThatFitsBlock: LUILayoutConstraintItemWrapperBlock?
    public var margin: UIEdgeInsets = .zero
    public var paddingSize: CGSize = .zero
    
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
    public func hidden() -> Bool {
        return self.originItem.hidden()
    }
    
    public func sizeOfLayout() -> CGSize {
        var size = self.originItem.sizeOfLayout()
        size.width += margin.left + margin.right
        size.height += margin.top + margin.bottom
        return size
    }
    
    public func setLayoutTransform(transform: CGAffineTransform) {
        self.originItem.setLayoutTransform(transform: transform)
    }
    
    public var layoutFrame: CGRect {
        set {
            self.originItem.layoutFrame = UIEdgeInsetsInsetRect(newValue, self.margin)
        } get {
            var f = self.originItem.layoutFrame
            f.origin.x -= margin.left
            f.origin.y -= margin.top
            f.size.width += margin.left + margin.right
            f.size.height += margin.top + margin.bottom
            return f
        }
    }
    //
    
    public func sizeThatFits(_ size: CGSize, resizeItems: Bool) -> CGSize {
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
                let s = fixedSize
                sizeFits.width = s.width + margin.left + margin.right + paddingSize.width
                sizeFits.height = s.height + margin.top + margin.bottom + paddingSize.height
            } else {
                var s = self.originItem.sizeThatFits(size, resizeItems: resizeItems)
                if fixedSize.width == CGFloat(Int.max) {
                    sizeFits.width = size.width
                } else {
                    if fixedSize.width > 0 {
                        s.width = fixedSize.width
                    }
                    sizeFits.width = s.width + margin.left + margin.right + paddingSize.width
                }
                if fixedSize.height == CGFloat(Int.max) {
                    sizeFits.height = size.height
                } else {
                    if fixedSize.height > 0 {
                        s.height = fixedSize.height
                    }
                    sizeFits.height = s.height + margin.top + margin.bottom + paddingSize.height
                }
            }
        }
        return sizeFits
    }
    
    public func layoutItemsWithResizeItems(resizeItems: Bool) {
        self.originItem.layoutItemsWithResizeItems(resizeItems: resizeItems)
    }
}
