//
//  LUIChatBubbleBaseTableViewCell.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class LUIChatBubbleBaseTableViewCell: LUIChatMsgTableViewCellBase {
    open var mineHeaderView: LUIChatUserPicView = {//我的头像
        let imageView = LUIChatUserPicView(image: UIImage(named: "cib_aiservice_icon_xiaozhi"))
        return imageView
    }()
    open var otherHeaderView: LUIChatUserPicView = {//其他头像
        let imageView = LUIChatUserPicView(image: UIImage(named: "cib_aiservice_textinput_kefu"))
        return imageView
    }()
}
