//
//  LUIChatImageTableViewCellMine.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import LUIToolSwift

class LUIChatImageTableViewCellMine: LUIChatBubbleBaseTableViewCell {
    private lazy var chatImageView: LUIChatImageView = {
        let view = LUIChatImageView(frame: .zero)
        return view
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.chatImageView)
        self.contentView.addSubview(self.mineHeaderView)
        
        let imageWrapper = LUILayoutConstraintItemWrapper.wrapItem(self.chatImageView, fixedSize: CGSize(width: 150, height: 150))
        
        self.flowlayout = LUIFlowLayoutConstraint([imageWrapper, self.mineHeaderView], param: .H_T_R, contentInsets: self.contentInsets, interitemSpacing: 5)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customReloadCellModel() {
        self.chatImageView.loadDataWithCellModel(cellModel: self.cellModel)
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
