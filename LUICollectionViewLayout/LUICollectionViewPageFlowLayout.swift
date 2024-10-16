//
//  LUICollectionViewPageFlowLayout.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/14.
//

import UIKit

public class _LUICollectionViewPageFlowSectionModel {
    var sectionInsets: UIEdgeInsets?
    var interitemSpacing: CGFloat?
    var itemCount: Int?
}

public protocol LUICollectionViewDelegatePageFlowLayout: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, itemSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat
    func pagingBoundsPositionForCollectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout) -> CGFloat
    func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, didScrollToPagingCell indexPathAtPagingCell: IndexPath)
}

extension LUICollectionViewDelegatePageFlowLayout {
    func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, itemSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize { return .zero }
    func collectionView(_ collectionView: UICollectionView, pageFlowLayout layout: LUICollectionViewPageFlowLayout, insetForSectionAt section: Int) -> UIEdgeInsets { return .zero }
    func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat { return 0 }
    func pagingBoundsPositionForCollectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout) -> CGFloat { return 0 }
    func collectionView(collectionView: UICollectionView, pageFlowLayout collectionViewLayout: LUICollectionViewPageFlowLayout, didScrollToPagingCell indexPathAtPagingCell: IndexPath) {}
}

public class LUICollectionViewPageFlowLayout: UICollectionViewLayout, UICollectionViewDelegate {
    public var interitemSpacing: CGFloat = 0
    public var itemSize: CGSize = .zero
    public var scrollDirection: UICollectionViewScrollDirection = .horizontal
    public var itemAlignment: LUICGRectAlignment = .mid
    public var scrollAxis: LUICGAxis {
        return self.scrollDirection == .horizontal ? .x : .y
    }
    public var sectionInset: UIEdgeInsets = .zero
    private var _enableCycleScroll: Bool = false //是否允许循环滚动，默认为false
    public var enableCycleScroll: Bool {
        get {
            return _enableCycleScroll
        }
        set {
            if _enableCycleScroll != newValue {
                _needReload = true
                _enableCycleScroll = newValue
                self._prepareDelegate()
            }
        }
    }
    
    var originDelegate: UICollectionViewDelegate?
    
    private var autoScrollingTimer: Timer?
    private var _needReload: Bool = false
    private var sectionModels: [_LUICollectionViewPageFlowSectionModel] = []
    private var _l_indexPathAtPagingCellBeforeBoundsChange: IndexPath?
    private var _l_preffedCellIndexpathAtPaging: IndexPath?
    private var __cachedPrePagingIndexPath: IndexPath?
    private var offsetChanging: Bool?
    private var _preContentOffset: CGPoint?
    private var _shouldCycleScroll: Bool = false
    private var _isSizeFitting: Bool = false
    
    struct AutoScrollingState {
        var isAutoScorlling: Bool
        var distance: Int
        var duration: TimeInterval
    }
    
    var _autoScrollingState: AutoScrollingState?
    
    public func reloadData() {
        
    }
    
    // MARK: paging scroll
    //停止滚动时，画面中的cell，是否与指定的位置对齐。pagingCellPosition指定cell的位置，pagingBoundsPosition指定bounds的位置，这两个位置要重合。
    //{pagingBoundsPosition：0，pagingCellPosition：0}:cell左侧与bounds左侧对齐
    //{pagingBoundsPosition：0.5，pagingCellPosition：0.5}:cell中线与bounds中线对齐
    //{pagingBoundsPosition：1，pagingCellPosition：1}:cell右侧与bounds右侧对齐
    //如果觉得scroll到paging位置速度太慢，可以设置：collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    private var _pagingEnabled: Bool = false //是否滚动到paging位置，默认为false
    public var pagingEnabled: Bool {
        get {
            return _pagingEnabled
        }
        set {
            if _pagingEnabled != newValue {
                _needReload = true
                _pagingEnabled = newValue
                self._prepareDelegate()
            }
        }
    }
    private var _pagingBoundsPosition: CGFloat = 0//百分比取值[0,1]
    public var pagingBoundsPosition: CGFloat {
        get {
            return _pagingBoundsPosition
        }
        set {
            if _pagingBoundsPosition != newValue {
                _needReload = true
                _pagingBoundsPosition = newValue
            }
        }
    }
    private var _pagingCellPosition: CGFloat = 0//百分比取值[0,1]
    public var pagingCellPosition: CGFloat {
        get {
            return _pagingCellPosition
        }
        set {
            if (_pagingCellPosition != newValue) {
                _needReload = true
                _pagingCellPosition = newValue
            }
        }
    }
    public var playPagingSound: Bool = false//当滚动到paging位置时，是否播放3DTouch效果，默认为false
    public var indexPathAtPagingCell: IndexPath? { //位于paging位置上的单元格，为nil时，代表没有单元格与paging位置相交。
        return self.indexPathAtPagingCellWithMinDistance()
    }
    
    public func setIndexPathAtPagingCell(indexPathAtPagingCell: IndexPath, animated: Bool) {
        guard let collectionView = self.collectionView else { return }
        let p = indexPathAtPagingCell
        if p.section < 0 || p.section >= collectionView.numberOfSections {
            return
        }
        let numberOfItems = collectionView.numberOfItems(inSection: p.section)
        if p.section >= 0 && p.section < collectionView.numberOfSections && p.item >= 0 && p.item < numberOfItems {
            let numberOfItemsInSetionModel = self.__numberOfItemsInSetionModelWithIndex(index: p.section)
            //判断self.sectionModels中的数据，是否与collectionView.dataSource中数量上一致.数量不一致，代表dataSource变化了，但prepare方法还未被执行
            // ||
            //bounds.size为0时，需要保存期望滚动到中线的值，等待size被重新赋值时，再滚动到该位置
            if numberOfItemsInSetionModel != numberOfItems || CGSizeEqualToSize(collectionView.bounds.size, .zero) {
                _l_preffedCellIndexpathAtPaging = p
                _l_indexPathAtPagingCellBeforeBoundsChange = nil
            } else {
                _l_preffedCellIndexpathAtPaging = nil;
                _l_indexPathAtPagingCellBeforeBoundsChange = nil;
                let X = self.scrollAxis
                var pagingOffset = self.pagingOffsetForCellIndexPath(indexPath: p)
                var offset = collectionView.contentOffset
                offset.LUICGPointSetValue(pagingOffset, axis: X)
                
                let minOffset = self.minContentoffset()
                let maxOffset = self.maxContentoffset()
                
                let outOfScollRange = pagingOffset < minOffset || pagingOffset > maxOffset
                if self.enableCycleScroll && outOfScollRange && !animated {
                    self.__setContentViewContentOffset(contentOffset: offset, animated: false)
                    collectionView.layoutIfNeeded()
                    pagingOffset = self.pagingOffsetForCellIndexPath(indexPath: p)
                    offset.LUICGPointSetValue(pagingOffset, axis: X)
                }
                self.__setContentViewContentOffset(contentOffset: offset, animated: animated)
            }
        }
    }
    
    public func indexPathForCellAtOffset(position: CGFloat) -> IndexPath? {
        let index = self._cellIndexForCellAtOffset(position: position)
        if index != NSNotFound {
            return self.cellAttributes[index].indexPath
        }
        return nil
    }
    
    public func setIndexPathAtPagingCellWithDistance(distance: Int, animated: Bool) {
        guard let collectionView = self.collectionView else { return }
        let position = self.positionOfPagingForRect(bounds: collectionView.bounds)
        let X = self.scrollAxis
        var velocity: CGPoint = .zero
        velocity.LUICGPointSetValue(CGFloat(distance), axis: X)
        let index = self._cellIndexForCellNearToOffset(position: position, scrollVelocity: velocity)
        if index != NSNotFound {
            var dis = distance
            if dis < 0 {
                dis = -((-distance) % self.cellAttributes.count)
            }
            let newIndex = (index + dis + self.cellAttributes.count) % self.cellAttributes.count
            let newIndexPath = self.cellAttributes[newIndex].indexPath
            if index != newIndex {
                if (self.enableCycleScroll && _shouldCycleScroll) && distance * (newIndex - index) < 0 {
                    //方向反了。需要进行一次重排
                    let nextBeginIndex = distance > 0 ? index : newIndex
                    self.__resortCellAttributeWithBeginIndex(beginIndex: nextBeginIndex)
                }
                self.setIndexPathAtPagingCell(indexPathAtPagingCell: newIndexPath, animated: animated)
            }
        }
    }
    
    private func scrollProgressWithContentOffset(offset: CGPoint, fromPagingCell fromPadingCellIndexPathPoint: inout IndexPath?, toPagingCell toPadingCellIndexPathPoint: inout IndexPath?) -> CGFloat {
        var progress: CGFloat = 0
        guard let collectionView = self.collectionView else { return progress }
        var bounds = collectionView.bounds
        bounds.origin = offset
        let position = self.positionOfPagingForRect(bounds: bounds)
        let range = self.pagableCellIndexRangeNearToOffset(position: position)
        
        if range.length > 0 {
            var p1: IndexPath?
            var p2: IndexPath?
            var x1: CGFloat = 0
            var x2: CGFloat = 0
            
            for i in 0..<range.length {
                let index = range.location + i
                let c = cellAttributes[index]
                let x = self.pagingPositionForCellFrame(frame: c.frame)
                
                if x <= position {
                    p1 = c.indexPath
                    x1 = x
                } else if x > position && p2 == nil {
                    p2 = c.indexPath
                    x2 = x
                }
            }
            
            fromPadingCellIndexPathPoint = p1
            toPadingCellIndexPathPoint = p2
            
            if let p1 = p1, let p2 = p2, x1 != x2 {
                progress = (position - x1) / (x2 - x1)
            }
        }
        return progress
    }
    
    public func scrollProgressWithContentOffset(offset: CGPoint, toPagingCell toPadingCellIndexPathPoint: inout IndexPath) -> CGFloat {
        var p1: IndexPath?
        var p2: IndexPath?
        let currentIndexPath = self.indexPathAtPagingCell
        var progress = self.scrollProgressWithContentOffset(offset: offset, fromPagingCell: &p1, toPagingCell: &p2)
        if p1 == currentIndexPath {
        } else {
            p2 = p1
            progress = 1 - progress
        }
        if let p = p2 {
            toPadingCellIndexPathPoint = p
        }
        return progress
    }
    
    //MARK: 定时滚动
    
    public var isAutoScrolling: Bool {
        return _autoScrollingState?.isAutoScorlling ?? false
    }
    /// 设置定时滚动。注意，如果collectionView没有被展示（比如viewcontroller被推到navigation的底部堆栈），定时滚动只会修改contentOffset，prepareLayout、shouldInvalidateLayoutForBoundsChange方法不会被调用，会导致循环滚动失效。如果开启了定时滚动功能，那么调用collectionView的reloadData方法时，也要同步调用本对象的reloadData方法，用来清除循环滚动中的中间状态。否则如果reloadData会修改cell数量，那么会出现contentSize计算错误的问题。
    /// - Parameters:
    ///   - distance: 滚动方向与步进距离，正值为向右，负值为向左
    ///   - duration: 间隔时长
    public func startAutoScrollingWithDistance(distance: Int, duration: TimeInterval) {
        if let autoScrollingState = _autoScrollingState, autoScrollingState.isAutoScorlling && autoScrollingState.distance == distance && autoScrollingState.duration == duration { return }
        _autoScrollingState = AutoScrollingState(isAutoScorlling: true, distance: distance, duration: duration)
        self.autoScrollingTimer?.invalidate()
        self.autoScrollingTimer = Timer.scheduledTimer(withTimeInterval: _autoScrollingState!.duration, repeats: true, block: { [weak self] timer in
            self?._onAudoScrollingTimer(timer: timer)
        })
    }
    
    public func stopAutoScrolling() {
        
    }
    
    //由于highlightPagingCell，可能导致cell位置偏移，从而将bounds之外的元素，也移到了bounds内部，造成bounds里，实际显示元素大于bounds。该方法返回指定bounds时，其显示cell原本所占用的区域。目前用于循环滚动时，获取到当前视图内，真正的显示元素区域。默认直接返回bounds，子类可定制重载。
    public func visibleRectForOriginBounds(bounds: CGRect) -> CGRect {
        return bounds
    }
    
    public var cellAttributes: [UICollectionViewLayoutAttributes] = []
    
    //查找指定offset位置，距离它最近的单元格范围
    public func pagableCellIndexRangeNearToOffset(position: CGFloat) -> NSRange {
        let X = self.scrollAxis
        let range = self.cellAttributes.l_rangeOfSortedObjectsWithComparator { [weak self] (arrayObj, idx) -> ComparisonResult in
            let frame = arrayObj.l_frameSafety
            var r: ComparisonResult = .orderedSame
            if frame.LUICGRectGetMin(X) <= position && position <= frame.LUICGRectGetMax(X) {
                r = .orderedSame
            } else if frame.LUICGRectGetMax(X) < position {//位于position左侧
                if let cellAttributes = self?.cellAttributes {
                    if  idx == cellAttributes.count - 1 {
                        r = .orderedSame
                    } else {
                        r = .orderedAscending
                        for i in idx + 1..<cellAttributes.count {
                            let c = cellAttributes[i]
                            if self?.isCellAttributesVisible(cellAttr: c) ?? false {
                                let f1 = c.l_frameSafety
                                if f1.LUICGRectGetMin(X) <= position && position <= f1.LUICGRectGetMax(X) {
                                    r = .orderedSame
                                } else if f1.LUICGRectGetMax(X) < position {
                                    r = .orderedAscending
                                } else {
                                    r = .orderedSame
                                }
                                break
                            }
                        }
                    }
                }
            } else {//位于position右侧
                if idx == 0 {
                    r = .orderedSame
                } else {
                    r = .orderedDescending
                    for i in idx-1...0 {
                        if let c = self?.cellAttributes[i] {
                            if self?.isCellAttributesVisible(cellAttr: c) ?? false {
                                let f1 = c.l_frameSafety
                                if f1.LUICGRectGetMin(X) <= position && position <= f1.LUICGRectGetMax(X) {
                                    r = .orderedSame
                                } else if f1.LUICGRectGetMin(X) > position {
                                    r = .orderedDescending
                                } else {
                                    r = .orderedSame
                                }
                                break
                            }
                        }
                    }
                }
            }
            return r
        }
        return range
    }
    
    public var highlightPagingCell: Bool = false//是否突出显示位于pagingBoundsPosition指定位置上的cell。默认为false
    
    //返回指定cell，距离bounds的paging对齐位置的距离。0代表就位于paging位置上,负值位于左侧，正值位于右侧
    public func distanceToPagingPositionForCellLayoutAttributes(cellAttr: UICollectionViewLayoutAttributes) -> CGFloat {
        let X = self.scrollAxis
        var dis: CGFloat = 0
        guard let collectionView = self.collectionView else { return dis }
        let position = self.positionOfPagingForRect(bounds: collectionView.bounds)
        let frame = cellAttr.l_frameSafety
        dis = (frame.LUICGRectGetMin(X) + frame.LUICGRectGetLength(X) * self.pagingCellPosition) - position
        return dis
    }
    
    public func highlightPagingCellAttributes(cellAttr: UICollectionViewLayoutAttributes) {
        
    }
    
    private var _contentSize:CGSize = .zero
    
    private func maxContentoffset() -> CGFloat {
        let bounds = self.collectionView?.bounds ?? .zero
        let contentSize = _contentSize
        let contentInset = self.collectionView?.l_adjustedContentInset ?? .zero
        let X = self.scrollAxis
        return max(self.minContentoffset(), contentSize.LUICGSizeGetLength(axis: X) - bounds.LUICGRectGetLength(X) + LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdge(contentInset, axis: X, edge: .max))
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
        var offset: CGFloat = 0
        let X = self.scrollAxis
        let bounds = self.collectionView?.bounds ?? .zero
        offset = frame.LUICGRectGetMin(X) + frame.LUICGRectGetLength(X) * self.pagingCellPosition - bounds.LUICGRectGetLength(X) * self.pagingBoundsPositionForCollectionView()
        return offset
    }
    private func pagingOffsetForCellIndexPath(indexPath: IndexPath) -> CGFloat {
        var offset: CGFloat = 0
        if let attr = self.layoutAttributesForItem(at: indexPath) {
            let frame = attr.l_frameSafety
            offset = self.pagingOffsetForCellFrame(frame: frame)
        }
        return offset
    }
    
    private func offsetUnit() -> CGFloat {
        return 1.0 / UIScreen.main.scale;
    }
    
    private func isCellAttributesVisible(cellAttr: UICollectionViewLayoutAttributes) ->Bool {
        let frame = cellAttr.l_frameSafety
        return frame.size.width > 0 && frame.size.height > 0
    }
    
    private func _cellIndexForCellNearToOffset(position: CGFloat, scrollVelocity velocity: CGPoint) -> Int {
        let X = self.scrollAxis
        let offset = self.collectionView?.contentOffset ?? .zero
        var result: Int = Int.max
        
        let range = self.pagableCellIndexRangeNearToOffset(position: position)
        let unit = self.offsetUnit()
        if range.location != NSNotFound {
            if velocity.LUICGPointGetValue(axis: X) > 0 {
                for i in 0..<range.length {
                    let index = i + range.location
                    let c = self.cellAttributes[index]
                    if self.isCellAttributesVisible(cellAttr: c) {
                        let pagingOffset = self.pagingOffsetForCellIndexPath(indexPath: c.indexPath)
                        if pagingOffset >= offset.LUICGPointGetValue(axis: X) - unit {
                            result = index
                            break
                        }
                    }
                }
            } else if velocity.LUICGPointGetValue(axis: X) < 0 {
                for i in 0..<range.length {
                    let index = range.location + range.length - 1 - i
                    let c = self.cellAttributes[index]
                    if self.isCellAttributesVisible(cellAttr: c) {
                        let pagingOffset = self.pagingOffsetForCellIndexPath(indexPath: c.indexPath)
                        if pagingOffset <= offset.LUICGPointGetValue(axis: X) + unit{
                            result = index
                            break
                        }
                    }
                }
            }
        }
        if result == NSNotFound {
            var min = CGFloat.greatestFiniteMagnitude
            for i in 0..<range.length {
                let index = i + range.location
                let c = self.cellAttributes[index]
                if self.isCellAttributesVisible(cellAttr: c) {
                    let pagingOffset = self.pagingOffsetForCellIndexPath(indexPath: c.indexPath)
                    let dis = abs(pagingOffset - offset.LUICGPointGetValue(axis: X))
                    if dis < min {
                        result = index
                        min = dis
                    }
                }
            }
        }
        return result
    }
    
    private func _cellIndexForCellAtOffset(position: CGFloat) -> Int {
        var p = NSNotFound
        let X = self.scrollAxis
        let unit = self.offsetUnit()
        let range = self.cellAttributes.l_rangeOfSortedObjectsWithComparator { (arrayObj, idx) -> ComparisonResult in
            var r:ComparisonResult = .orderedSame
            let frame = arrayObj.l_frameSafety
            if frame.LUICGRectGetMin(X) - unit <= position && position <= frame.LUICGRectGetMax(X) + unit {
                r = .orderedSame
            } else if frame.LUICGRectGetMax(X) - unit < position {
                r = .orderedAscending
            } else {
                r = .orderedDescending
            }
            return r
        }
        if range.location != NSNotFound {
            for i in 0..<range.length {
                let index = i + range.location
                let c = self.cellAttributes[index]
                if self.isCellAttributesVisible(cellAttr: c) {
                    p = index
                    break
                }
            }
        }
        return p
    }
    
    private func firstVisibleCellAttributeIn(cellAttributes: [UICollectionViewLayoutAttributes]) -> UICollectionViewLayoutAttributes? {
        for cellAttribute in cellAttributes {
            if self.isCellAttributesVisible(cellAttr: cellAttribute) {
                return cellAttribute
            }
        }
        return nil
    }
    
    private func lastVisibleCellAttributeIn(cellAttributes: [UICollectionViewLayoutAttributes]) -> UICollectionViewLayoutAttributes? {
        for cellAttribute in cellAttributes.reversed() {
            if self.isCellAttributesVisible(cellAttr: cellAttribute) {
                return cellAttribute
            }
        }
        return nil
    }
    
    private func positionOfPagingForRect(bounds: CGRect) -> CGFloat {
        let X = self.scrollAxis
        return bounds.LUICGRectGetMin(X) + bounds.LUICGRectGetLength(X) * self.pagingBoundsPositionForCollectionView()
    }
    
    private func _prepareDelegate() {
        if self.enableCycleScroll || self.pagingEnabled || (_autoScrollingState?.isAutoScorlling ?? false) {
            //循环滚动或分页对齐时，都需要添加scrollview的方法
            if let delegate = self.collectionView?.delegate {
                if delegate !== self {
                    self.originDelegate = delegate
                    self.collectionView?.delegate = self
                }
            }
        } else {
            if let originDelegate = self.originDelegate {
                self.collectionView?.delegate = originDelegate
                self.originDelegate = nil
            }
        }
    }
    
    private func indexPathAtPagingCellWithMinDistance() -> IndexPath? {
        var indexPath: IndexPath?
        guard let collectionView = self.collectionView else { return indexPath }
        let bounds = collectionView.bounds
        let position = self.positionOfPagingForRect(bounds: bounds)
        let range = self.pagableCellIndexRangeNearToOffset(position: position)
        if range.length != NSNotFound {
            var minDis: CGFloat = CGFloat.greatestFiniteMagnitude
            var minIndexPath: IndexPath?
            for i in 0..<range.length {
                let index = range.location + i
                let c = self.cellAttributes[index]
                let f1 = c.frame
                let x1 = self.pagingPositionForCellFrame(frame: f1)
                let dis = abs(position - x1)
                if dis < minDis {
                    minDis = dis
                    minIndexPath = c.indexPath
                }
            }
            indexPath = minIndexPath;
        }
        return indexPath
    }
    
    private func __numberOfItemsInSetionModelWithIndex(index: Int) -> Int {
        var count: Int = 0
        if index > 0 && index < self.sectionModels.count {
            count = self.sectionModels[index].itemCount ?? 0
        }
        return count
    }
    
    deinit {
            collectionView?.delegate = self.originDelegate
            autoScrollingTimer?.invalidate()
    }
    
    private func __setContentViewContentOffset(contentOffset: CGPoint, animated: Bool) {
        guard let collectionView = self.collectionView else { return }
        guard CGPointEqualToPoint(contentOffset, collectionView.contentOffset) else { return }
        self.offsetChanging = true
        collectionView.setContentOffset(contentOffset, animated: animated)
        self._preContentOffset = collectionView.contentOffset
    }
    
    private func __resortCellAttributeWithBeginIndex(beginIndex: Int) {
        guard let collectionView = self.collectionView else { return }
        let offset = collectionView.contentOffset
        let contentSize = _contentSize
        let bounds = self.visibleRectForOriginBounds(bounds: collectionView.bounds)
        let X = self.scrollAxis
        let cellIndexes: [NSNumber] = self._cellLayoutAttributesIndexForElements(cellAttributes: self.cellAttributes, inRect: bounds)
        
    }
    
    private func _cellLayoutAttributesIndexForElements(cellAttributes: [UICollectionViewLayoutAttributes], inRect rect: CGRect) -> [NSNumber] {
        var indexes: [NSNumber] = []
        let X = self.scrollAxis
        let range = cellAttributes.l_rangeOfSortedObjectsWithComparator { (arrayObj, idx) -> ComparisonResult in
            let frame = arrayObj.l_frameSafety
            if CGRectIntersectsRect(rect, frame) {
                return .orderedSame
            } else if frame.LUICGRectGetMin(X) < rect.LUICGRectGetMin(X) {
                return .orderedAscending
            } else {
                return.orderedDescending
            }
        }
        for i in 0..<range.length {
            indexes.append(NSNumber(value: i + range.location))
        }
        return indexes
    }
    
    private func _onAudoScrollingTimer(timer: Timer) {
        if let distance = _autoScrollingState?.distance {
            self.setIndexPathAtPagingCellWithDistance(distance: distance, animated: true)
        }
    }
    
    private func _prepareCellLayouts(cellAttributeMap: [IndexPath : UICollectionViewLayoutAttributes], shouldCycleScroll shouldCycleScrollRef: Bool, isSizeFit: Bool) -> CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        var cellAttributes: [UICollectionViewLayoutAttributes] = []
        var sectionModels: [_LUICollectionViewPageFlowSectionModel] = []
        var cycleCellAttributes: [UICollectionViewLayoutAttributes] = []
        var cellAttributeMap = cellAttributeMap
        
        let X = self.scrollAxis
        let Y = LUICGAxis.LUICGAxisReverse(X)
        let sc = collectionView.numberOfSections
        let bounds = collectionView.bounds
        var f: CGRect = .zero
        for i in 0..<sc {
            let sm = _LUICollectionViewPageFlowSectionModel()
            let cellCount = collectionView.numberOfItems(inSection: i)
            let sectionInsets = self.insetForSectionAtIndex(section: i)
            let interitemSpacing = self.interitemSpacingForSectionAtIndex(section: i)
            let sectionBounds = UIEdgeInsetsInsetRect(bounds, sectionInsets)
            var hadFirstVisibleCell = false
            var tmp = f.LUICGRectGetMin(X)
            f.LUICGRectSetMin(X, value: f.LUICGRectGetMin(X) + LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdge(sectionInsets, axis: X, edge: .min))
            for j in 0..<cellCount {
                let p = IndexPath(item: j, section: i)
                f.size = self.itemSizeForSectionAtIndexPath(indexPath: p)
                if f.size.LUICGSizeGetLength(axis: X) > 0 {
                    if !hadFirstVisibleCell {
                        hadFirstVisibleCell = true
                    } else {
                        f.LUICGRectSetMin(X, value: f.LUICGRectGetMin(X) + interitemSpacing)
                    }
                }
                f.LUICGRectAlignToRect(Y, alignment: self.itemAlignment, bounds: sectionBounds)
                if let layoutClass = type(of: self).layoutAttributesClass as? UICollectionViewLayoutAttributes.Type {
                    let cellAttr = layoutClass.init(forCellWith: p)
                    cellAttr.l_frameSafety = f
                    cellAttributes.append(cellAttr)
                    if f.LUICGRectGetLength(X) > 0 {
                        f.LUICGRectSetMin(X, value: f.LUICGRectGetMin(X) + f.LUICGRectGetLength(X))
                    }
                }
            }
            f.LUICGRectSetMin(X, value: f.LUICGRectGetMin(X) + LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdge(sectionInsets, axis: X, edge: .max))
            if (tmp + LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdgeSum(sectionInsets, axis: X)) == f.LUICGRectGetMin(X) {
                f.LUICGRectSetMin(X, value: tmp)
            }
            sm.sectionInsets = sectionInsets
            sm.itemCount = cellCount
            sectionModels.append(sm)
        }
        for cellAttribute in cellAttributes {
            cellAttributeMap[cellAttribute.indexPath] = cellAttribute
        }
        var size: CGSize = .zero
        size.LUICGSizeSetLength(bounds.LUICGRectGetLength(Y), axis: Y)
        if let lastCell = self.lastVisibleCellAttributeIn(cellAttributes: cellAttributes) {
            let frame = lastCell.l_frameSafety
            let sectionInsets = sectionModels[lastCell.indexPath.section].sectionInsets
            size.LUICGSizeSetLength(frame.LUICGRectGetMax(X) + LUIEdgeInsetsEdge.LUIEdgeInsetsGetEdge(sectionInset, axis: X, edge: .max), axis: X)
        }
        if self.enableCycleScroll {
            cycleCellAttributes.append(contentsOf: self.__genCycleCellAttributesWithCellAttributes(cellAttributes: cellAttributes, contentSize: size))
            var tryCells: [UICollectionViewLayoutAttributes] = []
            let firstCell = self.firstVisibleCellAttributeIn(cellAttributes: cellAttributes)
            if let lastCell = self.lastVisibleCellAttributeIn(cellAttributes: cellAttributes), tryCells.contains(where: lastCell) {
                
            }
            
        }
        
        return .zero
    }
    
    private func __genCycleCellAttributesWithCellAttributes(cellAttributes: [UICollectionViewLayoutAttributes], contentSize: CGSize) -> [UICollectionViewLayoutAttributes] {
        var cycleCellAttributes: [UICollectionViewLayoutAttributes] = []
        let X = self.scrollAxis
        for cellAttribute in cellAttributes {
            if let newCellAttr = cellAttribute.copy() as? UICollectionViewLayoutAttributes {
                var f1 = cellAttribute.l_frameSafety
                f1.LUICGRectSetMin(X, value: f1.LUICGRectGetMin(X) - contentSize.LUICGSizeGetLength(axis: X))
                newCellAttr.l_frameSafety = f1
                cycleCellAttributes.append(newCellAttr)
            }
        }
        cycleCellAttributes.append(contentsOf: cellAttributes)
        
        for cellAttribute in cellAttributes {
            if let newCellAttr = cellAttribute.copy() as? UICollectionViewLayoutAttributes {
                var f1 = cellAttribute.l_frameSafety
                f1.LUICGRectSetMin(X, value: f1.LUICGRectGetMin(X) + contentSize.LUICGSizeGetLength(axis: X))
                newCellAttr.l_frameSafety = f1
                cycleCellAttributes.append(newCellAttr)
            }
        }
        
        return cycleCellAttributes
    }
}

public extension LUICollectionViewPageFlowLayout {
    var pageFlowDelegate: LUICollectionViewDelegatePageFlowLayout? {
        return self.collectionView?.delegate as? LUICollectionViewDelegatePageFlowLayout
    }
    
    func itemSizeForSectionAtIndexPath(indexPath: IndexPath) -> CGSize {
        var value = self.itemSize
        if let delegate = self.pageFlowDelegate, let collectionView = self.collectionView {
            value = delegate.collectionView(collectionView: collectionView, pageFlowLayout: self, itemSizeForItemAtIndexPath: indexPath)
        }
        return value
    }
    
    func insetForSectionAtIndex(section: Int) -> UIEdgeInsets {
        var value = self.sectionInset
        if let delegate = self.pageFlowDelegate, let collectionView = self.collectionView {
            value = delegate.collectionView(collectionView: collectionView, pageFlowLayout: self, insetForSectionAtIndex: section)
        }
        return value
    }
    
    func interitemSpacingForSectionAtIndex(section: Int) -> CGFloat {
        var value = self.interitemSpacing
        if let delegate = self.pageFlowDelegate, let collectionView = self.collectionView {
            value = delegate.collectionView(collectionView: collectionView, pageFlowLayout: self, interitemSpacingForSectionAtIndex: section)
        }
        return value
    }
    
    func pagingBoundsPositionForCollectionView() -> CGFloat {
        var value = self.pagingBoundsPosition
        if let delegate = self.pageFlowDelegate, let collectionView = self.collectionView {
            value = delegate.pagingBoundsPositionForCollectionView(collectionView: collectionView, pageFlowLayout: self)
        }
        return value
    }
    
    /// 指定collectionview的最大尺寸，返回collectionview最合适的尺寸值
    /// @param size 外层最大尺寸
    func l_sizeThatFits(size: CGSize) -> CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        let sizeFit: CGSize = .zero
        let originBounds = collectionView.bounds
        var bounds = collectionView.bounds
        let X = self.scrollAxis
        let Y = LUICGAxis.LUICGAxisReverse(X)
        _isSizeFitting = true
        if !CGSizeEqualToSize(originBounds.size, size) {
            bounds.size = size
            collectionView.bounds = bounds
        }
//        var cellAttributes: [UICollectionViewLayoutAttributes] = []
//        var cycleCellAttributes: [UICollectionViewLayoutAttributes] = []
//        var sectionModels: [_LUICollectionViewPageFlowSectionModel] = []
        return .zero
    }
}
