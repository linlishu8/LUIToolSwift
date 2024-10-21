//
//  LUIChatTextView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatTextView: LUIChatBaseView, UITextViewDelegate {
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.white
        textView.dataDetectorTypes = .link
        return textView
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.textView)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.textView], param: .H_T_C, contentInsets: .zero, interitemSpacing: 0)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadDataWithCellModel(cellModel: LUITableViewCellModel) {
        if let modelValue = cellModel.modelValue as? LUIChatModel {
            if let text = modelValue.title {
                self.textView.text = text
                self.textView.textColor = modelValue.isSelf ?? false ? UIColor.white : UIColor.black
            } else if let attrTitle = modelValue.attrTitle {
                self.textView.attributedText = attrTitle
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        self.flowlayout?.bounds = bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // 这里可以使用 UIApplication 打开链接
        if interaction == .invokeDefaultAction {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
            return false // 返回 false 表示不执行 TextView 默认的打开操作
        }
        return true
    }
}
