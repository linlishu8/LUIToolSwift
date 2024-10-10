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
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
