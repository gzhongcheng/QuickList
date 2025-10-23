//___FILEHEADER___

import UIKit
import QuickList

// MARK: - ___FILEBASENAMEASIDENTIFIER___Cell
// ___FILEBASENAMEASIDENTIFIER___Cell
class ___FILEBASENAMEASIDENTIFIER___Cell: SwipeItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        
        /**
         * 直接添加到contentView中的内容不会跟随手势滑动
         * 需要跟随滑动的内容请添加到swipeContentView中
         * Content added to contentView will not follow the swipe gesture
         * Content that needs to follow the swipe gesture should be added to swipeContentView
         *
         * Example:   
         * swipeContentView.addSubview(testLabel)
         * testLabel.snp.makeConstraints { make in
         *     make.edges.equalToSuperview().inset(15)
         * }
         */
    }
}

// MARK: - ___FILEBASENAMEASIDENTIFIER___
// ___FILEBASENAMEASIDENTIFIER___
final class ___FILEBASENAMEASIDENTIFIER___: SwipeItemOf<___FILEBASENAMEASIDENTIFIER___Cell>, ItemType {
    
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
