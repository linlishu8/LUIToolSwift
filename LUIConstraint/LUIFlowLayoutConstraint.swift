//
//  LUIFlowLayoutConstraint.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/29.
//

import Foundation

enum LUIFlowLayoutConstraintParam {
    case LUIFlowLayoutConstraintParam_H_C_C
    case LUIFlowLayoutConstraintParam_H_C_L
    case LUIFlowLayoutConstraintParam_H_C_R
    case LUIFlowLayoutConstraintParam_H_T_C
    case LUIFlowLayoutConstraintParam_H_T_L
    case LUIFlowLayoutConstraintParam_H_T_R
    case LUIFlowLayoutConstraintParam_H_B_L
    case LUIFlowLayoutConstraintParam_H_B_C
    case LUIFlowLayoutConstraintParam_H_B_R
    case LUIFlowLayoutConstraintParam_V_C_C
    case LUIFlowLayoutConstraintParam_V_C_L
    case LUIFlowLayoutConstraintParam_V_C_R
    case LUIFlowLayoutConstraintParam_V_T_C
    case LUIFlowLayoutConstraintParam_V_T_L
    case LUIFlowLayoutConstraintParam_V_T_R
    case LUIFlowLayoutConstraintParam_V_B_C
    case LUIFlowLayoutConstraintParam_V_B_L
    case LUIFlowLayoutConstraintParam_V_B_R
}

class LUIFlowLayoutConstraint: LUILayoutConstraint {
    open var layoutDirection: LUILayoutConstraintDirection = .constraintVertical
    open var layoutVerticalAlignment: LUILayoutConstraintVerticalAlignment = .verticalCenter
    open var layoutHorizontalAlignment: LUILayoutConstraintHorizontalAlignment = .horizontalCenter
    open var contentInsets: UIEdgeInsets = .zero
    open var interitemSpacing: CGFloat = 0
    open var unLimitItemSizeInBounds: Bool = false
    var itemAttributeSection: LUILayoutConstraintItemAttributeSection?

    private func layoutDirectionAxis() -> LUICGAxis {
        return self.layoutDirection == .constraintHorizontal ? .x : .y
    }
    
    func itemSizeForItem(_ item: LUILayoutConstraintItemProtocol, thatFits size: CGSize, resizeItems: Bool) -> CGSize {
        var itemSize: CGSize = .zero
        var limitSize: CGSize = size
        if resizeItems {
            itemSize = item.sizeThatFits(limitSize, resizeItems: resizeItems)
        } else {
            itemSize = item.sizeOfLayout()
        }
        return itemSize
    }
    
    func itemAttributeSectionThatFits(_ size: CGSize, resizeItems: Bool, needLimitSize: Bool) -> LUILayoutConstraintItemAttributeSection? {
        var items = self.layoutedItems
        guard !items.isEmpty else { return nil }
        let needRevert = (self.layoutDirection == .constraintHorizontal && self.layoutHorizontalAlignment == .horizontalRight) || (self.layoutDirection == .constraintVertical && self.layoutVerticalAlignment == .verticalBottom)
        if needRevert {
            items = Array(items.reversed())
        }
        let X = self.layoutDirectionAxis()
        let Y = LUICGAxis.LUICGAxisReverse(X)
        
        let contentIndsets = self.contentInsets
        let xSpacing = self.interitemSpacing
        let originLimitSize = CGSize(width: size.width - contentIndsets.left - contentIndsets.right, height: size.height - contentIndsets.top - contentIndsets.bottom)
        var limitSize = originLimitSize
        limitSize.width = max(0, limitSize.width)
        limitSize.height = max(0, limitSize.height)
        
        let line = LUILayoutConstraintItemAttributeSection()
        for (idx, item) in items.enumerated() {
            var limitWidth = limitSize.LUICGSizeGetLength(axis: X)
            var itemSize = self.itemSizeForItem(item, thatFits: limitSize, resizeItems: resizeItems)
            let itemAttr = LUILayoutConstraintItemAttribute.init(item: item)
            line.addItemAttribute(itemAttribute: itemAttr)
            var w = itemSize.LUICGSizeGetLength(axis: X)
            var h = itemSize.LUICGSizeGetLength(axis: Y)
            if needLimitSize {
                w = min(w, limitSize.LUICGSizeGetLength(axis: X))
                h = min(h, limitSize.LUICGSizeGetLength(axis: Y))
                itemSize.LUICGSizeSetLength(w, axis: X)
                itemSize.LUICGSizeSetLength(h, axis: Y)
            }
            itemAttr.size = itemSize
            if w > 0 && h > 0 {
                limitWidth -= xSpacing + w
                limitWidth = max(0, limitWidth)
                limitSize.LUICGSizeSetLength(limitWidth, axis: X)
            }
        }
        if needRevert {
            line.itemAttributs = Array(line.itemAttributs.reversed())
        }
        line.size = line.sizeThatFlowLayoutItemsWithSpacing(xSpacing, axis: X)
        return line
    }
    
    override func sizeThatFits(_ size: CGSize, resizeItems: Bool) -> CGSize {
        var sizeFits: CGSize = .zero
        let contentInsets = self.contentInsets
        if let line = self.itemAttributeSectionThatFits(size, resizeItems: resizeItems, needLimitSize: false) {
            sizeFits = line.layoutFrame.size
            if sizeFits.width > 0 && sizeFits.height > 0 {
                sizeFits.width += contentInsets.left + contentInsets.right
                sizeFits.height += contentInsets.top + contentInsets.bottom
            }
        }
        return sizeFits
    }
    
    override func layoutItems() {
        self.layoutItemsWithResizeItems(resizeItems: false)
    }
    
    override func layoutItemsWithResizeItems(resizeItems: Bool) {
        let size = self.bounds.size
        let line = self.itemAttributeSectionThatFits(size, resizeItems: resizeItems, needLimitSize: !self.unLimitItemSizeInBounds)
        let X = self.layoutDirectionAxis()
        let Y = LUICGAxis.LUICGAxisReverse(X)
        
        let contentInsets = self.contentInsets
        let xSpacing = self.interitemSpacing
//        let alignX = self.layoutDirection == .constraintVertical ? 
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
