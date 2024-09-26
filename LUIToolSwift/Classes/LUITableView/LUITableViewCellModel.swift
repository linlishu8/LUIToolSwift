//
//  LUITableViewCellModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUITableViewCellModel: LUICollectionCellModel {
    
    var cellClass: LUITableViewCellBase.Type?
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
    var cellStyle: UITableViewCellStyle = .default
    
    var needReloadCell: Bool = false

    var reuseIdentity: String {
        return String(describing: cellClass)
    }

    static func model(withValue modelValue: Any?, cellClass: LUITableViewCellBase.Type, whenClick: ((LUITableViewCellModel) -> Void)? = nil) -> LUITableViewCellModel {
        let model = LUITableViewCellModel()
        model.cellClass = cellClass
        model.whenClick = whenClick
        return model
    }

    required init() {
        self.cellClass = LUITableViewCellBase.self
        super.init()
    }

    var tableView: UITableView? {
        return tableViewModel?.tableView
    }

    var tableViewModel: LUITableViewModel? {
        return collectionModel as? LUITableViewModel
    }

    func displayCell(_ cell: LUITableViewCellBase) {
        let isCellModelChanged = self.needReloadCell
                              || cell.cellModel !== self
                              || self.tableViewCell !== cell

        cell.cellModel = self
        self.tableViewCell = cell

        self.whenShow?(self, cell)

        if isCellModelChanged {
            cell.setNeedsLayout()
        }
    }

    func refresh() {
        guard let indexPath = self.tableViewModel?.indexPathOfCellModel(self) else { return }
        self.needReloadCell = true
        self.tableView?.reloadRows(at: [indexPath], with: .automatic)
    }

    func refreshWithAnimated(_ animated: Bool) {
        guard let indexPath = self.tableViewModel?.indexPathOfCellModel(self) else { return }
        self.needReloadCell = true
        self.tableView?.reloadRows(at: [indexPath], with: animated ? .automatic : .none)
        if self.selected {
            self.tableView?.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
        }
    }

    func deselectCellWithAnimated(_ animated: Bool) {
        setSelected(false, animated: animated)
    }

    func selectCellWithAnimated(_ animated: Bool) {
        setSelected(true, animated: animated)
    }

    func setSelected(_ selected: Bool, animated: Bool) {
        self.tableViewModel?.setCellModel(self, selected: selected, animated: animated)
    }

    func didClickSelf() {
        whenClick?(self)
    }

    func didClickAccessorySelf() {
        whenClickAccessory?(self)
    }

    func didSelectedSelf(_ selected: Bool) {
        whenSelected?(self, selected)
    }

    func didDeleteSelf() {
        whenDelete?(self)
    }
    
    func setFocused(_ focused: Bool, refreshed: Bool) {
        guard let tableViewModel = self.tableViewModel else {
            self.focused = focused
            return
        }
        if focused {
            guard let oldCM = tableViewModel.cellModelForFocusedCellModel() as? LUITableViewCellModel, oldCM !== self else { return }
            oldCM.focused = false
            oldCM.refreshWithAnimated(true)
            self.focused = true
            if refreshed {
                self.refreshWithAnimated(true)
                guard let indexPathInModel = self.indexPathInModel else { return }
                self.tableView?.scrollToRow(at: indexPathInModel, at: .middle, animated: true)
            }
        } else {
            self.tableViewModel?.focusCellModel(self, focused: false)
            if refreshed {
                self.refreshWithAnimated(true)
            }
        }
    }

    func removeFromModelWithAnimated(_ animated: Bool) {
        //todo
//        tableViewModel?.removeCellModel(self, animated: animated)
    }
    
    func editActions() -> [UITableViewRowAction] {
        var editActions: [UITableViewRowAction] = []
        guard let swipeActions: [LUITableViewCellSwipeAction] = self.swipeActions else { return editActions }
        for swipeAction in swipeActions {
            editActions.append(swipeAction.tableViewRowActionWithCellModel(self))
        }
        return editActions
    }

    @available(iOS 11.0, *)
    func swipeActionsConfigurationWithIndexPath(_ indexPath: IndexPath, leading: Bool) -> UISwipeActionsConfiguration? {
        guard let swipeActions = leading ? leadingSwipeActions : swipeActions else { return nil }

        let contextualActions = swipeActions.map { $0.contextualActionWithCellModel(self) }
        let config = UISwipeActionsConfiguration(actions: contextualActions)
        config.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
        return config
    }
}
