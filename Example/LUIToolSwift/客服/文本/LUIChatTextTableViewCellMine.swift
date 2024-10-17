//
//  LUIChatTextTableViewCellMine.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatTextTableViewCellMine: LUIChatBubbleBaseTableViewCell {
    private lazy var textView: LUIChatTextBubbleMineView = {
        let textView = LUIChatTextBubbleMineView(frame: .zero)
        return textView
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.mineHeaderView)
        self.contentView.addSubview(self.textView)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.textView, self.mineHeaderView], param: .H_T_R, contentInsets: self.contentInsets, interitemSpacing: 10)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customReloadCellModel() {
//        self.cellModel["text"] = "测试文字测试文字"
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
