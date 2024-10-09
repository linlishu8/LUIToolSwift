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
    var flowlayout: LUIFlowLayoutConstraint?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let titleLebel1 = UILabel()
        titleLebel1.text = "我是测试的文字"
        self.contentView.addSubview(titleLebel1)
        
        let titleLebel2 = UILabel()
        titleLebel2.numberOfLines = 0
        titleLebel2.text = "我是测试的文字2s"
        self.contentView.addSubview(titleLebel2)
        
        self.flowlayout = LUIFlowLayoutConstraint.init([titleLebel1, titleLebel2], param: .H_C_L, contentInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), interitemSpacing: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customLayoutSubviews() {
        super.customLayoutSubviews()
        
        let bounds = self.bounds
        self.flowlayout?.bounds = bounds;
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        var size = self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
        size.height = max(size.height, 44)
        return size
    }
}
