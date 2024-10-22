//
//  LUIChatInputGridCollectionCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/21.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import LUIToolSwift

class LUIChatInputGridCollectionCell: LUICollectionViewCellBase {
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(self.backView)
        self.contentView.addSubview(self.iconView)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customLayoutSubviews() {
        super.customLayoutSubviews()
        
        let bounds = self.contentView.bounds
        var iconRect = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.backView.frame = bounds
        iconRect.LUICGRectAlignCenterToRect(bounds)
    }
    
    override func customReloadCellModel() {
        if let image = self.collectionCellModel?.modelValue as? String {
            self.iconView.image = UIImage(named: image)
        }
    }
}
