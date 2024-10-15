//
//  UICollectionViewFlowLayout+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/15.
//

import Foundation

public extension UICollectionViewFlowLayout {
    var l_flowLayoutDelegate: UICollectionViewDelegateFlowLayout? {
            return self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }
    
    func l_sizeForItemAtIndexPath(_ indexPath: IndexPath) -> CGSize {
        guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
              delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) else {
            return itemSize
        }
        return delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) ?? itemSize
    }
    
    func l_insetForSectionAtIndex(_ index: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))) else {
            return sectionInset
        }
        return delegate.collectionView?(collectionView, layout: self, insetForSectionAt: index) ?? sectionInset
    }
    
    func l_minimumLineSpacingForSectionAtIndex(_ index: Int) -> CGFloat {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:))) else {
            return minimumLineSpacing
        }
        return delegate.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: index) ?? minimumLineSpacing
    }

    func l_minimumInteritemSpacingForSectionAtIndex(_ index: Int) -> CGFloat {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))) else {
            return minimumInteritemSpacing
        }
        return delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: index) ?? minimumInteritemSpacing
    }
    
    func l_referenceSizeForFooterInSection(_ index: Int) -> CGSize {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))) else {
            return footerReferenceSize
        }
        return delegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: index) ?? footerReferenceSize
    }

    func l_referenceSizeForHeaderInSection(_ index: Int) -> CGSize {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))) else {
            return headerReferenceSize
        }
        return delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: index) ?? headerReferenceSize
    }
    
    func l_contentBoundsForSectionAtIndex(_ index: Int) -> CGRect {
        guard let collectionView = collectionView else { return .zero }
        let insets = l_insetForSectionAtIndex(index)
        var bounds = collectionView.bounds
        bounds.origin = .zero
        let b = UIEdgeInsetsInsetRect(bounds, insets)
        return CGRect(origin: .zero, size: b.size)
    }
    
    /// 指定collectionview的最大尺寸，返回collectionview最合适的尺寸值
    /// @param size 外层最大尺寸
    func l_sizeThatFits(originBoundsSize: CGSize) -> CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        var size = originBoundsSize
        let direction = self.scrollDirection
        var axis: LUICGAxis = direction == .vertical ? .x : .y
        var axisR = LUICGAxis.LUICGAxisReverse(axis)
        size.LUICGSizeSetLength(CGFloat(Int.max), axis: axisR)
        
        let originBounds = collectionView.bounds
        var bounds = originBounds
        bounds.size = originBoundsSize
        collectionView.bounds = bounds
        
        var sizeFits: CGSize = .zero
        var insets = collectionView.l_adjustedContentInset
        size.width -= insets.left + insets.right
        size.height -= insets.top + insets.bottom
        
        //由于headerReferenceSize和footerReferenceSize会受bounds尺寸影响，因此要先算出bounds的最合适值，然后再计算head、foot的最合适尺寸
        //由于cell在originBoundsSize限制下，计算出适合的尺寸。这个尺寸会受originBoundsSize影响，在后续真实布局中，originBoundsSize的值可能会改变。因此要二次计算cell的最合适尺寸
        //第一次计算所有cell的最合适尺寸
        var allCellsSize = self.l_allCellsSizeThatFitsCellBoundsSize(size: size)//所有cell占用的总区域尺寸
        //如果allCellsSize限制值 != size限制值，代表cell动态计算时，限定的size变更了，需要二次计算
        if allCellsSize.LUICGSizeGetLength(axis: axis) != size.LUICGSizeGetLength(axis: axis) {
            var boundsSize = size
            boundsSize.LUICGSizeSetLength(allCellsSize.LUICGSizeGetLength(axis: axis), axis: axis)
            
            //更新collectionView的尺寸
            var newBounds = originBounds
            newBounds.size = originBoundsSize
            newBounds.LUICGRectSetLength(axis, value: allCellsSize.LUICGSizeGetLength(axis: axis) + LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdge(insets, axis: axis, edge: .min) + LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdge(insets, axis: axis, edge: .max))
            collectionView.bounds = newBounds
            allCellsSize = self.l_allCellsSizeThatFitsCellBoundsSize(size: boundsSize)
        }
        sizeFits = allCellsSize
        sizeFits.width += insets.left + insets.right
        sizeFits.height += insets.top + insets.bottom
        
        //在计算出cell的占用区域后，在此基础上，计算head和foot的最合适尺寸
        sizeFits.LUICGSizeSetLength(ceil(sizeFits.LUICGSizeGetLength(axis: axis)), axis: axis)
        bounds.LUICGRectSetLength(axis, value: sizeFits.LUICGSizeGetLength(axis: axis))
        collectionView.bounds = bounds
        
        for i in 0..<collectionView.numberOfSections {
            var headerReferenceSize = self.l_referenceSizeForHeaderInSection(i)
            var footerReferenceSize = self.l_referenceSizeForFooterInSection(i)
            
            sizeFits.LUICGSizeSetLength(sizeFits.LUICGSizeGetLength(axis: axisR) + headerReferenceSize.LUICGSizeGetLength(axis: axisR) + footerReferenceSize.LUICGSizeGetLength(axis: axisR), axis: axisR)
        }
        
        sizeFits.width = ceil(sizeFits.width)
        size.height = ceil(size.height)
        collectionView.bounds = originBounds
        return sizeFits
    }
    
    private func l_allCellsSizeThatFitsCellBoundsSize(size: CGSize) -> CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        let direction = self.scrollDirection
        var s = size
        let X: LUICGAxis = direction == .vertical ? .x : .y
        let Y: LUICGAxis = LUICGAxis.LUICGAxisReverse(X)
        s.LUICGSizeSetLength(CGFloat(Int.max), axis: Y)
        
        var allCellsSize: CGSize = .zero
        for i in 0..<collectionView.numberOfSections {
            var minimumLineSpacing = self.l_minimumLineSpacingForSectionAtIndex(i)
            var minimumInteritemSpacing = self.l_minimumInteritemSpacingForSectionAtIndex(i)
            var sectionInset = self.l_insetForSectionAtIndex(i)
            var boundSize = size
            boundSize.width -= sectionInset.left + sectionInset.right
            boundSize.height -= sectionInset.top + sectionInset.bottom
            
            var interitemSpacing = X == .x ? minimumInteritemSpacing : minimumLineSpacing
            var lineSpacing = X == .x ? minimumLineSpacing : minimumInteritemSpacing
            let itemCount = collectionView.numberOfItems(inSection: i)
            var sectionFitSize: CGSize = .zero
            var limitSize = boundSize
            var maxHeight: CGFloat = 0//元素的最大高度
            var widths: [NSNumber] = []
            var maxWidth: CGFloat = 0//每行的最大宽度
            var heights: [NSNumber] = []
            for j in 0..<collectionView.numberOfItems(inSection: i) {
                let p = IndexPath(row: j, section: i)
                var itemSize = self.l_sizeForItemAtIndexPath(p)
                itemSize.width = ceil(itemSize.width)
                itemSize.height = ceil(itemSize.height)
                let w = itemSize.LUICGSizeGetLength(axis: X)
                if w > 0 {
                    limitSize.LUICGSizeSetLength(limitSize.LUICGSizeGetLength(axis: X) - w, axis: X)
                    if limitSize.LUICGSizeGetLength(axis: X) < 0 {//当前行已经放不了，需要另起一行
                        var sumWidth = CGFloat(widths.count - 1) * interitemSpacing
                        for width in widths {
                            sumWidth += CGFloat(truncating: width)
                        }
                        maxWidth = max(maxWidth, sumWidth)
                        heights.append(NSNumber(value: maxHeight))
                        
                        limitSize.LUICGSizeSetLength(boundSize.LUICGSizeGetLength(axis: X) - w, axis: X)
                        limitSize.LUICGSizeSetLength(limitSize.LUICGSizeGetLength(axis: Y) - maxHeight - lineSpacing, axis: Y)
                        maxHeight = 0
                        widths.removeAll()
                    }
                    limitSize.LUICGSizeSetLength(limitSize.LUICGSizeGetLength(axis: X) - interitemSpacing, axis: X)
                    maxHeight = max(maxHeight, itemSize.LUICGSizeGetLength(axis: Y))
                    widths.append(NSNumber(value: w))
                }
            }
            if !widths.isEmpty {//处理最后一行
                var sumWidth = CGFloat(widths.count - 1) * interitemSpacing
                for width in widths {
                    sumWidth += CGFloat(truncating: width)
                }
                maxWidth = max(maxWidth, sumWidth)
                heights.append(NSNumber(value: maxHeight))
            }
            if !heights.isEmpty {
                var sumHeight = CGFloat(heights.count - 1) * interitemSpacing
                for height in heights {
                    sumHeight += CGFloat(truncating: height)
                }
                sectionFitSize.LUICGSizeSetLength(maxWidth, axis: X)
                sectionFitSize.LUICGSizeSetLength(sumHeight, axis: Y)
            }
            sectionFitSize.width += sectionInset.left + sectionInset.right
            sectionFitSize.height += sectionInset.top + sectionInset.bottom
            
            allCellsSize.LUICGSizeSetLength(max(allCellsSize.LUICGSizeGetLength(axis: X), sectionFitSize.LUICGSizeGetLength(axis: X)), axis: X)
            allCellsSize.LUICGSizeSetLength(allCellsSize.LUICGSizeGetLength(axis: Y) + sectionFitSize.LUICGSizeGetLength(axis: Y), axis: Y)
        }
        return allCellsSize
    }
}
