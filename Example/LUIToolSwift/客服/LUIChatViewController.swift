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
    let chatInputView = LUIChatInputView()
    private var chatInputViewBottomConstraint: NSLayoutConstraint?
    
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
        
        self.setupTableView()
        self.setupInputView()
        
        chatInputView.heightDidChange = { [weak self] in
                self?.adjustLayoutForKeyboardOrCustomView()
            }
        
        // 监听键盘显示和隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self  // 设置委托
        view.addGestureRecognizer(tapGesture)
    }
    
    private func adjustLayoutForKeyboardOrCustomView() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()  // 更新外部视图布局以适应输入区域的变化
        }
        scrollToBottom(animated: true)  // 确保聊天内容保持在底部
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTableView() {
        self.view.addSubview(self.chatTableView)
        self.reloadTableView()
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            chatTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func setupInputView() {
        view.addSubview(chatInputView)
        chatInputView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chatInputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            chatInputView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        chatInputViewBottomConstraint = chatInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        chatInputViewBottomConstraint?.isActive = true
        chatTableView.bottomAnchor.constraint(equalTo: chatInputView.topAnchor).isActive = true
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardFrame.height
        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        // 调整输入框的底部约束
        chatInputViewBottomConstraint?.constant = -keyboardHeight + bottomPadding
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let options = UIView.AnimationOptions(rawValue: curve)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.scrollToBottom(animated: true)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        chatInputViewBottomConstraint?.constant = 0
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let options = UIView.AnimationOptions(rawValue: curve)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // 滚动到 TableView 底部
    private func scrollToBottom(animated: Bool) {
        let lastRowIndex = max(0, chatTableView.numberOfRows(inSection: 0) - 1)
        if lastRowIndex >= 0 {
            let indexPath = IndexPath(row: lastRowIndex, section: 0)
            chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
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
        NotificationCenter.default.removeObserver(self)
    }
}


extension LUIChatViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 检查触摸的视图是否为控件本身或其子视图
        if touch.view is UIControl || touch.view?.isDescendant(of: chatInputView.textView) == true {
            // 如果是控件（如按钮、开关等），或者是富文本视图的一部分，不触发手势
            return false
        }
        // 在其他情况下，触发手势
        return true
    }
}
