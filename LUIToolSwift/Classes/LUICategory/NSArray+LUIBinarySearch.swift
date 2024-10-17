//
//  NSArray+LUIBinarySearch.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/16.
//

import Foundation

public extension Array {
    func l_rangeOfSortedObjectsWithComparator(cmptr: (Element, Int) -> ComparisonResult) -> NSRange {
        var range = NSRange(location: NSNotFound, length: 0)
                if self.isEmpty {
                    return range
                }

                var leftIndex: Int? = nil
                var rightIndex: Int? = nil

                // 查找区域左侧元素的索引
                var begin = 0
                var end = self.count - 1
                while begin <= end {
                    let i = begin + (end - begin) / 2
                    let value = self[i]
                    let result = cmptr(value, i)
                    
                    if result == .orderedSame || result == .orderedDescending {
                        rightIndex = i // 记录可能的右索引
                        end = i - 1
                    } else {
                        begin = i + 1
                    }
                }
                
                leftIndex = rightIndex // 尝试设置左索引

                // 查找区域右侧元素的索引
                if let left = leftIndex {
                    begin = left
                    end = self.count - 1
                    while begin <= end {
                        let i = begin + (end - begin + 1) / 2
                        let value = self[i]
                        let result = cmptr(value, i)
                        
                        if result == .orderedSame || result == .orderedAscending {
                            rightIndex = i
                            begin = i + 1
                        } else {
                            end = i - 1
                        }
                    }
                }
                
                if let left = leftIndex, let right = rightIndex, left <= right {
                    range = NSRange(location: left, length: right - left + 1)
                }

                return range
        }
}
