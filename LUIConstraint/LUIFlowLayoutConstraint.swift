//
//  LUIFlowLayoutConstraint.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/29.
//

import Foundation

public class LUIFlowLayoutConstraint: LUILayoutConstraint {
    open var layoutDirection: LUILayoutConstraintDirection = .constraintVertical
    open var layoutVerticalAlignment: LUILayoutConstraintVerticalAlignment = .verticalCenter
    open var layoutHorizontalAlignment: LUILayoutConstraintHorizontalAlignment = .horizontalCenter
    public var contentInsets: UIEdgeInsets = .zero
    public var interitemSpacing: CGFloat = 0
    open var unLimitItemSizeInBounds: Bool = false
    open var itemAttributeSection: LUILayoutConstraintItemAttributeSection?

    private func layoutDirectionAxis() -> LUICGAxis {
        return self.layoutDirection == .constraintHorizontal ? .x : .y
    }
    
    func itemSizeForItem(_ item: LUILayoutConstraintItemProtocol, thatFits size: CGSize, resizeItems: Bool) -> CGSize {
        var itemSize: CGSize = .zero
        let limitSize: CGSize = size
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
        for (_, item) in items.enumerated() {
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
    
    public override func sizeThatFits(_ size: CGSize, resizeItems: Bool) -> CGSize {
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
    
    public override func layoutItems() {
        self.layoutItemsWithResizeItems(resizeItems: false)
    }
    
    public override func layoutItemsWithResizeItems(resizeItems: Bool) {
        let size = self.bounds.size
        guard let line = self.itemAttributeSectionThatFits(size, resizeItems: resizeItems, needLimitSize: !self.unLimitItemSizeInBounds) else { return }
        let X = self.layoutDirectionAxis()
        let Y = LUICGAxis.LUICGAxisReverse(X)
        
        let contentInsets = self.contentInsets
        let xSpacing = self.interitemSpacing
        let alignX = self.layoutDirection == .constraintVertical ? LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(align: self.layoutVerticalAlignment) : LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(align: self.layoutHorizontalAlignment)
        
        let alignY = self.layoutDirection == .constraintHorizontal ? LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(align: self.layoutVerticalAlignment) : LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(align: self.layoutHorizontalAlignment)
        
        let bounds = UIEdgeInsetsInsetRect(self.bounds, contentInsets)
        var f1 = line.layoutFrame
        f1.LUICGRectAlignToRect(Y, alignment: alignY, bounds: bounds)
        f1.LUICGRectAlignToRect(X, alignment: alignX, bounds: bounds)
        line.layoutFrame = f1
        line.flowLayoutItemsWithSpacing(xSpacing, axis: X, alignment: alignY, needRevert: false)
        for itemAttribut in line.itemAttributs {
            if let item = itemAttribut as? LUILayoutConstraintItemAttribute {
                item.applyAttributeWithResizeItems(resizeItems: resizeItems)
            }
        }
        self.itemAttributeSection = line
    }
    
    func isEmptyBounds(_ bounds: CGRect, resizeItems: Bool) -> Bool {
        var isEmpty: Bool = false
        let items = self.layoutedItems
        if !items.isEmpty {
            let b = UIEdgeInsetsInsetRect(bounds, self.contentInsets)
            let interitemSpacing = self.interitemSpacing
            var limitSize = b.size
            let axis: LUICGAxis = self.layoutDirection == .constraintHorizontal ? .x : .y
            isEmpty = true
            for item in items {
                var f1 = b
                var f1_size: CGSize = .zero
                if resizeItems {
                    f1_size = item.sizeThatFits(limitSize, resizeItems: resizeItems)
                } else {
                    f1_size = item.sizeOfLayout()
                }
                if !CGSizeEqualToSize(f1_size, .zero) {
                    isEmpty = false
                    break
                }
                f1.size.width = min(f1.size.width, f1_size.width)
                f1.size.height = min(f1.size.height, f1_size.height)
                f1.LUICGRectSetLength(axis, value: min(limitSize.LUICGSizeGetLength(axis: axis), f1.LUICGRectGetLength(axis)))
                limitSize.LUICGSizeSetLength(limitSize.LUICGSizeGetLength(axis: axis) - f1.LUICGRectGetLength(axis) + interitemSpacing, axis: axis)
                limitSize.LUICGSizeSetLength(max(0, limitSize.LUICGSizeGetLength(axis: axis)), axis: axis)
            }
        } else {
            isEmpty = true
        }
        return isEmpty
    }
}

public enum LUIFlowLayoutConstraintParam: String {
    case H_C_C = "H_C_C", H_C_L = "H_C_L", H_C_R = "H_C_R", H_T_C = "H_T_C", H_T_L = "H_T_L", H_T_R = "H_T_R"
    case H_B_L = "H_B_L", H_B_C = "H_B_C", H_B_R = "H_B_R", V_C_C = "V_C_C", V_C_L = "V_C_L", V_C_R = "V_C_R"
    case V_T_C = "V_T_C", V_T_L = "V_T_L", V_T_R = "V_T_R", V_B_C = "V_B_C", V_B_L = "V_B_L", V_B_R = "V_B_R"
}

public extension LUIFlowLayoutConstraint {
    static let constraintParamMap: [String: [Int]] = {
        var map = [String: [Int]]()
        map[LUIFlowLayoutConstraintParam.H_C_C.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalCenter.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalCenter.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.H_C_L.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalCenter.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalLeft.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.H_C_R.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalCenter.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalRight.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.H_T_C.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalTop.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalCenter.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.H_T_L.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalTop.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalLeft.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.H_T_R.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalTop.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalRight.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.H_B_L.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalBottom.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalLeft.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.H_B_C.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalBottom.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalCenter.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.H_B_R.rawValue] = [
            LUILayoutConstraintDirection.constraintHorizontal.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalBottom.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalRight.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_C_C.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalCenter.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalCenter.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_C_L.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalCenter.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalLeft.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_C_R.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalCenter.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalLeft.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_T_C.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalTop.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalCenter.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_T_L.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalTop.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalLeft.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_T_R.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalTop.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalRight.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_B_C.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalBottom.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalCenter.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_B_L.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalBottom.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalLeft.rawValue
        ]
        map[LUIFlowLayoutConstraintParam.V_B_R.rawValue] = [
            LUILayoutConstraintDirection.constraintVertical.rawValue,
            LUILayoutConstraintVerticalAlignment.verticalBottom.rawValue,
            LUILayoutConstraintHorizontalAlignment.horizontalRight.rawValue
        ]
        return map
    }()
    
    static var constraintParamRevertMap: [Array<Int>: String] = {
        var map = [Array<Int>: String]()
        let constraintParamMap = LUIFlowLayoutConstraint.constraintParamMap
        for (key, value) in constraintParamMap {
            map[value] = key
        }
        return map
    }()
    
    static func constraintParamWithLayoutDirection(_ layoutDirection: LUILayoutConstraintDirection, layoutVerticalAlignment: LUILayoutConstraintVerticalAlignment, layoutHorizontalAlignment: LUILayoutConstraintHorizontalAlignment) -> LUIFlowLayoutConstraintParam {
        let key = [layoutDirection.rawValue, layoutVerticalAlignment.rawValue, layoutHorizontalAlignment.rawValue] as [Int]
        if let param = constraintParamRevertMap[key] {
            return LUIFlowLayoutConstraintParam(rawValue: param) ?? .H_C_C
        } else {
            return .H_C_C
        }
    }
    
    var constraintParam: LUIFlowLayoutConstraintParam {
        get {
            return LUIFlowLayoutConstraint.constraintParamWithLayoutDirection(self.layoutDirection, layoutVerticalAlignment: self.layoutVerticalAlignment, layoutHorizontalAlignment: self.layoutHorizontalAlignment)
        } set {
            self.configWithConstraintParam(newValue)
        }
    }
    
    convenience init(_ items: [LUILayoutConstraintItemProtocol], param: LUIFlowLayoutConstraintParam, contentInsets: UIEdgeInsets, interitemSpacing: CGFloat) {
        self.init()
        self.items = items
        self.contentInsets = contentInsets
        self.interitemSpacing = interitemSpacing
        self.configWithConstraintParam(param)
    }
    
    func configWithConstraintParam(_ param: LUIFlowLayoutConstraintParam) {
        let constraintParamMap: [String: [Int]] = LUIFlowLayoutConstraint.constraintParamMap
        self.layoutDirection = .constraintHorizontal
        self.layoutVerticalAlignment = .verticalCenter
        self.layoutHorizontalAlignment = .horizontalCenter
        if let enums = constraintParamMap[param.rawValue] {
            self.layoutDirection = LUILayoutConstraintDirection(rawValue: enums[0]) ?? .constraintHorizontal
            self.layoutVerticalAlignment = LUILayoutConstraintVerticalAlignment(rawValue: enums[1]) ?? .verticalCenter
            self.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignment(rawValue: enums[2]) ?? .horizontalCenter
        }
    }
}
