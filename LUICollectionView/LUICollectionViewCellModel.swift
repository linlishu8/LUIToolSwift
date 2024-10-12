//
//  LUICollectionViewCellModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/11.
//

import Foundation

public class LUICollectionViewCellModel: LUICollectionCellModel {
    public var cellClass: AnyClass?
    public var reuseIdentity: String = ""
    public var canDelete: Bool = false//是否可以被删除,默认为NO
    public var canMove: Bool = false//是否可以被移動,默认为 NO
    public var whenMove: ((LUICollectionViewCellModel, LUICollectionViewCellModel) -> Bool)?//移动数据时触发
    public var whenDelete: ((LUICollectionViewCellModel) -> Bool)?//删除数据时触发
    public var whenClick: ((LUICollectionViewCellModel) -> Void)?//点击时被触发
    public var whenSelected: ((LUICollectionViewCellModel, Bool) -> Void)?//被触控事件选中时触发
    
    public weak var collectionViewCell: LUICollectionViewCellBase?
    public var collectionView: UICollectionView?
    public var needReloadCell: Bool?//是否需要更新cell的视图内容
    
    init() {
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
        
    }
    
    public func didSelectedSelf(selected: Bool) {
        
    }
    
    public func didDeleteSelf() {
        
    }
    
    public func sectionModel() -> LUICollectionViewSectionModel {
        return LUICollectionViewSectionModel()
    }
    
    public func collectionModel() -> LUICollectionViewModel {
        return LUICollectionViewModel()
    }
    
    public func displayCell(cell: LUICollectionViewCellBase) {
        
    }
    
    public func refresh() {
        
    }
    
    public func removeCellModelWithAnimated(animated: Bool, completion: ((Bool) -> Void)) {
        
    }
}
