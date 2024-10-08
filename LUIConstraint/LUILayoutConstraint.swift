//
//  LUILayoutConstraint.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/28.
//

import Foundation

public protocol LUILayoutConstraintItemProtocol: LUILayoutConstraintItemAttributeProtocol {
    func hidden() -> Bool//是否隐藏,默认为NO
    func sizeOfLayout() -> CGSize//返回尺寸信息
    func setLayoutTransform(transform: CGAffineTransform) //以布局bounds为中心点,对布局作为一个整体,设置底下元素的仿射矩阵
    func sizeThatFits(_ size: CGSize, resizeItems: Bool) -> CGSize//适合于容器
    func layoutItemsWithResizeItems(resizeItems: Bool)//适合于容器
}

public enum LUILayoutConstraintVerticalAlignment: Int {
    case verticalCenter = 0
    case verticalTop = 1
    case verticalBottom = 2
}

func LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(align: LUILayoutConstraintVerticalAlignment) -> LUICGRectAlignment {
    return align == .verticalCenter ? .mid : (align == .verticalTop ? .min : .max)
}

public enum LUILayoutConstraintHorizontalAlignment: Int {
    case horizontalCenter = 0
    case horizontalLeft = 1
    case horizontalRight = 2
}

func LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(align: LUILayoutConstraintHorizontalAlignment) -> LUICGRectAlignment {
    return align == .horizontalCenter ? .mid : (align == .horizontalLeft ? .min : .max)
}

public enum LUILayoutConstraintDirection: Int {
    case constraintVertical//垂直布局
    case constraintHorizontal//水平布局
}

open class LUILayoutConstraint: NSObject, LUILayoutConstraintItemProtocol {
    public func hidden() -> Bool {
        return false
    }//是否隐藏,默认为NO
    
    private var internalItems: [LUILayoutConstraintItemProtocol] = []
    open var items: [LUILayoutConstraintItemProtocol] {
        set {
            self.internalItems.removeAll()
            self.internalItems.append(contentsOf: newValue)
        } get {
            return self.internalItems
        }
    }
    
    open var bounds: CGRect = .zero//在bounds的区域内布局
    open var layoutHiddenItem: Bool = false//是否布局隐藏元素,默认为NO
    
    public func addItem(item: LUILayoutConstraintItemProtocol) {
        if items.contains(where: { $0 === item }) {
            self.items.append(item)
        }
    }
    
    public func removeItem(item: LUILayoutConstraintItemProtocol) {
        if let index = self.items.firstIndex(where: { $0 === item }) {
            self.items.remove(at: index)
        }
    }
    
    public func replaceItem(oldItem: LUILayoutConstraintItemProtocol, newItem: LUILayoutConstraintItemProtocol) {
        if let index = items.firstIndex(where: { obj in
            if obj === oldItem {
                return true
            }
            if let w = obj as? LUILayoutConstraintItemWrapper, w.originItem === oldItem {
                return true
            }
            return false
        }) {
            items[index] = newItem
        }
    }
    
    //进行布局,子类实现
    open func layoutItems() {
        
    }
    
    //显示的元素,@[id<LUILayoutConstraintItemProtocol>]
    public var layoutedItems: [LUILayoutConstraintItemProtocol] {
        get {
            if self.layoutHiddenItem {
                return self.items
            } else {
                return self.visiableItems
            }
        }
    }
    
    //显示的元素,@[id<LUILayoutConstraintItemProtocol>]
    public var visiableItems: [LUILayoutConstraintItemProtocol] {
        get {
            var items: [LUILayoutConstraintItemProtocol] = []
            for item in items {
                if !item.hidden() {
                    items.append(item)
                }
            }
            return items
        }
    }
    
    public func sizeThatFits(_ size: CGSize, resizeItems: Bool) -> CGSize {
        return self.hidden() ? .zero : size
    }
    
    public func setLayoutTransform(transform: CGAffineTransform) {
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
    
    public func sizeOfLayout() -> CGSize {
        return self.bounds.size
    }
    
    public var layoutFrame: CGRect {
        get {
            return self.bounds
        } set {
            self.bounds = newValue
            self.layoutItems()
        }
    }
    
    public func layoutItemsWithResizeItems(resizeItems: Bool) {
        
    }
    
    func initWithItems(items: [LUILayoutConstraintItemProtocol], bounds: CGRect) {
        self.items = items
        self.bounds = bounds
    }
}

extension UIView: LUILayoutConstraintItemProtocol {
    public func hidden() -> Bool {
        return self.isHidden
    }
    
    public func sizeOfLayout() -> CGSize {
        return self.bounds.size
    }
    
    public func setLayoutTransform(transform: CGAffineTransform) {
        self.transform = transform
    }
    
    public func sizeThatFits(_ size: CGSize, resizeItems: Bool) -> CGSize {
        return self.hidden() ? .zero : size
    }
    
    public func layoutItemsWithResizeItems(resizeItems: Bool) {
        
    }
    
    public var layoutFrame: CGRect {
        get {
            var frame = self.bounds
            let center = self.center
            frame.origin.x = center.x - frame.size.width / 2
            frame.origin.y = center.y - frame.size.height / 2
            return frame
        }
        set {
            if CGAffineTransformIsIdentity(self.transform) {
                self.frame = newValue
            } else {
                var bounds = self.bounds
                bounds.size = newValue.size
                self.bounds = bounds
                
                var center = newValue.origin
                center.x += newValue.size.width / 2
                center.y += newValue.size.height / 2
                self.center = center
            }
        }
    }
}
