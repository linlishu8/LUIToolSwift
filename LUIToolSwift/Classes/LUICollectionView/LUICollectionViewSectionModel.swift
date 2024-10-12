//
//  LUICollectionViewSectionModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/11.
//

import Foundation

public class LUICollectionViewSectionModel: LUICollectionSectionModel {
    public weak var collectionView: UICollectionView?
    private var supplementaryElementCellClasses: [String : AnyClass] = [:]
    
    public func collectionModel() -> LUICollectionViewModel {
        return LUICollectionViewModel()
    }
    
    public func cellModelAtIndex(index: Int) -> LUICollectionViewCellModel {
        return LUICollectionViewCellModel()
    }
    
    //刷新分组视图
    public func refresh() {
        
    }
    
    //获取指定类型的补充元素的显示视图类
    public func supplementaryElementViewClassForKind(kind: String) -> AnyClass? {
        return self.supplementaryElementCellClasses[kind]
    }
    
    public func displaySupplementaryElementView(view: UICollectionReusableView, kind: String) {
        view.setCollectionSectionModel(sectionModel: self, forKind: kind)
        view.setNeedsLayout()
    }
}
