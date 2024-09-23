//
//  LUICollectionSectionModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUICollectionSectionModel: LUICollectionModelObjectBase {
    //含有的单元格
    var cellModels: [LUICollectionCellModel] = [] {
        didSet {
            for cellModel in cellModels {
                configCellModelAfterAdding(cellModel)
            }
        }
    }
    var userInfo: Any?
    var numberOfCells: Int {
        return cellModels.count
    }
    var indexInModel: Int {
        //todo
        return 0
    }
    var mutableCellModels: [LUICollectionCellModel] = []
    weak var collectionModel: LUICollectionModel?
    
    func addCellModel(_ cellModel: LUICollectionCellModel) {
        cellModel.sectionModel = self
        cellModels.append(cellModel)
    }
    
    func addCellModels(_ cellModels: [LUICollectionCellModel]) {
        guard cellModels.count > 0 else { return }
        for LUICollectionCellModel in cellModels {
            addCellModel(LUICollectionCellModel)
        }
    }
    
    func insertCellModel(_ cellModel: LUICollectionCellModel, atIndex index: Int) {
        cellModels.insert(cellModel, at: index)
        configCellModelAfterAdding(cellModel)
    }
    
    func insertCellModels(_ cellModels: [LUICollectionCellModel], afterIndex index: Int) {
        guard cellModels.count > 0 else { return }
        var currentIndex = index + 1
        for cellModel in cellModels {
            mutableCellModels.insert(cellModel, at: currentIndex)
            configCellModelAfterAdding(cellModel)
            currentIndex += 1
        }
    }
    func insertCellModels(_ cellModels: [LUICollectionCellModel], beforeIndex index: Int) {
        insertCellModels(cellModels, afterIndex: index - 1)
    }
    func insertCellModelsToTop(_ cellModels: [LUICollectionCellModel]) {
        insertCellModels(cellModels, beforeIndex: 0)
    }
    func insertCellModelsToBottom(_ cellModels: [LUICollectionCellModel]) {
        insertCellModels(cellModels, afterIndex: numberOfCells - 1)
    }
    
    func configCellModelAfterAdding(_ cellModel: LUICollectionCellModel) {
        cellModel.sectionModel = self
    }
    
    func configCellModelAfterRemoving(_ cellModel: LUICollectionCellModel) {
        cellModel.sectionModel = nil
    }
    
    func removeCellModel(cellModel: LUICollectionCellModel) {
        configCellModelAfterRemoving(cellModel)
        if let index = self.mutableCellModels.firstIndex(where: { $0 === cellModel }) {
            self.mutableCellModels.remove(at: index)
        }
    }
    
    func removeCellModelAtIndex(_ index: Int) {
        guard index >= 0 && index < mutableCellModels.count else { return }
        let cellModel = mutableCellModels[index]
        configCellModelAfterRemoving(cellModel)
        mutableCellModels.remove(at: index)
    }
    
    func removeCellModelsAtIndexes(indexes: IndexSet) {
        guard indexes.count > 0 else { return }
        let cellModels = indexes.compactMap { mutableCellModels.indices.contains($0) ? mutableCellModels[$0] : nil }
        for cellModel in cellModels {
            configCellModelAfterRemoving(cellModel)
        }
        for index in indexes.reversed() {
            if mutableCellModels.indices.contains(index) {
                mutableCellModels.remove(at: index)
            }
        }
    }
    
    func removeAllCellModels() {
        for LUICollectionCellModel in mutableCellModels {
            configCellModelAfterRemoving(LUICollectionCellModel)
        }
        mutableCellModels.removeAll()
    }
    
    func cellModelAtIndex(_ index: Int) -> LUICollectionCellModel? {
        guard index >= 0 && index < cellModels.count else { return nil }
        return cellModels[index]
    }
    
    func indexOfCellModel(_ cellModel: LUICollectionCellModel) -> Int? {
        return cellModels.firstIndex(of: cellModel)
    }
    
    //返回指定单元格数据对应的索引
    func indexOfCellModel(_ cellModel: LUICollectionCellModel) -> Int {
        if let index = mutableCellModels.firstIndex(where: { $0 === cellModel }) {
            return index
        } else {
            return -1
        }
    }
    
    func indexPathForSelectedCellModel() -> IndexPath? {
        //todo
        return nil
    }
    
    func cellModelForSelectedCellModel() -> LUICollectionCellModel? {
        for cellModel in cellModels {
            if cellModel.selected {
                return cellModel
            }
        }
        return nil
    }
    
    func indexPathsForSelectedCellModels() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        if let index = collectionModel?.indexOfSectionModel(self) {
            for (idx, cellModel) in cellModels.enumerated() {
                if cellModel.selected {
                    indexPaths.append(IndexPath(row: idx, section: index))
                }
            }
        }
        return indexPaths
    }
    
    func cellModelsForSelectedCellModels() -> [LUICollectionCellModel] {
        var selectedCellModels: [LUICollectionCellModel] = []
        for cellModel in cellModels {
            if cellModel.selected {
                selectedCellModels.append(cellModel)
            }
        }
        return selectedCellModels
    }
    
    func compare(_ otherObject: LUICollectionSectionModel) -> ComparisonResult {
        var compareResult: ComparisonResult = .orderedSame
        guard let section1 = collectionModel?.indexOfSectionModel(self) else { return compareResult }
        guard let section2 = otherObject.collectionModel?.indexOfSectionModel(otherObject) else { return compareResult }
        if section1 < section2 {
            compareResult = .orderedAscending
        } else if section1 > section2 {
            compareResult = .orderedDescending
        }
        return compareResult
    }
}

extension LUICollectionSectionModel {
    func indexForFocusedCellModel() -> Int? {
        for (i, cm) in cellModels.enumerated() {
            if cm.focused {
                return i
            }
        }
        return nil
    }
    
    func cellModelForFocusedCellModel() -> LUICollectionCellModel? {
        if let index = indexForFocusedCellModel() {
            return cellModels[index]
        }
        return nil
    }
}
