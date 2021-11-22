//
//  ViewController.swift
//  CustomLayoutWorkedEX
//
//  Created by 김신우 on 2021/11/15.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var customLayout: CustomViewLayout = {
        var layout = CustomViewLayout(inset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        layout.delegate = self
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: customLayout)
        collectionView.dataSource = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(CustomConnectorView.self, forSupplementaryViewOfKind: CustomViewLayout.SupplementaryViewOfKind.connectorView, withReuseIdentifier: "Connector")
        collectionView.isScrollEnabled = true
        return collectionView
    }()
    
    var model: [ClassObject] =  {
        var classObject: ClassObject =
            ClassObject("NSObject", [
                ClassObject("NSLayoutConstraint"),
                ClassObject("NSLayoutManager"),
                ClassObject("NSParagraphStyle", [
                    ClassObject("NSMutableParagraphStyle")
                ]),
                ClassObject("UIAcceleration"),
                ClassObject("UIAccelerometer", [
                    ClassObject("임시로추가1"),
                    ClassObject("임시로추가2", [
                        ClassObject("임시로추가2의추가1"),
                        ClassObject("임시로추가2의추가2")
                    ])
                ]),
                ClassObject("UIAccessibliltyElement"),
                ClassObject("UIBarItem", [
                    ClassObject("UIBarButtonItem"),
                    ClassObject("UITabBarItem"),
                    ClassObject("UIUIUIUI")
                ]),
                ClassObject("UIActivity"),
                ClassObject("UIBezierPath")
            ])
        var classObject2 = ClassObject("두번째Root",[
            ClassObject("두번째Root-1",[
                ClassObject("두번째Root-1-1"),
                ClassObject("두번째Root-1-2")
            ]),
            ClassObject("두번째Root-2")
        ])
        return [classObject2,classObject]
    }()
    
    lazy var datasource: [[ClassObject]] = {
        var datasource = [[ClassObject]]()
        var q: [ClassObject] = model
        var level = 0
        while !q.isEmpty {
            var levelList = q
            q.removeAll()
            datasource.append(levelList)
            
            for object in levelList {
                q.append(contentsOf: object.children)
            }
        }
        return datasource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }


}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard datasource.count > section else { return 0 }
        return datasource[section].count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CustomCollectionViewCell
        else { return UICollectionViewCell() }
        
        let section = indexPath.section
        let item = indexPath.row
        if datasource.count > section && datasource[section].count > item {
            cell.label.text = datasource[section][item].value
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Connector", for: indexPath) as? CustomConnectorView
        else { return UICollectionReusableView() }
        
        let section = indexPath.section
        let row = indexPath.row
        if datasource.count > section && datasource[section].count > row {
            let item  = datasource[section][row]
            var numberOfRowsInChildren = [Int]()
            
            for child in item.children {
                numberOfRowsInChildren.append(numberOfChildren(at: child))
            }
            view.configure(with: numberOfRowsInChildren)
            
        }
        
        return view
    }
}

extension ViewController: CustomLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numRowsForClassAndChildrenAt indexPath: IndexPath) -> Int {
        guard datasource.count > indexPath.section,
              datasource[indexPath.section].count > indexPath.row
        else {return 0}
        
        return numberOfChildren(at: datasource[indexPath.section][indexPath.row])
    }
    
    private func numberOfChildren(at item: ClassObject) -> Int {
        guard !item.children.isEmpty else { return 1 }
        var totalNum = 0
        for child in item.children {
            totalNum += numberOfChildren(at: child)
        }
        
        return totalNum
    }
    
    func collectionView(_ collectionView: UICollectionView, childrenAt indexPath: IndexPath) -> [IndexPath] {
        let section = indexPath.section
        let row = indexPath.row
        
        guard datasource.count > section + 1,
              datasource[section].count > row,
              datasource[section][row].children.count != 0
        else { return [] }
        
        var result = [IndexPath]()
        let item = datasource[section][row]
        for idx in 0..<datasource[section + 1].count {
            if datasource[section+1][idx] == item.children[0] {
                (idx..<(idx + item.children.count)).forEach {
                    result.append(IndexPath(item: $0, section: section + 1))
                }
                break
            }
        }
        
        return result
    }
    
    
}
