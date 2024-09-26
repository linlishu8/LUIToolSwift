//
//  LUITableViewCellBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/26.
//

import Foundation

class LUITableViewCellBase: UITableViewCell, LUITableViewCellProtocol {
    
    static var useCachedFitedSize: Bool = true //是否缓存sizeThatFits:的结果，默认为YES
    var isCellModelChanged: Bool = false//cellmodel是否有变化
    var isNeedLayoutCellSubviews: Bool = false//是否要重新布局视图
    static let estimatedHeightKey: String = "\(String(describing: type(of: LUITableViewCellBase.self)))_estimatedHeight"
    static let cachedFitedSizeKey: String = "\(String(describing: type(of: LUITableViewCellBase.self)))_cachedFitedSize"
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK LUITableViewCellProtocol
    
    static func heightWithTableView(_ tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat {
        if useCachedFitedSize {
            let bounds = tableView.bounds
            if let cacheSizeValue = cellModel.l_NSValueForKeyPath(self.cachedFitedSizeKey) {
                let cacheSize = cacheSizeValue.cgSizeValue
                if cacheSize.width == bounds.size.width {
                    return cacheSize.height
                }
            }
        }
        return UITableViewAutomaticDimension
    }
    
    static func estimatedHeightWithTableView(_ tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat {
        return CGFloat(cellModel.l_floatForKeyPath(self.estimatedHeightKey, otherwise: 44))
    }
    
    var cellModel: LUITableViewCellModel? {
        get {
            
        } set {
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !self.isCellModelChanged && !self.isNeedLayoutCellSubviews { return }
        self.customLayoutSubviews()
        self.isNeedLayoutCellSubviews = false
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if LUITableViewCellBase.useCachedFitedSize {
            if let cellModel = self.cellModel, let cacheSizeValue = cellModel.l_NSValueForKeyPath(LUITableViewCellBase.cachedFitedSizeKey) {
                let cacheSize = cacheSizeValue.cgSizeValue
                if cacheSize.width == size.width {
                    return cacheSize
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectCell selected: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayCellModel cellModel: LUITableViewCellModel) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingCellModel cellModel: LUITableViewCellModel) {
        
    }
    
    // MARK: - override
    func customReloadCellModel() {
        
    }
    
    func customLayoutSubviews() {
        
    }
    
    func customSizeThatFits(size: CGSize) -> CGSize {
        return size
    }
}
