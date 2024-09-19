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
    
    
}
