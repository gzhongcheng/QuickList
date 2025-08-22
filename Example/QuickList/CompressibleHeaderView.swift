//
//  CompressibleHeaderView.swift
//  QuickList_Example
//
//  Created by ZhongCheng Guo on 2025/8/22.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import QuickList

class CompressibleHeaderView: FormCompressibleHeaderFooterView {
    
    override func setupUI() {
        super.setupUI()
        self.backgroundColor = .systemRed
        
        let testLabel = UILabel()
        testLabel.text = "很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度很长很长的文案，测试是否能自动高度，哈哈哈哈很长很长的文案，测试是否能自动高度"
        testLabel.numberOfLines = 0
        self.addSubview(testLabel)
        testLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
}

