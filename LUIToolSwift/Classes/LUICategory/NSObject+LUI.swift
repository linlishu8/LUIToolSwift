//
//  NSObject+LUI.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/9/18.
//

import Foundation

extension NSObject {

    func l_valueForKeyPath(_ path: String, otherwise other: Any?) -> Any? {
        let obj = self.value(forKeyPath: path);
        return obj ?? other
    }
    func l_valueForKeyPath(_ path: String) -> Any? {
        return self.l_valueForKeyPath(path, otherwise: nil)
    }
    
    func l_arrayForKeyPath(_ path: String, otherwise other: [Any]?) -> [Any]? {
        let obj = self.l_valueForKeyPath(path, otherwise: other)
        var value = other
        if let array =  obj as? [Any] {
            value = array
        }
        if let string = obj as? String, let jsonArray = string.l_jsonArray() {
            value = jsonArray
        }
        return value
    }
    func l_arrayForKeyPath(_ path: String) -> [Any]? {
        return self.l_arrayForKeyPath(path, otherwise: nil)
    }
    
    func l_dictionaryForKeyPath(_ path: String, otherwise other: [String: Any]?) -> [String: Any]? {
        let obj = self.l_valueForKeyPath(path, otherwise: other)
        var value = other
        if let dictionary = obj as? [String: Any] {
            value = dictionary
        }
        if let string = obj as? String, let jsonDictionary = string.l_jsonDictionary() {
            value = jsonDictionary
        }
        return value
    }
    func l_dictionaryForKeyPath(_ path: String) -> [String: Any]? {
        return self.l_dictionaryForKeyPath(path, otherwise: nil)
    }
    
    func l_stringForKeyPath(_ path: String, otherwise other: String?) -> String? {
        let obj = self.l_valueForKeyPath(path, otherwise: other)
        var value = other
        if let stringValue = obj as? String {
            value = stringValue
        }
        if let numberValue = obj as? NSNumber {
            value = numberValue.stringValue
        }
        return value
    }
    func l_stringForKeyPath(_ path: String) -> String? {
        return self.l_stringForKeyPath(path, otherwise: nil)
    }
    
    func l_numberForKeyPath(_ path: String, otherwise other: NSNumber?) -> NSNumber? {
        let obj = self.l_valueForKeyPath(path, otherwise: other)
        var value = other
        if let numberValue = obj as? NSNumber {
            value = numberValue
        }
        if let stringValue = obj as? String {
            value = stringValue.l_numberValue()
        }
        return value
    }
    func l_numberForKeyPath(_ path: String) -> NSNumber? {
        return self.l_numberForKeyPath(path, otherwise: nil)
    }
    
    func l_boolForKeyPath(_ path: String, otherwise other: Bool) -> Bool {
        let obj = self.l_valueForKeyPath(path, otherwise: other)
        var value = other
        if let numberValue = obj as? NSNumber {
            value = numberValue.boolValue
        }
        return value
    }
    func l_boolForKeyPath(_ path: String) -> Bool {
        return self.l_boolForKeyPath(path, otherwise: false)
    }
    
    func l_integerForKeyPath(_ path: String, otherwise other: Int) -> Int {
        let obj = self.l_numberForKeyPath(path, otherwise: nil)
        guard let value = obj else { return other }
        return value.intValue
    }
    func l_integerForKeyPath(_ path: String) -> Int {
        return self.l_integerForKeyPath(path, otherwise: 0)
    }
    
    func l_floatForKeyPath(_ path: String, otherwise other: Float) -> Float {
        let obj = self.l_numberForKeyPath(path, otherwise: nil)
        guard let value = obj else { return other }
        return value.floatValue
    }
    func l_floatForKeyPath(_ path: String) -> Float {
        return self.l_floatForKeyPath(path, otherwise: 0.0)
    }
    
    func l_doubleForKeyPath(_ path: String, otherwise other: Double) -> Double {
        let obj = self.l_numberForKeyPath(path, otherwise: nil)
        guard let value = obj else { return other }
        return value.doubleValue
    }
    func l_doubleForKeyPath(_ path: String) -> Double {
        return self.l_doubleForKeyPath(path, otherwise: 0.0)
    }
    
    func l_NSValueForKeyPath(_ path: String, otherwise other: NSValue?) -> NSValue? {
        let obj = self.l_valueForKeyPath(path, otherwise: other)
        var value = other
        if let nsValue = obj as? NSValue {
            value = nsValue
        }
        return value
    }
    func l_NSValueForKeyPath(_ path: String) -> NSValue? {
        return self.l_NSValueForKeyPath(path, otherwise: nil)
    }
    
    func l_timeIntervalForKeyPath(_ path: String, otherwise other: TimeInterval) -> TimeInterval {
        let obj = self.l_numberForKeyPath(path, otherwise: nil)
        guard let value = obj else { return other }
        return value.doubleValue
    }
    func l_timeIntervalForKeyPath(_ path: String) -> TimeInterval {
        return self.l_timeIntervalForKeyPath(path, otherwise: 0.0)
    }
    
    func l_dateSinceReferenceDateForKeyPath(_ path: String, dateFormatter formatter: DateFormatter, otherwise other: Date?) -> Date? {
        let obj = self.l_valueForKeyPath(path, otherwise: other)
        if let dateValue = obj as? Date {
            return dateValue
        } else if let stringValue = obj as? String {
            guard let numberValue = stringValue.l_numberValue() else { return formatter.date(from: stringValue) }
            return Date(timeIntervalSinceReferenceDate: numberValue.doubleValue)
        } else if let numberValue = obj as? NSNumber {
            return Date(timeIntervalSinceReferenceDate: numberValue.doubleValue)
        }
        return other
    }
    func l_dateSinceReferenceDateForKeyPath(_ path: String, dateFormatter formatter: DateFormatter) -> Date? {
        return self.l_dateSinceReferenceDateForKeyPath(path, dateFormatter: formatter, otherwise: nil)
    }
}

