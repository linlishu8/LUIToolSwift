//
//  UITableViewCell+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/26.
//

import Foundation

extension UITableViewCell {
    var kLUIAccessoryTypeDefaultLeftMargin: CGFloat {
        return 10
    }
    var kLUIAccessoryTypeDefaultRightMargin: CGFloat {
        return 15
    }
    
    //系统操作区域视图宽度
    func l_accessorySystemTypeViewWidth() -> CGFloat {
        var cellWidth: CGFloat = 0
        switch accessoryType {
        case .none:
            cellWidth = 0
        case .disclosureIndicator:
            if #available(iOS 13.0, *) {
                cellWidth = 11.5
            } else {
                cellWidth = 8
            }
        case .detailDisclosureButton:
            if #available(iOS 13.0, *) {
                cellWidth = 44
            } else {
                cellWidth = 42
            }
        case .checkmark:
            if #available(iOS 13.0, *) {
                cellWidth = 19.5
            } else {
                cellWidth = 14
            }
        case .detailButton:
            if #available(iOS 13.0, *) {
                cellWidth = 25
            } else {
                cellWidth = 22
            }
        default: break
        }
        return cellWidth
    }
    
    //系统操作区域视图与contentView的左边距
    func l_accessorySystemTypeViewLeftMargin() -> CGFloat {
        var cellMargin: CGFloat = kLUIAccessoryTypeDefaultLeftMargin
        switch accessoryType {
        case .none:
            cellMargin = 0
        case .disclosureIndicator:
            if #available(iOS 13.0, *) {
                cellMargin = 0
            }
        case .detailDisclosureButton:
            if #available(iOS 13.0, *) {
                cellMargin = -0.5
            }
        case .checkmark:
            if #available(iOS 13.0, *) {
                cellMargin = 2.25
            }
        case .detailButton:
            if #available(iOS 13.0, *) {
                cellMargin = -0.5
            }
        default: break
        }
        return cellMargin
    }
    
    //系统操作区域视图与UITableViewCell的右边距
    func l_accessorySystemTypeViewRightMargin() -> CGFloat {
        var cellMargin: CGFloat = kLUIAccessoryTypeDefaultRightMargin
        switch accessoryType {
        case .none:
            cellMargin = 0
        case .disclosureIndicator:
            if #available(iOS 13.0, *) {
                cellMargin = 20
            }
        case .detailDisclosureButton:
            if #available(iOS 13.0, *) {
                cellMargin = 20
            }
        case .checkmark:
            if #available(iOS 13.0, *) {
                cellMargin = 22.25
            }
        case .detailButton:
            if #available(iOS 13.0, *) {
                cellMargin = 19.5
            }
        default: break
        }
        return cellMargin
    }
    
    func l_accessoryCustomViewLeftMargin() -> CGFloat {
        var cellWidth: CGFloat = kLUIAccessoryTypeDefaultLeftMargin;
        if #available(iOS 13.0, *) {
            cellWidth = 0;
        }
        return cellWidth;
    }
    
    func l_accessoryCustomViewRightMargin() -> CGFloat {
        var cellWidth: CGFloat = kLUIAccessoryTypeDefaultRightMargin;
        if #available(iOS 13.0, *) {
            cellWidth = 20;
        }
        return cellWidth;
    }
    
    func l_accessoryViewLeftMargin() -> CGFloat {
        var cellMargin: CGFloat = 0
        if accessoryView != nil {
            cellMargin = self.l_accessorySystemTypeViewLeftMargin()
        } else {
            cellMargin = self.l_accessoryCustomViewLeftMargin()
        }
        return cellMargin
    }
    
    func l_accessoryViewRightMargin() -> CGFloat {
        var cellMargin: CGFloat = 0
        if accessoryView != nil {
            cellMargin = self.l_accessorySystemTypeViewRightMargin()
        } else {
            cellMargin = self.l_accessoryCustomViewRightMargin()
        }
        return cellMargin
    }
    
    func l_sizeThatFits(size: CGSize, sizeFitsBlock block:(CGSize) -> CGSize) -> CGSize {
        var cellSize = size
        cellSize.height = 99999999
        let view = self.l_firstSuperViewWithClass(UITableView.self)
        var limitSize = self.contentView.bounds.size
        limitSize.height = max(cellSize.height, limitSize.height)
        var s = block(limitSize)
        if s.height > 0 && !UITableView.l_isAutoAddSeparatorHeightToCell() {
            if let tableView = view as? UITableView {
                s.height += tableView.l_separatorHeight()
            }
        }
        s.height = ceil(s.height)
        return s
    }
}
