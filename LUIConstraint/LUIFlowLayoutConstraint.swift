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
//    open var layoutVerticalAlignment: LUILayoutConstraintVerticalAlignment = .verticalCenter
//    open var layoutHorizontalAlignment: LUILayoutConstraintHorizontalAlignment = .horizontalCenter
//    open var contentInsets: UIEdgeInsets = .zero
//    open var interitemSpacing: CGFloat = 0
//    open var unLimitItemSizeInBounds: Bool = false
//    public var itemAttributeSection: LUILayoutConstraintItemAttributeSection
//    
//    private func layoutDirectionAxis() -> LUICGAxis {
//        return self.layoutDirection == .constraintHorizontal ? .x : .y
//    }
//    
//    func itemSizeForItem(_ item: LUILayoutConstraintItemProtocol, thatFits size: CGSize, resizeItems: Bool) -> CGSize {
//
//    }
}
