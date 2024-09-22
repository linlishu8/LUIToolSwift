//
//  LUICollectionModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUICollectionModel: LUICollectionModelObjectBase {
    //分组
    var sectionModels: [LUICollectionSectionModel] = [] {
        didSet {
            for sectionModel in sectionModels {
                sectionModel.collectionModel = self
            }
        }
    }
    
    //返回所有的单元格数据
    var allCellModels: [LUICollectionCellModel] {
        var cells: [LUICollectionCellModel] = []
        for section in sectionModels {
            cells.append(contentsOf: section.cellModels)
        }
        return cells
    }
    var userInfo: Any?//自定義的擴展對象
    
    //分组数量
    var numberOfSections: Int {
        return sectionModels.count
    }
    
    //所有单元格的数量
    var numberOfCells: Int {
        var i = 0
        for LUICollectionSectionModel in sectionModels {
            i += LUICollectionSectionModel.cellModels.count
        }
        return i
    }
    
    var allowsSelection = true
    var allowsMultipleSelection = false
    var allowsFocus = true
    
    func indexPathOfLastCellModel() -> IndexPath? {
        let sections = numberOfSections
        for i in (0..<sections).reversed() {
            if let sectionModel = sectionModelAtIndex(i), sectionModel.numberOfCells > 0 {
                return IndexPath(item: sectionModel.numberOfCells - 1, section: i)
            }
        }
        return nil
    }
    
    func sectionModelAtIndex(_ index: Int) -> LUICollectionSectionModel? {
        guard index >= 0 && index < sectionModels.count else { return nil }
        return self.sectionModels[index]
    }
    
    func createEmptySectionModel() -> LUICollectionSectionModel {
        return LUICollectionSectionModel()
    }
    
    func addCellModel(_ cellModel: LUICollectionCellModel) {
        guard let section = sectionModels.last else {
            let newSection = createEmptySectionModel()
            addSectionModel(newSection)
            newSection.addCellModel(cellModel)
            return
        }
        section.addCellModel(cellModel)
    }
    
    func addCellModelToFirst(_ cellModel: LUICollectionCellModel) {
        guard let section = sectionModels.last else {
            let newSection = createEmptySectionModel()
            addSectionModel(newSection)
            newSection.addCellModel(cellModel)
            return
        }
        section.insertCellModel(cellModel, atIndex: 0)
    }
    
    func addCellModels(_ cellModels:[LUICollectionCellModel]) {
        for LUICollectionCellModel in cellModels {
            addCellModel(LUICollectionCellModel)
        }
    }
    
    func insertCellModel(_ cellModel: LUICollectionCellModel, atIndexPath indexPath: IndexPath) {
        guard let sectionModel = sectionModelAtIndex(indexPath.section) else { return }
        sectionModel.insertCellModel(cellModel, atIndex: indexPath.row)
    }
    
    func insertCellModels(_ cellModels: [LUICollectionCellModel], afterIndexPath indexPath: IndexPath) {
        guard let sectionModel = sectionModelAtIndex(indexPath.section) else { return }
        sectionModel.insertCellModels(cellModels, afterIndex: indexPath.row)
    }
    
    func insertCellModels(_ cellModels: [LUICollectionCellModel], beforeIndexPath indexPath: IndexPath) {
        guard let sectionModel = sectionModelAtIndex(indexPath.section) else { return }
        sectionModel.insertCellModels(cellModels, beforeIndex: indexPath.row)
    }
    
    func insertCellModelsToBottom(_ cellModels: [LUICollectionCellModel]) {
        guard let sectionModel = self.sectionModels.last else { return }
        sectionModel.insertCellModelsToBottom(cellModels)
    }
    
    func insertCellModelsToTop(_ cellModels: [LUICollectionCellModel]) {
        guard let sectionModel = self.sectionModels.first else { return }
        sectionModel.insertCellModelsToTop(cellModels)
    }
    
    func removeCellModel(_ cellModel: LUICollectionCellModel) {
        for sectionModel in sectionModels {
            sectionModel.removeCellModel(cellModel: cellModel)
        }
    }
    
    func removeCellModels(_ cellModels: [LUICollectionCellModel]) {
        for cellModel in cellModels {
            removeCellModel(cellModel)
        }
    }
    
    func removeCellModelAtIndexPath(_ indexPath: IndexPath) {
        guard let sectionModel = sectionModelAtIndex(indexPath.section) else { return }
        sectionModel .removeCellModelAtIndex(indexPath.row)
    }
    
    func removeCellModelsAtIndexPaths(_ indexPaths: [IndexPath]) {
        var sectionMap = [Int: [IndexPath]]()
        for indexPath in indexPaths {
            let section = indexPath.section
            if sectionMap[section] == nil {
                sectionMap[section] = [indexPath]
            } else {
                sectionMap[section]?.append(indexPath)
            }
        }
        for (section, subIndexPaths) in sectionMap {
            let indexSet = IndexSet(subIndexPaths.map { $0.row })
            if let sectionModel = sectionModelAtIndex(section) {
                sectionModel.removeCellModelsAtIndexes(indexes: indexSet)
            }
        }
    }
    
    func addSectionModel(_ sectionModel: LUICollectionSectionModel) {
        sectionModel.collectionModel = self;
        self.sectionModels.append(sectionModel)
    }
    
    func insertSectionModel(_ sectionModel: LUICollectionSectionModel, atIndex index: Int) {
        sectionModel.collectionModel = self
        sectionModels.insert(sectionModel, at: index)
    }
    
    func addSectionModels(_ sectionModels: [LUICollectionSectionModel]) {
        for sectionModel in sectionModels {
            addSectionModel(sectionModel)
        }
    }
    
    func removeSectionModel(_ sectionModel: LUICollectionSectionModel) {
        sectionModel.collectionModel = nil
        if let index = sectionModels.firstIndex(where: { $0 == sectionModel} ) {
            removeSectionModelAtIndex(index)
        }
    }
    
    func removeSectionModelAtIndex(_ index: Int) {
        if index > 0 && index < self.sectionModels.count {
            sectionModels.remove(at: index)
        }
    }
    
    func removeSectionModelsInRange(_ range: Range<Int>) {
        sectionModels.removeSubrange(range)
    }
    
    func removeAllSectionModels() {
        sectionModels.removeAll()
    }
    
    func indexPathOfCellModel(_ cellModel: LUICollectionCellModel) -> IndexPath? {
        for (idx, section) in sectionModels.enumerated() {
            if let row = section.indexOfCellModel(cellModel), row != NSNotFound {
                return IndexPath(row: row, section: idx)
            }
        }
        return nil
    }
    
    func enumerateCellModelsUsingBlock(_ block: (LUICollectionCellModel, IndexPath, inout Bool) -> Void) {
        var stop = false
        for (sectionIndex, section) in sectionModels.enumerated() {
            for (itemIndex, cellModel) in section.cellModels.enumerated() {
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                block(cellModel, indexPath, &stop)
                if stop { return }
            }
        }
    }
    
    func indexPathOfCellModelPassingTest(_ block: (LUICollectionCellModel, IndexPath, inout Bool) -> Bool) -> IndexPath? {
        var result: IndexPath?
        enumerateCellModelsUsingBlock { cellModel, indexpath, stop in
            if block(cellModel, indexpath, &stop) {
                result = indexpath
                stop = true
            }
        }
        return result
    }
    
    func indexPathsOfCellModels(_ cellModels: [LUICollectionCellModel]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for cellModel in cellModels {
            if let indexPath = indexPathOfCellModel(cellModel) {
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    func indexOfSectionModel(_ sectionModel: LUICollectionSectionModel) -> Int? {
        return sectionModels.firstIndex(of: sectionModel)
    }
    
    func indexOfSectionModel(_ sectionModel: LUICollectionSectionModel) -> NSIndexSet? {
        if let index = sectionModels.firstIndex(of: sectionModel) {
            return NSIndexSet(index: index)
        }
        return nil
    }
    
    func cellModelAtIndexPath(_ indexPath: IndexPath) -> LUICollectionCellModel? {
        if let section = sectionModelAtIndex(indexPath.section), let cell = section.cellModelAtIndex(indexPath.row) {
            return cell
        }
        return nil
    }
    
    func cellModelsAtIndexPaths(_ indexPaths: [IndexPath]) -> [LUICollectionCellModel] {
        var cellModels: [LUICollectionCellModel] = []
        for indexPath in indexPaths {
            if let cm = cellModelAtIndexPath(indexPath) {
                cellModels.append(cm)
            }
        }
        return cellModels
    }
    
    func emptySectionModels() -> [LUICollectionSectionModel] {
        var models: [LUICollectionSectionModel] = []
        for sectionModel in sectionModels {
            if sectionModel.numberOfCells == 0 {
                models.append(sectionModel)
            }
        }
        return models
    }
    
    func removeEmptySectionModels() {
        let models = emptySectionModels()
        sectionModels.removeAll { model in
            models.contains(where: { $0 === model })
        }
    }
    
    func moveCellModelAtIndexPath(_ sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        guard let sourceCellModel = cellModelAtIndexPath(sourceIndexPath) else { return }
        removeCellModelAtIndexPath(sourceIndexPath)
        insertCellModel(sourceCellModel, atIndexPath: destinationIndexPath)
    }
    
    func selectCellModel(_ cellModel: LUICollectionCellModel) {
        guard allowsSelection else { cellModel.selected = true; return }
        guard !allowsMultipleSelection else { return }
        for allCellModel in allCellModels {
            if allCellModel.isEqual(cellModel) {
                allCellModel.selected = false
            }
        }
    }
    
    func selectCellModels(_ cellModels: [LUICollectionCellModel]) {
        guard allowsSelection else { return }
        guard allowsMultipleSelection else { return }
        for cellModel in cellModels {
            cellModel.selected = true
        }
    }
    
    func selectCellModelAtIndexPath(_ indexPath: IndexPath) {
        guard let cellModel = cellModelAtIndexPath(indexPath) else { return }
        selectCellModel(cellModel)
    }
    
    func selectCellModelsAtIndexPaths(_ indexPaths: [IndexPath]) {
        selectCellModels(cellModelsAtIndexPaths(indexPaths))
    }
    
    func selectAllCellModels() {
        selectCellModels(allCellModels)
    }
    
    func deselectCellModel(_ cellModel: LUICollectionCellModel) {
        cellModel.selected = false
    }
    
    func deselectCellModelAtIndexPath(_ indexPath: IndexPath) {
        guard let cellModel = cellModelAtIndexPath(indexPath) else { return }
        deselectCellModel(cellModel)
    }
    
    func deselectCellModels(_ cellModels: [LUICollectionCellModel]) {
        for cellModel in cellModels {
            deselectCellModel(cellModel)
        }
    }
    
    func deselectAllCellModels() {
        deselectCellModels(allCellModels)
    }
    
    func indexPathForSelectedCellModel() -> IndexPath? {
        for (sectionIdx, secionModel) in sectionModels.enumerated() {
            let cellModels = secionModel.cellModels
            for (cellIdx, cellModel) in cellModels.enumerated() {
                if cellModel.selected {
                    return IndexPath(item: cellIdx, section: sectionIdx)
                }
            }
        }
        return nil
    }

    func cellModelForSelectedCellModel() -> LUICollectionCellModel? {
        for (sectionIdx, secionModel) in sectionModels.enumerated() {
            let cellModels = secionModel.cellModels
            for (cellIdx, cellModel) in cellModels.enumerated() {
                if cellModel.selected {
                    return cellModel
                }
            }
        }
        return nil
    }
    
    func indexPathsForSelectedCellModels() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for (sectionIdx, secionModel) in sectionModels.enumerated() {
            let cellModels = secionModel.cellModels
            for (cellIdx, cellModel) in cellModels.enumerated() {
                if cellModel.selected {
                    indexPaths.append(IndexPath(item: cellIdx, section: sectionIdx))
                }
            }
        }
        return indexPaths
    }
    
    func cellModelsForSelectedCellModels() -> [LUICollectionCellModel] {
        var models: [LUICollectionCellModel] = []
        for sectionModel in sectionModels {
            for cellModel in sectionModel.cellModels {
                if cellModel.selected {
                    models.append(cellModel)
                }
            }
        }
        return models
    }
}

extension LUICollectionModel {
    func indexPathForFocusedCellModel() -> IndexPath? {
        for (sectionIdx, secionModel) in sectionModels.enumerated() {
            let cellModels = secionModel.cellModels
            for (cellIdx, cellModel) in cellModels.enumerated() {
                if cellModel.selected {
                    return IndexPath(item: cellIdx, section: sectionIdx)
                }
            }
        }
        return nil
    }
}
