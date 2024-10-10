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
        tableView.l_hiddenFooterAreaSeparators()
        return tableView
    }()
    
    private lazy var backImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "liu_chat_header_bg"))
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "在线客服";
        self.view.backgroundColor = UIColor(hex: "F9F9F9")
        self.view.addSubview(self.backImage)
        self.view.addSubview(self.chatTableView)
        
        self.reloadTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var bounds = self.view.bounds
        bounds.size.height = 240
        self.backImage.frame = bounds
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
