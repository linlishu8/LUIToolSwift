//
//  LUICollectionView.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/14.
//

import UIKit

public class LUICollectionView: UICollectionView {
    public var model: LUICollectionViewModel! {
        didSet {
            if oldValue !== model {
                model.setCollectionViewDataSourceAndDelegate(collectionView: self)
            }
        }
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.model = LUICollectionViewModel.init(collectionView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.l_sizeThatFits(originBoundsSize: size)
        }
        return self.collectionViewLayout.collectionViewContentSize
    }
}

public class LUICollectionFlowLayoutView: LUICollectionView {
    public init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout.init()
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
