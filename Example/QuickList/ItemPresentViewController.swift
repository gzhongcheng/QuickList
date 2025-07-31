//
//  ItemPresentViewController.swift
//  QuickList_Example
//
//  Created by Guo ZhongCheng on 2025/4/4.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import QuickList

class ItemPresentViewController<Item: TypedCollectionValueItemType>: UIViewController, TypedItemControllerType {
    
    var item: QuickList.Item! {
        didSet {
            guard let item = self.item as? (any TypedCollectionValueItemType) else { return }
            valueLabel.text = item.sendValue as? String
        }
    }
    
    var onDismissCallback: ((UIViewController) -> Void)?
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("返回", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(valueLabel)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(backButton.snp.top).offset(-10)
        }
    }
    
    @objc func backAction() {
        onDismissCallback?(self)
    }
}
