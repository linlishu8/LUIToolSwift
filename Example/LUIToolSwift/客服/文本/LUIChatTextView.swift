//
//  LUIChatTextView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatTextView: LUIChatBaseView, UITextViewDelegate {
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.white
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
        self.textView.text = "我来输入点子阿斯蒂芬撒旦法"
        if let text = cellModel.modelValue as? String {
            self.textView.text = text
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        self.flowlayout?.bounds = bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let s = self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
        return s
    }
}
