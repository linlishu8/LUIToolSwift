//
//  LUITableViewCellBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/26.
//

import Foundation

open class LUITableViewCellBase: UITableViewCell, LUITableViewCellProtocol {
    
    static var useCachedFitedSize: Bool = true //是否缓存sizeThatFits:的结果，默认为YES
    var isCellModelChanged: Bool = false//cellmodel是否有变化
    var isNeedLayoutCellSubviews: Bool = false//是否要重新布局视图
    static let estimatedHeightKey: String = "\(String(describing: type(of: LUITableViewCellBase.self)))_estimatedHeight"
    static let cachedFitedSizeKey: String = "\(String(describing: type(of: LUITableViewCellBase.self)))_cachedFitedSize"
    
    required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cellModel = LUITableViewCellModel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func heightWithTableView(_ tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat {
        if useCachedFitedSize {
            let bounds = tableView.bounds
            if let cacheSizeValue = cellModel[LUITableViewCellBase.cachedFitedSizeKey] as? NSValue {
                let cacheSize = cacheSizeValue.cgSizeValue
                if cacheSize.width == bounds.size.width {
                    return cacheSize.height
                }
            }
        }
        return UITableViewAutomaticDimension
    }
    
    static func estimatedHeightWithTableView(_ tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat {
        return CGFloat(cellModel.l_cellHeightForKeyPath(self.estimatedHeightKey, otherwise: 44))
    }
    
    open var cellModel: LUITableViewCellModel {
        didSet {
            self.isCellModelChanged = cellModel.needReloadCell || oldValue !== cellModel || cellModel.tableViewCell !== self
            if LUITableViewCellBase.useCachedFitedSize && cellModel.needReloadCell {
                cellModel[LUITableViewCellBase.cachedFitedSizeKey] = nil
            }
            cellModel.needReloadCell = false
            if !self.isCellModelChanged { return }
            self.isNeedLayoutCellSubviews = true
            self.customReloadCellModel()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !self.isCellModelChanged && !self.isNeedLayoutCellSubviews { return }
        self.customLayoutSubviews()
        self.isNeedLayoutCellSubviews = false
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        if LUITableViewCellBase.useCachedFitedSize {
            if let cacheSizeValue = cellModel[LUITableViewCellBase.cachedFitedSizeKey] as? NSValue {
                let cacheSize = cacheSizeValue.cgSizeValue
                if cacheSize.width == size.width {
                    return cacheSize
                }
            }
        }
        var sizeFits = self.l_sizeThatFits(size: size) { blockSize in
            return self.customSizeThatFits(size: blockSize)
        }
        sizeFits.width = size.width
        if LUITableViewCellBase.useCachedFitedSize {
            self.cellModel[LUITableViewCellBase.cachedFitedSizeKey] = [NSValue (cgSize: sizeFits)]
        }
        self.cellModel[LUITableViewCellBase.estimatedHeightKey] = sizeFits.height
        return sizeFits
    }
    
    func tableView(_ tableView: UITableView, didSelectCell selected: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayCellModel cellModel: LUITableViewCellModel) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingCellModel cellModel: LUITableViewCellModel) {
        
    }
    
    // MARK: - override
    open func customReloadCellModel() {
        
    }
    
    open func customLayoutSubviews() {
        
    }
    
    open func customSizeThatFits(size: CGSize) -> CGSize {
        return size
    }
}
