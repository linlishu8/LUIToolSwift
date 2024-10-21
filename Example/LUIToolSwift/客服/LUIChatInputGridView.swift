//
//  LUIChatInputGridView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/21.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatInputGridView: LUIChatBaseView {
    private lazy var collectionView: LUICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsets.LUIEdgeInsetsMakeSameEdge(10);
        
        let collectionView = LUICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.backgroundColor = .clear
        
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
