//
//  LUICollectionViewCellBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/11.
//

import Foundation

open class LUICollectionViewCellBase: UICollectionViewCell {
    private static var instances: [String: Any] = [:]
    private static let queue = DispatchQueue(label: "com.lui.singleton")
    
    public class func sharedInstance<T: LUICollectionViewCellBase>() -> T {
        let key = String(describing: T.self)
        return queue.sync {
            if let instance = instances[key] as? T {
                return instance
            }
            let instance = T.init()
            instances[key] = instance
            return instance
        }
    }
    
    static var cachedFitedSizeKey: String {
        return "\(self)_cachedFitedSize"
    }
    
    public var collectionCellModel: LUICollectionViewCellModel? {
        didSet {
            self.isCellModelChanged = collectionCellModel?.needReloadCell ?? false || oldValue !== collectionCellModel || collectionCellModel?.collectionViewCell !== self
            if LUICollectionViewCellBase.useCachedFitedSize && collectionCellModel?.needReloadCell ?? false {
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
    static var useCachedFitedSize: Bool {
        return true
    } //是否缓存sizeThatFits:的结果，默认为YES
    private var isNeedLayoutCellSubviews: Bool = false //是否要重新布局视图
    
    private var isSharedInstance: Bool {
        return self === LUICollectionViewCellBase.sharedInstance()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !self.isCellModelChanged && !self.isNeedLayoutCellSubviews && !isSharedInstance {
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
    static func sizeWithCollectionView(collectionView: UICollectionView, collectionCellModel: LUICollectionViewCellModel) -> CGSize {
        if useCachedFitedSize {
            if let cacheSizeValue = collectionCellModel[LUICollectionViewCellBase.cachedFitedSizeKey] as? NSValue {
                let cacheSize = cacheSizeValue.cgSizeValue
                return cacheSize
            }
        }
        let sizeFits = dynamicSizeWithCollectionView(collectionView: collectionView, collectionCellModel: collectionCellModel, cell: self.sharedInstance()) { collectionView, cellModel, cell in
            let bounds = cell.bounds
            return cell .sizeThatFits(bounds.size)
        }
        if useCachedFitedSize {
            collectionCellModel[LUICollectionViewCellBase.cachedFitedSizeKey] = [NSValue (cgSize: sizeFits)]
        }
        
        return sizeFits
    }
    
    static func dynamicSizeWithCollectionView(collectionView: UICollectionView, collectionCellModel: LUICollectionViewCellModel, cell: LUICollectionViewCellBase, calBlock: (UICollectionView, LUICollectionViewCellModel, LUICollectionViewCellBase) -> CGSize) -> CGSize {
        var size: CGSize = .zero
        var bounds = collectionView.l_contentBounds
        let originBounds = cell.bounds
        var sectionInsets: UIEdgeInsets = .zero
        if let flowlayout = collectionView.l_collectionViewFlowLayout {
            let sectionIndex = collectionCellModel.indexPathInModel?.section ?? 0
            sectionInsets = flowlayout.l_insetForSectionAtIndex(sectionIndex)
            bounds = UIEdgeInsetsInsetRect(bounds, sectionInsets)
        }
        bounds.origin = .zero
        cell.bounds = bounds
        cell.collectionCellModel = collectionCellModel
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        size = calBlock(collectionView, collectionCellModel, cell)
        cell.collectionCellModel = nil
        cell.bounds = originBounds
        if let flowlayout = collectionView.l_collectionViewFlowLayout {
            if flowlayout.scrollDirection == .vertical {
                size.width = min(size.width, bounds.size.width)
            } else {
                size.height = min(size.height, bounds.size.height)
            }
        }
        
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        
        return size
    }
    
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
