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
    subscript(key: String) -> Any? {
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
