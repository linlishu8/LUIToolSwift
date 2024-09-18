//
//  Untitled.swift
//  Pods
//
//  Created by 六月 on 2024/9/18.
//

import Foundation

extension String {
    func l_numberValue() -> NSNumber? {
        if let number = self.l_numberOfInteger() {
            return number
        } else if let number = self.l_numberOfLongLong() {
            return number
        } else if let number = self.l_numberOfFloat() {
            return number
        } else if let number = self.l_numberOfDouble() {
            return number
        }
        return nil
    }
    
    func l_numberOfInteger() -> NSNumber? {
        let scanner = Scanner(string: self)
        var value: Int = 0
        if scanner.scanInt(&value), scanner.isAtEnd {
            return NSNumber(value: value)
        }
        return nil
    }
    
    func l_numberOfLongLong() -> NSNumber? {
        let scanner = Scanner(string: self)
        var value: Int64 = 0
        if scanner.scanInt64(&value), scanner.isAtEnd {
            return NSNumber(value: value)
        }
        return nil
    }
    
    func l_numberOfFloat() -> NSNumber? {
        let scanner = Scanner(string: self)
        var value: Float = 0.0
        if scanner.scanFloat(&value), scanner.isAtEnd {
            return NSNumber(value: value)
        }
        return nil
    }
    
    func l_numberOfDouble() -> NSNumber? {
        let scanner = Scanner(string: self)
        var value: Double = 0.0
        if scanner.scanDouble(&value), scanner.isAtEnd {
            return NSNumber(value: value)
        }
        return nil
    }
    
    func l_jsonValue() -> Any? {
        guard !self.isEmpty else {
            return nil
        }
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [])
            return obj
        } catch {
            return nil
        }
    }
    
    func l_jsonDictionary() -> [String: Any]? {
        if let obj = self.l_jsonValue() as? [String: Any] {
            return obj
        }
        return nil
    }
    
    func l_jsonArray() -> [Any]? {
        if let obj = self.l_jsonValue() as? [Any] {
            return obj
        }
        return nil
    }
}
