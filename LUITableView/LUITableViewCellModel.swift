//
//  LUITableViewCellModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUITableViewCellModel: LUICollectionCellModel {
    
    var cellClass: UITableViewCell.Type = UITableViewCell.self
    var indexTitle: String?
    var canEdit: Bool = false
    var canMove: Bool = false

    var whenClick: ((LUITableViewCellModel) -> Void)?
    var whenSelected: ((LUITableViewCellModel, Bool) -> Void)?
    var whenClickAccessory: ((LUITableViewCellModel) -> Void)?
    var whenDelete: ((LUITableViewCellModel) -> Void)?
    var whenMove: ((LUITableViewCellModel, LUITableViewCellModel) -> Void)?
    var whenShow: ((LUITableViewCellModel, UITableViewCell) -> Void)?

    var swipeActions: [LUITableViewCellSwipeAction]?
    var performsFirstActionWithFullSwipe: Bool = true
    var leadingSwipeActions: [LUITableViewCellSwipeAction]?

    weak var tableViewCell: UITableViewCell?
    
    var needReloadCell: Bool = false

    var reuseIdentity: String {
        return String(describing: cellClass)
    }

    static func model(withValue modelValue: Any?, cellClass: UITableViewCell.Type, whenClick: ((LUITableViewCellModel) -> Void)? = nil) -> LUITableViewCellModel {
        let model = LUITableViewCellModel()
        model.cellClass = cellClass
        model.whenClick = whenClick
        return model
    }

    required init() {
        super.init()
        self.cellClass = UITableViewCell.self
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! LUITableViewCellModel
        copy.cellClass = self.cellClass
        copy.indexTitle = self.indexTitle
        copy.canEdit = self.canEdit
        copy.canMove = self.canMove
        copy.whenClick = self.whenClick
        copy.whenSelected = self.whenSelected
        copy.whenClickAccessory = self.whenClickAccessory
        copy.whenDelete = self.whenDelete
        copy.whenMove = self.whenMove
        copy.whenShow = self.whenShow
        copy.swipeActions = self.swipeActions
        copy.performsFirstActionWithFullSwipe = self.performsFirstActionWithFullSwipe
        copy.leadingSwipeActions = self.leadingSwipeActions
        copy.tableViewCell = self.tableViewCell
        copy.needReloadCell = self.needReloadCell
        return copy
    }

    var tableView: UITableView? {
        return tableViewModel?.tableView
    }

    var tableViewModel: LUITableViewModel? {
        return collectionModel as? LUITableViewModel
    }

    func displayCell(_ cell: UITableViewCell) {
        let isCellModelChanged = needReloadCell || (cell.tableViewCellModel !== self) || (self.tableViewCell !== cell)
        cell.tableViewCellModel = self
        self.tableViewCell = cell
        whenShow?(self, cell)
        if isCellModelChanged {
            cell.setNeedsLayout()
        }
    }

    func refresh() {
        guard let indexPath = tableViewModel?.indexPath(of: self) else { return }
        needReloadCell = true
        tableView?.reloadRows(at: [indexPath], with: .automatic)
    }

    func refresh(animated: Bool) {
        guard let indexPath = tableViewModel?.indexPath(of: self) else { return }
        needReloadCell = true
        tableView?.reloadRows(at: [indexPath], with: animated ? .automatic : .none)
        if isSelected {
            tableView?.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
        }
    }

    func selectCell(animated: Bool) {
        setSelected(true, animated: animated)
    }

    func deselectCell(animated: Bool) {
        setSelected(false, animated: animated)
    }

    func setSelected(_ selected: Bool, animated: Bool) {
        tableViewModel?.setCellModel(self, selected: selected, animated: animated)
    }

    func didClick() {
        whenClick?(self)
    }

    func didClickAccessory() {
        whenClickAccessory?(self)
    }

    func didSelect(_ selected: Bool) {
        whenSelected?(self, selected)
    }

    func didDelete() {
        whenDelete?(self)
    }

    func removeFromModel(animated: Bool) {
        tableViewModel?.removeCellModel(self, animated: animated)
    }

    func swipeActionsConfiguration(for indexPath: IndexPath, leading: Bool) -> UISwipeActionsConfiguration? {
        let actions = leading ? leadingSwipeActions : swipeActions
        guard let swipeActions = actions, !swipeActions.isEmpty else { return nil }

        let contextualActions = swipeActions.map { $0.contextualAction(with: self) }
        let config = UISwipeActionsConfiguration(actions: contextualActions)
        config.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
        return config
    }

    override var description: String {
        return "\(super.description):[cellClass: \(cellClass), userInfo: \(userInfo)]"
    }
}
