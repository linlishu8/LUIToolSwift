//
//  LUICollectionModelObjectBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

public class LUICollectionModelObjectBase: NSObject {
    open var modelValue: Any?
    private var dynamicProperties: [String: Any]
    
    public init(modelValue: Any? = nil) {
        self.modelValue = modelValue
        self.dynamicProperties = [:]
    }
    
    // 创建模型方法
    static func modelWithValue(_ modelValue: Any?) -> LUICollectionModelObjectBase {
        let model = LUICollectionModelObjectBase.init(modelValue: modelValue)
        return model
    }

    // 设置动态属性
    public subscript(key: String) -> Any? {
        get {
            return dynamicProperties[key]
        }
        set {
            if let value = newValue {
                dynamicProperties[key] = value
            } else {
                dynamicProperties.removeValue(forKey: key)
            }
        }
    }
}

extension LUICollectionModelObjectBase {
    func l_cellHeightForKeyPath(_ path: String, otherwise other: CGFloat) -> CGFloat {
        let obj = dynamicProperties[path]
        guard let value = obj else { return other }
        return value as? CGFloat ?? 0
    }
}
