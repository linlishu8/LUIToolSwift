//
//  CIBChatBackgroundOtherView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class CIBChatBackgroundOtherView: UIView {
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lui_chat_message_other"))
        return imageView
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backView)
        self.addSubview(self.arrowImageView)
        
        let viewWrapper = LUILayoutConstraintItemWrapper.wrapItem(self.backView) { wrapper, size, resizeItems in
            return size
        }
        
        self.flowlayout = LUIFlowLayoutConstraint([self.arrowImageView, viewWrapper], param: .H_T_L, contentInsets: .zero, interitemSpacing: 0)
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
        return self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
    }
}
