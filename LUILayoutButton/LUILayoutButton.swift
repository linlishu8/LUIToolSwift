//
//  LUILayoutButton.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/9.
//

import Foundation

public enum LUILayoutButtonContentStyle: Int {
    case horizontal
    case vertical
}

public class LUILayoutButton: UIButton {
    private lazy var flowlayout: LUIFlowLayoutConstraint = {
        let layout = LUIFlowLayoutConstraint.init()
        layout.layoutHiddenItem = true
        layout.layoutDirection = .constraintHorizontal
        return layout
    }()
    private var _contentStyle: LUILayoutButtonContentStyle = .horizontal //图标和文字的位置，默认横着放
    open var contentStyle: LUILayoutButtonContentStyle {
        get {
            return _contentStyle
        }
        set {
            if _contentStyle == newValue { return }
            _contentStyle = newValue
            switch _contentStyle {
            case .horizontal:
                self.flowlayout.layoutDirection = .constraintHorizontal
            case .vertical:
                self.flowlayout.layoutDirection = .constraintVertical
            }
            self.setNeedsLayout()
        }
    }
    //图标与文字之间的间距,默认是3px
    open var interitemSpacing: CGFloat {
        get {
            return self.flowlayout.interitemSpacing
        }
        set {
            if self.interitemSpacing == newValue { return }
            self.flowlayout.interitemSpacing = newValue
            self.setNeedsLayout()
        }
    }
    
    private var titleLabelLayoutConstraint: LUILayoutConstraintItemWrapper?
    private var imageViewLayoutConstraint: LUILayoutConstraintItemWrapper?
    //是否逆转图标与文字的顺序,默认是NO:图标在左/上,文本在右/下
    private var _reverseContent: Bool = false
    open var reverseContent: Bool {
        get {
            return _reverseContent
        }
        set {
            if _reverseContent == newValue { return }
            guard let titleLabelLayoutConstraint = self.titleLabelLayoutConstraint, let imageViewLayoutConstraint = self.imageViewLayoutConstraint else { return }
            self.flowlayout.items = _reverseContent ? [titleLabelLayoutConstraint, imageViewLayoutConstraint] : [imageViewLayoutConstraint, titleLabelLayoutConstraint]
            self.setNeedsLayout()
        }
    }
    
    //imageView尺寸,如果某一边为0，代表不限制。默认为(0,0),代表自动根据图片大小计算
    private var _imageSize: CGSize = .zero
    open var imageSize: CGSize {
        get {
            return _imageSize
        }
        set {
            if CGSizeEqualToSize(newValue, _imageSize) { return }
            _imageSize = newValue
            self.setNeedsLayout()
        }
    }
    open var hideImageViewForNoImage: Bool = false //当没有图片时，是否隐藏imageView。默认为NO，不隐藏imageView，如果imageSize不为(0,0),imageView将继续占用空间
    open var layoutVerticalAlignment: LUILayoutConstraintVerticalAlignment {
        get {
            return self.flowlayout.layoutVerticalAlignment
        }
        set {
            if self.flowlayout.layoutVerticalAlignment == newValue { return }
            self.flowlayout.layoutVerticalAlignment = newValue
            self.setNeedsLayout()
        }
    } //所有元素作为一个整体,在垂直方向上的位置,以及每一个元素在整体内的垂直方向上的对齐方式.默认为LUILayoutConstraintVerticalAlignmentCenter.详细查看LUIFlowLayoutConstraint.h
    open var layoutHorizontalAlignment: LUILayoutConstraintHorizontalAlignment {
        get {
            return self.flowlayout.layoutHorizontalAlignment
        }
        set {
            if self.flowlayout.layoutHorizontalAlignment == newValue { return }
            self.flowlayout.layoutHorizontalAlignment = newValue
            self.setNeedsLayout()
        }
    } //所有元素作为一个整体,在水平方向上的位置,以及每一个元素在整体内的水平方向上的对方方式.默认为LUILayoutConstraintHorizontalAlignmentCenter.详细查看LUIFlowLayoutConstraint.h
    
    //内边距,默认为(0,0,0,0)
    open var contentInsets: UIEdgeInsets {
        get {
            self.flowlayout.contentInsets
        }
        set {
            if UIEdgeInsetsEqualToEdgeInsets(self.contentInsets, newValue) { return }
            self.flowlayout.contentInsets = newValue
            self.setNeedsLayout()
        }
    }
    open var minHitSize: CGSize = CGSize(width: 30, height: 30)//最小的点击区域尺寸，通过设置该值，可以使得点击区域大于self.bounds(当minHitSize>bounds.size时)。默认为30x30
    
    private lazy var sizeFitTitleLabel: UILabel = {
        guard let labelType = titleLabel?.classForCoder as? UILabel.Type else {
            return UILabel()
        }
        let label = labelType.init()
        configureLabel(label)
        return label
    }()

    private func configureLabel(_ label: UILabel) {
        guard let titleLabel = titleLabel else { return }
        
        label.attributedText = nil
        label.text = nil
        label.contentMode = titleLabel.contentMode
        label.font = titleLabel.font
        label.shadowOffset = titleLabel.shadowOffset
        label.textAlignment = titleLabel.textAlignment
        label.lineBreakMode = titleLabel.lineBreakMode
        label.isHighlighted = titleLabel.isHighlighted
        label.isEnabled = titleLabel.isEnabled
        label.numberOfLines = titleLabel.numberOfLines
        label.adjustsFontSizeToFitWidth = titleLabel.adjustsFontSizeToFitWidth
        label.baselineAdjustment = titleLabel.baselineAdjustment
        label.minimumScaleFactor = titleLabel.minimumScaleFactor
        label.allowsDefaultTighteningForTruncation = titleLabel.allowsDefaultTighteningForTruncation
        // label.lineBreakStrategy = titleLabel.lineBreakStrategy // Uncomment if needed and available in your iOS version
        label.preferredMaxLayoutWidth = titleLabel.preferredMaxLayoutWidth
    }
    
    private lazy var sizeFitImageView: UIImageView = {
        let imageViewType = self.imageView?.classForCoder as? UIImageView.Type ?? UIImageView.self
        let imageView = imageViewType.init()
        configureImageView(imageView)
        return imageView
    }()

    private func configureImageView(_ imageView: UIImageView) {
        guard let originalImageView = self.imageView else { return }
        
        imageView.image = nil
        imageView.contentMode = originalImageView.contentMode
    }
    
    public init(contentStyle: LUILayoutButtonContentStyle) {
        super.init(frame: .zero)
        self.contentStyle = contentStyle
        self.setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        self.imageView?.contentMode = .scaleAspectFit
//        self.titleLabelLayoutConstraint = LUILayoutConstraintItemWrapper.wrapItem(self.titleLabel, sizeThatFitsBlock: { <#LUILayoutConstraintItemWrapper#>, <#CGSize#>, <#Bool#> in
//            <#code#>
//        })
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !self.isUserInteractionEnabled || self.isHidden || !self.isEnabled {
            return false
        }
        let minHitSize = self.minHitSize
        var bounds = self.bounds
        let center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        bounds.size.width = max(bounds.size.width, minHitSize.width)
        bounds.size.height = max(bounds.size.height, minHitSize.height)
        bounds.origin.x = center.x - bounds.size.width / 2
        bounds.origin.y = center.y - bounds.size.height / 2
        return CGRectContainsPoint(bounds, point)
    }
}
