//
//  LUIMainViewTableViewCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/9/27.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import LUIToolSwift

class LUIMainViewTableViewCell: LUITableViewCellBase {
    var flowlayout: LUIFlowLayoutConstraint
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let titleLebel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        titleLebel.text = "我是测试的文字"
        
        self.flowlayout = LUIFlowLayoutConstraint.init([titleLebel], param: .H_C_C, contentInsets: .zero, interitemSpacing: 0)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(titleLebel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customLayoutSubviews() {
        super.customLayoutSubviews()
        
        let bounds = self.contentView.bounds
        self.flowlayout.bounds = bounds;
        self.flowlayout.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        return self.flowlayout.sizeThatFits(size, resizeItems: true)
    }
}
