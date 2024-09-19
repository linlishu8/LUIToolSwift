//
//  LUICollectionModelObjectBase.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/19.
//

import Foundation

class LUICollectionModelObjectBase: NSObject, NSCopying {
    var modelValue: Any?
    private var dynamicProperties: [AnyHashable: Any] = [:]

    // Required initializer
    required override init() {
        super.init()
    }

    // NSCopying 协议方法
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        copy.dynamicProperties = dynamicProperties
        copy.modelValue = modelValue
        return copy
    }

    // 创建模型方法
    class func model(withValue modelValue: Any?) -> LUICollectionModelObjectBase {
        let model = self.init() // 使用 required initializer
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

// 扩展方法
extension LUICollectionModelObjectBase {
    func l_value(forKeyPath path: String, otherwise other: Any?) -> Any? {
        // 这里实现具体的逻辑，比如 KVC 访问
        return dynamicProperties[path] ?? other
    }
}
