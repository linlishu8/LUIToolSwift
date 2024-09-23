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
    
    func reloadTableViewData() {
        reloadTableViewDataWithAnimated(false)
    }
    
    func reloadTableViewDataWithAnimated(_ animated: Bool) {
        for sectionModel in self.sectionModels {
            for cellModel in sectionModel.cellModels {
                if let cm = cellModel as? LUITableViewCellModel {
                    cm.needReloadCell = true
                }
            }
        }
        tableView?.reloadData()
        if allowsSelection {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.allowsMultipleSelection {
                    for indexPath in indexPathsForSelectedCellModels() {
                        tableView?.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
                    }
                } else {
                    tableView?.selectRow(at: indexPathForFocusedCellModel(), animated: animated, scrollPosition: .none)
                }
            }
        }
        reloadTableViewBackgroundView()
    }
    
    // empty background
    func createEmptyBackgroundView() -> UIView? {
        let viewClass = emptyBackgroundViewClass as? UIView.Type
        return viewClass?.init()
    }
    
    func reloadTableViewBackgroundView() {
        guard emptyBackgroundViewClass != nil || emptyBackgroundView != nil else { return }
        guard let tableView = self.tableView else { return }
        if numberOfCells == 0 {
            emptyBackgroundView = emptyBackgroundView ?? createEmptyBackgroundView()
            tableView.backgroundView = emptyBackgroundView
        } else {
            tableView.backgroundView = nil
        }
        whenReloadBackgroundView?(self)
    }
    
    func addCellModel(_ cellModel: LUITableViewCellModel, animated: Bool) {
        cellModel.needReloadCell = true
        addCellModel(cellModel)
        guard let sm = sectionModels.last else { return }
        let indexPath = IndexPath(item: sm.numberOfCells - 1, section: sectionModels.count - 1)
        guard let tableView = self.tableView else { return }
        tableView.beginUpdates()
        if tableView.numberOfSections == 0 {
            tableView.insertSections(IndexSet(integer: 0), with: animated ? .automatic : .none)
        }
        tableView.insertRows(at: [indexPath], with: animated ? .automatic : .none)
        tableView.endUpdates()
        reloadTableViewBackgroundView()
    }
    
    func insertCellModel(_ cellModel: LUITableViewCellModel, atIndexPath: IndexPath, animated: Bool) {
        cellModel.needReloadCell = true
        guard let sectionModel = sectionModelAtIndex(atIndexPath.section) else { return }
        sectionModel.insertCellModel(cellModel, atIndex: atIndexPath.row)
        guard let tableView = self.tableView else { return }
        tableView.beginUpdates()
        tableView.insertRows(at: [atIndexPath], with:  animated ? .automatic : .none)
        tableView.endUpdates()
        reloadTableViewBackgroundView()
    }
    
    func insertCellModel(_ cellModel: LUITableViewCellModel, afterIndexPath: IndexPath, animated: Bool) {
        insertCellModels([cellModel], afterIndexPath: afterIndexPath, animated: animated)
    }
    
    func insertCellModels(_ cellModels: [LUITableViewCellModel], afterIndexPath: IndexPath, animated: Bool) {
        guard let tableView = self.tableView else { return }
        for cellModel in cellModels {
            cellModel.needReloadCell = true
        }
        insertCellModels(cellModels, afterIndexPath: afterIndexPath)
        var indexPaths: [IndexPath] = []
        for index in 0...cellModels.count {
            indexPaths.append(IndexPath(row: afterIndexPath.row + 1 + index, section: afterIndexPath.section))
        }
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: animated ? .automatic : .none)
        tableView.endUpdates()
        reloadTableViewBackgroundView()
    }
    
    func insertCellModel(_ cellModels: [LUITableViewCellModel], beforeIndexPath: IndexPath, animated: Bool) {
        insertCellModels(cellModels, beforeIndexPath: beforeIndexPath, animated: animated)
    }
    
    func insertCellModels(_ cellModels: [LUITableViewCellModel], beforeIndexPath: IndexPath, animated: Bool) {
        guard let tableView = self.tableView else { return }
        for cellModel in cellModels {
            cellModel.needReloadCell = true
        }
        insertCellModels(cellModels, beforeIndexPath: beforeIndexPath)
        var indexPaths: [IndexPath] = []
        for index in 0...cellModels.count {
            indexPaths.append(IndexPath(row: beforeIndexPath.row + index, section: beforeIndexPath.section))
        }
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: animated ? .automatic : .none)
        tableView.endUpdates()
        reloadTableViewBackgroundView()
    }
    
    func insertCellModelsToBottom(_ cellModels: [LUITableViewCellModel], scrollToBottom: Bool) {
        let sm = sectionModels.last as? LUITableViewSectionModel ?? createEmptySectionModel()
        if sm !== sectionModels.last {
            addSectionModel(sm)
        }
        sm.insertCellModelsToBottom(cellModels)
        reloadTableViewData()
        if scrollToBottom {
            tableView.l_scr
        }
    }
}
