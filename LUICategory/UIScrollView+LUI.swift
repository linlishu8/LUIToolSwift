//
//  UIScrollView+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/20.
//

import UIKit

enum LUIScrollViewScrollDirection {
    case vertical //垂直滚动
    case horizontal //水平滚动
}

enum LUIScrollViewScrollPosition {
    case head //居上或居左
    case middle //居中
    case foot //居下或居右
}


extension UIScrollView {
    
    func scrollToBottom(animated: Bool) {
        var offsetYMax = self.contentOffsetOfMaxY
        var offsetYMin = self.contentOffsetOfMinY
        if offsetYMax < offsetYMin {
            offsetYMax = offsetYMin
        }
        var contentOffset = self.contentOffset
        contentOffset.y = offsetYMax
        setContentOffset(contentOffset, animated: animated)
    }
    
    func scrollToTop(animated: Bool) {
        let offsetYMin = self.contentOffsetOfMinY
        var contentOffset = self.contentOffset
        contentOffset.y = offsetYMin
        setContentOffset(contentOffset, animated: animated)
    }
    
    var contentOffsetOfRange: UIEdgeInsets {
        let bounds = self.bounds
        let contentSize = self.contentSize
        let contentInset = self.adjustedContentInset
        let minY = -contentInset.top
        let maxY = max(minY, contentSize.height - bounds.height + contentInset.bottom)
        let minX = -contentInset.left
        let maxX = max(minX, contentSize.width - bounds.width + contentInset.right)
        return UIEdgeInsets(top: minY, left: minX, bottom: maxY, right: maxX)
    }
    
    func adjustContentOffset(in range: CGPoint) -> CGPoint {
        var offset = range
        let contentRange = self.contentOffsetOfRange
        offset.x = min(max(offset.x, contentRange.left), contentRange.right)
        offset.y = min(max(offset.y, contentRange.top), contentRange.bottom)
        return offset
    }
    
    var contentOffsetOfMinX: CGFloat {
        return self.contentOffsetOfRange.left
    }
    
    var contentOffsetOfMaxX: CGFloat {
        return self.contentOffsetOfRange.right
    }
    
    var contentOffsetOfMinY: CGFloat {
        return self.contentOffsetOfRange.top
    }
    
    var contentOffsetOfMaxY: CGFloat {
        return self.contentOffsetOfRange.bottom
    }
    
    var contentDisplayRect: CGRect {
        let zoomScale = self.zoomScale
        var displayRect = CGRect(origin: self.contentOffset, size: self.frame.size)
        displayRect.origin.x /= zoomScale
        displayRect.origin.y /= zoomScale
        displayRect.size.width /= zoomScale
        displayRect.size.height /= zoomScale
        return displayRect
    }
    
    var contentBounds: CGRect {
        let insets = self.adjustedContentInset
        var bounds = self.bounds
        bounds.origin = .zero
        return UIEdgeInsetsInsetRect(bounds, insets)
    }
    
    var centerPointOfContent: CGPoint {
        let bounds = self.bounds
        let safeAreaInsets = self.adjustedContentInset
        let contentFrame = UIEdgeInsetsInsetRect(bounds, safeAreaInsets)
        return CGPoint(x: contentFrame.midX, y: contentFrame.midY)
    }
    
    var adjustedContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.adjustedContentInset
        } else {
            return self.contentInset
        }
    }
    
    func zoom(to point: CGPoint, scale: CGFloat, animated: Bool) {
        let zoomScale = self.zoomScale
        var adjustedPoint = point
        adjustedPoint.x /= zoomScale
        adjustedPoint.y /= zoomScale
        
        var displayRect = self.contentDisplayRect
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: -displayRect.midX, y: -displayRect.midY)
        transform = transform.scaledBy(x: zoomScale / scale, y: zoomScale / scale)
        
        let zoomPoint = adjustedPoint.applying(transform)
        transform = transform.translatedBy(x: adjustedPoint.x - zoomPoint.x, y: adjustedPoint.y - zoomPoint.y)
        let zoomRect = displayRect.applying(transform)
        
        self.zoom(to: zoomRect, animated: true)
    }
    
    func toggleZoomScale(gesture: UIGestureRecognizer) {
        let maxScale = self.maximumZoomScale
        let zoomScale = self.zoomScale
        let resultZoomScale = (zoomScale == 1) ? maxScale : 1
        let point = gesture.location(in: self)
        self.zoom(to: point, scale: resultZoomScale, animated: true)
    }
    
    func adjustContent(forKeyboard notification: Notification, responderViewClass: AnyClass?, contentInsets: UIEdgeInsets, window: UIWindow) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardRect = keyboardFrame.cgRectValue
        let windowRect = window.bounds
        let scrollViewFrame = self.superview?.convert(self.frame, to: window) ?? .zero
        var insets = contentInsets
        insets.bottom += keyboardRect.height - (windowRect.height - scrollViewFrame.maxY)
        self.contentInset = insets
        
        guard let responderView = self.firstResponder(ofClass: responderViewClass) else { return }
        let responderFrame = responderView.superview?.convert(responderView.frame, to: self) ?? .zero
        var contentOffset = self.contentOffset
        
        let offsetMinY = responderFrame.origin.y - self.frame.height + keyboardRect.height - (windowRect.height - scrollViewFrame.maxY) + responderFrame.height
        if contentOffset.y < offsetMinY {
            contentOffset.y = offsetMinY
            UIView.animate(withDuration: duration) {
                self.setContentOffset(contentOffset, animated: false)
            }
        }
    }
    
    func contentOffset(forScrollTo viewFrame: CGRect, direction: LUIScrollViewScrollDirection, position: LUIScrollViewScrollPosition) -> CGPoint {
        let axis: LUICGAxis = (direction == .vertical) ? .y : .x
        var offset = self.contentOffset
        let bounds = self.bounds
        let contentInset = self.adjustedContentInset
        let visibleBounds = bounds.inset(by: contentInset)
        
        switch position {
        case .head:
            offset.setValue(LUICGRectGetMin(viewFrame, axis) - LUIEdgeInsetsGetEdge(contentInset, axis, .min), forAxis: axis)
        case .middle:
            offset.setValue(LUICGRectGetMid(viewFrame, axis) - LUIEdgeInsetsGetEdge(contentInset, axis, .min) - (visibleBounds.size.height * 0.5), forAxis: axis)
        case .foot:
            offset.setValue(LUICGRectGetMax(viewFrame, axis) - (bounds.size.height) + LUIEdgeInsetsGetEdge(contentInset, axis, .max), forAxis: axis)
        default:
            break
        }
        
        // 限制 offset 范围
        offset = adjustContentOffset(in: offset)
        return offset
    }
    
    func autoBounces() {
        let contentSize = self.contentSize
        let contentInset = self.adjustedContentInset
        let bounds = self.bounds
        
        let delta: CGFloat = 0.0000001
        let bounces = (contentSize.width + contentInset.left + contentInset.right > bounds.size.width + delta) ||
                      (contentSize.height + contentInset.top + contentInset.bottom > bounds.size.height + delta)
        
        self.bounces = bounces
    }
    
    // MARK: - Helper Method
    private func firstResponder(ofClass responderViewClass: AnyClass?) -> UIView? {
        guard let responderViewClass = responderViewClass else { return self.firstResponder }
        var responder: UIView? = self.firstResponder
        while let superview = responder?.superview {
            if superview.isKind(of: responderViewClass) {
                return superview
            }
            responder = superview
        }
        return responder
    }
}
