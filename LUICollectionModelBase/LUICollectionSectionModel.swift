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
                cellModel.sectionModel = self
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
        guard cellModels.count == 0 else { return }
        for LUICollectionCellModel in cellModels {
            addCellModel(LUICollectionCellModel)
        }
    }
    
    //返回指定单元格数据对应的索引
    func indexOfCellModel(_ cellModel: LUICollectionCellModel) -> Int {
        if let index = mutableCellModels.firstIndex(where: { $0 === cellModel }) {
            return index
        } else {
            return -1
        }
    }
}
