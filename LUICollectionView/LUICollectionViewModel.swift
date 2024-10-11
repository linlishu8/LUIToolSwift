//
//  LUICollectionViewModel.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/11.
//

import Foundation

public class LUICollectionViewModel: LUICollectionModel, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    open weak var forwardDataSource: UICollectionViewDataSource?
    open weak var forwardDelegate: UICollectionViewDelegate?
    public var editting: Bool?//是否处在编辑状态中
    public weak var collectionView: UICollectionView?//弱引用外部的collectionView
    
    public var emptyBackgroundViewClass: AnyClass?//没有单元格数据时的背景视图类
    public var emptyBackgroundView: UIView?
    var whenReloadBackgroundView: ((LUICollectionViewModel) -> Void)?
    var reuseCell: Bool?
    
    init(collectionView: UICollectionView) {
        super.init()
    }
}
