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
    
    func l_scrollToBottomWithAnimated(_ animated: Bool) {
        var offsetYMax = l_contentOffsetOfMaxY
        var offsetYMin = l_contentOffsetOfMinY
        if offsetYMax < offsetYMin {
            offsetYMax = offsetYMin
        }
        var contentOffset = self.contentOffset
        contentOffset.y = offsetYMax
        setContentOffset(contentOffset, animated: animated)
    }
    
    func l_scrollToTopWithAnimated(_ animated: Bool) {
        let offsetYMin = l_contentOffsetOfMinY
        var contentOffset = self.contentOffset
        contentOffset.y = offsetYMin
        setContentOffset(contentOffset, animated: animated)
    }
    
    var l_contentOffsetOfRange: UIEdgeInsets {
        let bounds = self.bounds
        let contentSize = self.contentSize
        let contentInset = self.adjustedContentInset
        let minY = -contentInset.top
        let maxY = max(minY, contentSize.height - bounds.height + contentInset.bottom)
        let minX = -contentInset.left
        let maxX = max(minX, contentSize.width - bounds.width + contentInset.right)
        return UIEdgeInsets(top: minY, left: minX, bottom: maxY, right: maxX)
    }
    
    func l_adjustContentOffsetInRange(in range: CGPoint) -> CGPoint {
        var offset = range
        let contentRange = self.l_contentOffsetOfRange
        offset.x = min(max(offset.x, contentRange.left), contentRange.right)
        offset.y = min(max(offset.y, contentRange.top), contentRange.bottom)
        return offset
    }
    
    var l_contentOffsetOfMinX: CGFloat {
        return self.l_contentOffsetOfRange.left
    }
    
    var l_contentOffsetOfMaxX: CGFloat {
        return self.l_contentOffsetOfRange.right
    }
    
    var l_contentOffsetOfMinY: CGFloat {
        return self.l_contentOffsetOfRange.top
    }
    
    var l_contentOffsetOfMaxY: CGFloat {
        return self.l_contentOffsetOfRange.bottom
    }
    
    var l_contentDisplayRect: CGRect {
        let zoomScale = self.zoomScale
        var displayRect = CGRect(origin: self.contentOffset, size: self.frame.size)
        displayRect.origin.x /= zoomScale
        displayRect.origin.y /= zoomScale
        displayRect.size.width /= zoomScale
        displayRect.size.height /= zoomScale
        return displayRect
    }
    
    var l_contentBounds: CGRect {
        let insets = l_adjustedContentInset
        var bounds = self.bounds
        bounds.origin = .zero
        return UIEdgeInsetsInsetRect(bounds, insets)
    }
    
    var l_centerPointOfContent: CGPoint {
        let bounds = self.bounds
        let safeAreaInsets = l_adjustedContentInset
        let contentFrame = UIEdgeInsetsInsetRect(bounds, safeAreaInsets)
        return CGPoint(x: contentFrame.midX, y: contentFrame.midY)
    }
    
    var l_adjustedContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.adjustedContentInset
        } else {
            return self.contentInset
        }
    }
    
    func l_zoomToPoint(_ point: CGPoint, zoomScale scale: CGFloat, animated: Bool) {
        let zoomScale = self.zoomScale
        let resultZoomScale = scale
        var p = point // Adjust point to account for zoomScale
        p.x /= zoomScale
        p.y /= zoomScale

        let displayRect = self.l_contentDisplayRect
        var transform = CGAffineTransform(translationX: -displayRect.midX, y: -displayRect.midY)
        transform = transform.scaledBy(x: zoomScale / resultZoomScale, y: zoomScale / resultZoomScale)

        let zoomPoint = p.applying(transform)
        transform = transform.translatedBy(x: p.x - zoomPoint.x, y: p.y - zoomPoint.y)
        let zoomRect = displayRect.applying(transform)

        self.zoom(to: zoomRect, animated: true)
    }
    
    func l_toggleZoomScale(_ gesture: UIGestureRecognizer) {
        let maxScale = self.maximumZoomScale
        let zoomScale = self.zoomScale
        let resultZoomScale = (zoomScale == 1) ? maxScale : 1
        let point = gesture.location(in: self)
        l_zoomToPoint(point, zoomScale: resultZoomScale, animated: true)
    }
    
    func l_adjustContentWithUIKeyboardDidShowNotification(_ notification: Notification, responderViewClass: AnyClass?, contentInsets: UIEdgeInsets, window: UIWindow) {
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
    
    func l_contentOffsetWithScrollTo(_ viewFrame: CGRect, direction: LUIScrollViewScrollDirection, position: LUIScrollViewScrollPosition) -> CGPoint {
        let axis = direction == .vertical ? LUICGAxis : NSLayoutConstraint.Attribute.centerX
        var offset = self.contentOffset
        let bounds = self.bounds
        let contentInset = self.adjustedContentInset
        let visibleBounds = bounds.inset(by: contentInset)
        
        let targetPosition: CGFloat
        switch position {
        case .head:
            targetPosition = axis == .centerY ? viewFrame.minY - contentInset.top : viewFrame.minX - contentInset.left
        case .middle:
            let visibleLength = axis == .centerY ? visibleBounds.height : visibleBounds.width
            targetPosition = (axis == .centerY ? viewFrame.midY : viewFrame.midX) - contentInset.top - visibleLength * 0.5
        case .foot:
            let boundsLength = axis == .centerY ? bounds.height : bounds.width
            targetPosition = (axis == .centerY ? viewFrame.maxY : viewFrame.maxX) - boundsLength + (axis == .centerY ? contentInset.bottom : contentInset.right)
        }
        
        if axis == .centerY {
            offset.y = targetPosition
        } else {
            offset.x = targetPosition
        }
        
        return adjustContentOffsetInRange(offset)
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
