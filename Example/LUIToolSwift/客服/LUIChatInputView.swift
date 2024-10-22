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
    var voiceButton = UIButton(type: .custom)

    
    var heightDidChange: (() -> Void)?
    var onSendText: ((String) -> Void)?
    
    var maxTextViewHeight: CGFloat = 100
    var inputViewHeightConstraint: NSLayoutConstraint?
    
    private var textViewBottomConstraint: NSLayoutConstraint?
    private var moreButtonBottomConstraint: NSLayoutConstraint?
    
    public var customInputView: LUIChatInputGridView!
    private let customInputViewHeight: CGFloat = 110
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustomInputView()
        setupViews()
    }
    
    private func setupCustomInputView() {
        customInputView = LUIChatInputGridView()
        customInputView.backgroundColor = UIColor(hex: "F9F9F9")
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
    
    @objc public func toggleCustomInputView() {
        
        if customInputView.isHidden {
            textView.resignFirstResponder()
        }
        customInputView.isHidden.toggle()
        self.customInputView.alpha = self.customInputView.isHidden ? 0 : 1
        
        self.moreButtonBottomConstraint?.isActive = false
        self.moreButtonBottomConstraint = self.moreButton.bottomAnchor.constraint(equalTo: self.customInputView.isHidden ? self.bottomAnchor : self.customInputView.topAnchor, constant: -8)
        self.moreButtonBottomConstraint?.isActive = true
        
        self.textViewBottomConstraint?.isActive = false
        self.textViewBottomConstraint = self.textView.bottomAnchor.constraint(equalTo: self.customInputView.isHidden ? self.bottomAnchor : self.customInputView.topAnchor, constant: -8)
        self.textViewBottomConstraint?.isActive = true
        
        self.updateInputViewHeight()
        self.layoutIfNeeded()
        if self.customInputView.isHidden {
            self.customInputView.isHidden = true
        }
        
        heightDidChange?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        moreButton.setImage(UIImage(named: "lui_chat_input_more"), for: .normal)
        moreButton.addTarget(self, action: #selector(toggleCustomInputView), for: .touchUpInside)
        addSubview(moreButton)
        
        // 设置 textView
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 4
        textView.layer.borderWidth = 1
        textView.returnKeyType = .send
        textView.text = "请简短输入您的问题"
        textView.textColor = UIColor(hex: "dfdfdf")
        textView.layer.borderColor = UIColor.lightGray.cgColor
        var textEdge = textView.textContainerInset
        textEdge.right = 54
        textView.textContainerInset = textEdge
        addSubview(textView)
        if #available(iOS 13.0, *) {
            textView.overrideUserInterfaceStyle = .light
        }
        
        voiceButton.setImage(UIImage(named: "lui_chat_input_voiceinput"), for: .normal)
        addSubview(voiceButton)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 40),
            moreButton.heightAnchor.constraint(equalToConstant: 40),
            
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            voiceButton.widthAnchor.constraint(equalToConstant: 30),
            voiceButton.heightAnchor.constraint(equalToConstant: 30),
            voiceButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
            voiceButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor)
        ])
        
        moreButtonBottomConstraint = moreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        moreButtonBottomConstraint?.isActive = true
        
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        textViewBottomConstraint?.isActive = true
        
        inputViewHeightConstraint = heightAnchor.constraint(equalToConstant: 50)
        inputViewHeightConstraint?.isActive = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateInputViewHeight()
        heightDidChange?()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendText(textView.text)
            textView.text = ""
            textViewDidChange(textView)
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(hex: "dfdfdf") {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "请简短输入您的问题"
            textView.textColor = UIColor(hex: "dfdfdf")
        }
    }
    
    private func sendText(_ text: String) {
        // 实际发送文本的逻辑
        onSendText?(text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private func updateInputViewHeight() {
        let fittingSize = CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let size = textView.sizeThatFits(fittingSize)
        let newHeight = min(max(size.height, 36), maxTextViewHeight)
        textView.isScrollEnabled = newHeight == maxTextViewHeight
        
        let paddingHeight = 16  // 根据实际布局调整
        let totalHeight = newHeight + CGFloat(paddingHeight) + (customInputView.isHidden ? 0 : customInputViewHeight)
        inputViewHeightConstraint?.constant = totalHeight
        
        self.layoutIfNeeded()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if !customInputView.isHidden {
            hideCustomInputView()
        }
        return true
    }

    private func hideCustomInputView() {
        customInputView.isHidden = true
        UIView.animate(withDuration: 0.1, animations: {
            self.customInputView.alpha = 0
            
            // 更新底部约束，以确保textView正确放置
            self.moreButtonBottomConstraint?.isActive = false
            self.moreButtonBottomConstraint = self.moreButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            self.moreButtonBottomConstraint?.isActive = true

            self.textViewBottomConstraint?.isActive = false
            self.textViewBottomConstraint = self.textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            self.textViewBottomConstraint?.isActive = true

            self.updateInputViewHeight()
            self.layoutIfNeeded()
        }, completion: { _ in
            self.customInputView.isHidden = true
        })

        heightDidChange?()
    }
    
    
}
