//
//  LUIChatBaseView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatBaseView: UIView {
    weak var cellModel: LUITableViewCellModel?
    open var chatTextMarginMine: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
    open var chatTextMarginOther: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
    open var chatMargin: UIEdgeInsets = UIEdgeInsets.LUIEdgeInsetsMakeSameEdge(10)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadDataWithCellModel(cellModel: LUITableViewCellModel) {
        
    }
}
