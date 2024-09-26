//
//  LUITableViewSectionViewProtocol.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

enum LUITableViewSectionViewKind {
    case head // 头部
    case foot // 尾部
}

protocol LUITableViewSectionViewProtocol: AnyObject {
    static func heightWithTableView(_: UITableView, sectionModel: LUITableViewSectionModel, kind: LUITableViewSectionViewKind) -> CGFloat
    
    func setSectionModel(_ sectionModel: LUITableViewSectionModel?, kind: LUITableViewSectionViewKind)

    func tableView(_: UITableView, willDisplaySectionModel sectionModel: LUITableViewSectionModel, kind: LUITableViewSectionViewKind)
    
    func tableView(_: UITableView, didEndDisplayingSectionModel sectionModel: LUITableViewSectionModel, kind: LUITableViewSectionViewKind)
}
