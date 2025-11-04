//
//  TestEditDeleteItem.swift
//  QuickList_Example
//
//  Created by ZhongCheng Guo on 2025/10/29.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import QuickList

// MARK: - TestEditDeleteItemCell
// TestEditDeleteItemCell
class TestEditDeleteItemCell: EditableItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(testLabel)
        testLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }
    
    let testLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
}

// MARK: - TestEditDeleteItem
// TestEditDeleteItem
final class TestEditDeleteItem: AutolayoutEditableItemOf<TestEditDeleteItemCell>, ItemType {
    
    required init(title: String? = nil, tag: String? = nil) {
        super.init(title: title, tag: tag)
        editType = .delete
        editIcon = UIImage(named: "icon_delete")
        editIconColor = .red
        editIconSize = CGSize(width: 24, height: 24)
    }
    
    /**
     * 更新cell的布局
     * Update cell layout
     */
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? TestEditDeleteItemCell else {
            return
        }
        cell.testLabel.text = title
    }
    
    override var identifier: String {
        return "TestEditDeleteItem"
    }
}
