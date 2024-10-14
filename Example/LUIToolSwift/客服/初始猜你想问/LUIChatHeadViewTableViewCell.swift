//
//  LUIChatHeadViewTableViewCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatHeadViewTableViewCell: LUIChatMsgTableViewCellBase {
    private lazy var chatHeaderView: LUIChatHeaderView = {
        return LUIChatHeaderView.init()
    }()
    private lazy var chatHeaderCollectionView: LUIChatHeaderCollectionView = {
        return LUIChatHeaderCollectionView.init()
    }()
    private var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.chatHeaderView)
        self.contentView.addSubview(self.chatHeaderCollectionView)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.chatHeaderView, self.chatHeaderCollectionView], param: .V_T_C, contentInsets: .zero, interitemSpacing: 10)
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
        self.chatHeaderCollectionView.loadDataWithCellModel(cellModel: self.cellModel)
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        return self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
    }
}
