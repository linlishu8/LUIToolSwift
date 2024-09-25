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
    
    func performIfTableViewAvailable(_ action: (UITableView) -> Void) {
        guard let tableView = tableView else { return }
        action(tableView)
    }
    
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
        let section = self.sectionModels.last as? LUITableViewSectionModel ?? self.createEmptySectionModel()
        if section !== self.sectionModels.last {
            self.addSectionModel(section)
        }
        section.addCellModel(cellModel)
    }
    
    override func cellModelAtIndexPath(_ indexPath: IndexPath) -> LUITableViewCellModel? {
        guard let cellModel = super.cellModelAtIndexPath(indexPath) as? LUITableViewCellModel else { return nil }
        return cellModel
    }
    
    override func cellModelForSelectedCellModel() -> LUITableViewCellModel? {
        guard let cellModel = super.cellModelForSelectedCellModel() as? LUITableViewCellModel else { return nil }
        return cellModel
    }
    
    override func sectionModelAtIndex(_ index: Int) -> LUITableViewSectionModel? {
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
        let useDefaultIndexTitle: Bool = cellModel.indexTitle?.count == 0;
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
        self.reloadTableViewBackgroundView()
    }
    
    // MARK: -  empty background
    func createEmptyBackgroundView() -> UIView? {
        let viewClass = emptyBackgroundViewClass as? UIView.Type
        return viewClass?.init()
    }
    
    func reloadTableViewBackgroundView() {
        guard emptyBackgroundViewClass != nil || emptyBackgroundView != nil else { return }
        performIfTableViewAvailable { tableView in
            if numberOfCells == 0 {
                emptyBackgroundView = emptyBackgroundView ?? createEmptyBackgroundView()
                tableView.backgroundView = emptyBackgroundView
            } else {
                tableView.backgroundView = nil
            }
        }
        whenReloadBackgroundView?(self)
    }
    
    func addCellModel(_ cellModel: LUITableViewCellModel, animated: Bool) {
        cellModel.needReloadCell = true
        addCellModel(cellModel)
        guard let sm = sectionModels.last else { return }
        let indexPath = IndexPath(item: sm.numberOfCells - 1, section: sectionModels.count - 1)
        performIfTableViewAvailable { tableView in
            tableView.beginUpdates()
            if tableView.numberOfSections == 0 {
                tableView.insertSections(IndexSet(integer: 0), with: animated ? .automatic : .none)
            }
            tableView.insertRows(at: [indexPath], with: animated ? .automatic : .none)
            tableView.endUpdates()
        }
        self.reloadTableViewBackgroundView()
    }
    
    func insertCellModel(_ cellModel: LUITableViewCellModel, atIndexPath: IndexPath, animated: Bool) {
        cellModel.needReloadCell = true
        guard let sectionModel = sectionModelAtIndex(atIndexPath.section) else { return }
        sectionModel.insertCellModel(cellModel, atIndex: atIndexPath.row)
        performIfTableViewAvailable { tableView in
            tableView.beginUpdates()
            tableView.insertRows(at: [atIndexPath], with:  animated ? .automatic : .none)
            tableView.endUpdates()
        }
        self.reloadTableViewBackgroundView()
    }
    
    func insertCellModel(_ cellModel: LUITableViewCellModel, afterIndexPath: IndexPath, animated: Bool) {
        insertCellModels([cellModel], afterIndexPath: afterIndexPath, animated: animated)
    }
    
    func insertCellModels(_ cellModels: [LUITableViewCellModel], afterIndexPath: IndexPath, animated: Bool) {
        for cellModel in cellModels {
            cellModel.needReloadCell = true
        }
        insertCellModels(cellModels, afterIndexPath: afterIndexPath)
        var indexPaths: [IndexPath] = []
        for index in 0...cellModels.count {
            indexPaths.append(IndexPath(row: afterIndexPath.row + 1 + index, section: afterIndexPath.section))
        }
        performIfTableViewAvailable { tableView in
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: animated ? .automatic : .none)
            tableView.endUpdates()
        }
        self.reloadTableViewBackgroundView()
    }
    
    func insertCellModel(_ cellModels: [LUITableViewCellModel], beforeIndexPath: IndexPath, animated: Bool) {
        insertCellModels(cellModels, beforeIndexPath: beforeIndexPath, animated: animated)
    }
    
    func insertCellModels(_ cellModels: [LUITableViewCellModel], beforeIndexPath: IndexPath, animated: Bool) {
        for cellModel in cellModels {
            cellModel.needReloadCell = true
        }
        insertCellModels(cellModels, beforeIndexPath: beforeIndexPath)
        var indexPaths: [IndexPath] = []
        for index in 0...cellModels.count {
            indexPaths.append(IndexPath(row: beforeIndexPath.row + index, section: beforeIndexPath.section))
        }
        performIfTableViewAvailable { tableView in
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: animated ? .automatic : .none)
            tableView.endUpdates()
        }
        self.reloadTableViewBackgroundView()
    }
    
    func insertCellModelsToBottom(_ cellModels: [LUITableViewCellModel], scrollToBottom: Bool) {
        let sm = sectionModels.last as? LUITableViewSectionModel ?? createEmptySectionModel()
        if sm !== sectionModels.last {
            addSectionModel(sm)
        }
        sm.insertCellModelsToBottom(cellModels)
        reloadTableViewData()
        if scrollToBottom {
            self.tableView?.l_scrollToBottomWithAnimated(true)
        }
    }
    
    func insertCellModelsToTop(_ cellModels: [LUITableViewCellModel], keepContentOffset: Bool) {
        let sm = sectionModels.first as? LUITableViewSectionModel ?? createEmptySectionModel()
        if sm !== sectionModels.first {
            addSectionModel(sm)
        }
        sm.insertCellModelsToTop(cellModels)
        guard let tableView = self.tableView else { return }
        var contentOffset = tableView.contentOffset;
        let contentSize1 = tableView.contentSize;
        self.reloadTableViewData()
        let contentSize2 = tableView.contentSize;
        contentOffset.y += contentSize2.height-contentSize1.height;
        if (keepContentOffset) {
            tableView.setContentOffset(contentOffset, animated: false)
        }
    }
    
    func removeCellModel(_ cellModel: LUITableViewCellModel, animated: Bool) {
        guard let indexPath = self.indexPathOfCellModel(cellModel) else { return }
        cellModel.needReloadCell = false
        self.removeCellModelAtIndexPath(indexPath)
        performIfTableViewAvailable { tableView in
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: animated ? .automatic : .none)
            tableView.endUpdates()
        }
        self.reloadTableViewBackgroundView()
    }
    
    func removeCellModels(_ cellModels: [LUICollectionCellModel], animated: Bool) {
        let indexPaths = self.indexPathsOfCellModels(cellModels)
        self.removeCellModelsAtIndexPaths(indexPaths)
    }
    
    func removeCellModelsAtIndexPaths(_ indexPaths: [IndexPath], animated: Bool) {
        self.removeCellModelsAtIndexPaths(indexPaths)
        performIfTableViewAvailable { tableView in
            tableView.beginUpdates()
            tableView.deleteRows(at: indexPaths, with: animated ? .automatic : .none)
            tableView.endUpdates()
        }
        self.reloadTableViewBackgroundView()
    }
    
    func insertSectionModel(_ sectionModel: LUITableViewSectionModel, index: Int, animated: Bool) {
        for cellModel in sectionModel.cellModels {
            if let tableCellModel = cellModel as? LUITableViewCellModel {
                tableCellModel.needReloadCell = true
            }
        }
        self.insertSectionModel(sectionModel, atIndex: index)
        var indexPaths: [IndexPath] = []
        for _ in 0..<sectionModel.numberOfCells {
            indexPaths.append(IndexPath(row: index, section: index))
        }
        performIfTableViewAvailable { tableView in
            tableView.beginUpdates()
            tableView.insertSections(IndexSet(integer: index), with: animated ? .automatic : .none)
            tableView.insertRows(at: indexPaths, with: animated ? .automatic : .none)
            tableView.endUpdates()
        }
    }
    
    func removeSectionModel(_ sectionModel: LUITableViewSectionModel, animated: Bool) {
        guard let index = sectionModel.indexInModel else { return }
        let set = IndexSet(integer: index)
        self.removeSectionModel(sectionModel)
        var indexPaths: [IndexPath] = []
        for _ in 0..<sectionModel.numberOfCells {
            indexPaths.append(IndexPath(row: index, section: index))
        }
        performIfTableViewAvailable { tableView in
            tableView.beginUpdates()
            tableView.deleteSections(set, with: animated ? .automatic : .none)
            tableView.deleteRows(at: indexPaths, with: animated ? .automatic : .none)
            tableView.endUpdates()
        }
    }
    
    func deselectAllCellModelsWithAnimated(_ animated: Bool) {
        guard let indexPaths = self.tableView?.indexPathsForSelectedRows else { return }
        self.deselectAllCellModels()
        for indexPath in indexPaths {
            self.tableView?.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    func deselectCellModels(_ cellModels: [LUICollectionCellModel], animated: Bool) {
        super.deselectCellModels(cellModels)
        for cellModel in cellModels {
            if let tableViewCellModel = cellModel as? LUITableViewCellModel, let indexPathInModel = tableViewCellModel.indexPathInModel {
                self.tableView?.deselectRow(at: indexPathInModel, animated: animated)
            }
        }
    }
    
    func selectAllCellModelsWithAnimated(_ animated: Bool) {
        self.selectAllCellModels()
        for (i, sectionModel) in self.sectionModels.enumerated() {
            for j in 0...sectionModel.numberOfCells {
                self.tableView?.selectRow(at: IndexPath(row: j, section: i), animated: animated, scrollPosition: .none)
            }
        }
        let allcellModels: [LUITableViewCellModel] = self.allCellModels.compactMap { $0 as? LUITableViewCellModel }
        self.selectCellModels(allcellModels, animated: animated)
    }
    
    func selectCellModels(_ cellModels: [LUITableViewCellModel], animated: Bool) {
        super.selectCellModels(cellModels)
        for cellModel in cellModels {
            self.tableView?.selectRow(at: cellModel.indexPathInModel, animated: animated, scrollPosition: .none)
        }
    }
    
    func setCellModel(_ cellModel: LUITableViewCellModel, selected: Bool, animated: Bool) {
        if selected {
            self.selectCellModel(cellModel)
            self.tableView?.selectRow(at: cellModel.indexPathInModel, animated: animated, scrollPosition: .top)
        } else {
            self.deselectCellModel(cellModel)
            if let modelIndexPath = cellModel.indexPathInModel {
                self.tableView?.deselectRow(at: modelIndexPath, animated: animated)
            }
        }
        if !animated, let offset = self.tableView?.contentOffset {
            self.tableView?.contentOffset = offset
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return self.sectionModelAtIndex(section)?.numberOfCells ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellModel = self.cellModelAtIndexPath(indexPath) else {
            return UITableViewCell()
        }
        
        let identity = self.reuseCell ? cellModel.reuseIdentity : "\(cellModel.reuseIdentity)_\(Unmanaged.passUnretained(cellModel).toOpaque())"
        var cell = tableView.dequeueReusableCell(withIdentifier: identity)
        
        if cell == nil {
            let cellClass = cellModel.cellClass ?? LUITableViewCellBase.self  // 提供默认类
            cell = cellClass.init(style: .default, reuseIdentifier: identity)
        }
        
        if let disCell = cell as? LUITableViewCellBase {
            cellModel.displayCell(disCell)
        }
        
        return cell ?? UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt canEditRowAtIndexPath: IndexPath) -> Bool {
        return self.cellModelAtIndexPath(canEditRowAtIndexPath)?.canEdit ?? false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt editActionsForRowAtIndexPath: IndexPath) -> [UITableViewRowAction]? {
        if let forwardDelegate = self.forwardDelegate, forwardDelegate.responds(to: #selector(tableView(_:editActionsForRowAt:))) {
            return forwardDelegate.tableView?(tableView, editActionsForRowAt: editActionsForRowAtIndexPath)
        }
        return self.cellModelAtIndexPath(editActionsForRowAtIndexPath)?.editActions()
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt leadingSwipeActionsConfigurationForRowAtIndexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let forwardDelegate = self.forwardDelegate, forwardDelegate.responds(to: #selector(tableView(_: leadingSwipeActionsConfigurationForRowAt:))) {
            return forwardDelegate.tableView?(tableView, leadingSwipeActionsConfigurationForRowAt: leadingSwipeActionsConfigurationForRowAtIndexPath)
        }
        return self.cellModelAtIndexPath(leadingSwipeActionsConfigurationForRowAtIndexPath)?.swipeActionsConfigurationWithIndexPath(leadingSwipeActionsConfigurationForRowAtIndexPath, leading: true)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt trailingSwipeActionsConfigurationForRowAtIndexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let forwardDelegate = self.forwardDelegate, forwardDelegate.responds(to: #selector(tableView(_:trailingSwipeActionsConfigurationForRowAt:))) {
            return forwardDelegate.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: trailingSwipeActionsConfigurationForRowAtIndexPath)
        }
        return self.cellModelAtIndexPath(trailingSwipeActionsConfigurationForRowAtIndexPath)?.swipeActionsConfigurationWithIndexPath(trailingSwipeActionsConfigurationForRowAtIndexPath, leading: false)
    }
    
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith accessoryButtonTappedForRowWithIndexPath: IndexPath) {
        guard let cellModel = self.cellModelAtIndexPath(accessoryButtonTappedForRowWithIndexPath) else { return }
        cellModel.whenClickAccessory?(cellModel)
    }
    
    private func _sectionIndexTitlesForTableView(_ tableView: UITableView) -> [[String : Any]] {
        var sectionIndexTitles: [[String : Any]] = []
        guard self.showSectionIndexTitle, !self.sectionModels.isEmpty else { return sectionIndexTitles }
        for model in self.sectionModels {
            if let sectionModel = model as? LUITableViewSectionModel {
                let title = sectionModel.indexTitle ?? defaultSectionIndexTitle
                sectionIndexTitles.append(["title": title, "model": sectionModel])
            }
        }
        return sectionIndexTitles
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var sectionIndexTitles: [String] = []
        guard self.showSectionIndexTitle else { return sectionIndexTitles }
        let map = self._sectionIndexTitlesForTableView(tableView)
        for info in map {
            if let title = info["title"] as? String {
                sectionIndexTitles.append(title)
            }
        }
        return sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var sectionIndex = NSNotFound
        guard self.showSectionIndexTitle else { return sectionIndex }
        let map = self._sectionIndexTitlesForTableView(tableView)
        guard map.count > index else { return sectionIndex }
        let info = map[index]
        if let sectionModel = info.l_valueForKeyPath("model") as? LUITableViewSectionModel {
            sectionIndex = self.indexOfSectionModel(sectionModel) ?? NSNotFound
        }
        return sectionIndex
    }
    
    
    
}
