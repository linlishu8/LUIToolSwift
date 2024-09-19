//
//  LUICollectionCellModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUICollectionCellModel:LUICollectionModelObjectBase {
    weak var sectionModel: LUICollectionSectionModel?
    var userInfo: Any?
    var selected: Bool = false
    var focused: Bool = false
    
    var collectionModel: LUICollectionModel? {
        return sectionModel?.collectionModel
    }
    
    var indexInSectionModel: Int {
        return sectionModel?.indexOfCellModel(self) ?? NSNotFound
    }
    
    var indexPathInModel: IndexPath? {
        guard let sectionIndex = sectionModel?.indexInModel,
              indexInSectionModel != NSNotFound else {
            return nil
        }
        return IndexPath(row: indexInSectionModel, section: sectionIndex)
    }
    
    var indexPathOfPreCell: IndexPath? {
        guard let section = sectionModel, let collectionModel = collectionModel else { return nil }
        let row = indexInSectionModel
        let sectionIndex = section.indexInModel
        
        if row > 0 {
            return IndexPath(row: row - 1, section: sectionIndex)
        } else {
            for i in stride(from: sectionIndex - 1, through: 0, by: -1) {
                let sm = collectionModel.sectionModel(at: i)
                if sm.numberOfCells > 0 {
                    return IndexPath(row: sm.numberOfCells - 1, section: i)
                }
            }
        }
        return nil
    }
    
    var indexPathOfNextCell: IndexPath? {
        guard let section = sectionModel, let collectionModel = collectionModel else { return nil }
        let row = indexInSectionModel
        let sectionIndex = section.indexInModel
        
        if row + 1 < section.numberOfCells {
            return IndexPath(row: row + 1, section: sectionIndex)
        } else {
            let sectionCount = collectionModel.numberOfSections
            for i in (sectionIndex + 1)..<sectionCount {
                let sm = collectionModel.sectionModel(at: i)
                if sm.numberOfCells > 0 {
                    return IndexPath(row: 0, section: i)
                }
            }
        }
        return nil
    }
    
    var isFirstInAllCellModels: Bool {
        return indexPathOfPreCell == nil
    }
    
    var isLastInAllCellModels: Bool {
        return indexPathOfNextCell == nil
    }
    
    // NSCopying protocol method
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = LUICollectionCellModel()
        copy.userInfo = self.userInfo
        copy.selected = self.selected
        copy.focused = self.focused
        copy.sectionModel = self.sectionModel
        return copy
    }
    
    // Comparing two cell models
    func compare(_ otherObject: LUICollectionCellModel) -> ComparisonResult {
        guard let sectionModel1 = self.sectionModel,
              let sectionModel2 = otherObject.sectionModel else {
            return .orderedSame
        }
        
        let sectionComparison = sectionModel1.compare(sectionModel2)
        if sectionComparison == .orderedSame {
            let row1 = sectionModel1.indexOfCellModel(self)
            let row2 = sectionModel2.indexOfCellModel(otherObject)
            
            if row1 < row2 {
                return .orderedAscending
            } else if row1 > row2 {
                return .orderedDescending
            }
        }
        
        return sectionComparison
    }
}

