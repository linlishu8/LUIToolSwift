//
//  LUIChatMsgTableViewCellBase.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatMsgTableViewCellBase: LUITableViewCellBase {
    var contentInsets = UIEdgeInsets(top: 16, left: 6, bottom: 0, right: 16)
    var noHeaderContentInsets = UIEdgeInsets(top: 8, left: 55, bottom: 0, right: 16)
    var systemContentInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 55)
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
