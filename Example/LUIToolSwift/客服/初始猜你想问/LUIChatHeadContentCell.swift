//
//  LUIChatHeadContentCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import LUIToolSwift

class LUIChatHeadContentCell: LUIChatMsgTableViewCellBase {
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
        
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(self.titleLabel)
        
        let imageWrapper = LUILayoutConstraintItemWrapper.wrapItem(self.arrowImageView, fixedSize: CGSizeMake(12, 12))
        self.flowlayout = LUIFlowLayoutConstraint.init([self.titleLabel, imageWrapper], param: .H_C_R, contentInsets: UIEdgeInsets.LUIEdgeInsetsMakeSameEdge(5), interitemSpacing: 10)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customLayoutSubviews() {
        super.customLayoutSubviews()
        
        self.flowlayout?.bounds = self.contentView.bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        let ss = self.flowlayout?.sizeThatFits(size, resizeItems: true)
        guard var s = self.flowlayout?.sizeThatFits(size, resizeItems: true) else { return .zero }
        s.height = max(s.height, 30)
        return s
    }
    
    override func customReloadCellModel() {
        super.customReloadCellModel()
        
        self.titleLabel.text = self.cellModel.modelValue as? String ?? ""
    }
}
