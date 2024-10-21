//
//  LUIChatViewController.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatViewController: UIViewController {
    
    var inputViewHeight: CGFloat = 70
    // 键盘的高度
    var bottomConstraint: NSLayoutConstraint?
    var keyboardHeight: CGFloat = 0
    
    let chatInputView = LUIChatInputView()
    
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
        
        self.setupInputView()
        self.setupTableView()
        
        chatInputView.heightDidChange = { [weak self] in
            self?.scrollToBottom()
        }
        
        // 监听键盘显示和隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setupTableView() {
        self.view.addSubview(self.chatTableView)
        self.reloadTableView()
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: chatInputView.topAnchor)
        ])
    }
    
    private func setupInputView() {
        view.addSubview(chatInputView)
        chatInputView.translatesAutoresizingMaskIntoConstraints = false
        
        // 创建 bottomConstraint，将 inputViewContainer 底部与 view 的 safeAreaLayoutGuide 底部关联
        bottomConstraint = chatInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            chatInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint!  // 激活约束
        ])
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height  // 获取键盘高度
            adjustViewForKeyboard(up: true, keyboardHeight: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustViewForKeyboard(up: false, keyboardHeight: 0)
    }
    
    private func adjustViewForKeyboard(up: Bool, keyboardHeight: CGFloat) {
        // 动画调整约束
        UIView.animate(withDuration: 0.3) {
            if up {
                // 键盘弹出时，将输入框移动到键盘上方，并忽略 safeAreaLayoutGuide
                self.bottomConstraint?.constant = -keyboardHeight
            } else {
                // 键盘收起时，恢复到 safeAreaLayoutGuide 的底部
                self.bottomConstraint?.constant = 0
            }
            self.view.layoutIfNeeded()
        }
        
        if up {
            scrollToBottom()  // 键盘弹出时滚动到最新消息
        }
    }
    
    
    // 滚动到 TableView 底部
    func scrollToBottom() {
        guard chatTableView.numberOfSections > 0 else { return }
        let lastRow = chatTableView.numberOfRows(inSection: 0) - 1
        if lastRow >= 0 {
            let indexPath = IndexPath(row: lastRow, section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var bounds = self.view.bounds
        bounds.size.height = 240
        self.backImage.frame = bounds
    }
    
    
    deinit {
        
    }
}
