//
//  LUITableViewCellProtocol.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

protocol LUITableViewCellProtocol: AnyObject {
    static func height(with tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat
    static func estimatedHeight(with tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat
    
    var cellModel: LUITableViewCellModel? { get set }
    func tableView(_ tableView: UITableView, didSelectCell selected: Bool)
    func tableView(_ tableView: UITableView, willDisplay cellModel: LUITableViewCellModel)
    func tableView(_ tableView: UITableView, didEndDisplaying cellModel: LUITableViewCellModel)
}

class LUITableViewCellClass: UITableViewCell, LUITableViewCellProtocol {
    static func height(with tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat {
        return 0
    }
    
    static func estimatedHeight(with tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat {
        return 0
    }
    
    var cellModel: LUITableViewCellModel?
    
    func tableView(_ tableView: UITableView, didSelectCell selected: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cellModel: LUITableViewCellModel) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cellModel: LUITableViewCellModel) {
        
    }
    
    
}
