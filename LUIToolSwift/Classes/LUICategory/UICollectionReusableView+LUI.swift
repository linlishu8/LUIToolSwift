//
//  UICollectionReusableView+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/12.
//

import Foundation

public extension UICollectionReusableView {
    /**
     *  设置补充视图所在的分组以及类型
     *
     *  @param sectionModel 分组数据
     *  @param kind         类型
     */
    func setCollectionSectionModel(sectionModel: LUICollectionViewSectionModel, forKind kind: String) {
        
    }
    
    /**
     *  返回视图的尺寸,UICollectionViewDelegateFlowLayout使用
     *
     *  @param collectionView 集合
     *  @param sectionModel   分组
     *  @param kind           类型
     *
     *  @return 尺寸值
     */
    func referenceSizeWithCollectionView(collectionView: UICollectionView, collectionSectionModel sectionModel: LUICollectionViewSectionModel, forKind kind: String) -> CGSize {
        return .zero
    }
    
    
    /// 集合分组视图将要被显示的回调。
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - sectionModel: 分组
    ///   - kind: 类别
    func collectionView(collectionView: UICollectionView, willDisplaySectionModel sectionModel: LUICollectionViewSectionModel, kind: String) {
        
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingSectionModel sectionModel: LUICollectionViewSectionModel, kind: String) {
        
    }
}
