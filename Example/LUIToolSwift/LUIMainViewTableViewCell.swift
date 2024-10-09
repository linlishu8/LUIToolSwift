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
    private lazy var titleLebel1: UILabel = {
        return UILabel()
    }()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.titleLebel1)
        
        self.flowlayout = LUIFlowLayoutConstraint.init([self.titleLebel1], param: .V_C_C, contentInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), interitemSpacing: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customReloadCellModel() {
        if let title = self.cellModel.modelValue as? String {
            self.titleLebel1.text = title
        }
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
