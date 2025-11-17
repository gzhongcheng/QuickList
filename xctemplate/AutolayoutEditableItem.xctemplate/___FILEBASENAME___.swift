//___FILEHEADER___

import UIKit
import QuickList

// MARK: - ___FILEBASENAMEASIDENTIFIER___Cell
// ___FILEBASENAMEASIDENTIFIER___Cell
class ___FILEBASENAMEASIDENTIFIER___Cell: EditableItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        /**
         * 直接添加到contentView中的内容不会跟随编辑状态改变尺寸
         * 需要跟随编辑状态改变尺寸的内容请添加到editContentView中
         * Content added to contentView will not follow the edit state
         * Content that needs to follow the edit state should be added to editContentView
         *
         * Example:   
         * editContainer.addSubview(testLabel)
         * testLabel.snp.makeConstraints { make in
         *     make.edges.equalToSuperview().inset(15)
         * }
         */
    }
}

// MARK: - ___FILEBASENAMEASIDENTIFIER___
// ___FILEBASENAMEASIDENTIFIER___
final class ___FILEBASENAMEASIDENTIFIER___: AutolayoutEditableItemOf<___FILEBASENAMEASIDENTIFIER___Cell>, ItemType {
    
    /**
     * 更新cell
     * Update cell
     */
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? ___FILEBASENAMEASIDENTIFIER___Cell else {
            return
        }
        updateCellData(cell)
    }
    
    /**
     * 自动布局计算尺寸时需要用到这个方法设置完数据后再算尺寸，所以上面的updateCell方法直接转调这个方法
     * When auto layout size calculation is needed, this method is used to set data first then calculate size, so the above updateCell method directly calls this method
     */
    override func updateCellData(_ cell: ___FILEBASENAMEASIDENTIFIER___Cell) {
        
    }
    
    override var identifier: String {
        return "___FILEBASENAMEASIDENTIFIER___"
    }
}
