//
//  LUICollectionViewCellBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/11.
//

import Foundation

open class LUICollectionViewCellBase: UICollectionViewCell {
    
    static var cachedFitedSizeKey: String {
        return "\(self)_cachedFitedSize"
    }
    
    public var collectionCellModel: LUICollectionViewCellModel? {
        didSet {
            self.isCellModelChanged = collectionCellModel?.needReloadCell ?? false || oldValue !== collectionCellModel || collectionCellModel?.collectionViewCell !== self
            if self.useCachedFitedSize && collectionCellModel?.needReloadCell ?? false {
                collectionCellModel?[LUICollectionViewCellBase.cachedFitedSizeKey] = nil
            }
            
            collectionCellModel?.needReloadCell = false
            if !self.isCellModelChanged {
                return
            }
            self.isNeedLayoutCellSubviews = true
            self.customReloadCellModel()
        }
    }
    public var isCellModelChanged: Bool = false //cellmodel是否有变化
    public let useCachedFitedSize: Bool = true //是否缓存sizeThatFits:的结果，默认为YES
    private var isNeedLayoutCellSubviews: Bool = false //是否要重新布局视图
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !self.isCellModelChanged && !self.isNeedLayoutCellSubviews {
            return
        }
        self.customLayoutSubviews()
        self.isNeedLayoutCellSubviews = false
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.customSizeThatFits(size: size)
    }
    
    open func customReloadCellModel() {
        
    }
    
    open func customLayoutSubviews() {
        
    }
    
    open func customSizeThatFits(size: CGSize) -> CGSize {
        return .zero
    }
}

public extension LUICollectionViewCellBase {
    
    //选中/取消选中单元格
    func collectionView(collectionView: UICollectionView, didSelectCell selected: Bool) {
        
    }
    
    //cell要被显示前的回调。可在此处进行异步加载图片等资源。
    func collectionView(collectionView: UICollectionView, willDisplayCellModel cellModel: LUICollectionViewCellModel) {
        
    }
    
    //cell完成显示的回调。该方法的回调时机不确定。
    func collectionView(collectionView: UICollectionView, didEndDisplayingCellModel cellModel: LUICollectionViewCellModel) {
        
    }
}
