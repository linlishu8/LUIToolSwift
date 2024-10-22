//
//  LUIChatEvaluateView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/10/22.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class LUIChatEvaluateView: UIView {
    // MARK: - Properties
    private let backgroundView = UIView()
    private let containerView = UIView()
    private var buttons: [UIButton] = []
    private let buttonHeight: CGFloat = 50
    private let interButtonSpacing: CGFloat = 10
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.frame = self.bounds
        addSubview(backgroundView)
        
        // Tap gesture on backgroundView to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundView.addGestureRecognizer(tapGesture)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        setupButtons()
    }
    
    private func setupButtons() {
        let buttonTitles = ["Option 1", "Option 2", "Cancel"]
        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            containerView.addSubview(button)
            buttons.append(button)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let totalHeight = CGFloat(buttons.count) * buttonHeight + CGFloat(buttons.count - 1) * interButtonSpacing
        containerView.frame = CGRect(x: 20, y: bounds.height - totalHeight - 20, width: bounds.width - 40, height: totalHeight)
        
        var buttonY: CGFloat = 0
        for button in buttons {
            button.frame = CGRect(x: 0, y: buttonY, width: containerView.bounds.width, height: buttonHeight)
            buttonY += buttonHeight + interButtonSpacing
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        print("Button tapped: \(sender.title(for: .normal) ?? "")")
        dismiss()
    }
    
    @objc private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func show(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
}
