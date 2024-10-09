//
//  LUITableView.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/20.
//

import UIKit

public class LUITableView: UITableView {
    open var model: LUITableViewModel! {
        didSet {
            if model != oldValue {
                model.setTableViewDataSourceAndDelegate(for: self)
            }
        }
    }
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.model = LUITableViewModel(tableView: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.model = LUITableViewModel(tableView: self)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
}
