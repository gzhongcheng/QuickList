//
//  AutolayoutItem.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import Foundation
import UIKit
import SnapKit

/// 使用自动布局自动计算尺寸的Iteml（如果可能，建议还是手动计算尺寸）
open class AutolayoutItemOf<Cell: ItemCell>: ItemOf<Cell> {
    public override var cellSize: CGSize {
        didSet {
            if self.cellSize.width > 0, self.cellSize.height > 0 {
                /// 如果计算出来的尺寸还是0，就还需重新计算
                needReSize = false
            }
        }
    }
    
    /// 未重写updateCalculateCellData方法时，自动布局计算尺寸时需要用到这个方法设置完数据后再算尺寸
    open func updateCellData(_ cell: Cell) {
        assertionFailure("This method must be rewritten to set the content of the cell！")
    }
    
    /// 仅做为重新计算尺寸用的方法，可以少设置一些与尺寸无关的属性用于计算，减少资源占用，如果返回false，则会使用默认的updateCellData方法来设置内容并计算尺寸
    open func updateCalculateCellData(_ cell: Cell) -> Bool {
        return false
    }
    
    open override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            needReSize,
            item == self
        else {
            return self.cellSize
        }
        var tempCell: Cell?
        if tempCell == nil {
            if let fromNib = fromNib {
                tempCell = fromNib.instantiate(withOwner: nil, options: nil).first as? Cell
            } else {
                tempCell = Cell(frame: CGRect(x: 0, y: 0, width: 9999, height: 9999))
            }
        }
        guard let cell = tempCell else {
            assertionFailure("failed to create view！")
            return self.cellSize
        }
        if !cell.isSetup {
            cell.setup()
        }
        var estimateItemSize = CGSize(width: floor(estimateItemSize.width), height: floor(estimateItemSize.height))
        /// 自适应尺寸时需要先设置宽度约束，才能准确使用autolayout计算需要的高度，尤其iOS8及以下
        switch layoutType {
        case .vertical:
            cell.contentView.snp.makeConstraints { make in
                make.width.equalTo(estimateItemSize.width)
            }
        case .horizontal:
            cell.contentView.snp.makeConstraints { make in
                make.height.equalTo(estimateItemSize.height)
            }
        case .free:
            break
        }
        if updateCalculateCellData(cell) == false {
            self.updateCellData(cell)
        }
        self.cellSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        cell.contentView.snp.removeConstraints()
        return self.cellSize
    }
    
}
