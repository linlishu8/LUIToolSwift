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
        section.insertCellModel(cellModel, at: 0)
    }
    
    func addCellModels(_ cellModels:[LUICollectionCellModel]) {
        for LUICollectionCellModel in cellModels {
            addCellModel(LUICollectionCellModel)
        }
    }
    
    func insertCellModel(_ cellModel: LUICollectionCellModel, atIndexPath indexPath: NSIndexPath) {
//        guard let sectionModel = sectionModelAtIndex(indexPath.section) else { return }
//        sectionModel.insertCellModel(cellModel, atIndexPath: indexPath.row)
    }

    func addSectionModel(_ sectionModel: LUICollectionSectionModel) {
        sectionModel.collectionModel = self;
        self.sectionModels.append(sectionModel)
    }
}
