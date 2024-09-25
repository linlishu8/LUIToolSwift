//
//  UITableView+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/20.
//

import Foundation

extension UITableView {
    
    // 隐藏 header 区域空白
    func l_hiddenHeaderAreaBlank() {
        if tableHeaderView == nil && style == .grouped {
            let emptyHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            tableHeaderView = emptyHeaderView
        }
    }
    
    // 隐藏 footer 区域分隔线
    func l_hiddenFooterAreaSeparators() {
        if tableFooterView == nil && separatorStyle != .none {
            let emptyFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            tableFooterView = emptyFooterView
        }
    }
    
    // 获取可见区域最大的 cell 的 indexPath
    func l_indexPathForMaxVisibleArea() -> IndexPath? {
        let bounds = self.bounds
        let offset = self.contentOffset
        guard let indexPaths = indexPathsForVisibleRows else { return nil }
        
        var maxArea: CGFloat = -1
        var maxAreaIndexPath: IndexPath?
        
        for indexPath in indexPaths {
            if let cell = cellForRow(at: indexPath) {
                var cellFrame = cell.frame
                cellFrame.origin.x -= offset.x
                cellFrame.origin.y -= offset.y
                let intersection = cellFrame.intersection(bounds)
                let area = intersection.width * intersection.height
                
                if area > maxArea {
                    maxArea = area
                    maxAreaIndexPath = indexPath
                }
            }
        }
        return maxAreaIndexPath
    }
    
    // 获取分隔线高度
    func l_separatorHeight() -> CGFloat {
        return separatorStyle == .none ? 0 : 1.0 / UIScreen.main.scale
    }
    
    // 是否自动添加分隔线高度
    static func l_isAutoAddSeparatorHeightToCell() -> Bool {
        let version = UIDevice.current.systemVersion
        return Float(version)! >= 13.0
    }
    
    // 获取指定类型的可见 cell
    func l_visibleCells<T: UITableViewCell>(ofClass cellClass: T.Type) -> [T] {
        return visibleCells.compactMap { $0 as? T }
    }
    
    func l_cellHeight(for indexPath: IndexPath) -> CGFloat {
        var cellHeight: CGFloat = 0
        
        // 调用代理方法获取 cell 的高度
        if let delegate = self.delegate, let height = delegate.tableView?(self, heightForRowAt: indexPath) {
            cellHeight = height
        }
        
        if cellHeight == UITableViewAutomaticDimension {
            if let cell = dataSource?.tableView(self, cellForRowAt: indexPath) {
                let noSuperview = cell.superview == nil
                if noSuperview {
                    addSubview(cell)
                }
                
                let originalBounds = cell.frame
                let originalContentBounds = cell.contentView.frame
                
                let bounds = l_contentBounds
                var cellBounds = bounds
                cellBounds.size.height = .greatestFiniteMagnitude
                cellBounds.origin = .zero
                
                var contentViewBounds = cellBounds
                
                if #available(iOS 11.0, *) {
                    contentViewBounds = UIEdgeInsetsInsetRect(cellBounds, safeAreaInsets)
                }
                
                if cell.accessoryView == nil {
                    contentViewBounds.size.width -= cell.accessoryView?.bounds.size.width ?? 0
                }
                
                cell.frame = cellBounds
                cell.contentView.frame = contentViewBounds
                
                let cellSize = cell.sizeThatFits(CGSize(width: cellBounds.size.width, height: .greatestFiniteMagnitude))
                
                if noSuperview {
                    cell.removeFromSuperview()
                }
                
                cell.frame = originalBounds
                cell.contentView.frame = originalContentBounds
                
                cellHeight = cellSize.height
            }
        }
        return cellHeight
    }
    
    func __l_sectionHeight(in section: Int, isHeader: Bool) -> CGFloat {
        var sectionHeight: CGFloat = 0
        
        if isHeader {
            if let delegate = delegate,
               delegate.responds(to: #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:))) {
                sectionHeight = delegate.tableView!(self, heightForHeaderInSection: section)
            } else {
                sectionHeight = sectionHeaderHeight
            }
        } else {
            if let delegate = delegate,
               delegate.responds(to: #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:))) {
                sectionHeight = delegate.tableView!(self, heightForFooterInSection: section)
            } else {
                sectionHeight = sectionFooterHeight
            }
        }
        
        if sectionHeight == UITableViewAutomaticDimension {
            let sectionView: UIView? = isHeader
                ? delegate?.tableView?(self, viewForHeaderInSection: section)
                : delegate?.tableView?(self, viewForFooterInSection: section)
            
            if sectionView != nil {
                let size = sectionView!.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
                sectionHeight = size.height
            }
        }
        
        if isHeader {
            sectionHeight += __l_sectionHeaderTopPadding()
        }
        return sectionHeight
    }
    
    func __l_sectionHeaderTopPadding() -> CGFloat {
        var padding: CGFloat = 0
        if #available(iOS 15.0, *) {
            padding += sectionHeaderTopPadding == UITableViewAutomaticDimension ? 22 : sectionHeaderTopPadding
        }
        return padding
    }
    
    func l_heightThatFits(_ boundsWidth: CGFloat) -> CGFloat {
        var totalHeight: CGFloat = contentInset.top + contentInset.bottom
        
        totalHeight += __l_tableHeadFootViewHeightThatFits(boundsWidth: boundsWidth, isHead: true)
        totalHeight += __l_tableHeadFootViewHeightThatFits(boundsWidth: boundsWidth, isHead: false)
        
        for section in 0..<numberOfSections {
            totalHeight += __l_sectionHeight(in: section, isHeader: true)
            totalHeight += __l_sectionHeight(in: section, isHeader: false)
            
            for row in 0..<numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                totalHeight += l_cellHeight(for: indexPath)
            }
        }
        
        return ceil(totalHeight)
    }
    
    private func __l_tableHeadFootViewHeightThatFits(boundsWidth: CGFloat, isHead: Bool) -> CGFloat {
        let view = isHead ? tableHeaderView : tableFooterView
        return view?.sizeThatFits(CGSize(width: boundsWidth, height: .greatestFiniteMagnitude)).height ?? 0
    }
}

// 自定义的 section 视图类
class LUITableViewDefaultSectionView: UIView {
    
    static let sharedInstance = LUITableViewDefaultSectionView()
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(titleLabel)
    }
    
    static func contentInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 33, left: 15, bottom: 7, right: 15)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let insets = Self.contentInsets()
        let limitSize = CGSize(width: size.width - insets.left - insets.right, height: size.height - insets.top - insets.bottom)
        var sizeFits = titleLabel.sizeThatFits(limitSize)
        
        if sizeFits != .zero {
            sizeFits.width += insets.left + insets.right
            sizeFits.height += insets.top + insets.bottom
        }
        
        sizeFits.height = max(18, sizeFits.height)
        return sizeFits
    }
}
