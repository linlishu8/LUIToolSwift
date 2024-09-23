//
//  LUITableViewModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUITableViewModel: LUICollectionModel, UITableViewDelegate, UITableViewDataSource {
    private var defaultIndexTitleSectionModel: LUITableViewSectionModel?
    
    weak var forwardDataSource: UITableViewDataSource?
    weak var forwardDelegate: UITableViewDelegate?
    weak var tableView: UITableView?
    
    var showSectionIndexTitle: Bool = false
    var defaultSectionIndexTitle: String = "#"
    var isEditing: Bool = false
    var reuseCell: Bool = true
    
    var emptyBackgroundViewClass: AnyClass?
    var emptyBackgroundView: UIView?
    var whenReloadBackgroundView: ((LUITableViewModel) -> Void)?
    
    var hiddenSectionHeadView: Bool = false
    var hiddenSectionFootView: Bool = false
    
    init(tableView: UITableView) {
        super.init()
        self.setTableViewDataSourceAndDelegate(for: tableView)
    }
    
    func setTableViewDataSourceAndDelegate(for tableView: UITableView) {
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func createEmptySectionModel() -> LUITableViewSectionModel {
        return LUITableViewSectionModel()
    }
    
    override func addCellModel(_ cellModel: LUICollectionCellModel) {
        var section = sectionModels.last as? LUITableViewSectionModel ?? createEmptySectionModel()
        section.addCellModel(cellModel)
    }
    
    override func cellModelAtIndexPath(_ indexPath: IndexPath) -> LUICollectionCellModel? {
        guard let cellModel = super.cellModelAtIndexPath(indexPath) as? LUITableViewCellModel else { return nil }
        return cellModel
    }
    
    override func cellModelForSelectedCellModel() -> LUICollectionCellModel? {
        guard let cellModel = super.cellModelForSelectedCellModel() as? LUITableViewCellModel else { return nil }
        return cellModel
    }
    
    override func sectionModelAtIndex(_ index: Int) -> LUICollectionSectionModel? {
        guard let sectionModel = super.sectionModelAtIndex(index) as? LUITableViewSectionModel else { return nil }
        return sectionModel
    }
    
    func sectionModelWithIndexTitle(_ indexTitle: String) -> LUITableViewSectionModel? {
        for sectionModel in self.sectionModels {
            if let tableSectionModel = sectionModel as? LUITableViewSectionModel, tableSectionModel.indexTitle == indexTitle {
                return tableSectionModel
            }
        }
        return nil
    }
    
    func addAutoIndexedCellModel(_ cellModel: LUITableViewCellModel) -> LUITableViewSectionModel? {
        var useDefaultIndexTitle: Bool = cellModel.indexTitle?.count == 0;
        let indexTitle = useDefaultIndexTitle ? defaultSectionIndexTitle : cellModel.indexTitle ?? defaultSectionIndexTitle
        var sectionModel = useDefaultIndexTitle ? defaultIndexTitleSectionModel : sectionModelWithIndexTitle(indexTitle)
        if sectionModel == nil {
            sectionModel = createEmptySectionModel()
            sectionModel?.indexTitle = indexTitle
            sectionModel?.headTitle = indexTitle
            sectionModel?.showHeadView = true
            sectionModel?.showDefaultHeadView = true
            if useDefaultIndexTitle {
                self.defaultIndexTitleSectionModel = sectionModel
            }
            guard let safeModel = sectionModel else { return nil }
            addSectionModel(safeModel)
        }
        sectionModel?.addCellModel(cellModel)
        return sectionModel
    }
}
