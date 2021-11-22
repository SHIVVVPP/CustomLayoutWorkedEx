//
//  CustomViewLayout.swift
//  CustomLayoutWorkedEX
//
//  Created by 김신우 on 2021/11/15.
//

import UIKit



protocol CustomLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, childrenAt indexPath: IndexPath) -> [IndexPath]
    func collectionView(_ collectionView: UICollectionView, numRowsForClassAndChildrenAt indexPath: IndexPath) -> Int
}

class CustomViewLayout: UICollectionViewLayout {
    
    enum SupplementaryViewOfKind {
        static let connectorView: String = "ConnectorView"
    }
    
    weak var delegate: CustomLayoutDelegate?
    
    var layoutInformation: [String: [IndexPath: UICollectionViewLayoutAttributes]] = [:]
    var maxNumRows: Int = 0
    var insets: UIEdgeInsets = .zero
    
    var ITEM_WIDTH: CGFloat = 115
    var ITEM_HEIGHT: CGFloat = 50
    
    init(inset: UIEdgeInsets) {
        super.init()
        self.insets = inset
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        layoutInformation.removeAll()
        guard let collectionView = collectionView,
            let delegate = delegate
        else { return }
        
        var layoutInformation = [String: [IndexPath: UICollectionViewLayoutAttributes]]()
        var connectorInformation = [IndexPath: UICollectionViewLayoutAttributes]()
        var cellInformation = [IndexPath: CustomLayoutAttributes]()
        
        let numSections = collectionView.numberOfSections
        for section in (0..<numSections).reversed() {
            let numItems = collectionView.numberOfItems(inSection: section)
            for item in 0..<numItems {
                let indexPath = IndexPath(item: item, section: section)
                let attributes = attributesWithChildren(for: indexPath, with: cellInformation)
                let supplementaryViewAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryViewOfKind.connectorView, with: indexPath)
                connectorInformation[indexPath] = supplementaryViewAttributes
                cellInformation[indexPath] = attributes
            }
        }
        
        for section in (0..<numSections).reversed() {
            var totalRowsInSection = 0
            let numItem = collectionView.numberOfItems(inSection: section)
            for item in 0..<numItem {
                let indexPath = IndexPath(item: item, section: section)
                guard let cellAttributes = cellInformation[indexPath],
                      let connectorAttributes = connectorInformation[indexPath]
                else { continue }
                let numRowsInItem = delegate.collectionView(collectionView, numRowsForClassAndChildrenAt: indexPath)
                
                cellAttributes.frame = frameForCell(at: indexPath, with: totalRowsInSection)
                connectorAttributes.frame = frameForConnector(atCell: cellAttributes.frame, with: numRowsInItem)
                
                totalRowsInSection += numRowsInItem
                
                if section == 0 {
                    adjustFrameOfChildrenAndConnectorsForClass(at: indexPath, cellInfo: &cellInformation, connectorInfo: &connectorInformation)
                }
                
                cellInformation[indexPath] = cellAttributes
            }
            
            if section == 0 {
                self.maxNumRows = totalRowsInSection
            }
        }
        
        layoutInformation[SupplementaryViewOfKind.connectorView] = connectorInformation
        layoutInformation["Cell"] = cellInformation
        self.layoutInformation = layoutInformation
    }
    
    override var collectionViewContentSize: CGSize {
        guard let numSections = collectionView?.numberOfSections else { return .zero }
        let width = CGFloat(numSections) * (insets.left + ITEM_WIDTH + insets.right)
        let height = CGFloat(maxNumRows) * (insets.top + ITEM_HEIGHT + insets.bottom)
        return CGSize(width: width, height: height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var myAttributes = [UICollectionViewLayoutAttributes]()
        
        for (_, attributesInfo) in self.layoutInformation {
            for (_ , attributes) in attributesInfo {
                if rect.intersects(attributes.frame) {
                    myAttributes.append(attributes)
                }
            }
        }
        
        return myAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutInformation["Cell"]?[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutInformation[elementKind]?[indexPath]
    }
   
}

// MARK :-  Private Functions
extension CustomViewLayout {
    private func attributesWithChildren(for indexPath: IndexPath, with information: [IndexPath: CustomLayoutAttributes]) -> CustomLayoutAttributes {
        let attributes = CustomLayoutAttributes(forCellWith: indexPath)
        guard let delegate = self.delegate,
                let collectionView = self.collectionView
        else { return attributes }
        let children = delegate.collectionView(collectionView, childrenAt: indexPath)
        
        for child in children {
            guard let childAttributes = information[child] else { continue }
            attributes.children.append(childAttributes)
        }
        
        return attributes
    }
    
    private func adjustFrameOfChildrenAndConnectorsForClass(at indexPath: IndexPath, cellInfo: inout [IndexPath: CustomLayoutAttributes], connectorInfo: inout [IndexPath:UICollectionViewLayoutAttributes]) {
        guard let attributes = cellInfo[indexPath],
              let collectionView = collectionView,
              let delegate = delegate
        else { return }
        
        var totalRows = 0
        for child in attributes.children {
            child.frame.origin.y = attributes.frame.origin.y + CGFloat(totalRows) * (insets.top + insets.bottom + ITEM_HEIGHT)
            
            if let connectorAttributes = connectorInfo[child.indexPath] {
                connectorAttributes.frame.origin.y = child.frame.origin.y - insets.top
            }
            
            totalRows += delegate.collectionView(collectionView, numRowsForClassAndChildrenAt: child.indexPath)
            
            adjustFrameOfChildrenAndConnectorsForClass(at: child.indexPath, cellInfo: &cellInfo, connectorInfo: &connectorInfo)
        }
    }
    
    private func frameForCell(at indexPath: IndexPath, with totalRows: Int) -> CGRect {
        
        let x = insets.left + CGFloat(indexPath.section) * (insets.left + insets.right + ITEM_WIDTH)
        let y = insets.top + CGFloat(totalRows) * (insets.top + insets.bottom + ITEM_HEIGHT)
        
        let frame = CGRect(x: x, y: y, width: ITEM_WIDTH, height: ITEM_HEIGHT)
        
        return frame
    }
    
    private func frameForConnector(atCell rect: CGRect, with numberOfRows: Int) -> CGRect {
        let x = rect.origin.x + rect.width
        let y = rect.origin.y - insets.top
        let width = insets.left + insets.right
        let height = (insets.top + insets.bottom + ITEM_HEIGHT) * CGFloat(numberOfRows)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
