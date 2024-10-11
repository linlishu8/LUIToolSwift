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
    
    public weak var collectionViewCell: LUICollectionViewCellBase?
}
