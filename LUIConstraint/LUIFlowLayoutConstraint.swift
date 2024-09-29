//
//  LUIFlowLayoutConstraint.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/29.
//

import Foundation

class LUIFlowLayoutConstraint: LUILayoutConstraint {
    open var layoutDirection: LUILayoutConstraintDirection = .constraintVertical
    open var layoutVerticalAlignment: LUILayoutConstraintVerticalAlignment = .verticalCenter
    open var layoutHorizontalAlignment: LUILayoutConstraintHorizontalAlignment = .horizontalCenter
    open var contentInsets: UIEdgeInsets = .zero
    open var interitemSpacing: CGFloat = 0
    open var unLimitItemSizeInBounds: Bool = false
    public var itemAttributeSection: LUILayoutConstraintItemAttributeSection
}
