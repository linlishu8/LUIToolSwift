//
//  LUIChatInputView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/18.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class LUIChatInputView: UIView, UITextViewDelegate {
    let textView = UITextView()
    let emojiButton = UIButton(type: .system)
    let sendButton = UIButton(type: .system)
    let maxTextViewHeight: CGFloat = 100
    var heightDidChange: (() -> Void)?  // 高度变化时的回调
    var inputViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 设置 emojiButton
        emojiButton.setTitle("😊", for: .normal)
        addSubview(emojiButton)
        
        // 设置 textView
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 4
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        addSubview(textView)
        
        // 设置 sendButton
        sendButton.setTitle("发送", for: .normal)
        sendButton.isEnabled = false
        addSubview(sendButton)
        
        // 设置约束
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            emojiButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            emojiButton.widthAnchor.constraint(equalToConstant: 32),
            emojiButton.heightAnchor.constraint(equalToConstant: 32),
            
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
            
            textView.leadingAnchor.constraint(equalTo: emojiButton.trailingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)  // 设置最小高度
        ])
        
        inputViewHeightConstraint = heightAnchor.constraint(equalToConstant: 50)  // 初始高度
        inputViewHeightConstraint?.isActive = true
    }
    
    // 监听文本内容变化
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
        sendButton.isEnabled = !textView.text.isEmpty
    }
    
    // 动态调整 textView 和 inputView 的高度
    private func adjustTextViewHeight() {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        var newHeight = size.height
        
        if newHeight > maxTextViewHeight {
            newHeight = maxTextViewHeight
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
        
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = newHeight
            }
        }
        
        inputViewHeightConstraint?.constant = newHeight + 16  // 更新整体 view 的高度
        heightDidChange?()  // 通知外部 view 高度发生了变化
    }
}
