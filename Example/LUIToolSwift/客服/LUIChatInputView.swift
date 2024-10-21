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
    let sendButton = UIButton(type: .system)
    var heightDidChange: (() -> Void)?
    var onSendText: ((String) -> Void)?
    
    var maxTextViewHeight: CGFloat = 100
    var inputViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // 设置发送按钮
        sendButton.setTitle("发送", for: .normal)
        sendButton.addTarget(self, action: #selector(sendText), for: .touchUpInside)
        addSubview(sendButton)
        
        // 设置 textView
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 4
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        addSubview(textView)
        
        // 使用自动布局
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)  // 设置最小高度
        ])
        
        inputViewHeightConstraint = heightAnchor.constraint(equalToConstant: 50)
        inputViewHeightConstraint?.isActive = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
    }
    
    private func adjustTextViewHeight() {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        var newHeight = size.height
        if newHeight > maxTextViewHeight {
            newHeight = maxTextViewHeight
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
        
        if let heightConstraint = inputViewHeightConstraint, heightConstraint.constant != newHeight + 16 {
            heightConstraint.constant = newHeight + 16
            heightDidChange?()
        }
    }
    
    @objc private func sendText() {
        guard let text = textView.text, !text.isEmpty else { return }
        onSendText?(text)
        textView.text = ""
        adjustTextViewHeight()
    }
}
