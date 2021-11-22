//
//  CustomConnectorView.swift
//  CustomLayoutWorkedEX
//
//  Created by 김신우 on 2021/11/22.
//

import UIKit

class CustomConnectorView: UICollectionReusableView {
    var numberOfRowsInChildren: [Int] = []
    var totalRows: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with numberOfRowsInChildren: [Int]) {
        self.numberOfRowsInChildren = numberOfRowsInChildren
        self.totalRows = numberOfRowsInChildren.reduce(0) { $0 + $1 }
        setNeedsDisplay()
    }
    
    override func prepareForReuse() {
        numberOfRowsInChildren.removeAll()
        totalRows = 0
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext(), totalRows != 0 else { return }
        let partialHeight = rect.height / CGFloat(totalRows)
        let startY = partialHeight / 2
        let endY = rect.height - partialHeight / 2
            - CGFloat((numberOfRowsInChildren.last ?? 1) - 1) * partialHeight
        
        // 수직라인 그리기
        context.setStrokeColor(UIColor.link.cgColor)
        context.move(to: CGPoint(x: rect.midX, y: startY))
        context.addLine(to: CGPoint(x: rect.midX, y: endY))
        context.strokePath()
        
        var posY = startY
        
        for i in 0..<numberOfRowsInChildren.count {
            if(i == 0) {
                context.move(to: CGPoint(x: 0, y: posY))
                context.addLine(to: CGPoint(x: rect.width, y: posY))
            } else {
                context.move(to: CGPoint(x: rect.midX, y: posY))
                context.addLine(to: CGPoint(x: rect.width, y: posY))
            }
            context.strokePath()
            
            posY += CGFloat(numberOfRowsInChildren[i]) * partialHeight
        }
        
    }
}
