//
//  LUITableViewCellProtocol.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

protocol LUITableViewCellProtocol: AnyObject {
    static func heightWithTableView(_ tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat
    static func estimatedHeightWithTableView(_ tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat
    
    func tableView(_ tableView: UITableView, didSelectCell selected: Bool)
    func tableView(_ tableView: UITableView, willDisplayCellModel cellModel: LUITableViewCellModel)
    func tableView(_ tableView: UITableView, didEndDisplayingCellModel cellModel: LUITableViewCellModel)
}
