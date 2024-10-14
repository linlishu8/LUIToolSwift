//
//  CGGeometry+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/20.
//

import UIKit
import CoreGraphics

public enum LUICGAxis {
    case x, y
}

extension LUICGAxis {
    static func LUICGAxisReverse(_ axis: LUICGAxis) -> LUICGAxis {
        return axis == .x ? .y : .x
    }
    
    func LUICGFloatInterpolate(_ v1: CGFloat, _ v2: CGFloat, _ progress: CGFloat) -> CGFloat {
        return v1 * (1 - progress) + v2 * progress
    }
    
    func LUICGPointInterpolate(_ v1: CGPoint, _ v2: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(x: LUICGFloatInterpolate(v1.x, v2.x, progress), y: LUICGFloatInterpolate(v1.y, v2.y, progress))
    }

    func LUICGVectorInterpolate(_ v1: CGVector, _ v2: CGVector, progress: CGFloat) -> CGVector {
        CGVector(dx: LUICGFloatInterpolate(v1.dx, v2.dx, progress), dy: LUICGFloatInterpolate(v1.dy, v2.dy, progress))
    }

    func LUICGSizeInterpolate(_ v1: CGSize, _ v2: CGSize, progress: CGFloat) -> CGSize {
        CGSize(width: LUICGFloatInterpolate(v1.width, v2.width, progress), height: LUICGFloatInterpolate(v1.height, v2.height, progress))
    }

    func LUICGRectInterpolate(_ v1: CGRect, _ v2: CGRect, progress: CGFloat) -> CGRect {
        CGRect(x: LUICGFloatInterpolate(v1.origin.x, v2.origin.x, progress), y: LUICGFloatInterpolate(v1.origin.y, v2.origin.y, progress), width: LUICGFloatInterpolate(v1.size.width, v2.size.width, progress), height: LUICGFloatInterpolate(v1.size.height, v2.size.height, progress))
    }
    
    func LUICGAffineTransformInterpolate(_ v1: CGAffineTransform, _ v2: CGAffineTransform, progress: CGFloat) -> CGAffineTransform {
        CGAffineTransform(a: LUICGFloatInterpolate(v1.a, v2.a, progress), b: LUICGFloatInterpolate(v1.b, v2.b, progress), c: LUICGFloatInterpolate(v1.c, v2.c, progress), d: LUICGFloatInterpolate(v1.d, v2.d, progress), tx: LUICGFloatInterpolate(v1.tx, v2.tx, progress), ty: LUICGFloatInterpolate(v1.ty, v2.ty, progress))
    }

    func LUICATransform3DInterpolate(_ v1: CATransform3D, _ v2: CATransform3D, progress: CGFloat) -> CATransform3D {
        var v = CATransform3DIdentity
        v.m11 = LUICGFloatInterpolate(v1.m11, v2.m11, progress)
        v.m12 = LUICGFloatInterpolate(v1.m12, v2.m12, progress)
        v.m13 = LUICGFloatInterpolate(v1.m13, v2.m13, progress)
        v.m14 = LUICGFloatInterpolate(v1.m14, v2.m14, progress)
        v.m21 = LUICGFloatInterpolate(v1.m21, v2.m21, progress)
        v.m22 = LUICGFloatInterpolate(v1.m22, v2.m22, progress)
        v.m23 = LUICGFloatInterpolate(v1.m23, v2.m23, progress)
        v.m24 = LUICGFloatInterpolate(v1.m24, v2.m24, progress)
        v.m31 = LUICGFloatInterpolate(v1.m31, v2.m31, progress)
        v.m32 = LUICGFloatInterpolate(v1.m32, v2.m32, progress)
        v.m33 = LUICGFloatInterpolate(v1.m33, v2.m33, progress)
        v.m34 = LUICGFloatInterpolate(v1.m34, v2.m34, progress)
        v.m41 = LUICGFloatInterpolate(v1.m41, v2.m41, progress)
        v.m42 = LUICGFloatInterpolate(v1.m42, v2.m42, progress)
        v.m43 = LUICGFloatInterpolate(v1.m43, v2.m43, progress)
        v.m44 = LUICGFloatInterpolate(v1.m44, v2.m44, progress)
        return v
    }
    
    func __LUIColorInterpolate(_ v1: UIColor, _ v2: UIColor, progress: CGFloat) -> UIColor? {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        guard v1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1),
              v2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else {
            return nil
        }

        let r = LUICGFloatInterpolate(r1, r2, progress)
        let g = LUICGFloatInterpolate(g1, g2, progress)
        let b = LUICGFloatInterpolate(b1, b2, progress)
        let a = LUICGFloatInterpolate(a1, a2, progress)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    func LUIColorInterpolate(_ v1: UIColor, _ v2: UIColor, progress: CGFloat) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection -> UIColor in
                let c1 = v1.resolvedColor(with: traitCollection)
                let c2 = v2.resolvedColor(with: traitCollection)
                return __LUIColorInterpolate(c1, c2, progress: progress) ?? v1
            }
        } else {
            return __LUIColorInterpolate(v1, v2, progress: progress) ?? v1
        }
    }
}

extension CGPoint {
    func LUICGPointGetValue(_ point: CGPoint, axis: LUICGAxis) -> CGFloat {
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

public enum LUICGRectAlignment {
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

    func LUICGRectGetCenter() -> CGPoint {
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
    
    // 与另一个rect进行对齐
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
    
    //Axis operation
    func LUICGRectGetMin(_ axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.minX
        case .y:
            return self.minY
        }
    }
    
    mutating func LUICGRectSetMin(_ axis: LUICGAxis, value: CGFloat) {
        switch axis {
        case .x:
            LUICGRectSetMinX(value)
        case .y:
            LUICGRectSetMinY(value)
        }
    }
    
    mutating func LUICGRectAddMin(_ axis: LUICGAxis, value: CGFloat) {
        LUICGRectSetMin(axis, value: LUICGRectGetMin(axis) + value)
    }
    
    func LUICGRectGetMid(_ axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.midX
        case .y:
            return self.midY
        }
    }
    
    mutating func LUICGRectSetMid(_ axis: LUICGAxis, value: CGFloat) {
        switch axis {
        case .x:
            LUICGRectSetMidX(value)
        case .y:
            LUICGRectSetMidY(value)
        }
    }
    
    mutating func LUICGRectAddMid(_ axis: LUICGAxis, value: CGFloat) {
        LUICGRectSetMid(axis, value: LUICGRectGetMid(axis) + value)
    }
    
    func LUICGRectGetMax(_ axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.maxX
        case .y:
            return self.maxY
        }
    }
    
    mutating func LUICGRectSetMax(_ axis: LUICGAxis, value: CGFloat) {
        switch axis {
        case .x:
            LUICGRectSetMaxX(value)
        case .y:
            LUICGRectSetMaxY(value)
        }
    }
    
    mutating func LUICGRectAddMax(_ axis: LUICGAxis, value: CGFloat) {
        LUICGRectSetMax(axis, value: LUICGRectGetMax(axis) + value)
    }
    
    mutating func LUICGRectSetMinEdgeToRect(_ axis: LUICGAxis, bounds: CGRect, edge: CGFloat) {
        switch axis {
        case .x:
            LUICGRectSetMinXEdgeToRect(bounds, edge: edge)
        case .y:
            LUICGRectSetMinYEdgeToRect(bounds, edge: edge)
        }
    }
    
    mutating func LUICGRectSetMaxEdgeToRect(_ axis: LUICGAxis, bounds: CGRect, edge: CGFloat) {
        switch axis {
        case .x:
            LUICGRectSetMaxXEdgeToRect(bounds, edge: edge)
        case .y:
            LUICGRectSetMaxYEdgeToRect(bounds, edge: edge)
        }
    }
    
    func LUICGRectGetLength(_ axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self.width
        case .y:
            return self.height
        }
    }
    
    mutating func LUICGRectSetLength(_ axis: LUICGAxis, value: CGFloat) {
        switch axis {
        case .x:
            LUICGRectSetWidth(value)
        case .y:
            LUICGRectSetHeight(value)
        }
    }
    
    mutating func LUICGRectAddLength(_ axis: LUICGAxis, value: CGFloat) {
        LUICGRectSetLength(axis, value: LUICGRectGetLength(axis) + value)
    }
    
    mutating func LUICGRectAlignMinToRect(_ axis: LUICGAxis, bounds: CGRect) {
        switch axis {
        case .x:
            LUICGRectAlignMinXToRect(bounds)
        case .y:
            LUICGRectAlignMinYToRect(bounds)
        }
    }
    
    mutating func LUICGRectAlignMidToRect(_ axis: LUICGAxis, bounds: CGRect) {
        switch axis {
        case .x:
            LUICGRectAlignMidXToRect(bounds)
        case .y:
            LUICGRectAlignMidYToRect(bounds)
        }
    }
    
    mutating func LUICGRectAlignMaxToRect(_ axis: LUICGAxis, bounds: CGRect) {
        switch axis {
        case .x:
            LUICGRectAlignMaxXToRect(bounds)
        case .y:
            LUICGRectAlignMaxYToRect(bounds)
        }
    }
    
    mutating func LUICGRectAlignToRect(_ axis: LUICGAxis, alignment: LUICGRectAlignment, bounds: CGRect) {
        switch alignment {
        case .min:
            LUICGRectAlignMinToRect(axis, bounds: bounds)
        case .mid:
            LUICGRectAlignMidToRect(axis, bounds: bounds)
        case .max:
            LUICGRectAlignMaxToRect(axis, bounds: bounds)
        }
    }
    
    mutating func LUICGRectAlignMidCenterToRect(_ bounds: CGRect) {
        LUICGRectAlignMidToRect(.x, bounds: bounds)
        LUICGRectAlignMidToRect(.y, bounds: bounds)
    }
}

// UIRectEdge
enum LUIEdgeInsetsEdge {
    case min  // 对应于top, left
    case max  // 对应于bottom, right
}

extension LUIEdgeInsetsEdge {
    func LUIEdgeInsetsGetEdge(_ insets: UIEdgeInsets, axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return self == .min ? insets.left : insets.right
        case .y:
            return self == .min ? insets.top : insets.bottom
        }
    }
    
    func LUIEdgeInsetsGetEdgeSum(_ insets: UIEdgeInsets, axis: LUICGAxis) -> CGFloat {
        switch axis {
        case .x:
            return insets.left + insets.right
        case .y:
            return insets.top + insets.bottom
        }
    }
    
    func LUIEdgeInsetsSetEdge(_ insets: inout UIEdgeInsets, axis: LUICGAxis, value: CGFloat) {
        switch (axis, self) {
        case (.x, .min):
            insets.left = value
        case (.x, .max):
            insets.right = value
        case (.y, .min):
            insets.top = value
        case (.y, .max):
            insets.bottom = value
        }
    }
    
    func LUIEdgeInsetsAddEdge(_ insets: inout UIEdgeInsets, axis: LUICGAxis, value: CGFloat) {
        let currentEdgeValue = LUIEdgeInsetsGetEdge(insets, axis: axis)
        LUIEdgeInsetsSetEdge(&insets, axis: axis, value: currentEdgeValue + value)
    }
    
    //CGAffineTransform
    func LUICGAffineTransformMakeTranslation(_ axis: LUICGAxis, _ tx: CGFloat) -> CGAffineTransform {
        axis == .x ? CGAffineTransform(translationX: tx, y: 0) : CGAffineTransform(translationX: 0, y: tx)
    }

    func LUICATransform3DMakeTranslation(_ axis: LUICGAxis, _ tx: CGFloat) -> CATransform3D {
        axis == .x ? CATransform3DMakeTranslation(tx, 0, 0) : CATransform3DMakeTranslation(0, tx, 0)
    }

    func LUICATransform3DMakeRotation(_ axis: LUICGAxis, _ angle: CGFloat) -> CATransform3D {
        axis == .x ? CATransform3DMakeRotation(angle, 1, 0, 0) : CATransform3DMakeRotation(angle, 0, 1, 0)
    }

    func LUICATransform3DMakeScale(_ axis: LUICGAxis, _ sx: CGFloat) -> CATransform3D {
        axis == .x ? CATransform3DMakeScale(sx, 1, 1) : CATransform3DMakeScale(1, sx, 1)
    }
}

struct LUICGRange {
    var begin: CGFloat
    var end: CGFloat
    
    static func LUICGRangeMake(_ begin: CGFloat, end: CGFloat) -> LUICGRange {
        LUICGRange(begin: begin, end: end)
    }
    
    //插值
    func LUICGRangeInterpolate(_ progress: CGFloat) -> CGFloat {
        begin * (1.0 - progress) + end * progress
    }
    
    //是否包含指定值
    func LUICGRangeContainsValue(v: CGFloat) -> Bool {
        v >= begin && v <= end
    }
    
    //是否是无效的区域
    func LUICGRangeIsNull() -> Bool {
        end < begin
    }
    
    //是否是空区间
    func LUICGRangeIsEmpty() -> Bool {
        end == begin
    }
    
    //两个区间是否相交
    func LUICGRangeIntersectsRange(r1: LUICGRange, r2: LUICGRange) -> Bool {
        LUICGRangeContainsValue(v: r2.end) || LUICGRangeContainsValue(v: r2.begin) || LUICGRangeContainsValue(v: r1.end) || LUICGRangeContainsValue(v: r1.begin)
    }
    
    //返回两个区间的并
    func LUICGRangeUnion(r1: LUICGRange, r2: LUICGRange) -> LUICGRange {
        .LUICGRangeMake(min(r1.begin, r2.begin), end: max(r1.end, r2.end))
    }
    
    //返回两个区间的交，没有交集时，返回无效区间
    func LUICGRangeIntersection(r1: LUICGRange, r2: LUICGRange) -> LUICGRange {
        .LUICGRangeMake(max(r1.begin, r2.begin), end: min(r1.end, r2.end))
    }
    
    func LUICGRectGetRange(_ rect: CGRect, axis: LUICGAxis) -> LUICGRange {
        .LUICGRangeMake(rect.LUICGRectGetMin(axis), end: rect.LUICGRectGetMax(axis))
    }
    
    func LUICGRangeGetMin(_ r: LUICGRange) -> CGFloat {
        r.begin
    }
    
    func LUICGRangeGetMax(_ r: LUICGRange) -> CGFloat {
        r.end
    }
    
    func LUICGRangeGetMid(_ r: LUICGRange) -> CGFloat {
        r.begin + (r.end - r.begin) * 0.5
    }
    
    func LUICGRangeGetLength(_ r: LUICGRange) -> CGFloat {
        r.end - r.begin
    }
    
    func LUICGRangeCompareWithValue(_ r: LUICGRange, value: CGFloat) -> ComparisonResult {
        LUICGRangeContainsValue(v: value) ? .orderedSame : (r.end < value ? .orderedAscending : .orderedDescending)
    }
    
    func LUICGRangeCompareWithRange(r1: LUICGRange, r2: LUICGRange) -> ComparisonResult {
        LUICGRangeIntersectsRange(r1: r1, r2: r2) ? .orderedSame : (r1.end < r2.begin ? .orderedAscending : .orderedDescending)
    }
    
    func LUICGRectCompareWithPoint(_ rect: CGRect, point: CGPoint, axis: LUICGAxis) -> ComparisonResult {
        LUICGRangeCompareWithValue(LUICGRectGetRange(rect, axis: axis), value: point.LUICGPointGetValue(point, axis: axis))
    }
    
    func LUICGRectCompareWithCGRect(r1: CGRect, r2: CGRect, axis: LUICGAxis) -> ComparisonResult {
        LUICGRangeCompareWithRange(r1: LUICGRectGetRange(r1, axis: axis), r2: LUICGRectGetRange(r2, axis: axis))
    }
}

public extension UIEdgeInsets {
    static func LUIEdgeInsetsMakeSameEdge(_ edge: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
    }
}

public extension UIColor {
    convenience init(hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)

            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0

            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        }
}
