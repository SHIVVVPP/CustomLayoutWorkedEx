//
//  CustomLayoutAttributes.swift
//  CustomLayoutWorkedEX
//
//  Created by 김신우 on 2021/11/15.
//

import UIKit

class CustomLayoutAttributes: UICollectionViewLayoutAttributes {
    var children: [CustomLayoutAttributes] = []
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? CustomLayoutAttributes else { return false }
        
        return children.elementsEqual(object.children)
    }
}
