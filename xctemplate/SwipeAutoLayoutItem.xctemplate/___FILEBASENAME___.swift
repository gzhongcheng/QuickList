//___FILEHEADER___

import UIKit
import QuickList

// MARK: - ___FILEBASENAMEASIDENTIFIER___Cell
// ___FILEBASENAMEASIDENTIFIER___Cell
class ___FILEBASENAMEASIDENTIFIER___Cell: SwipeItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        /// 直接添加到contentView中的内容不会跟随手势滑动
        /// 需要跟随滑动的内容请添加到swipeContentView中
        /// swipeContentView.addSubview(<#T##view: UIView##UIView#>)
    }
}

// MARK: - ___FILEBASENAMEASIDENTIFIER___
// ___FILEBASENAMEASIDENTIFIER___
final class ___FILEBASENAMEASIDENTIFIER___: SwipeAutolayoutItemOf<___FILEBASENAMEASIDENTIFIER___Cell>, ItemType {
    
    // 更新cell的布局
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? ___FILEBASENAMEASIDENTIFIER___Cell else {
            return
        }
        updateCellData(cell)
    }
    
    /// 自动布局计算尺寸时需要用到这个方法设置完数据后再算尺寸，所以上面的updateCell方法直接转调这个方法
    override func updateCellData(_ cell: ___FILEBASENAMEASIDENTIFIER___Cell) {
        
    }
    
    override var identifier: String {
        return "___FILEBASENAMEASIDENTIFIER___"
    }
}
