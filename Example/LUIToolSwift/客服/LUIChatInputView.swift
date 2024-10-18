//
//  LUIChatInputView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/18.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class LUIChatInputView: UIView {
    let inputTextField: UITextField = {
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.placeholder = "Enter text here..."
            return textField
        }()
        
        let actionButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Menu", for: .normal)
            return button
        }()
        
        let menuView: UIView = {
            let view = UIView()
            view.backgroundColor = .lightGray
            return view
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            setupConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            addSubview(inputTextField)
            addSubview(actionButton)
            backgroundColor = .white
            
            actionButton.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        }
        
        private func setupConstraints() {
            inputTextField.translatesAutoresizingMaskIntoConstraints = false
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            menuView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                inputTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                inputTextField.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                inputTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
                inputTextField.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -10),
                
                actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                actionButton.widthAnchor.constraint(equalToConstant: 80)
            ])
        }
        
        @objc func toggleMenu() {
            if menuView.superview == nil {
                // Assuming the menu should appear where the keyboard was
                if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                    window.addSubview(menuView)
                    menuView.frame = CGRect(x: 0, y: window.bounds.height - 300, width: window.bounds.width, height: 300)
                }
            } else {
                menuView.removeFromSuperview()
            }
        }
}
