//
//  LUITableViewSectionView.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/27.
//

import Foundation

class LUITableViewSectionView: UIView, LUITableViewSectionViewProtocol {
    let defaultHeight: Double = 22
    open var sectionModel: LUITableViewSectionModel?
    var kind: LUITableViewSectionViewKind?
    lazy var contentView: UIView = {
        return UIView()
    }()
    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 17)
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .left
        textLabel.textColor = UIColor.gray
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.textLabel)
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var bounds = self.bounds
        if #available(iOS 11.0, *) {
            bounds = self.safeAreaLayoutGuide.layoutFrame
        }
        self.contentView.frame = bounds
        
        let margin: CGFloat = 16
        let insets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        let f1 = UIEdgeInsetsInsetRect(self.contentView.bounds, insets)
        self.textLabel.frame = f1
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: defaultHeight)
    }
    
    
    // MARK: - LUITableViewSectionViewProtocol
    static func heightWithTableView(_: UITableView, sectionModel: LUITableViewSectionModel, kind: LUITableViewSectionViewKind) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    func setSectionModel(_ sectionModel: LUITableViewSectionModel?, kind: LUITableViewSectionViewKind) {
        self.sectionModel = sectionModel
        self.kind = kind
        
        self.textLabel.text = kind == .head ? sectionModel?.headTitle : sectionModel?.footTitle
        
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    func tableView(_: UITableView, willDisplaySectionModel sectionModel: LUITableViewSectionModel, kind: LUITableViewSectionViewKind) {
        
    }
    
    func tableView(_: UITableView, didEndDisplayingSectionModel sectionModel: LUITableViewSectionModel, kind: LUITableViewSectionViewKind) {
        
    }
    
    
}
