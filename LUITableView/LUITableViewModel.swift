//
//  LUITableViewModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUITableViewModel: LUICollectionModel {
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
    
    // MARK: - Initialization
    init(tableView: UITableView) {
        super.init()
        self.setTableViewDataSourceAndDelegate(tableView)
        self.defaultSectionIndexTitle = "#"
        self.reuseCell = true
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    // MARK: - Empty Background
    private func createEmptyBackgroundView() -> UIView? {
        guard let classType = emptyBackgroundViewClass else { return nil }
        return classType.init()
    }
    
    func reloadTableViewBackgroundView() {
        guard emptyBackgroundViewClass != nil || emptyBackgroundView != nil else { return }
        
        if numberOfCells == 0 {
            if emptyBackgroundView == nil {
                emptyBackgroundView = createEmptyBackgroundView()
            }
            tableView?.backgroundView = emptyBackgroundView
        } else {
            tableView?.backgroundView = nil
        }
        
        whenReloadBackgroundView?(self)
    }
    
    // MARK: - Forward Invocations
    override func methodSignature(for selector: Selector) -> NSMethodSignature? {
        if let signature = super.methodSignature(for: selector) {
            return signature
        }
        
        if let delegate = forwardDelegate, delegate.responds(to: selector) {
            return delegate.methodSignature(for: selector)
        } else if let delegate = forwardDataSource, delegate.responds(to: selector) {
            return delegate.methodSignature(for: selector)
        }
        
        return nil
    }
    
    override func responds(to selector: Selector) -> Bool {
        if super.responds(to: selector) {
            return true
        }
        
        if let delegate = forwardDelegate, delegate.responds(to: selector) {
            return true
        } else if let delegate = forwardDataSource, delegate.responds(to: selector) {
            return true
        }
        
        if !hiddenSectionHeadView {
            if selector == #selector(tableView(_:heightForHeaderInSection:)) ||
                selector == #selector(tableView(_:titleForHeaderInSection:)) ||
                selector == #selector(tableView(_:viewForHeaderInSection:)) {
                return true
            }
        }
        
        if !hiddenSectionFootView {
            if selector == #selector(tableView(_:heightForFooterInSection:)) ||
                selector == #selector(tableView(_:titleForFooterInSection:)) ||
                selector == #selector(tableView(_:viewForFooterInSection:)) {
                return true
            }
        }
        
        return false
    }
    
    override func forwardInvocation(_ invocation: NSInvocation) {
        var didForward = false
        
        if let delegate = forwardDelegate, delegate.responds(to: invocation.selector) {
            invocation.invoke(with: delegate)
            didForward = true
        }
        
        if !didForward, let delegate = forwardDataSource, delegate.responds(to: invocation.selector) {
            invocation.invoke(with: delegate)
            didForward = true
        }
        
        if !didForward {
            var responds = false
            
            if !hiddenSectionHeadView {
                if invocation.selector == #selector(tableView(_:heightForHeaderInSection:)) {
                    invocation.selector = #selector(__tableView(_:heightForHeaderInSection:))
                    responds = true
                } else if invocation.selector == #selector(tableView(_:titleForHeaderInSection:)) {
                    invocation.selector = #selector(__tableView(_:titleForHeaderInSection:))
                    responds = true
                } else if invocation.selector == #selector(tableView(_:viewForHeaderInSection:)) {
                    invocation.selector = #selector(__tableView(_:viewForHeaderInSection:))
                    responds = true
                }
            }
            
            if !hiddenSectionFootView {
                if invocation.selector == #selector(tableView(_:heightForFooterInSection:)) {
                    invocation.selector = #selector(__tableView(_:heightForFooterInSection:))
                    responds = true
                } else if invocation.selector == #selector(tableView(_:titleForFooterInSection:)) {
                    invocation.selector = #selector(__tableView(_:titleForFooterInSection:))
                    responds = true
                } else if invocation.selector == #selector(tableView(_:viewForFooterInSection:)) {
                    invocation.selector = #selector(__tableView(_:viewForFooterInSection:))
                    responds = true
                }
            }
            
            if responds {
                invocation.invoke(with: self)
            } else {
                super.forwardInvocation(invocation)
            }
        }
    }
    
    override func doesNotRecognizeSelector(_ aSelector: Selector) {
        super.doesNotRecognizeSelector(aSelector)
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        let sectionModel = sectionModel(at: section)
        return sectionModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = cellModel(at: indexPath)
        var cell: UITableViewCell? = nil
        let cellClass = cellModel.cellClass
        
        if let cellClass = cellClass, !(cell is cellClass) {
            cell = nil
        }
        
        if cell == nil {
            let identity = reuseCell ? cellModel.reuseIdentity : "\(cellModel.reuseIdentity)_\(Unmanaged.passUnretained(cellModel).toOpaque())"
            cell = tableView.dequeueReusableCell(withIdentifier: identity) ?? (cellClass != nil ? cellClass!.init(style: cellModel.cellStyle, reuseIdentifier: identity) : UITableViewCell(style: .default, reuseIdentifier: identity))
        }
        
        cellModel.displayCell(cell!)
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cellModel = cellModel(at: indexPath)
        return cellModel.canEdit
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let delegate = forwardDelegate, delegate.responds(to: #selector(tableView(_:editActionsForRowAt:))) {
            return delegate.tableView?(tableView, editActionsForRowAt: indexPath)
        }
        let cellModel = cellModel(at: indexPath)
        return cellModel.editActions
    }
}
