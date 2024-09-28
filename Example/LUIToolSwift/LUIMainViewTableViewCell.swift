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
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let titleLebel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        titleLebel.text = "我是测试的文字"
        self.addSubview(titleLebel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customSizeThatFits(size: CGSize) -> CGSize {
        var s = size
        s.height = 44
        return s
    }
}
