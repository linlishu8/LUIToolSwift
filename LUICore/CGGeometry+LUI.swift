//
//  CGGeometry+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/20.
//

import UIKit
import CoreGraphics
import QuartzCore

// MARK: - 枚举类型

enum LUICGAxis {
    case x, y
}

enum LUICGRectAlignment {
    case min, mid, max

    func reversed() -> LUICGRectAlignment {
        switch self {
        case .min: return .max
        case .max: return .min
        default: return .mid
        }
    }
}

enum LUIEdgeInsetsEdge {
    case min, max
}

// MARK: - CGPoint 扩展

extension CGPoint {
    mutating func setValue(for axis: LUICGAxis, value: CGFloat) {
        switch axis {
        case .x: x = value
        case .y: y = value
        }
    }

    mutating func addValue(for axis: LUICGAxis, value: CGFloat) {
        switch axis {
        case .x: x += value
        case .y: y += value
        }
    }

    static func interpolate(from point1: CGPoint, to point2: CGPoint, progress: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat.interpolate(from: point1.x, to: point2.x, progress: progress),
                       y: CGFloat.interpolate(from: point1.y, to: point2.y, progress: progress))
    }
}

// MARK: - CGFloat 扩展

extension CGFloat {
    static func interpolate(from value1: CGFloat, to value2: CGFloat, progress: CGFloat) -> CGFloat {
        return value1 * (1 - progress) + value2 * progress
    }
}

// MARK: - CGRect 扩展

extension CGRect {
    mutating func setMinX(_ value: CGFloat) { origin.x = value }
    mutating func setMinY(_ value: CGFloat) { origin.y = value }
    mutating func setMidX(_ value: CGFloat) { origin.x = value - size.width * 0.5 }
    mutating func setMidY(_ value: CGFloat) { origin.y = value - size.height * 0.5 }
    mutating func setMaxX(_ value: CGFloat) { origin.x = value - size.width }
    mutating func setMaxY(_ value: CGFloat) { origin.y = value - size.height }

    static func interpolate(from rect1: CGRect, to rect2: CGRect, progress: CGFloat) -> CGRect {
        return CGRect(x: CGFloat.interpolate(from: rect1.origin.x, to: rect2.origin.x, progress: progress),
                      y: CGFloat.interpolate(from: rect1.origin.y, to: rect2.origin.y, progress: progress),
                      width: CGFloat.interpolate(from: rect1.size.width, to: rect2.size.width, progress: progress),
                      height: CGFloat.interpolate(from: rect1.size.height, to: rect2.size.height, progress: progress))
    }
}

// MARK: - CGAffineTransform 扩展

extension CGAffineTransform {
    static func interpolate(from t1: CGAffineTransform, to t2: CGAffineTransform, progress: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(a: CGFloat.interpolate(from: t1.a, to: t2.a, progress: progress),
                                b: CGFloat.interpolate(from: t1.b, to: t2.b, progress: progress),
                                c: CGFloat.interpolate(from: t1.c, to: t2.c, progress: progress),
                                d: CGFloat.interpolate(from: t1.d, to: t2.d, progress: progress),
                                tx: CGFloat.interpolate(from: t1.tx, to: t2.tx, progress: progress),
                                ty: CGFloat.interpolate(from: t1.ty, to: t2.ty, progress: progress))
    }
}

// MARK: - UIColor 扩展

extension UIColor {
    static func interpolate(from color1: UIColor, to color2: UIColor, progress: CGFloat) -> UIColor {
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return UIColor(red: .interpolate(from: red1, to: red2, progress: progress),
                       green: .interpolate(from: green1, to: green2, progress: progress),
                       blue: .interpolate(from: blue1, to: blue2, progress: progress),
                       alpha: .interpolate(from: alpha1, to: alpha2, progress: progress))
    }
}

extension CGVector {
    mutating func setValue(for axis: LUICGAxis, value: CGFloat) {
        switch axis {
        case .x: dx = value
        case .y: dy = value
        }
    }

    mutating func addValue(for axis: LUICGAxis, value: CGFloat) {
        switch axis {
        case .x: dx += value
        case .y: dy += value
        }
    }

    static func interpolate(from vector1: CGVector, to vector2: CGVector, progress: CGFloat) -> CGVector {
        return CGVector(dx: CGFloat.interpolate(from: vector1.dx, to: vector2.dx, progress: progress),
                        dy: CGFloat.interpolate(from: vector1.dy, to: vector2.dy, progress: progress))
    }
}

// MARK: - CGSize 扩展

extension CGSize {
    mutating func setLength(for axis: LUICGAxis, length: CGFloat) {
        switch axis {
        case .x: width = length
        case .y: height = length
        }
    }

    mutating func addLength(for axis: LUICGAxis, length: CGFloat) {
        switch axis {
        case .x: width += length
        case .y: height += length
        }
    }

    static func interpolate(from size1: CGSize, to size2: CGSize, progress: CGFloat) -> CGSize {
        return CGSize(width: CGFloat.interpolate(from: size1.width, to: size2.width, progress: progress),
                      height: CGFloat.interpolate(from: size1.height, to: size2.height, progress: progress))
    }
}

// MARK: - UIEdgeInsets 扩展

extension UIEdgeInsets {
    static func makeSameEdge(_ edge: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
    }

    mutating func setEdge(for axis: LUICGAxis, edge: LUIEdgeInsetsEdge, value: CGFloat) {
        switch axis {
        case .x:
            if edge == .min {
                left = value
            } else {
                right = value
            }
        case .y:
            if edge == .min {
                top = value
            } else {
                bottom = value
            }
        }
    }

    mutating func addEdge(for axis: LUICGAxis, edge: LUIEdgeInsetsEdge, value: CGFloat) {
        switch axis {
        case .x:
            if edge == .min {
                left += value
            } else {
                right += value
            }
        case .y:
            if edge == .min {
                top += value
            } else {
                bottom += value
            }
        }
    }

    static func interpolate(from insets1: UIEdgeInsets, to insets2: UIEdgeInsets, progress: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: CGFloat.interpolate(from: insets1.top, to: insets2.top, progress: progress),
                            left: CGFloat.interpolate(from: insets1.left, to: insets2.left, progress: progress),
                            bottom: CGFloat.interpolate(from: insets1.bottom, to: insets2.bottom, progress: progress),
                            right: CGFloat.interpolate(from: insets1.right, to: insets2.right, progress: progress))
    }
}
