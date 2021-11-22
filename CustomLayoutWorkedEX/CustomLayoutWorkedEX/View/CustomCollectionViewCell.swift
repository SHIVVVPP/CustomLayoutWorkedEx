//
//  CustomCollectionViewCell.swift
//  CustomLayoutWorkedEX
//
//  Created by 김신우 on 2021/11/16.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    var label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(label)
        let constraints = [
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        contentView.backgroundColor = .link
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
