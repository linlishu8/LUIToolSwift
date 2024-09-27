//
//  LUICollectionCellModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

public class LUICollectionCellModel:LUICollectionModelObjectBase {
    weak var sectionModel: LUICollectionSectionModel?
    var collectionModel: LUICollectionModel? {
        return sectionModel?.collectionModel
    }
    var userInfo: Any?//自定义的扩展对象
    var selected: Bool = false
    var focused: Bool = false//是否获取焦点
    var indexInSectionModel: Int? {
        return sectionModel?.indexOfCellModel(self)
    }
    var indexPathInModel: IndexPath? {
        let cellIndex = indexInSectionModel
        let sectionIndex = sectionModel?.indexInModel
        if let safeCellIndex = cellIndex, let safeSectionIndex = sectionIndex {
            return IndexPath(row: safeCellIndex, section: safeSectionIndex)
        }
        return nil
    }
    
    //上一个单元格的indexpath
    var indexPathOfPreCell: IndexPath? {
        guard let row = indexInSectionModel else { return nil }
        guard let section = sectionModel?.indexInModel else { return nil }
        if row > 0 {
            return IndexPath(row: row - 1, section: section)
        } else {
            for i in (0...section).reversed() {
                if let sm = collectionModel?.sectionModelAtIndex(i), sm.numberOfCells > 0 {
                    return IndexPath(row: sm.numberOfCells-1, section: i)
                }
            }
            return nil
        }
    }
    
    //下一个单元格的indexpath
    var indexPathOfNextCell: IndexPath? {
        guard let row = indexInSectionModel else { return nil }
        guard let section = sectionModel?.indexInModel else { return nil }
        guard let numberOfCells = sectionModel?.numberOfCells else { return nil }
        if row + 1 < numberOfCells {
            return IndexPath(row: row + 1, section: section)
        } else {
            guard let sectionCount = collectionModel?.numberOfSections else { return nil }
            for i in (section + 1...sectionCount).reversed() {
                if let sm = collectionModel?.sectionModelAtIndex(i), sm.numberOfCells > 0 {
                    return IndexPath(row: 0, section: i)
                }
            }
            return nil
        }
    }
    
    var isFirstInAllCellModels: Bool {
        return indexPathOfPreCell == nil
    }
    
    var isLastInAllCellModels: Bool {
        return indexPathOfNextCell == nil
    }
    
    func compare(_ otherObject: LUICollectionCellModel) -> ComparisonResult {
        var r: ComparisonResult = .orderedSame
        guard let otherSectionModel = otherObject.sectionModel, let safeSectionModel = sectionModel else { return r }
        r = safeSectionModel.compare(otherSectionModel)
        if r == .orderedSame {
            let row1: Int = safeSectionModel.indexOfCellModel(self)
            let row2: Int = otherSectionModel.indexOfCellModel(otherObject)
            if row1 < row2 {
                r = .orderedAscending
            } else if row1 > row2 {
                r = .orderedDescending
            }
        }
        return r
    }
}

