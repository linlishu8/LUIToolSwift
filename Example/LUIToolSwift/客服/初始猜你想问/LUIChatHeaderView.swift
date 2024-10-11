//
//  LUIChatHeaderView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatHeaderView: LUIChatBaseView {
    private let dataList = ["钱大掌柜是什么", "钱大掌柜产品持有后能否通过兴业银行柜台查询", "我购买钱大掌柜上销售的各家机构提供的各类产品是否纳入该我购买钱大掌柜上销售的各家机构提供的各类产品是否纳入该", "非身份证能否签约钱大掌柜？", "钱大掌柜是什么钱大掌柜是什么钱大掌柜是什么", "猜你想问猜你想问猜你想问猜你想问猜你想问"]
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lui_chat_header_tablebg"))
        return imageView
    }()
    
    private lazy var headTitleView: LUILayoutButton = {
        let button = LUILayoutButton(contentStyle: .vertical)
        button.imageSize = CGSize(width: 40, height: 40)
        button.interitemSpacing = 5
        button.setImage(UIImage(named: "lui_chat_head_head"), for: .normal)
        button.setTitle("猜你想问", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    private lazy var changeButton: LUILayoutButton = {
        let button = LUILayoutButton(contentStyle: .vertical)
        button.imageSize = CGSize(width: 20, height: 20)
        button.interitemSpacing = 5
        button.setImage(UIImage(named: "lui_chat_head_change"), for: .normal)
        button.setTitle("换一批", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        self.__reloadData()
        self.cellModel?.refresh()
    }
    
    private lazy var tableView: LUITableView = {
        let tableView = LUITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.l_hiddenFooterAreaSeparators()
        return tableView
    }()
    
    private var flowlayout: LUIFlowLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.headTitleView)
        self.addSubview(self.changeButton)
        self.addSubview(self.tableView)
        
        let leftFlowlayout = LUIFlowLayoutConstraint([self.headTitleView, self.changeButton], param: .V_C_C, contentInsets: .zero, interitemSpacing: 20)
        let tableWrapper = LUILayoutConstraintItemWrapper.wrapItem(self.tableView) { wrapper, size, resizeItems in
            guard let tableView = wrapper.originItem as? UITableView else { return .zero }
            let height = tableView.l_heightThatFits(size.width)
            return CGSize(width: size.width, height: height)
        }
        self.flowlayout = LUIFlowLayoutConstraint([leftFlowlayout, tableWrapper], param: .H_T_C, contentInsets: UIEdgeInsets(top: 15, left: 25, bottom: 10, right: 30), interitemSpacing: 10)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let chatMargin = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let backbounds = UIEdgeInsetsInsetRect(bounds, chatMargin)
        self.backgroundImageView.frame = backbounds
        
        self.flowlayout?.bounds = bounds
        self.flowlayout?.layoutItemsWithResizeItems(resizeItems: true)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let s = self.flowlayout?.sizeThatFits(size, resizeItems: true) ?? .zero
        return s
    }
    
    private func __reloadData() {
        self.tableView.model.removeAllSectionModels()
        let randomElements = self.dataList.shuffled().prefix(4)
        let result = Array(randomElements)
        for string in result {
            let cellModel = LUITableViewCellModel.init()
            cellModel.cellClass = LUIChatHeadContentCell.self
            cellModel.modelValue = string
            self.tableView.model.addCellModel(cellModel)
        }
        self.tableView.model.reloadTableViewData()
    }
    
    override func loadDataWithCellModel(cellModel: LUITableViewCellModel) {
        self.cellModel = cellModel
        self.__reloadData()
    }
    
    deinit {
        
    }
}
