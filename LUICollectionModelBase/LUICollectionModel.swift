//
//  LUICollectionModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUICollectionModel: LUICollectionModelObjectBase {
    var sectionModels: [LUICollectionSectionModel]? {
        didSet {
            mutableSectionModels.removeAll()
            if let sectionModels = sectionModels {
                mutableSectionModels.append(contentsOf: sectionModels)
                sectionModels.forEach { $0.collectionModel = self }
            }
        }
    }
    var allCellModels: [LUICollectionCellModel]? {
        var cells = [LUICollectionCellModel]()
        sectionModels?.forEach { section in
            cells.append(contentsOf: section.cellModels)
        }
        return cells
    }
    var userInfo: Any?
    var numberOfSections: Int {
        return sectionModels?.count ?? 0
    }
    var numberOfCells: Int {
        return sectionModels?.reduce(0) { $0 + $1.numberOfCells } ?? 0
    }
    
    var allowsSelection = true
    var allowsMultipleSelection = false
    var allowsFocus = true
    
    var indexPathOfLastCellModel: IndexPath? {
        guard let sections = sectionModels, sections.count > 0 else { return nil }
        for i in stride(from: sections.count - 1, through: 0, by: -1) {
            let section = sections[i]
            if section.numberOfCells > 0 {
                return IndexPath(item: section.numberOfCells - 1, section: i)
            }
        }
        return nil
    }
    
    private var mutableSectionModels: [LUICollectionSectionModel] = []
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let obj = LUICollectionModel()
        obj.mutableSectionModels = mutableSectionModels
        obj.sectionModels = sectionModels
        obj.userInfo = userInfo
        obj.allowsSelection = allowsSelection
        obj.allowsMultipleSelection = allowsMultipleSelection
        obj.allowsFocus = allowsFocus
        return obj
    }
    
    func createEmptySectionModel() -> LUICollectionSectionModel {
        return LUICollectionSectionModel()
    }
    
    func addCellModel(_ cellModel: LUICollectionCellModel) {
        guard let lastSection = sectionModels?.last else {
            let section = createEmptySectionModel()
            addSectionModel(section)
            section.addCellModel(cellModel)
            return
        }
        lastSection.addCellModel(cellModel)
    }
    
    func addCellModelToFirst(_ cellModel: LUICollectionCellModel) {
        guard let firstSection = sectionModels?.first else {
            let section = createEmptySectionModel()
            addSectionModel(section)
            section.insertCellModel(cellModel, at: 0)
            return
        }
        firstSection.insertCellModel(cellModel, at: 0)
    }
    
    func addCellModels(_ cellModels: [LUICollectionCellModel]) {
        cellModels.forEach { addCellModel($0) }
    }
    
    func insertCellModel(_ cellModel: LUICollectionCellModel, at indexPath: IndexPath) {
        guard let section = sectionModels?[indexPath.section] else { return }
        section.insertCellModel(cellModel, at: indexPath.item)
    }
    
    func insertCellModels(_ cellModels: [LUICollectionCellModel], after indexPath: IndexPath) {
        guard let section = sectionModels?[indexPath.section] else { return }
        section.insertCellModels(cellModels, after: indexPath.item)
    }
    
    func insertCellModels(_ cellModels: [LUICollectionCellModel], before indexPath: IndexPath) {
        guard let section = sectionModels?[indexPath.section] else { return }
        section.insertCellModels(cellModels, before: indexPath.item)
    }
    
    func insertCellModelsToBottom(_ cellModels: [LUICollectionCellModel]) {
        guard let section = sectionModels?.last else { return }
        section.insertCellModelsToBottom(cellModels)
    }
    
    func insertCellModelsToTop(_ cellModels: [LUICollectionCellModel]) {
        guard let section = sectionModels?.first else { return }
        section.insertCellModelsToTop(cellModels)
    }
    
    func removeCellModel(_ cellModel: LUICollectionCellModel) {
        sectionModels?.forEach { $0.removeCellModel(cellModel) }
    }
    
    func removeCellModels(_ cellModels: [LUICollectionCellModel]) {
        cellModels.forEach { removeCellModel($0) }
    }
    
    func removeCellModel(at indexPath: IndexPath) {
        guard let section = sectionModels?[indexPath.section] else { return }
        section.removeCellModel(at: indexPath.item)
    }
    
    func removeCellModels(at indexPaths: [IndexPath]) {
        let sectionMap = Dictionary(grouping: indexPaths) { $0.section }
        for (section, paths) in sectionMap {
            let indices = IndexSet(paths.map { $0.item })
            sectionModels?[section].removeCellModels(at: indices)
        }
    }
    
    func addSectionModel(_ sectionModel: LUICollectionSectionModel) {
        sectionModel.collectionModel = self
        mutableSectionModels.append(sectionModel)
    }
    
    func insertSectionModel(_ sectionModel: LUICollectionSectionModel, at index: Int) {
        sectionModel.collectionModel = self
        mutableSectionModels.insert(sectionModel, at: index)
    }
    
    func addSectionModels(_ sectionModels: [LUICollectionSectionModel]) {
        sectionModels.forEach { addSectionModel($0) }
    }
    
    func removeSectionModel(_ sectionModel: LUICollectionSectionModel) {
        sectionModel.collectionModel = nil
        mutableSectionModels.removeAll { $0 === sectionModel }
    }
    
    func removeSectionModel(at index: Int) {
        mutableSectionModels.remove(at: index)
    }
    
    func removeSectionModels(in range: Range<Int>) {
        mutableSectionModels.removeSubrange(range)
    }
    
    func removeAllSectionModels() {
        mutableSectionModels.removeAll()
    }
    
    func indexPath(of cellModel: LUICollectionCellModel) -> IndexPath? {
        for (sectionIndex, section) in sectionModels?.enumerated() ?? [].enumerated() {
            if let rowIndex = section.indexOf(cellModel) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    func enumerateCellModels(using block: (LUICollectionCellModel, IndexPath, inout Bool) -> Void) {
        var stop = false
        for (sectionIndex, section) in sectionModels?.enumerated() ?? [].enumerated() {
            for (rowIndex, cellModel) in section.cellModels.enumerated() {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                block(cellModel, indexPath, &stop)
                if stop { return }
            }
        }
    }
    
    func indexPath(passingTest block: (LUICollectionCellModel, IndexPath, inout Bool) -> Bool) -> IndexPath? {
        var result: IndexPath?
        enumerateCellModels { cellModel, indexPath, stop in
            if block(cellModel, indexPath, &stop) {
                result = indexPath
                stop = true
            }
        }
        return result
    }
    
    func indexPaths(passingTest block: (LUICollectionCellModel, IndexPath, inout Bool) -> Bool) -> [IndexPath]? {
        var result = [IndexPath]()
        enumerateCellModels { cellModel, indexPath, stop in
            if block(cellModel, indexPath, &stop) {
                result.append(indexPath)
            }
        }
        return result
    }
    
    func indexPaths(of cellModels: [LUICollectionCellModel]) -> [IndexPath]? {
        return cellModels.compactMap { indexPath(of: $0) }
    }
    
    func index(of sectionModel: LUICollectionSectionModel) -> Int? {
        return sectionModels?.firstIndex(of: sectionModel)
    }
    
    func indexSet(of sectionModel: LUICollectionSectionModel) -> IndexSet? {
        guard let index = index(of: sectionModel) else { return nil }
        return IndexSet(integer: index)
    }
    
    func cellModel(at indexPath: IndexPath) -> LUICollectionCellModel? {
        return sectionModels?[indexPath.section].cellModel(at: indexPath.item)
    }
    
    func cellModels(at indexPaths: [IndexPath]) -> [LUICollectionCellModel]? {
        return indexPaths.compactMap { cellModel(at: $0) }
    }
    
    func sectionModel(at index: Int) -> LUICollectionSectionModel? {
        return sectionModels?[index]
    }
    
    func removeEmptySectionModels() {
        sectionModels?.removeAll { $0.numberOfCells == 0 }
    }
    
    func emptySectionModels() -> [LUICollectionSectionModel]? {
        return sectionModels?.filter { $0.numberOfCells == 0 }
    }
    
    func moveCellModel(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let sourceCellModel = cellModel(at: sourceIndexPath) else { return }
        removeCellModel(at: sourceIndexPath)
        insertCellModel(sourceCellModel, at: destinationIndexPath)
    }
    
    // Selection methods are omitted for brevity
}
