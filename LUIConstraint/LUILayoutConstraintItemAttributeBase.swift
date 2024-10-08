//
//  LUILayoutConstraintItemAttributeBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/28.
//

import Foundation

public protocol LUILayoutConstraintItemAttributeProtocol: AnyObject {
    var layoutFrame: CGRect { get set }
}

public class LUILayoutConstraintItemAttributeBase: LUILayoutConstraintItemAttributeProtocol {
    public var layoutFrame: CGRect = .zero {
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
            item.bounds = self.layoutFrame
        } else {
            self.item?.layoutFrame = self.layoutFrame
        }
        if let item = self.item as? LUILayoutConstraintItemProtocol {
            item.layoutItemsWithResizeItems(resizeItems: resizeItems)
        }
    }
}

public class LUILayoutConstraintItemAttributeSection: LUILayoutConstraintItemAttributeBase {
    var itemAttributs: [LUILayoutConstraintItemAttributeProtocol] {
        get {
            return self.allItemAttributes
        } set {
            self.allItemAttributes.removeAll()
            self.allItemAttributes.append(contentsOf: newValue)
        }
    }
    private var allItemAttributes: [LUILayoutConstraintItemAttributeProtocol] = []
    
    func addItemAttribute(itemAttribute: LUILayoutConstraintItemAttributeProtocol) {
        self.allItemAttributes.append(itemAttribute)
    }
    
    func insertItemAttribute(itemAttribute: LUILayoutConstraintItemAttributeProtocol, atIndex index: Int) {
        self.allItemAttributes.insert(itemAttribute, at: index)
    }
    
    func removeItemAttributeAtIndex(index: Int) {
        self.allItemAttributes.remove(at: index)
    }
    
    func sizeThatFlowLayoutItemsWithSpacing(_ itemSpacing: CGFloat, axis X: LUICGAxis) -> CGSize {
        var size: CGSize = .zero
        var sumWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        var count: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = 0
        var f: CGRect = .zero
        let Y = LUICGAxis.LUICGAxisReverse(X)
        for allItemAttribute in allItemAttributes {
            f = allItemAttribute.layoutFrame
            w = f.LUICGRectGetLength(X)
            h = f.LUICGRectGetLength(Y)
            if w > 0 && h > 0 {
                count += 1
                sumWidth += w
                maxHeight = max(maxHeight, h)
            }
        }
        if count > 0 {
            sumWidth += itemSpacing * (count - 1)
            size.LUICGSizeSetLength(sumWidth, axis: X)
            size.LUICGSizeSetLength(maxHeight, axis: Y)
        }
        return size
    }
    
    func flowLayoutItemsWithSpacing(_ itemSpacing:CGFloat, axis X:LUICGAxis, alignment alignY:LUICGRectAlignment, needRevert: Bool) {
        let Y = LUICGAxis.LUICGAxisReverse(X)
        let bounds = self.layoutFrame
        var f1: CGRect = .zero
        f1.origin = bounds.origin
        let allItemAttributes = needRevert ? self.allItemAttributes : self.allItemAttributes.reversed()
        for allItemAttribute in allItemAttributes {
            f1.size = allItemAttribute.layoutFrame.size
            f1.LUICGRectAlignToRect(Y, alignment: alignY, bounds: bounds)
            allItemAttribute.layoutFrame = f1
            if f1.LUICGRectGetLength(X) > 0 && f1.LUICGRectGetLength(Y) > 0 {
                f1.LUICGRectSetMin(X, value: f1.LUICGRectGetMax(X) + itemSpacing)
            }
        }
    }
}
