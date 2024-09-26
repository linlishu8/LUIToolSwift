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
    
    var cellModel: LUITableViewCellModel? { get }
    
    func tableView(_ tableView: UITableView, didSelectCell selected: Bool)
    func tableView(_ tableView: UITableView, willDisplayCellModel cellModel: LUITableViewCellModel)
    func tableView(_ tableView: UITableView, didEndDisplayingCellModel cellModel: LUITableViewCellModel)
}

class LUITableViewCellBase: UITableViewCell, LUITableViewCellProtocol {
    var cellModel: LUITableViewCellModel?
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func heightWithTableView(_ tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    static func estimatedHeightWithTableView(_ tableView: UITableView, cellModel: LUITableViewCellModel) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, didSelectCell selected: Bool) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayCellModel cellModel: LUITableViewCellModel) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingCellModel cellModel: LUITableViewCellModel) {
        
    }
    
}
