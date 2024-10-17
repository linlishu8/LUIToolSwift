//
//  LUIChatHeadGridTableViewCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import LUIToolSwift

class LUIChatHeadGridTableViewCell: LUIChatMsgTableViewCellBase {
    private lazy var chatHeaderCollectionView: LUIChatHeaderCollectionView = {
        return LUIChatHeaderCollectionView.init()
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.chatHeaderCollectionView)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.chatHeaderCollectionView], param: .H_T_C, contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0), interitemSpacing: 0)
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
        self.chatHeaderCollectionView.loadDataWithCellModel(cellModel: self.cellModel)
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        return self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
    }
}
