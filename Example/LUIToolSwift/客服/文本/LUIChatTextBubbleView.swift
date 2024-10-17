//
//  LUIChatTextBubbleView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import LUIToolSwift

class LUIChatTextBubbleView: LUIChatBaseBubbleView {
    private lazy var textView: LUIChatTextView = {
        let textView = LUIChatTextView(frame: .zero)
        return textView
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.textView)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.textView], param: .H_C_C, contentInsets: self.chatTextMargin, interitemSpacing: 0)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func loadDataWithCellModel(cellModel: LUITableViewCellModel) {
        self.textView.loadDataWithCellModel(cellModel: cellModel)
    }
}

class LUIChatTextBubbleMineView: LUIChatTextBubbleView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.mineView = LUIChatBackgroundMineView()
        self.bgView.addSubview(self.mineView!)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mineView?.frame = bounds
    }
}
