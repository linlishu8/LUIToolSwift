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
    
    private lazy var modelList: [LUIChatModel] = {
        var list: [LUIChatModel] = []
        let headModel = LUIChatModel()
        headModel.cellClass = LUIChatHeadViewTableViewCell.self
        list.append(headModel)
        
        let textMineModel = LUIChatModel()
        textMineModel.cellClass = LUIChatTextTableViewCellMine.self
        textMineModel.title = "测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试"
        textMineModel.isSelf = true
        list.append(textMineModel)
        
        let textOtherModel = LUIChatModel()
        textOtherModel.cellClass = LUIChatTextTableViewCellOther.self
        textOtherModel.title = "别人的别人的别人的别人的别人的别人的别人的别人的别人的别人的别人的别人的别人的别人的别人的别人的"
        textOtherModel.isSelf = false
        list.append(textOtherModel)
        
        return list
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
        for chatModel in self.modelList {
            self.chatTableView.model.addCellModel(self.setupTableViewCellModel(chatModel: chatModel))
        }
        self.chatTableView.model.reloadTableViewData()
        
    }
    
    private func setupTableViewCellModel(chatModel: LUIChatModel) -> LUITableViewCellModel {
        let model = LUITableViewCellModel.init()
        model.cellClass = chatModel.cellClass as? LUITableViewCellBase.Type
        model.modelValue = chatModel
        return model
    }
    
    deinit {
        
    }
}
