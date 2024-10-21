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
    let moreButton = UIButton(type: .custom)
    var heightDidChange: (() -> Void)?
    var onSendText: ((String) -> Void)?
    
    var maxTextViewHeight: CGFloat = 100
    var inputViewHeightConstraint: NSLayoutConstraint?
    
    private var customInputView: UIView!
    private let customInputViewHeight: CGFloat = 200  // 自定义视图的高度
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustomInputView()
        setupViews()
        
    }
    
    private func setupCustomInputView() {
        customInputView = UIView()
        customInputView.backgroundColor = UIColor.lightGray
        customInputView.isHidden = true
        addSubview(customInputView)
        
        customInputView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customInputView.leadingAnchor.constraint(equalTo: leadingAnchor),
            customInputView.trailingAnchor.constraint(equalTo: trailingAnchor),
            customInputView.bottomAnchor.constraint(equalTo: bottomAnchor),
            customInputView.heightAnchor.constraint(equalToConstant: customInputViewHeight)
        ])
    }
    
    @objc private func toggleCustomInputView() {
        let shouldShow = customInputView.isHidden
        UIView.animate(withDuration: 0.3, animations: {
            self.customInputView.alpha = shouldShow ? 1 : 0
            self.customInputView.isHidden = !shouldShow
            self.inputViewHeightConstraint?.constant = shouldShow ? 50 + self.customInputViewHeight : 50
            self.layoutIfNeeded()
        })
        heightDidChange?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // 设置发送按钮
        moreButton.setImage(UIImage(named: "lui_chat_input_more"), for: .normal)
        moreButton.addTarget(self, action: #selector(toggleCustomInputView), for: .touchUpInside)
        addSubview(moreButton)
        
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
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            moreButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            moreButton.widthAnchor.constraint(equalToConstant: 40),
            moreButton.heightAnchor.constraint(equalToConstant: 40),
            
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textView.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        inputViewHeightConstraint = heightAnchor.constraint(equalToConstant: 50)
        inputViewHeightConstraint?.isActive = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fittingSize = CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let size = textView.sizeThatFits(fittingSize)
        let newHeight = min(max(size.height, 36), maxTextViewHeight)
        textView.isScrollEnabled = newHeight == maxTextViewHeight
        inputViewHeightConstraint?.constant = newHeight + (customInputView.isHidden ? 0 : customInputViewHeight)
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        heightDidChange?()
    }
}
