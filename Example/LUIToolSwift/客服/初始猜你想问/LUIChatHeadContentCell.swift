//
//  LUIChatHeadContentCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import LUIToolSwift

class LUIChatHeadContentCell: LUIChatMsgTableViewCellBase {
    private lazy var backImageView = {
        let imageView = UIImageView(image: UIImage(named: "lui_chat_head_tablecell_bg"))
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private lazy var arrowImageView = {
        return UIImageView(image: UIImage(named: "lui_chat_headerview_tableviewmore"))
    }()
    private lazy var titleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.numberOfLines = 2
        return label
    }()
    private var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.backImageView)
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(self.titleLabel)
        
        let titlelayout = LUIFlowLayoutConstraint([self.titleLabel], param: .H_C_L, contentInsets: .zero, interitemSpacing: 0)
        let titleWrapper = LUILayoutConstraintItemWrapper.wrapItem(titlelayout) { titleWrapper, size, rest in
            var s = titleWrapper.originItem.sizeThatFits(size, resizeItems: true)
            s.width = size.width
            return s
        }
        
        let imageWrapper = LUILayoutConstraintItemWrapper.wrapItem(self.arrowImageView, fixedSize: CGSizeMake(12, 12))
        self.flowlayout = LUIFlowLayoutConstraint.init([titleWrapper, imageWrapper], param: .H_C_R, contentInsets: UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10), interitemSpacing: 10)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customLayoutSubviews() {
        super.customLayoutSubviews()
        
        let bounds = self.contentView.bounds
        let imageMargin = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        let imageBounds = UIEdgeInsetsInsetRect(bounds, imageMargin)
        self.backImageView.frame = imageBounds
        self.flowlayout?.bounds = bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        guard var s = self.flowlayout?.sizeThatFits(size, resizeItems: true) else { return .zero }
        s.height = max(s.height, 40)
        return s
    }
    
    override func customReloadCellModel() {
        super.customReloadCellModel()
        
        self.titleLabel.text = self.cellModel.modelValue as? String ?? ""
    }
}
