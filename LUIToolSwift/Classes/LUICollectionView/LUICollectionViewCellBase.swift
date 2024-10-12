//
//  LUICollectionViewCellBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/11.
//

import Foundation

public class LUICollectionViewCellBase: UICollectionViewCell {
    public var collectionCellModel: LUICollectionViewCellModel?
}

public extension LUICollectionViewCellBase {
    /**
     *  返回单元格的尺寸信息
     *
     *  @param collectionView      集合视图
     *  @param collectionCellModel 数据对象
     *
     *  @return 尺寸信息
     */
    static func sizeWithCollectionView(collectionView: UICollectionView, collectionCellModel: LUICollectionViewCellModel) -> CGSize {
        return .zero
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
