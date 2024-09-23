//
//  CGGeometry+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/20.
//

import UIKit
import CoreGraphics

enum LUICGAxis {
    case x, y
}

extension LUICGAxis {
    func LUICGAxisReverse(_ axis: LUICGAxis) -> LUICGAxis {
        return axis == .x ? .y : .x
    }
}

extension CGPoint {
    mutating func LUICGPointGetValue(_ point: CGPoint, axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.x
        case .y:
            return self.y
        }
    }
    
    mutating func LUICGPointSetValue(_ value: CGFloat, axis: LUICGAxis) {
            switch axis {
            case .x:
                self.x = value
            case .y:
                self.y = value
            }
        }
    
    mutating func LUICGPointAddValue(_ value: CGFloat, axis: LUICGAxis) {
        switch axis {
        case .x:
            self.x += value
        case .y:
            self.y += value
        }
    }
}

extension CGVector {
    mutating func LUICGVectorSetValue(_ value: CGFloat, axis: LUICGAxis) {
        switch axis {
        case .x:
            self.dx = value
        case .y:
            self.dy = value
        }
    }
    
    mutating func LUICGVectorAddValue(_ value: CGFloat, axis: LUICGAxis) {
        switch axis {
        case .x:
            self.dx += value
        case .y:
            self.dy += value
        }
    }
    
    func LUICGVectorGetValue(_ axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.dx
        case .y:
            return self.dy
        }
    }
}

extension CGSize {
    mutating func LUICGSizeSetLength(_ value: CGFloat, axis: LUICGAxis) {
        switch axis {
        case .x:
            self.width = value
        case .y:
            self.height = value
        }
    }
    
    mutating func LUICGSizeAddLength(_ value: CGFloat, axis: LUICGAxis) {
        switch axis {
        case .x:
            self.width += value
        case .y:
            self.height += value
        }
    }
    
    func LUICGSizeGetLength( axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.width
        case .y:
            return self.height
        }
    }
}

enum LUICGRectAlignment {
    case min, mid, max
}

extension LUICGRectAlignment {
    func reverse() -> LUICGRectAlignment {
        switch self {
        case .min:
            return .max
        case .max:
            return .min
        case .mid:
            return .mid
        }
    }
}

extension CGRect {
    mutating func LUICGRectSetMinX(_ value: CGFloat) {
        self.origin.x = value
    }

    mutating func LUICGRectSetMinY(_ value: CGFloat) {
        self.origin.y = value
    }

    mutating func LUICGRectSetMidX(_ value: CGFloat) {
        self.origin.x = value - self.size.width * 0.5
    }

    mutating func LUICGRectSetMidY(_ value: CGFloat) {
        self.origin.y = value - self.size.height * 0.5
    }

    mutating func LUICGRectSetMaxX(_ value: CGFloat) {
        self.origin.x = value - self.size.width
    }

    mutating func LUICGRectSetMaxY(_ value: CGFloat) {
        self.origin.y = value - self.size.height
    }

    mutating func LUICGRectSetWidth(_ value: CGFloat) {
        self.size.width = value
    }

    mutating func LUICGRectSetHeight(_ value: CGFloat) {
        self.size.height = value
    }

    mutating func LUICGRectGetCenter() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
    
    mutating func LUICGRectSetCenter(_ center: CGPoint) {
        LUICGRectSetMidX(center.x)
        LUICGRectSetMidY(center.y)
    }
    
    func LUICGRectGetPercentX(_ percent: CGFloat) -> CGFloat {
        return minX + percent * width
    }
    
    func LUICGRectGetPercentY(_ percent: CGFloat) -> CGFloat {
        return minY + percent * height
    }
    
    mutating func LUICGRectSetMinXEdgeToRect(_ bounds: CGRect, edge: CGFloat) {
        LUICGRectSetMinX(bounds.minX + edge)
    }
    
    mutating func LUICGRectSetMaxXEdgeToRect(_ bounds: CGRect, edge: CGFloat) {
        LUICGRectSetMaxX(bounds.maxX - edge)
    }
    
    mutating func LUICGRectSetMinYEdgeToRect(_ bounds: CGRect, edge: CGFloat) {
        LUICGRectSetMinY(bounds.minY + edge)
    }
    
    mutating func LUICGRectSetMaxYEdgeToRect(_ bounds: CGRect, edge: CGFloat) {
        LUICGRectSetMaxY(bounds.maxY - edge)
    }
    
    mutating func LUICGRectAlignCenterToRect(_ bounds: CGRect) {
        LUICGRectSetCenter(LUICGRectGetCenter())
    }
    
    mutating func LUICGRectAlignMinXToRect(_ bounds: CGRect) {
        LUICGRectSetMinX(bounds.minX)
    }
    
    mutating func LUICGRectAlignMidXToRect(_ bounds: CGRect) {
        LUICGRectSetMidX(bounds.midX)
    }
    
    mutating func LUICGRectAlignMaxXToRect(_ bounds: CGRect) {
        LUICGRectSetMaxX(bounds.maxX)
    }
    
    mutating func LUICGRectAlignMinYToRect(_ bounds: CGRect) {
        LUICGRectSetMinY(bounds.minY)
    }
    
    mutating func LUICGRectAlignMidYToRect(_ bounds: CGRect) {
        LUICGRectSetMidY(bounds.midY)
    }
    
    mutating func LUICGRectAlignMaxYToRect(_ bounds: CGRect) {
        LUICGRectSetMaxY(bounds.maxY)
    }
    
    func LUICGRectGetMin(_ bounds: CGRect, axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.minX
        case .y:
            return self.minY
        }
    
    }
}
