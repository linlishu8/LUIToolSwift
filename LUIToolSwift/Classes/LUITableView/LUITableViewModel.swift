//
//  LUITableViewModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

public class LUITableViewModel: LUICollectionModel, UITableViewDelegate, UITableViewDataSource {
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
        return LUITableViewSectionModel.init()
    }
    
    public override func addCellModel(_ cellModel: LUICollectionCellModel) {
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
    
    public func reloadTableViewData() {
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return self.sectionModelAtIndex(section)?.numberOfCells ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    private func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    
    private func tableView(_ tableView: UITableView, canEditRowAt canEditRowAtIndexPath: IndexPath) -> Bool {
        return self.cellModelAtIndexPath(canEditRowAtIndexPath)?.canEdit ?? false
    }
    
    private func tableView(_ tableView: UITableView, editActionsForRowAt editActionsForRowAtIndexPath: IndexPath) -> [UITableViewRowAction]? {
        if let forwardDelegate = self.forwardDelegate {
            return forwardDelegate.tableView?(tableView, editActionsForRowAt: editActionsForRowAtIndexPath)
        }
        return self.cellModelAtIndexPath(editActionsForRowAtIndexPath)?.editActions()
    }
    
    @available(iOS 11.0, *)
    private func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt leadingSwipeActionsConfigurationForRowAtIndexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let forwardDelegate = self.forwardDelegate {
            return forwardDelegate.tableView?(tableView, leadingSwipeActionsConfigurationForRowAt: leadingSwipeActionsConfigurationForRowAtIndexPath)
        }
        return self.cellModelAtIndexPath(leadingSwipeActionsConfigurationForRowAtIndexPath)?.swipeActionsConfigurationWithIndexPath(leadingSwipeActionsConfigurationForRowAtIndexPath, leading: true)
    }
    
    @available(iOS 11.0, *)
    private func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt trailingSwipeActionsConfigurationForRowAtIndexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let forwardDelegate = self.forwardDelegate {
            return forwardDelegate.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: trailingSwipeActionsConfigurationForRowAtIndexPath)
        }
        return self.cellModelAtIndexPath(trailingSwipeActionsConfigurationForRowAtIndexPath)?.swipeActionsConfigurationWithIndexPath(trailingSwipeActionsConfigurationForRowAtIndexPath, leading: false)
    }
    
    
    private func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith accessoryButtonTappedForRowWithIndexPath: IndexPath) {
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
    
    private func sectionIndexTitles(for tableView: UITableView) -> [String]? {
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
    
    private func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
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
    
    private func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sectionModel = self.sectionModelAtIndex(indexPath.section)
            let model = sectionModel?.cellModelAtIndex(indexPath.row)
            if let cellModel = model {
                cellModel.whenDelete?(cellModel)
            }
        }
        if let forwardDataSource = self.forwardDataSource {
            forwardDataSource.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
        }
    }
    
    private func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let scrTableCellModel = self.cellModelAtIndexPath(sourceIndexPath)
        let dstTableCellModel = self.cellModelAtIndexPath(destinationIndexPath)
        var handed = false
        if let handler = scrTableCellModel?.whenMove ?? dstTableCellModel?.whenMove {
            if let scrHander = scrTableCellModel, let dstHander = dstTableCellModel {
                handler(scrHander, dstHander)
                handed = true
            }
        }
        if let forwardDataSource = self.forwardDataSource {
            self.forwardDataSource?.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        }
        if !handed {
            self.moveCellModelAtIndexPath(sourceIndexPath, toIndexPath: destinationIndexPath)
        }
    }
    
    private func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cellModel = self.cellModelAtIndexPath(indexPath) {
            let cellClass = cellModel.cellClass
            return cellClass?.heightWithTableView(tableView, cellModel: cellModel) ?? 0
        }
        return 0
    }
    
    private func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cellModel = self.cellModelAtIndexPath(indexPath) {
            let cellClass = cellModel.cellClass
            return cellClass?.estimatedHeightWithTableView(tableView, cellModel: cellModel) ?? 0
        }
        return 0
    }
    
    private func __tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 0
        if let sectionModel = self.sectionModelAtIndex(section), sectionModel.showHeadView {
            if sectionModel.showDefaultHeadView {
                let headHeight = sectionModel.headViewHeight
                if headHeight == 0 {
                    height = UITableViewAutomaticDimension
                }
            } else {
                height = sectionModel.headViewClass?.heightWithTableView(tableView, sectionModel: sectionModel, kind: .head) ?? 0
            }
        }
        return height
    }
    
    private func __tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height: CGFloat = 0
        if let sectionModel = self.sectionModelAtIndex(section), sectionModel.showFootView {
            if sectionModel.showDefaultFootView {
                let headHeight = sectionModel.footViewHeight
                if headHeight == 0 {
                    height = UITableViewAutomaticDimension
                }
            } else {
                height = sectionModel.footViewClass?.heightWithTableView(tableView, sectionModel: sectionModel, kind: .foot) ?? 0
            }
        }
        return height
    }
    
    private func __tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if let sectionModel = self.sectionModelAtIndex(section) {
            var title = sectionModel.headTitle
            if title?.count == 0 && sectionModel.showHeadView {
                title = " "
            }
        }
        return ""
    }
    
    private func __tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String {
        if let sectionModel = self.sectionModelAtIndex(section) {
            var title = sectionModel.footTitle
            if title?.count == 0 && sectionModel.showFootView {
                title = " "
            }
        }
        return ""
    }
    
    private func __tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionModel = self.sectionModelAtIndex(section), !sectionModel.showDefaultHeadView else { return nil }
        if let viewType = sectionModel.headViewClass as? UIView.Type {
            let height = __tableView(tableView, heightForHeaderInSection: section)
            let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height >= 0 ? height : 40)
            if let view = viewType.init(frame: frame) as? UIView & LUITableViewSectionViewProtocol {
                sectionModel.displayHeadView(view)
                return view
            }
        }
        return nil
    }
    
    private func __tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let sectionModel = self.sectionModelAtIndex(section), !sectionModel.showDefaultFootView else { return nil }
        if let viewType = sectionModel.footViewClass as? UIView.Type {
            let height = __tableView(tableView, heightForFooterInSection: section)
            let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height >= 0 ? height : 40)
            if let view = viewType.init(frame: frame) as? UIView & LUITableViewSectionViewProtocol {
                sectionModel.displayFootView(view)
                return view
            }
        }
        return nil
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? LUITableViewCellProtocol {
            cell.tableView(tableView, didSelectCell: true)
        }
        if let cellModel = self.cellModelAtIndexPath(indexPath) {
            self.selectCellModel(cellModel)
            cellModel.whenSelected?(cellModel, true)
            cellModel.whenClick?(cellModel)
        }
        if let forwardDelegate = self.forwardDelegate {
            forwardDelegate.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }
    
    private func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? LUITableViewCellProtocol {
            cell.tableView(tableView, didSelectCell: false)
        }
        if let cellModel = self.cellModelAtIndexPath(indexPath) {
            self.deselectCellModel(cellModel)
            cellModel.whenSelected?(cellModel, false)
            if tableView.allowsMultipleSelection {
                cellModel.whenClick?(cellModel)
            }
        }
        if let forwardDelegate = self.forwardDelegate {
            forwardDelegate.tableView?(tableView, didDeselectRowAt: indexPath)
        }
    }
    
    // MARK: - Display customization
    
    private func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cellModel = self.cellModelAtIndexPath(indexPath), let tableCell = cell as? LUITableViewCellProtocol {
            tableCell.tableView(tableView, willDisplayCellModel: cellModel)
        }
        if let forwardDelegate = self.forwardDelegate {
            forwardDelegate.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    
    private func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? LUITableViewSectionViewProtocol, let sectionModel = self.sectionModelAtIndex(section) {
            headerView.tableView(tableView, willDisplaySectionModel: sectionModel, kind: .head)
        }
        if let forwardDelegate = self.forwardDelegate {
            forwardDelegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
        }
    }
    
    private func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footView = view as? LUITableViewSectionViewProtocol, let sectionModel = self.sectionModelAtIndex(section) {
            footView.tableView(tableView, willDisplaySectionModel: sectionModel, kind: .foot)
        }
        if let forwardDelegate = self.forwardDelegate {
            forwardDelegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
        }
    }
    
    private func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cellModel = self.cellModelAtIndexPath(indexPath), let tableCell = cell as? LUITableViewCellProtocol {
            tableCell.tableView(tableView, didEndDisplayingCellModel: cellModel)
        }
        if let forwardDelegate = self.forwardDelegate {
            forwardDelegate.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        }
    }
    
    private func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let headView = view as? LUITableViewSectionViewProtocol, let sectionModel = self.sectionModelAtIndex(section) {
            headView.tableView(tableView, didEndDisplayingSectionModel: sectionModel, kind: .head)
        }
        if let forwardDelegate = self.forwardDelegate {
            forwardDelegate.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
        }
    }
    
    private func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if let footView = view as? LUITableViewSectionViewProtocol, let sectionModel = self.sectionModelAtIndex(section) {
            footView.tableView(tableView, didEndDisplayingSectionModel: sectionModel, kind: .foot)
        }
        if let forwardDelegate = self.forwardDelegate {
            forwardDelegate.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
        }
    }
}
