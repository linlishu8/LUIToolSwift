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
            if let sectionModel = self.sectionModelAtIndex(i), sectionModel.numberOfCells > 0 {
                return IndexPath(item: sectionModel.numberOfCells - 1, section: i)
            }
        }
        return nil
    }
    
    func sectionModelAtIndex(_ index: Int) -> LUICollectionSectionModel? {
        guard index >= 0 && index < self.sectionModels.count else { return nil }
        return self.sectionModels[index]
    }
}
