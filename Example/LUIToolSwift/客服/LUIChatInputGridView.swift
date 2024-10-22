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
        let layout = LUICollectionViewPageFlowLayout.init()
        layout.pagingCellPosition = 0;
        layout.pagingBoundsPosition = 0;
        layout.interitemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        layout.itemSize = CGSize(width: 50, height: 50)
        
        let collectionView = LUICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.collectionView)
        self.__reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func __reloadData() {
        let collectionData = ["lui_chat_input_grid_1"]
        self.collectionView.model.removeAllSectionModels()
        for data in collectionData {
            let cellModel = LUICollectionViewCellModel.init()
            cellModel.cellClass = LUIChatInputGridCollectionCell.self
            cellModel.modelValue = data
            self.collectionView.model.addCellModel(cellModel)
        }
        self.collectionView.model.reloadCollectionViewData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        self.collectionView.frame = bounds
    }
}
