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
    open var contentStyle: LUILayoutButtonContentStyle = .horizontal //图标和文字的位置，默认横着放
    open var interitemSpacing: Int = 3 //图标与文字之间的间距,默认是3px
    open var reverseContent: Bool = false //是否逆转图标与文字的顺序,默认是NO:图标在左/上,文本在右/下
    open var imageSize: CGSize = .zero //imageView尺寸,如果某一边为0，代表不限制。默认为(0,0),代表自动根据图片大小计算
    open var hideImageViewForNoImage: Bool = false //当没有图片时，是否隐藏imageView。默认为NO，不隐藏imageView，如果imageSize不为(0,0),imageView将继续占用空间
    open var layoutVerticalAlignment: LUILayoutConstraintVerticalAlignment = .verticalCenter //所有元素作为一个整体,在垂直方向上的位置,以及每一个元素在整体内的垂直方向上的对齐方式.默认为LUILayoutConstraintVerticalAlignmentCenter.详细查看LUIFlowLayoutConstraint.h
    open var layoutHorizontalAlignment: LUILayoutConstraintHorizontalAlignment = .horizontalCenter //所有元素作为一个整体,在水平方向上的位置,以及每一个元素在整体内的水平方向上的对方方式.默认为LUILayoutConstraintHorizontalAlignmentCenter.详细查看LUIFlowLayoutConstraint.h
    open var contentInsets: UIEdgeInsets = .zero //内边距,默认为(0,0,0,0)
    open var minHitSize: CGSize = CGSize(width: 30, height: 30)//最小的点击区域尺寸，通过设置该值，可以使得点击区域大于self.bounds(当minHitSize>bounds.size时)。默认为30x30
    
    public init(contentStyle: LUILayoutButtonContentStyle) {
        super.init(frame: .zero)
        self.contentStyle = contentStyle
    }
    
    lazy private var sizeFitTitleLabel: UILabel = {
        let titleLabel = self.titleLabel
        return titleLabel ?? UILabel()
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
