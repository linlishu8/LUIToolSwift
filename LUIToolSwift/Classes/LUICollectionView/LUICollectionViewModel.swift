//
//  LUICollectionViewModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/11.
//

import Foundation

public class LUICollectionViewModel: LUICollectionModel, UICollectionViewDataSource, UICollectionViewDelegate {
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
    
    public override func createEmptySectionModel() -> LUICollectionSectionModel {
        return LUICollectionViewSectionModel.init()
    }
    
    public override func addCellModel(_ cellModel: LUICollectionCellModel) {
        let section = self.sectionModels.last as? LUICollectionViewSectionModel ?? self.createEmptySectionModel()
        if section !== self.sectionModels.last {
            self.addSectionModel(section)
        }
        section.addCellModel(cellModel)
    }
    
    //刷新collectionView的backgroundView
    func reloadCollectionViewBackgroundView() {
        // 确保有需要显示的背景视图类或已存在的背景视图
        guard emptyBackgroundViewClass != nil || emptyBackgroundView != nil else { return }
        
        // 根据单元格数量决定是否显示背景视图
        if numberOfCells == 0 {
            if emptyBackgroundView == nil {
                emptyBackgroundView = createEmptyBackgroundView()
            }
            self.collectionView?.backgroundView = emptyBackgroundView
        } else {
            self.collectionView?.backgroundView = nil
        }
        
        self.whenReloadBackgroundView?(self)
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
        guard let collectionView = self.collectionView else { return }
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
    
    public func insertCellModel(cellModel: LUICollectionViewCellModel, indexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)?) {
        cellModel.needReloadCell = true
        self.insertCellModel(cellModel, atIndexPath: indexPath)
        if let collectionView = self.collectionView, animated {
            collectionView.performBatchUpdates {
                if collectionView.numberOfSections == 0 {
                    collectionView.insertSections(IndexSet(integer: 0))
                }
                collectionView .insertItems(at: [indexPath])
            } completion: { finished in
                self.reloadCollectionViewBackgroundView()
                completion?(finished)
            }
        } else {
            self.reloadCollectionViewData()
            completion?(true)
        }
    }
    
    public func insertCellModels(cellModels: [LUICollectionViewCellModel], afterIndexPath indexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)?) {
        for cellModel in cellModels {
            cellModel.needReloadCell = true
        }
        self.insertCellModels(cellModels, afterIndexPath: indexPath)
        if let collectionView = self.collectionView, animated {
            collectionView.performBatchUpdates {
                if collectionView.numberOfSections == 0 {
                    collectionView.insertSections(IndexSet(integer: 0))
                }
                var indexPaths: [IndexPath] = []
                for i in 0..<cellModels.count {
                    let ip = IndexPath(item: indexPath.item + i + 1, section: indexPath.section)
                    indexPaths.append(ip)
                }
                collectionView.insertItems(at: indexPaths)
            } completion: { finished in
                self.reloadCollectionViewBackgroundView()
                completion?(true)
            }
        } else {
            self.reloadCollectionViewData()
            completion?(true)
        }
    }
    
    public func insertCellModels(cellModels: [LUICollectionViewCellModel], beforeIndexPath indexPath: IndexPath, animated: Bool, completion: ((Bool) -> Void)?) {
        for cellModel in cellModels {
            cellModel.needReloadCell = true
        }
        self.insertCellModels(cellModels, beforeIndexPath: indexPath)
        if let collectionView = self.collectionView, animated {
            collectionView.performBatchUpdates {
                if collectionView.numberOfSections == 0 {
                    collectionView.insertSections(IndexSet(integer: 0))
                }
                var indexPaths: [IndexPath] = []
                for i in 0..<cellModels.count {
                    let ip = IndexPath(item: indexPath.item + i, section: indexPath.section)
                    indexPaths.append(ip)
                }
                collectionView.insertItems(at: indexPaths)
            } completion: { finished in
                self.reloadCollectionViewBackgroundView()
                completion?(true)
            }
        } else {
            self.reloadCollectionViewData()
            completion?(true)
        }
    }
    
    public func removeCellModel(cellModel: LUICollectionViewCellModel, animated: Bool, completion: ((Bool) -> Void)?) {
        if let indexPath = self.indexPathOfCellModel(cellModel) {
            let sm = self.sectionModelAtIndex(index: indexPath.section)
            self.removeCellModelAtIndexPath(indexPath)
            if sm.numberOfCells == 0 {
                self.removeCellModelAtIndexPath(indexPath)
            }
            if let collectionView = self.collectionView, animated {
                collectionView.performBatchUpdates {
                    if sm.numberOfCells == 0 {
                        collectionView.deleteSections(IndexSet(integer: indexPath.section))
                    }
                    collectionView.deleteItems(at: [indexPath])
                } completion: { finished in
                    self.reloadCollectionViewBackgroundView()
                    completion?(true)
                }
            } else {
                self.reloadCollectionViewData()
                completion?(true)
            }
        }
    }
    
    public func removeCellModels(cellModels: [LUICollectionViewCellModel], animated: Bool, completion: ((Bool) -> Void)?) {
        let indexPaths: [IndexPath] = self.indexPathsOfCellModels(cellModels)
        if indexPaths.count > 0 {
            var deletedSectionIndexs: IndexSet = IndexSet()
            for cellModel in cellModels {
                let sm = cellModel.sectionModel()
                sm.removeCellModel(cellModel: cellModel)
                if sm.numberOfCells == 0, let idx = sm.indexInModel {
                    deletedSectionIndexs.insert(idx)
                    self.removeSectionModel(sm)
                }
            }
            
            if let collectionView = self.collectionView, animated {
                collectionView.performBatchUpdates {
                    if deletedSectionIndexs.count != 0 {
                        collectionView.deleteSections(deletedSectionIndexs)
                    }
                    collectionView.deleteItems(at: indexPaths)
                } completion: { finished in
                    self.reloadCollectionViewBackgroundView()
                    completion?(true)
                }
            } else {
                self.reloadCollectionViewData()
                completion?(true)
            }
        }
    }
    
    public func moveCellModelAtIndexPath(sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath, inCollectionViewBatchUpdatesBlock isBatchUpdates: Bool) {
        guard sourceIndexPath != destinationIndexPath else { return }
        var addedIndexPathes: [IndexPath] = []
        var removeIndexPathes: [IndexPath] = []
        let sourceCellModel = self.cellModelAtIndexPath(indexpath: sourceIndexPath)
        self.removeCellModelAtIndexPath(sourceIndexPath)
        self.insertCellModel(sourceCellModel, atIndexPath: destinationIndexPath)
        addedIndexPathes.append(destinationIndexPath)
        removeIndexPathes.append(sourceIndexPath)
        if isBatchUpdates, let collectionView = self.collectionView {
            collectionView.deleteItems(at: removeIndexPathes)
            collectionView.insertItems(at: addedIndexPathes)
        }
    }
    
    //动画添加分组
    public func insertSectionModel(sectionModel: LUICollectionViewSectionModel, atIndex index: Int, animated: Bool, completion: ((Bool) -> Void)?) {
        self.insertSectionModel(sectionModel, atIndex: index)
        for cellModel in sectionModel.cellModels {
            if let model = cellModel as? LUICollectionViewCellModel {
                model.needReloadCell = true
            }
        }
        let set = IndexSet(integer: index)
        let count = sectionModel.numberOfCells
        var indexPaths: [IndexPath] = []
        for i in 0..<count {
            indexPaths.append(IndexPath(item: i, section: index))
        }
        if let collectionView = self.collectionView, animated {
            collectionView.performBatchUpdates {
                collectionView.insertSections(set)
                collectionView.insertItems(at: indexPaths)
            } completion: { finished in
                self.reloadCollectionViewBackgroundView()
                completion?(true)
            }
        } else {
            self.reloadCollectionViewData()
            completion?(true)
        }
    }
    
    //动画移除分组
    public func removeSectionModel(sectionModel: LUICollectionViewSectionModel, animated: Bool, completion: ((Bool) -> Void)?) {
        guard let index = sectionModel.indexInModel else { return }
        let set = IndexSet(integer: index)
        self.removeSectionModel(sectionModel)
        if let collectionView = self.collectionView, animated {
            collectionView.performBatchUpdates {
                collectionView.deleteSections(set)
            } completion: { finished in
                self.reloadCollectionViewBackgroundView()
                completion?(true)
            }
        } else {
            self.reloadCollectionViewData()
            completion?(true)
        }
    }
    
    private func createEmptyBackgroundView() -> UIView {
        if let c = self.emptyBackgroundViewClass, let view = c.init() as? UIView {
            return view
        }
        return UIView()
    }
    
    //MARK: UICollectionViewDataSource, UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView = collectionView
        let sm = self.sectionModelAtIndex(index: section)
        return sm.numberOfCells
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cm = self.cellModelAtIndexPath(indexpath: indexPath)
        let cellClass: AnyClass = cm.cellClass
        let reuseIdentity = self.reuseCell ? cm.reuseIdentity : "\(cm.reuseIdentity)_\(Unmanaged.passUnretained(cm).toOpaque())"
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentity)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentity, for: indexPath)
        if let disCell = cell as? LUICollectionViewCellBase {
            cm.displayCell(cell: disCell)
        }
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sm = self.sectionModelAtIndex(index: indexPath.section)
        guard let aClass = sm.supplementaryElementViewClassForKind(kind: kind) else { return UICollectionReusableView.init() }
        collectionView.register(aClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: aClass))
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: aClass), for: indexPath)
        sm.displaySupplementaryElementView(view: view, kind: kind)
        return view
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        var isMove = false
        let cellModel = self.cellModelAtIndexPath(indexpath: indexPath)
        isMove = cellModel.canMove
        return isMove
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let srcTablecellModel = self.cellModelAtIndexPath(indexpath: sourceIndexPath)
        let dstTablecellModel = self.cellModelAtIndexPath(indexpath: destinationIndexPath)
        var handed = false
        if let handler = srcTablecellModel.whenMove ?? dstTablecellModel.whenMove {
            handler(srcTablecellModel, dstTablecellModel)
            handed = true
        }
        if self.forwardDataSource?.collectionView?(collectionView, moveItemAt: destinationIndexPath, to: destinationIndexPath) != nil {
            handed = true
        }
        if !handed {
            self.moveCellModelAtIndexPath(sourceIndexPath, toIndexPath: destinationIndexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LUICollectionViewCellBase {
            cell.collectionView(collectionView: collectionView, didSelectCell: true)
        }
        let cm = self.cellModelAtIndexPath(indexpath: indexPath)
        self.selectCellModel(cm)
        cm.whenSelected?(cm, true)
        cm.whenClick?(cm)
        self.forwardDelegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LUICollectionViewCellBase {
            cell.collectionView(collectionView: collectionView, didSelectCell: false)
        }
        let cm = self.cellModelAtIndexPath(indexpath: indexPath)
        self.deselectCellModel(cm)
        cm.whenSelected?(cm, false)
        if collectionView.allowsMultipleSelection {
            cm.whenClick?(cm)
        }
        self.forwardDelegate?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LUICollectionViewCellBase {
            let cm = self.cellModelAtIndexPath(indexpath: indexPath)
            cell.collectionView(collectionView: collectionView, willDisplayCellModel: cm)
        }
        self.forwardDelegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        let sm = self.sectionModelAtIndex(index: indexPath.section)
        view.collectionView(collectionView: collectionView, willDisplaySectionModel: sm, kind: elementKind)
        self.forwardDelegate?.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LUICollectionViewCellBase {
            let cm = self.cellModelAtIndexPath(indexpath: indexPath)
            cell.collectionView(collectionView: collectionView, didEndDisplayingCellModel: cm)
        }
        self.forwardDelegate?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        let sm = self.sectionModelAtIndex(index: indexPath.section)
        view.collectionView(collectionView: collectionView, didEndDisplayingSectionModel: sm, kind: elementKind)
        self.forwardDelegate?.collectionView?(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
    }
}

extension LUICollectionViewModel: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        var size: CGSize = .zero
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            if bounds.size == .zero {
                size = .zero
            } else {
                size = flowLayout.itemSize
            }
        }
        
        if let delegate = self.forwardDelegate as? UICollectionViewDelegateFlowLayout {
            if delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
                size = delegate.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? .zero
            }
        } else {
            let cm = self.cellModelAtIndexPath(indexpath: indexPath)
            if let cellClass = cm.cellClass as? LUICollectionViewCellBase.Type {
                size = cellClass.sizeWithCollectionView(collectionView: collectionView, collectionCellModel: cm)
            }
        }
        return size
    }

//    @available(iOS 6.0, *)
//    optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
//
//    @available(iOS 6.0, *)
//    optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
//
//    @available(iOS 6.0, *)
//    optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
//
//    @available(iOS 6.0, *)
//    optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
//
//    @available(iOS 6.0, *)
//    optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
}

extension LUICollectionViewModel: LUICollectionViewDelegatePageFlowLayout {
    public func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, itemSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return .zero
    }
    public func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return .zero
    }
    public func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    public func pagingBoundsPositionForCollectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout) -> CGFloat {
        return 0
    }
    public func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, didScrollToPagingCell indexPathAtPagingCell: IndexPath) {
        
    }
}
