//
//  ViewController.swift
//  LUIToolSwift
//
//  Created by Your Name on 09/14/2024.
//  Copyright (c) 2024 Your Name. All rights reserved.
//

import UIKit
import LUIToolSwift

class ViewController: UIViewController {
    private lazy var tableView: LUITableView = {
        let tableView = LUITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.l_hiddenFooterAreaSeparators()
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "钱X项目"
        
        view.addSubview(tableView)
        self.__reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.safeBounds()
    }
    
    func safeBounds() -> CGRect {
        var bounds = self.view.bounds
        if #available(iOS 11.0, *) {
            bounds = self.view.safeAreaLayoutGuide.layoutFrame
        }
        return bounds
    }
    
    func __reloadData() {
        let testModel1 = self.addCellModelWithCellTitle("客服")
        testModel1.whenClick = { cellModel in
            let chatView = LUIChatViewController.init()
            self.navigationController?.pushViewController(chatView, animated: true)
        }
        let testModel2 = self.addCellModelWithCellTitle("测试2")
        let testModel3 = self.addCellModelWithCellTitle("测试3")
        self.tableView.model.reloadTableViewData()
    }
    
    func addCellModelWithCellTitle(_ cellTitle: String) -> LUITableViewCellModel {
        let cellModel = LUITableViewCellModel.init()
        cellModel.cellClass = LUIMainViewTableViewCell.self
        cellModel.modelValue = cellTitle
        self.tableView.model.addCellModel(cellModel)
        return cellModel
    }
}

