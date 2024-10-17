//
//  LUIChatHeadViewTableViewCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatHeadViewTableViewCell: LUIChatMsgTableViewCellBase {
    private lazy var chatHeaderView: LUIChatHeaderView = {
        return LUIChatHeaderView.init()
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.chatHeaderView)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.chatHeaderView], param: .H_T_C, contentInsets: .zero, interitemSpacing: 0)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customLayoutSubviews() {
        super.customLayoutSubviews()
        self.flowlayout?.bounds = self.contentView.bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func customReloadCellModel() {
        self.chatHeaderView.loadDataWithCellModel(cellModel: self.cellModel)
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        return self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
    }
}
