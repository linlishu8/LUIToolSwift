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
    public weak var collectionView: UICollectionView?//弱引用外部的collectionView
    
    open weak var forwardDataSource: UICollectionViewDataSource?
    open weak var forwardDelegate: UICollectionViewDelegate? {
        didSet {
            if let collectionView = self.collectionView, collectionView.delegate === self {
                collectionView.delegate = nil
                collectionView.delegate = self // 重新赋值一次，使得scrollView重新判断scrollViewDidScroll:方法的有无
            }
        }
    }
    public var editting: Bool?//是否处在编辑状态中
    
    public var emptyBackgroundViewClass: AnyClass?//没有单元格数据时的背景视图类
    public var emptyBackgroundView: UIView?
    var whenReloadBackgroundView: ((LUICollectionViewModel) -> Void)?
    var reuseCell: Bool = true//是否重用cell，默认为YES
    
    init() {
        super.init()
    }
    
    init(collectionView: UICollectionView) {
        super.init()
        self.setCollectionViewDataSourceAndDelegate(collectionView: collectionView)
    }
    
    //刷新collectionView的backgroundView
    public func reloadCollectionViewBackgroundView() {
        if let emptyBackgroundViewClass = self.emptyBackgroundViewClass, let emptyBackgroundView = self.emptyBackgroundView {
            if self.numberOfCells == 0 {
                self.collectionView?.backgroundView = self.emptyBackgroundView ?? self.createEmptyBackgroundView()
            } else {
                self.collectionView?.backgroundView = nil
            }
            self.whenReloadBackgroundView?(self)
        }
    }
    
    public func cellModelAtIndexPath(indexpath: IndexPath) -> LUICollectionViewCellModel {
        if let cellModel = super.cellModelAtIndexPath(indexpath) as? LUICollectionViewCellModel {
            return cellModel
        }
        return LUICollectionViewCellModel()
    }
    
    public func sectionModelAtIndex(index: Int) -> LUICollectionViewSectionModel {
        if let sectionModel = super.sectionModelAtIndex(index) as? LUICollectionViewSectionModel {
            return sectionModel
        }
        return LUICollectionViewSectionModel()
    }
    
    public override func cellModelForSelectedCellModel() -> LUICollectionViewCellModel {
        if let cellModel = super.cellModelForSelectedCellModel() as? LUICollectionViewCellModel {
            return cellModel
        }
        return LUICollectionViewCellModel()
    }
    
    public func setCollectionViewDataSourceAndDelegate(collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    public func reloadCollectionViewData() {
        if let collectionView = self.collectionView {
            collectionView.reloadData()
            for sectionModel in self.sectionModels {
                for cellModel in sectionModel.cellModels {
                    if let model = cellModel as? LUICollectionViewCellModel {
                        model.needReloadCell = true
                    }
                }
            }
            if self.allowsSelection {
                if self.allowsMultipleSelection {
                    let indexPaths = self.indexPathsForSelectedCellModels()
                    for indexPath in indexPaths {
                        self.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    }
                } else {
                    let indexPath = self.indexPathForSelectedCellModel()
                    self.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
        self.reloadCollectionViewBackgroundView()
    }
    
    public func addCellModel(cellModel: LUICollectionViewCellModel, animated: Bool, completion: ((Bool) -> Void)?) {
        cellModel.needReloadCell = true
        self.addCellModel(cellModel)
        if let collectionView = self.collectionView, animated {
            if let sm = self.sectionModels.last {
                let indexPath = IndexPath(item: sm.numberOfCells - 1, section: self.sectionModels.count - 1)
                collectionView.performBatchUpdates {
                    if collectionView.numberOfSections == 0 {
                        collectionView.insertSections(IndexSet(integer: 0))
                    }
                    collectionView .insertItems(at: [indexPath])
                } completion: { finished in
                    self.reloadCollectionViewBackgroundView()
                    completion?(finished)
                }

            }
            
        } else {
            self.reloadCollectionViewData()
            completion?(true)
        }
    }
    
    public func insertCellModel(cellModel: LUICollectionViewCellModel, indexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    public func insertCellModels(cellModels: [LUICollectionViewCellModel], afterIndexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    public func insertCellModels(cellModels: [LUICollectionViewCellModel], beforeIndexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    public func removeCellModel(cellModel: LUICollectionViewCellModel, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    public func removeCellModels(cellModel: [LUICollectionViewCellModel], animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    public func moveCellModelAtIndexPath(sourceIndexPath: IndexPath, toIndexPath: IndexPath, isBatchUpdates: Bool) {
        
    }
    
    //动画添加分组
    public func insertSectionModel(sectionModel: LUICollectionViewSectionModel, atIndex: Int, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    //动画移除分组
    public func removeSectionModel(sectionModel: LUICollectionViewSectionModel, animated: Bool, completion: ((Bool) -> Void)) {
        
    }
    
    private func createEmptyBackgroundView() -> UIView {
        if let c = self.emptyBackgroundViewClass, let view = c.init() as? UIView {
            return view
        }
        return UIView()
    }
}
