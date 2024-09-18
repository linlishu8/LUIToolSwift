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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let obj = NSObject()
        print(obj.l_objectAddress())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

