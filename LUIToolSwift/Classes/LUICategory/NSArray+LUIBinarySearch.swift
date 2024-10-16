//
//  NSArray+LUIBinarySearch.swift
//  LUIToolSwift
//
//  Created by 六月 on 2024/10/16.
//

import Foundation

public extension Array {
    func l_rangeOfSortedObjectsWithComparator(comparator: (Element, Int) -> ComparisonResult) -> NSRange {
            var range = NSRange(location: NSNotFound, length: 0)
            guard !self.isEmpty else {
                return range
            }

            var leftIndex: Int? = nil
            var rightIndex: Int? = nil

            // 二分查找左侧索引
            var begin = 0
            var end = self.count - 1
            while begin <= end {
                let mid = begin + (end - begin) / 2
                let result = comparator(self[mid], mid)
                if result == .orderedSame || result == .orderedDescending {
                    rightIndex = mid
                    end = mid - 1
                } else {
                    begin = mid + 1
                }
            }
            
            leftIndex = rightIndex // 简化处理，实际逻辑可能需要调整

            // 二分查找右侧索引
            if let left = leftIndex {
                begin = left
                end = self.count - 1
                while begin <= end {
                    let mid = begin + (end - begin + 1) / 2
                    let result = comparator(self[mid], mid)
                    if result == .orderedSame || result == .orderedAscending {
                        leftIndex = mid
                        begin = mid + 1
                    } else {
                        end = mid - 1
                    }
                }
            }

            if let left = leftIndex, let right = rightIndex, left <= right {
                range = NSRange(location: left, length: right - left + 1)
            }

            return range
        }
}
