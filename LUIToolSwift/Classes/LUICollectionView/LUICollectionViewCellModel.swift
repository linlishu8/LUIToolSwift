//
//  LUICollectionViewCellModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/1/11.
//

import Foundation

public class LUICollectionViewCellModel: LUICollectionCellModel {
    public var cellClass: AnyClass = LUICollectionViewCellBase.self
    public lazy var reuseIdentity: String = {
        return NSStringFromClass(self.cellClass)
    }()//用于列表重用单元格视图时的标志符,默认为NSStringFromCGClass(self.class)
    public var canDelete: Bool = false//是否可以被删除,默认为NO
    public var canMove: Bool = false//是否可以被移動,默认为 NO
    public var whenMove: ((LUICollectionViewCellModel, LUICollectionViewCellModel) -> Bool)?//移动数据时触发
    public var whenDelete: ((LUICollectionViewCellModel) -> Bool)?//删除数据时触发
    public var whenClick: ((LUICollectionViewCellModel) -> Void)?//点击时被触发
    public var whenSelected: ((LUICollectionViewCellModel, Bool) -> Void)?//被触控事件选中时触发
    
    public weak var collectionViewCell: LUICollectionViewCellBase?
    public var collectionView: UICollectionView? {
        get {
            guard let collectionView = self.collectionModel().collectionView else { return nil }
            return collectionView
        }
    }
    public var needReloadCell: Bool?//是否需要更新cell的视图内容
    
    public init() {
        super.init()
    }
    
    required init(modelValue: Any?, cellClass: AnyClass, whenClick: ((LUICollectionViewCellModel) -> Void)?) {
        super.init()
        self.modelValue = modelValue
        self.cellClass = cellClass
        self.whenClick = whenClick
    }
    
    static func modelWithValue(modelValue: Any?, cellClass: AnyClass) -> LUICollectionViewCellModel {
        return self.init(modelValue: modelValue, cellClass: cellClass, whenClick: nil)
    }
    
    static func modelWithValue(modelValue: Any?, cellClass: AnyClass, whenClick: ((LUICollectionViewCellModel) -> Void)?) -> LUICollectionViewCellModel {
        return self.init(modelValue: modelValue, cellClass: cellClass, whenClick: whenClick)
    }
    
    public func didClickSelf() {
        self.whenClick?(self)
    }
    
    public func didSelectedSelf(selected: Bool) {
        self.whenSelected?(self, selected)
    }
    
    public func didDeleteSelf() -> Bool {
        return self.whenDelete?(self) ?? false
    }
    
    public func sectionModel() -> LUICollectionViewSectionModel {
        guard let sectionModel = super.sectionModel as? LUICollectionViewSectionModel else { return LUICollectionViewSectionModel() }
        return sectionModel
    }
    
    public func collectionModel() -> LUICollectionViewModel {
        guard let cellModel = super.collectionModel as? LUICollectionViewModel else { return LUICollectionViewModel() }
        return cellModel
    }
    
    public func displayCell(cell: LUICollectionViewCellBase) {
        cell.collectionCellModel = self
        self.collectionViewCell = cell
        cell.setNeedsLayout()
    }
    
    public func refresh() {
        if let indexPath = self.collectionModel().indexPathOfCellModel(self) {
            self.needReloadCell = true
            self.collectionView?.reloadItems(at: [indexPath])
            if self.selected {
                self.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    public func removeCellModelWithAnimated(animated: Bool, completion: @escaping ((Bool) -> Void)) {
        self.collectionModel().removeCellModel(cellModel: self, animated: animated, completion: completion)
    }
}
