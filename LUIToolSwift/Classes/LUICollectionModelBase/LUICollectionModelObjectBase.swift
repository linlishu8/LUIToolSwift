//
//  LUICollectionModelObjectBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

public class LUICollectionModelObjectBase: NSObject {
    open var modelValue: Any?
    private var dynamicProperties: [AnyHashable: Any] = [:]

    required override init() {
        super.init()
    }

    // 创建模型方法
    class func modelWithValue(_ modelValue: Any?) -> LUICollectionModelObjectBase {
        let model = self.init()
        model.modelValue = modelValue
        return model
    }

    // 设置动态属性
    subscript(key: AnyHashable) -> Any? {
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
