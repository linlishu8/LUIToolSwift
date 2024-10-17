//
//  LUIChatBackgroundMineView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatBackgroundMineView: UIView {
    
    private lazy var backImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lui_chat_message_mine_bg"))
        return imageView
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lui_chat_message_mine"))
        return imageView
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backImageView)
        self.addSubview(self.arrowImageView)
        
        self.flowlayout = LUIFlowLayoutConstraint([self.backImageView, self.arrowImageView], param: .H_T_R, contentInsets: .zero, interitemSpacing: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        self.flowlayout?.bounds = bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let s = self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
        return s
    }
}
