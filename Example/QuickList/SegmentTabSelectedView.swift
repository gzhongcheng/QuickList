//
//  SegmentTabSelectedView.swift
//  QuickList_Example
//
//  Created by ZhongCheng Guo on 2025/8/26.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class SegmentTabSelectedView: UIView {
    // MARK: - Public
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        addSubview(lineView)
        
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    // MARK: Private
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
}
