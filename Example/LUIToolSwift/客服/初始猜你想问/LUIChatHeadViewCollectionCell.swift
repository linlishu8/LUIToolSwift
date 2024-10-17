//
//  LUIChatHeadViewCollectionCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/14.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatHeadViewCollectionCell: LUICollectionViewCellBase {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lui_chat_head_collection_bg"))
        return imageView
    }()
    
    private lazy var iconButton: LUILayoutButton = {
        let button = LUILayoutButton(contentStyle: .vertical)
        button.imageSize = CGSize(width: 40, height: 40)
        button.interitemSpacing = 10
        button.setImage(UIImage(named: "lui_chat_head_head"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(self.backgroundImageView)
        self.contentView.addSubview(self.iconButton)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.iconButton], param: .H_C_C, contentInsets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15), interitemSpacing: 0)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customLayoutSubviews() {
        super.customLayoutSubviews()
        
        let bounds = self.contentView.bounds
        self.backgroundImageView.frame = bounds
        self.flowlayout?.bounds = bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func customReloadCellModel() {
        if let title = self.collectionCellModel?.modelValue as? String {
            self.iconButton.setTitle(title, for: .normal)
        }
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        return self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
    }
}
