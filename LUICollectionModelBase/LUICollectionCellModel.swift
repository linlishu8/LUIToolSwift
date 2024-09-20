//
//  LUICollectionCellModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUICollectionCellModel:LUICollectionModelObjectBase {
    weak var sectionModel: LUICollectionSectionModel?
    var collectionModel: LUICollectionModel?
    var userInfo: Any?//自定义的扩展对象
    var selected: Bool = false
    var focused: Bool = false//是否获取焦点
    var indexInSectionModel: Int?
    var indexPathInModel: NSIndexPath?
    
    //上一个单元格的indexpath
    var indexPathOfPreCell: NSIndexPath? {
        let row = sectionModel?.indexOfCellModel(self)
        let section = sectionModel
    }
    var indexPathOfNextCell: NSIndexPath?//下一个单元格的indexpath
    
    var isFirstInAllCellModels: Bool {
        return false
    }
    
    var isLastInAllCellModels: Bool {
        return false
    }
    
}

