//
//  LUIChatImageView.swift
//  LUIToolSwift_Example
//
//  Created by 六月 on 2024/1/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import LUIToolSwift

class LUIChatImageView: LUIChatBaseView {
    private lazy var imageMsgView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    @objc func imageTapped() {
        guard let image = imageMsgView.image else { return }
        let fullscreenImageView = UIImageView(image: image)
        fullscreenImageView.frame = UIScreen.main.bounds
        fullscreenImageView.backgroundColor = .black
        fullscreenImageView.contentMode = .scaleAspectFit
        fullscreenImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(_:)))
        fullscreenImageView.addGestureRecognizer(tapGesture)
        
        UIApplication.shared.keyWindow?.addSubview(fullscreenImageView)
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.imageMsgView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageMsgView.frame = bounds;
    }
    
    override func loadDataWithCellModel(cellModel: LUITableViewCellModel) {
        if let modelValue = cellModel.modelValue as? LUIChatModel, let imageName = modelValue.msgImage {
            self.imageMsgView.image = UIImage(named: imageName)
        }
    }
}
