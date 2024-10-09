//
//  LUITableViewCellSwipeAction.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

enum LUITableViewCellSwipeActionStyle: Int {
    case normal = 0
    case destructive = 1
}

public class LUITableViewCellSwipeAction {

    let style: LUITableViewCellSwipeActionStyle
    var title: String?
    var handler: ((LUITableViewCellSwipeAction, LUITableViewCellModel) -> Void)?
    var backgroundColor: UIColor? // Default background color set from action style
    var image: UIImage?
    var autoCompletion: Bool = true // Default is true

    init(style: LUITableViewCellSwipeActionStyle, title: String?, handler: ((LUITableViewCellSwipeAction, LUITableViewCellModel) -> Void)?) {
        self.style = style
        self.title = title
        self.handler = handler
    }

    static func action(with style: LUITableViewCellSwipeActionStyle, title: String?, handler: ((LUITableViewCellSwipeAction, LUITableViewCellModel) -> Void)?) -> LUITableViewCellSwipeAction {
        return LUITableViewCellSwipeAction(style: style, title: title, handler: handler)
    }

    @available(iOS 11.0, *)
    func contextualActionWithCellModel(_ cellModel: LUITableViewCellModel) -> UIContextualAction {
        let actionStyle: UIContextualAction.Style = (style == .destructive) ? .destructive : .normal
        let contextualAction = UIContextualAction(style: actionStyle, title: title) { action, sourceView, completionHandler in
            self.handler?(self, cellModel)
            if self.autoCompletion {
                completionHandler(true)
            }
        }
        
        contextualAction.image = image
        contextualAction.backgroundColor = backgroundColor
        return contextualAction
    }

    func tableViewRowActionWithCellModel(_ cellModel: LUITableViewCellModel) -> UITableViewRowAction {
        let actionStyle: UITableViewRowAction.Style = (style == .destructive) ? .destructive : .normal
        let rowAction = UITableViewRowAction(style: actionStyle, title: title) { action, indexPath in
            self.handler?(self, cellModel)
            if self.autoCompletion {
                cellModel.refreshWithAnimated(true)
            }
        }
        
        if let bgColor = backgroundColor {
            rowAction.backgroundColor = bgColor
        }
        return rowAction
    }
}
