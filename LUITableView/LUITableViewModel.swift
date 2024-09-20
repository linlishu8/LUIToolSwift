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
    
    override func copy(with zone: NSZone? = nil) -> Any {
        guard let tableView = self.tableView else {
            fatalError("TableView is nil while copying model")
        }
        let obj = LUITableViewModel(tableView: tableView)
        obj.defaultIndexTitleSectionModel = self.defaultIndexTitleSectionModel
        obj.forwardDataSource = self.forwardDataSource
        obj.forwardDelegate = self.forwardDelegate
        obj.tableView = self.tableView
        obj.showSectionIndexTitle = self.showSectionIndexTitle
        obj.defaultSectionIndexTitle = self.defaultSectionIndexTitle
        obj.isEditing = self.isEditing
        obj.reuseCell = self.reuseCell
        obj.emptyBackgroundViewClass = self.emptyBackgroundViewClass
        obj.emptyBackgroundView = self.emptyBackgroundView
        obj.whenReloadBackgroundView = self.whenReloadBackgroundView
        obj.hiddenSectionHeadView = self.hiddenSectionHeadView
        obj.hiddenSectionFootView = self.hiddenSectionFootView
        return obj
    }
    
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
    
    override func createEmptySectionModel() -> LUICollectionSectionModel {
        return LUICollectionSectionModel()
    }
    
    override func addCellModel(_ cellModel: LUICollectionCellModel?) {
        guard let cellModel = cellModel else { return }
        if let section = self.sectionModels?.last as? LUICollectionSectionModel {
            section.addCellModel(cellModel)
        } else {
            let newSection = createEmptySectionModel()
            newSection.addCellModel(cellModel)
            self.addSectionModel(newSection)
        }
    }
    
    override func cellModelAtIndexPath(_ indexpath: NSIndexPath) -> LUITableViewCellModel? {
        if let cellModel = super.cellModel(at: indexpath as IndexPath) as? LUITableViewCellModel {
            return cellModel
        }
        return nil
    }
}
