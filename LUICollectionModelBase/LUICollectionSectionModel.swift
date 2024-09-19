//
//  LUICollectionSectionModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUICollectionSectionModel: LUICollectionModelObjectBase {
    var cellModels: [LUICollectionCellModel] = []
    var userInfo: Any? // 自定义的扩展对象
    weak var collectionModel: LUICollectionModel? // 弱引用外层的数据
    
    var numberOfCells: Int {
        return cellModels.count
    }
    
    var indexInModel: Int {
        return collectionModel?.index(of: self) ?? NSNotFound
    }
    
    var mutableCellModels: [LUICollectionCellModel] {
        return cellModels
    }
    
    // MARK: - NSCopying
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = LUICollectionSectionModel()
        copy.userInfo = self.userInfo
        copy.cellModels = self.cellModels.map { $0.copy() as! LUICollectionCellModel }
        for cm in self.cellModels {
            copy.configCellModelAfterAdding(cm)
        }
        return copy
    }
    
    // 添加单元格
    func addCellModel(_ cellModel: LUICollectionCellModel) {
        cellModels.append(cellModel)
        configCellModelAfterAdding(cellModel)
    }
    
    func addCellModels(_ cellModels: [LUICollectionCellModel]) {
        for cellModel in cellModels {
            addCellModel(cellModel)
        }
    }
    
    // 插入单元格
    func insertCellModel(_ cellModel: LUICollectionCellModel, at index: Int) {
        cellModels.insert(cellModel, at: index)
        configCellModelAfterAdding(cellModel)
    }
    
    func insertCellModels(_ cellModels: [LUICollectionCellModel], afterIndex index: Int) {
        guard !cellModels.isEmpty else { return }
        var newIndex = index + 1
        for cellModel in cellModels {
            insertCellModel(cellModel, at: newIndex)
            newIndex += 1
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
    
    // 配置单元格
    func configCellModelAfterAdding(_ cellModel: LUICollectionCellModel) {
        cellModel.sectionModel = self
    }
    
    func configCellModelAfterRemoving(_ cellModel: LUICollectionCellModel) {
        cellModel.sectionModel = nil
    }
    
    // 删除单元格
    func removeCellModel(_ cellModel: LUICollectionCellModel) {
        configCellModelAfterRemoving(cellModel)
        if let index = cellModels.firstIndex(of: cellModel) {
            cellModels.remove(at: index)
        }
    }
    
    func removeCellModel(at index: Int) {
        guard index >= 0 && index < cellModels.count else { return }
        let cellModel = cellModels[index]
        configCellModelAfterRemoving(cellModel)
        cellModels.remove(at: index)
    }
    
    func removeCellModels(at indexes: IndexSet) {
        for index in indexes.reversed() {
            removeCellModel(at: index)
        }
    }
    
    func removeAllCellModels() {
        for cellModel in cellModels {
            configCellModelAfterRemoving(cellModel)
        }
        cellModels.removeAll()
    }
    
    // 返回单元格或索引
    func cellModel(at index: Int) -> LUICollectionCellModel? {
        guard index >= 0 && index < cellModels.count else { return nil }
        return cellModels[index]
    }
    
    func indexOfCellModel(_ cellModel: LUICollectionCellModel) -> Int {
        return cellModels.firstIndex(of: cellModel) ?? NSNotFound
    }
    
    // 返回选中单元格相关数据
    func indexPathForSelectedCellModel() -> IndexPath? {
        for (i, cm) in cellModels.enumerated() {
            if cm.selected {
                return IndexPath(row: i, section: indexInModel)
            }
        }
        return nil
    }
    
    func cellModelForSelectedCellModel() -> LUICollectionCellModel? {
        return cellModels.first { $0.selected }
    }
    
    func indexPathsForSelectedCellModels() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        let sectionIndex = indexInModel
        for (i, cm) in cellModels.enumerated() {
            if cm.selected {
                indexPaths.append(IndexPath(row: i, section: sectionIndex))
            }
        }
        return indexPaths
    }
    
    func cellModelsForSelectedCellModels() -> [LUICollectionCellModel] {
        return cellModels.filter { $0.selected }
    }
    
    // 比较
    func compare(_ otherObject: LUICollectionSectionModel) -> ComparisonResult {
        guard let section1 = collectionModel?.index(of: self),
              let section2 = otherObject.collectionModel?.index(of: otherObject) else {
            return .orderedSame
        }
        
        if section1 < section2 {
            return .orderedAscending
        } else if section1 > section2 {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
}
