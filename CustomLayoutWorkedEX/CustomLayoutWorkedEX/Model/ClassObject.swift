//
//  ClassObject.swift
//  CustomLayoutWorkedEX
//
//  Created by 김신우 on 2021/11/15.
//

import Foundation

class ClassObject: Equatable {
    
    var children: [ClassObject]
    var value: String
    
    init(_ value: String, _ children: [ClassObject] = []) {
        self.value = value
        self.children = children
    }
    
    static func == (lhs: ClassObject, rhs: ClassObject) -> Bool {
        if lhs.value == rhs.value {
            return lhs.children.elementsEqual(rhs.children)
        }
        return false
    }
    
}
