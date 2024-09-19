//
//  UITableViewSectionModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUITableViewSectionModel: LUICollectionSectionModel {
    var indexTitle: String?
    var headViewClass: LUITableViewSectionViewProtocol.Type?
    var footViewClass: LUITableViewSectionViewProtocol.Type?
    
    var showHeadView: Bool = false
    var showFootView: Bool = false
    var showDefaultHeadView: Bool = false
    var showDefaultFootView: Bool = false
    var headViewHeight: CGFloat = 0
    var footViewHeight: CGFloat = 0
    var headTitle: String?
    var footTitle: String?
    
    weak var tableView: UITableView? {
        return tableViewModel?.tableView
    }
    weak var tableViewModel: LUITableViewModel?
    
    var whenShowHeadView: ((LUITableViewSectionModel, UIView) -> Void)?
    var whenShowFootView: ((LUITableViewSectionModel, UIView) -> Void)?
    
    // 初始化显示空白头部
    init(blankHeadViewHeight: CGFloat) {
        super.init()
        showDefaultHeadViewWithHeight(height: blankHeadViewHeight)
        showDefaultFootViewWithHeight(height: 0.1)
    }
    
    // 初始化显示空白尾部
    init(blankFootViewHeight: CGFloat) {
        super.init()
        showDefaultHeadViewWithHeight(height: 0.1)
        showDefaultFootViewWithHeight(height: blankFootViewHeight)
    }
    
    // 初始化显示空白头部/尾部
    init(blankHeadViewHeight: CGFloat, blankFootViewHeight: CGFloat) {
        super.init()
        showDefaultHeadViewWithHeight(height: blankHeadViewHeight)
        showDefaultFootViewWithHeight(height: blankFootViewHeight)
    }
    
    // 设置默认的头部视图高度
    func showDefaultHeadViewWithHeight(height: CGFloat) {
        showHeadView = true
        showDefaultHeadView = true
        headViewHeight = height
    }
    
    // 设置默认的尾部视图高度
    func showDefaultFootViewWithHeight(height: CGFloat) {
        showFootView = true
        showDefaultFootView = true
        footViewHeight = height
    }
    
    // 返回指定索引的单元格模型
    func cellModel(at index: Int) -> LUITableViewCellModel? {
        return super.cellModel(at: index) as? LUITableViewCellModel
    }
    
    // 显示自定义的头部视图
    func displayHeadView(_ view: UIView & LUITableViewSectionViewProtocol) {
        view.setSectionModel(self, kind: .head)
        whenShowHeadView?(self, view)
        view.setNeedsLayout()
    }
    
    // 显示自定义的尾部视图
    func displayFootView(_ view: UIView & LUITableViewSectionViewProtocol) {
        view.setSectionModel(self, kind: .foot)
        whenShowFootView?(self, view)
        view.setNeedsLayout()
    }
    
    // 刷新 Section
    func refresh(animated: Bool = false) {
        guard let tableView = tableView else { return }
        
        for cellModel in cellModels as! [LUITableViewCellModel] {
            cellModel.needReloadCell = true
        }
        
        if let indexSet = tableViewModel?.indexSet(of: self) {
            tableView.reloadSections(indexSet, with: animated ? .none : .automatic)
        }
        
        DispatchQueue.main.async {
            for cellModel in self.cellModels as! [LUITableViewCellModel] {
                if cellModel.selected {
                    tableView.selectRow(at: cellModel.indexPathInModel, animated: animated, scrollPosition: .none)
                }
            }
        }
    }
    
    // Debug
    override var description: String {
        return "\(String(describing: type(of: self))): [indexTitle: \(indexTitle ?? ""), showHeadView: \(showHeadView), headTitle: \(headTitle ?? ""), headViewHeight: \(headViewHeight), showFootView: \(showFootView), footTitle: \(footTitle ?? ""), footViewHeight: \(footViewHeight), cells: \(cellModels), userInfo: \(userInfo)]"
    }
    
    deinit {
    }
            
}
