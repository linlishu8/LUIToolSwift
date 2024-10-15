//
//  LUICollectionViewPageFlowLayout.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/14.
//

import UIKit

protocol LUICollectionViewDelegatePageFlowLayout: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, itemSizeForItemAt indexPath: IndexPath) -> CGSize?
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, insetForSectionAt section: Int) -> UIEdgeInsets?
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, interitemSpacingForSectionAt section: Int) -> CGFloat?
    func pagingBoundsPositionForCollectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout) -> CGFloat?
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, didScrollToPagingCellAt indexPath: IndexPath)
}

// 协议扩展，为方法提供默认实现（使方法变成可选）
extension LUICollectionViewDelegatePageFlowLayout {
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, itemSizeForItemAt indexPath: IndexPath) -> CGSize? { nil }
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, insetForSectionAt section: Int) -> UIEdgeInsets? { nil }
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, interitemSpacingForSectionAt section: Int) -> CGFloat? { nil }
    func pagingBoundsPositionForCollectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout) -> CGFloat? { nil }
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, didScrollToPagingCellAt indexPath: IndexPath) {}
}

public class LUICollectionViewPageFlowLayout: UICollectionViewLayout {
    public var interitemSpacing: CGFloat = 0
    public var itemSize: CGSize = .zero
    public var scrollDirection: UICollectionViewScrollDirection = .horizontal
    public var itemAlignment: LUICGRectAlignment = .mid
    public var scrollAxis: LUICGAxis {
        return self.scrollDirection == .horizontal ? .x : .y
    }
    public var sectionInset: UIEdgeInsets = .zero
    public var enableCycleScroll: Bool = false //是否允许循环滚动，默认为false
    
    public func reloadData() {
        
    }
    
    // MARK: paging scroll
    //停止滚动时，画面中的cell，是否与指定的位置对齐。pagingCellPosition指定cell的位置，pagingBoundsPosition指定bounds的位置，这两个位置要重合。
    //{pagingBoundsPosition：0，pagingCellPosition：0}:cell左侧与bounds左侧对齐
    //{pagingBoundsPosition：0.5，pagingCellPosition：0.5}:cell中线与bounds中线对齐
    //{pagingBoundsPosition：1，pagingCellPosition：1}:cell右侧与bounds右侧对齐
    //如果觉得scroll到paging位置速度太慢，可以设置：collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    public var pagingEnabled: Bool = false //是否滚动到paging位置，默认为false
    public var pagingBoundsPosition: CGFloat = 0//百分比取值[0,1]
    public var pagingCellPosition: CGFloat = 0//百分比取值[0,1]
    public var playPagingSound: Bool = false//当滚动到paging位置时，是否播放3DTouch效果，默认为false
    public var indexPathAtPagingCell: IndexPath?//位于paging位置上的单元格，为nil时，代表没有单元格与paging位置相交。
    
    public func setIndexPathAtPagingCell(indexPathAtPagingCell: IndexPath, animated: Bool) {
        
    }
    
    public func funcindexPathForCellAtOffset(position: CGFloat) -> IndexPath {
        return IndexPath()
    }
    
    public func setIndexPathAtPagingCellWithDistance(distance: Int, animated: Bool) {
        
    }
    
    public func scrollProgressWithContentOffset(offset: CGPoint, toPagingCell toPadingCellIndexPathPoint: IndexPath) -> CGFloat {
        return 0
    }
    
    //MARK: 定时滚动
    
    public var isAutoScrolling: Bool = false
    /// 设置定时滚动。注意，如果collectionView没有被展示（比如viewcontroller被推到navigation的底部堆栈），定时滚动只会修改contentOffset，prepareLayout、shouldInvalidateLayoutForBoundsChange方法不会被调用，会导致循环滚动失效。如果开启了定时滚动功能，那么调用collectionView的reloadData方法时，也要同步调用本对象的reloadData方法，用来清除循环滚动中的中间状态。否则如果reloadData会修改cell数量，那么会出现contentSize计算错误的问题。
    /// - Parameters:
    ///   - distance: 滚动方向与步进距离，正值为向右，负值为向左
    ///   - duration: 间隔时长
    public func startAutoScrollingWithDistance(distance: Int, duration: TimeInterval) {
        
    }
    
    public func stopAutoScrolling() {
        
    }
    
    //由于highlightPagingCell，可能导致cell位置偏移，从而将bounds之外的元素，也移到了bounds内部，造成bounds里，实际显示元素大于bounds。该方法返回指定bounds时，其显示cell原本所占用的区域。目前用于循环滚动时，获取到当前视图内，真正的显示元素区域。默认直接返回bounds，子类可定制重载。
    public func visibleRectForOriginBounds(bounds: CGRect) -> CGRect {
        return.zero
    }
    
    public var cellAttributes: [UICollectionViewLayoutAttributes] = []
    
    //查找指定offset位置，距离它最近的单元格范围
    public func pagableCellIndexRangeNearToOffset(position: CGFloat) -> NSRange {
        return NSRange()
    }
    
    public var highlightPagingCell: Bool = false//是否突出显示位于pagingBoundsPosition指定位置上的cell。默认为false
    
    //返回指定cell，距离bounds的paging对齐位置的距离。0代表就位于paging位置上,负值位于左侧，正值位于右侧
    public func distanceToPagingPositionForCellLayoutAttributes(cellAttr: UICollectionViewLayoutAttributes) -> CGFloat {
        return 0
    }
    
    public func highlightPagingCellAttributes(cellAttr: UICollectionViewLayoutAttributes) {
        
    }
    
    private var _contentSize:CGSize = .zero
    
    private func maxContentoffset() -> CGFloat {
        let bounds = self.collectionView?.bounds ?? .zero
        let contentSize = _contentSize
        let contentInset = self.collectionView?.l_adjustedContentInset ?? .zero
        let X = self.scrollAxis
        var max = max(self.minContentoffset(), contentSize.LUICGSizeGetLength(axis: X) - bounds.LUICGRectGetLength(X) + LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdge(contentInset, axis: X, edge: .max))
        return max
    }
    
    private func minContentoffset() -> CGFloat {
        let contentInset = self.collectionView?.l_adjustedContentInset ?? .zero
        let X = self.scrollAxis
        return -LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdge(contentInset, axis: X, edge: .max)
    }
    
    private func pagingPositionForCellFrame(frame: CGRect) -> CGFloat {
        let X = self.scrollAxis
        return frame.LUICGRectGetMin(X) + frame.LUICGRectGetLength(X) * self.pagingCellPosition
    }
    
    private func pagingOffsetForCellFrame(frame: CGRect) -> CGFloat {
        let X = self.scrollAxis
        let bounds = self.collectionView?.bounds ?? .zero
        return frame.LUICGRectGetMin(X) + frame.LUICGRectGetLength(X) * self.pagingCellPosition - bounds.LUICGRectGetLength(X) * self.paginfor
    }
    
    private var pagingBoundsPositionForCollectionView: CGFloat {
        var value = self.pagingBoundsPosition
        if
    }
}
