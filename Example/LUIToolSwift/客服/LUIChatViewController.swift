//
//  LUIChatViewController.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatViewController: UIViewController {
    private lazy var chatTableView: LUITableView = {
        let tableView = LUITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.l_hiddenFooterAreaSeparators()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "在线客服";
        self.view.addSubview(self.chatTableView)
        
        self.reloadTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.chatTableView.frame = self.view.bounds
    }
    
    private func reloadTableView() {
        self.chatTableView.model.addCellModel(self.setupTableViewCellModel(modelCellClass: LUIChatHeadViewTableViewCell.self))
        self.chatTableView.model.reloadTableViewData()
    }
    
    private func setupTableViewCellModel(modelCellClass: LUITableViewCellBase.Type) -> LUITableViewCellModel {
        let cellModel = LUITableViewCellModel.init()
        cellModel.cellClass = modelCellClass.self
        return cellModel
    }
}
