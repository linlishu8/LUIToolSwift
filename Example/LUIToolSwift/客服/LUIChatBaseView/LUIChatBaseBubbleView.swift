//
//  LUIChatBaseBubbleView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class LUIChatBaseBubbleView: LUIChatBaseView {
    public var bgView: UIView = {
        return UIView()
    }()
    public var mineView: LUIChatBackgroundMineView?
    public var otherView: CIBChatBackgroundOtherView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.bgView)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
