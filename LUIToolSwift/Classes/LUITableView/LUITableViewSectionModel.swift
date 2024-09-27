//
//  UITableViewSectionModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

public class LUITableViewSectionModel: LUICollectionSectionModel {
    var indexTitle: String = ""
    var headViewClass: LUITableViewSectionViewProtocol.Type = LUITableViewSectionView.self
    var footViewClass: LUITableViewSectionViewProtocol.Type = LUITableViewSectionView.self
    
    var showHeadView: Bool = false
    var showFootView: Bool = false
    var showDefaultHeadView: Bool = false
    var showDefaultFootView: Bool = false
    var headViewHeight: CGFloat = 0
    var footViewHeight: CGFloat = 0
    var headTitle: String = ""
    var footTitle: String = ""
    
    weak var tableView: UITableView? {
        return tableViewModel?.tableView
    }
    weak var tableViewModel: LUITableViewModel? {
        if let collectionModel = super.collectionModel as? LUITableViewModel {
            return collectionModel
        }
        return nil
    }
    
    var whenShowHeadView: ((LUITableViewSectionModel, UIView) -> Void)?
    var whenShowFootView: ((LUITableViewSectionModel, UIView) -> Void)?
    
    override func cellModelAtIndex(_ index: Int) -> LUITableViewCellModel? {
        if let cellModel = super.cellModelAtIndex(index) as? LUITableViewCellModel {
            return cellModel
        }
        return nil
    }
    
    // 初始化显示空白头部
    init(blankHeadViewHeight: CGFloat) {
        super.init()
        self.showDefaultHeadViewWithHeight(height: blankHeadViewHeight)
        self.showDefaultFootViewWithHeight(height: 0.1)
    }
    
    // 初始化显示空白尾部
    init(blankFootViewHeight: CGFloat) {
        super.init()
        self.showDefaultHeadViewWithHeight(height: 0.1)
        self.showDefaultFootViewWithHeight(height: blankFootViewHeight)
    }
    
    // 初始化显示空白头部/尾部
    init(blankHeadViewHeight: CGFloat, blankFootViewHeight: CGFloat) {
        super.init()
        self.showDefaultHeadViewWithHeight(height: blankHeadViewHeight)
        self.showDefaultFootViewWithHeight(height: blankFootViewHeight)
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
    
    func refresh() {
        refreshWithAnimated(false)
    }
    
    func refreshWithAnimated(_ animated: Bool) {
        guard let safeTableView = tableView else { return }
        guard let safeModels = cellModels as? [LUITableViewCellModel] else { return }
        for cellModel in safeModels {
            cellModel.needReloadCell = true
        }
        guard let set = tableViewModel?.indexSetOfSectionModel(self) else { return }
        safeTableView.reloadSections(set, with: animated ? .none : .automatic )
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cellModels.forEach { cm in
                if cm.selected {
                    safeTableView.selectRow(at: cm.indexPathInModel, animated: animated, scrollPosition: .none)
                }
            }
        }
    }
}
