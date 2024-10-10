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
    var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.arrowImageView)
        self.contentView.addSubview(self.titleLabel)
        
        let imageWrapper = LUILayoutConstraintItemWrapper.wrapItem(self.arrowImageView, fixedSize: CGSizeMake(12, 12))
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
