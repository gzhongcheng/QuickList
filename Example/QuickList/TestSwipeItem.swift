//
//  TestSwipeItem.swift
//  QuickList_Example
//
//  Created by ZhongCheng Guo on 2025/9/5.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import QuickList

// MARK: - TestSwipeItemCell
// TestSwipeItemCell
class TestSwipeItemCell: SwipeItemCell {
    
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

// MARK: - TestSwipeItem
// TestSwipeItem
final class TestSwipeItem: SwipeAutolayoutItemOf<TestSwipeItemCell>, ItemType {
    
    /**
     * 更新cell的布局
     * Update cell layout
     */
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? TestSwipeItemCell else {
            return
        }
        cell.testLabel.text = title
    }
    
    override var identifier: String {
        return "TestSwipedItem"
    }
}
