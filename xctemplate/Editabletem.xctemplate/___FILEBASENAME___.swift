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
final class ___FILEBASENAMEASIDENTIFIER___: EditableItemOf<___FILEBASENAMEASIDENTIFIER___Cell>, ItemType {
    
    /**
     * 更新cell
     * Update cell
     */
    override func customUpdateCell() {
        super.customUpdateCell()
        guard let cell = cell as? ___FILEBASENAMEASIDENTIFIER___Cell else {
            return
        }
        
    }
    
    override var identifier: String {
        return "___FILEBASENAMEASIDENTIFIER___"
    }
    
    /**
     * 计算尺寸
     * Calculate size
     */
    override func sizeForItem(_ item: Item, with estimateItemSize: CGSize, in view: QuickListView, layoutType: ItemCellLayoutType) -> CGSize? {
        guard
            item == self
        else {
            return nil
        }
        switch layoutType {
        case .vertical:
            return <#CGSize#>
        case .horizontal:
            return <#CGSize#>
        case .free:
            return <#CGSize#>
        }
    }
}
