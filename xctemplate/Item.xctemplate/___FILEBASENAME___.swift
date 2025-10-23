//___FILEHEADER___

import UIKit
import QuickList

// MARK: - ___FILEBASENAMEASIDENTIFIER___Cell
// ___FILEBASENAMEASIDENTIFIER___Cell
class ___FILEBASENAMEASIDENTIFIER___Cell: ItemCell {
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
    }
}

// MARK: - ___FILEBASENAMEASIDENTIFIER___
// ___FILEBASENAMEASIDENTIFIER___
final class ___FILEBASENAMEASIDENTIFIER___: ItemOf<___FILEBASENAMEASIDENTIFIER___Cell>, ItemType {
    
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

