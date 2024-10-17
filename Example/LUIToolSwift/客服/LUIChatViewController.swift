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
        
        let headGridModel = LUIChatModel()
        headGridModel.cellClass = LUIChatHeadGridTableViewCell.self
        list.append(headGridModel)
        
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
        
        let textOtherModel2 = LUIChatModel()
        textOtherModel2.cellClass = LUIChatTextTableViewCellOther.self
        textOtherModel2.attrTitle = self.attributedString()
        textOtherModel2.isSelf = false
        list.append(textOtherModel2)
        
        let imageMineModel = LUIChatModel()
        imageMineModel.cellClass = LUIChatImageTableViewCellMine.self
        imageMineModel.isSelf = true
        imageMineModel.msgImage = "WX233135"
        list.append(imageMineModel)
        
        return list
    }()
    
    private let attributedString = {
        let attributedString = NSMutableAttributedString(string: "这是一段示例文本。点击这里跳转这是一段示例文本。点击这里跳转这是一段示例文本。点击这里跳转这是一段示例文本。网页地址。")
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange(location: 10, length: 4))
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(location: 10, length: 4))
        attributedString.addAttribute(.link, value: "yourAppScheme://do_something", range: NSRange(location: 16, length: 4))
        
        // 添加链接
        let linkRange = (attributedString.string as NSString).range(of: "网页地址")
        attributedString.addAttribute(.link, value: "https://www.baidu.com", range: linkRange)
        return attributedString
    }
    
    
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
