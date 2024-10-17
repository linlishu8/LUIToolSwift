//
//  LUIChatTextTableViewCellOther.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatTextTableViewCellOther: LUIChatBubbleBaseTableViewCell {
    private lazy var textView: LUIChatTextBubbleOtherView = {
        let textView = LUIChatTextBubbleOtherView(frame: .zero)
        return textView
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.otherHeaderView)
        self.contentView.addSubview(self.textView)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.otherHeaderView, self.textView], param: .H_T_L, contentInsets: self.contentInsets, interitemSpacing: 5)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customReloadCellModel() {
        self.textView.loadDataWithCellModel(cellModel: self.cellModel)
    }
    
    override func customLayoutSubviews() {
        let bounds = self.contentView.bounds
        self.flowlayout?.bounds = bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        return self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
    }
}
