//
//  LUIChatHeaderCollectionView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/14.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatHeaderCollectionView: LUIChatBaseView {
    private lazy var collectionView: LUICollectionFlowLayoutView = {
        let collectionView = LUICollectionFlowLayoutView.init(frame: .zero)
        return collectionView
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.collectionView)
        self.flowlayout = LUIFlowLayoutConstraint([self.collectionView], param: .H_C_C, contentInsets: .zero, interitemSpacing: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadDataWithCellModel(cellModel: LUITableViewCellModel) {
        self.__reloadData()
    }
    
    private func __reloadData() {
        let collectionData = ["我的资产", "理财产品", "转账汇款", "基金代销", "我要贷款"]
        self.collectionView.model.removeAllSectionModels()
        for data in collectionData {
            let cellModel = LUICollectionViewCellModel.init()
            cellModel.cellClass = LUIChatHeadViewCollectionCell.self
            cellModel.modelValue = data
            self.collectionView.model.addCellModel(cellModel)
        }
        self.collectionView.model.reloadCollectionViewData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.flowlayout?.bounds = self.bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
    }
}
