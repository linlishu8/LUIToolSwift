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
        tableView.isScrollEnabled = false
        tableView.l_hiddenFooterAreaSeparators()
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        self.__reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func __reloadData() {
        
    }
    
}

