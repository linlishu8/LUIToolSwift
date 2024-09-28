//
//  LUILayoutConstraint.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/28.
//

import Foundation

protocol LUILayoutConstraintItemProtocol: LUILayoutConstraintItemAttributeProtocol {
    var isHidden: Bool { get }//是否隐藏,默认为NO
    func sizeOfLayout() -> CGSize//返回尺寸信息
    func setLayoutTransform(transform: CGAffineTransform) //以布局bounds为中心点,对布局作为一个整体,设置底下元素的仿射矩阵
}

extension LUILayoutConstraintItemProtocol {
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return .zero
    }
    
    func sizeThatFits(_ size: CGSize, resizeItems: Bool) -> CGSize {
        return .zero
    }
    
    func layoutItemsWithResizeItems(resizeItems: Bool) {
        
    }
}

enum LUILayoutConstraintVerticalAlignment: Int {
    case verticalCenter = 0
    case verticalTop = 1
    case verticalBottom = 2
}

func LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(align: LUILayoutConstraintVerticalAlignment) -> LUICGRectAlignment {
    return align == .verticalCenter ? .mid : (align == .verticalTop ? .min : .max)
}

enum LUILayoutConstraintHorizontalAlignment: Int {
    case horizontalCenter = 0
    case horizontalLeft = 1
    case horizontalRight = 2
}

func LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(align: LUILayoutConstraintHorizontalAlignment) -> LUICGRectAlignment {
    return align == .horizontalCenter ? .mid : (align == .horizontalLeft ? .min : .max)
}

enum LUILayoutConstraintDirection: Int {
    case constraintVertical//垂直布局
    case constraintHorizontal//水平布局
}

class LUILayoutConstraint: NSObject, LUILayoutConstraintItemProtocol {
    // MARK: LUILayoutConstraintItemProtocol
    var isHidden: Bool = false
    var visiableItems: [LUILayoutConstraintItemProtocol] {
        get {
            var items: [LUILayoutConstraintItemProtocol] = []
            for item in items {
                if !item.isHidden {
                    items.append(item)
                }
            }
            return items
        }
    }
    var layoutedItems: [LUILayoutConstraintItemProtocol] {
        get {
            if self.layoutHiddenItem {
                return self.items
            } else {
                return self.visiableItems
            }
        }
    }
    
    func sizeOfLayout() -> CGSize {
        return self.bounds.size
    }
    
    func setLayoutTransform(transform: CGAffineTransform) {
        let bounds = self.bounds
        let c1 = CGPoint(x: bounds.midX, y: bounds.midY)
        for item in items {
            let f = item.layoutFrame
            let c = CGPoint(x: f.midX, y: f.midY)
            var m = CGAffineTransformIdentity
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(c.x - c1.x, c.y - c1.y))
            m = CGAffineTransformConcat(m, transform)
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-(c.x - c1.x), -(c.y - c1.y)))
            item.setLayoutTransform(transform: m)
        }
    }
    
    var layoutFrame: CGRect {
        get {
            return self.bounds
        } set {
            self.bounds = newValue
            self.layoutItems()
        }
    }
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.isHidden ? .zero : size
    }
    //
    
    open func layoutItems() {
        
    }
    
    private var internalItems: [LUILayoutConstraintItemProtocol] = []
    
    var items: [LUILayoutConstraintItemProtocol] {
        set {
            self.internalItems.removeAll()
            self.internalItems.append(contentsOf: newValue)
        } get {
            return self.internalItems
        }
    }
    var bounds: CGRect = .zero
    var layoutHiddenItem: Bool = false
    
    func initWithItems(items: [LUILayoutConstraintItemProtocol], bounds: CGRect) {
        self.items = items
        self.bounds = bounds
    }
    
    func addItem(item: LUILayoutConstraintItemProtocol) {
        if items.contains(where: { $0 === item }) {
            self.items.append(item)
        }
    }
    
    func removeItem(item: LUILayoutConstraintItemProtocol) {
        if let index = self.items.firstIndex(where: { $0 === item }) {
            self.items.remove(at: index)
        }
    }
    
    func replaceItem(oldItem: LUILayoutConstraintItemProtocol, newItem: LUILayoutConstraintItemProtocol) {
        if let index = items.firstIndex(where: { obj in
            if obj === oldItem {
                return true
            }
            if let w = obj as? LUILayoutConstraintItemWrapper, w.originItem === oldItem {
                return true
            }
            return false
        }) {
            // 如果找到，替换这个元素
            items[index] = newItem
        }
    }
}
