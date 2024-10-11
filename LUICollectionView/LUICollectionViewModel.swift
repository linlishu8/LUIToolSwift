//
//  LUICollectionViewModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/11.
//

import Foundation

public class LUICollectionViewModel: LUICollectionModel, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    open weak var forwardDataSource: UICollectionViewDataSource?
    open weak var forwardDelegate: UICollectionViewDelegate?
    public var editting: Bool?//是否处在编辑状态中
    public weak var collectionView: UICollectionView?//弱引用外部的collectionView
    
    public var emptyBackgroundViewClass: AnyClass?//没有单元格数据时的背景视图类
    public var emptyBackgroundView: UIView?
    var whenReloadBackgroundView: ((LUICollectionViewModel) -> Void)?
    var reuseCell: Bool?//是否重用cell，默认为YES
    
    init(collectionView: UICollectionView) {
        super.init()
    }
    
    //刷新collectionView的backgroundView
    public func reloadCollectionViewBackgroundView() {
        
    }
    
    public func cellModelAtIndexPath(indexpath: IndexPath) -> LUICollectionViewCellModel {
        return LUICollectionViewCellModel()
    }
    
    public func sectionModelAtIndex(index: Int) -> LUICollectionViewSectionModel {
        return LUICollectionViewSectionModel()
    }
    
    public override func cellModelForSelectedCellModel() -> LUICollectionViewCellModel {
        return LUICollectionViewCellModel()
    }
    
    public func setCollectionViewDataSourceAndDelegate(collectionView: UICollectionView) {
        
    }
    
    public func reloadCollectionViewData() {
        
    }
    
    public func addCellModel(cellModel: LUICollectionViewCellModel, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    public func insertCellModel(cellModel: LUICollectionViewCellModel, indexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    public func insertCellModels(cellModels: [LUICollectionViewCellModel], afterIndexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
}
