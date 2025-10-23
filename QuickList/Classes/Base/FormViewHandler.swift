//
//  FormViewHandler.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import UIKit

// MARK: - FormViewHandlerDelegate
@objc public protocol FormViewHandlerDelegate: UIScrollViewDelegate {
    
}

// MARK: - FormViewHandler - Class
public class FormViewHandler: NSObject {
//    deinit {
//        #if DEBUG
//        print("—————— 验证是否正确释放，如果返回时有输出这行，表示已经正确释放，没有循环引用 ——————")
//        #endif
//    }
    
    public var form: Form = Form() {
        didSet {
            form.delegate = self
        }
    }
    
    public weak var formView: QuickListView?
    
    public private(set) var layout: QuickListCollectionLayout = QuickListCollectionLayout()
    
    public weak var delegate: FormViewHandlerDelegate?
    
    /**
     * 用于存储已注册的header对应的identifier
     * Store registered header identifiers
     */
    var registedHeaderIdentifier = [String]()
    /**
     * 用于存储已注册的footer对应的identifier
     * Store registered footer identifiers
     */
    var registedFooterIdentifier = [String]()
    /**
     * 用于存储已注册的decoration对应的identifier
     * Store registered decoration identifiers
     */
    var registedDecorationIdentifier = [String]()
    /**
     * 用于存储已注册的Cell对应的identifier
     * Store registered cell identifiers
     */
    var registedCellIdentifier = [String]()
    /**
     * 当前已展开左滑按钮的cell
     * Currently opened swipe button cell
     */
    public var currentOpenedSwipeCell: SwipeItemCell?
    
    /**
     * 滚动方向,默认为竖直方向滚动
     * Scroll direction, default is vertical scrolling
     */
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            layout.scrollDirection = scrollDirection
            reloadCollection()
        }
    }
    
    /**
     * 是否正在滚动
     * Whether is currently scrolling
     */
    public var isScrolling: Bool = false
    
    public override init() {
        super.init()
        form.delegate = self
        layout.form = form
    }
    
    public convenience init(_ view: QuickListView, _ delegate: FormViewHandlerDelegate? = nil) {
        self.init()
        view.collectionViewLayout = self.layout
        view.delegate = self
        view.dataSource = self
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        self.formView = view
        self.delegate = delegate
    }
    
    // 刷新数据 / Refresh data
    public func reloadCollection() {
        UIView.performWithoutAnimation {
            formView?.reloadData()
        }
        self.layout.reloadAll()
    }
    /**
     * 仅刷新Layout
     * Only refresh layout
     */
    public func updateLayout() {
        self.layout.reloadAll()
    }
    
    /**
     * 更新背景控件
     * Update background control
     */
    public func updateBackgroundDecoration(contentSize: CGSize) {
        formView?.addBackgroundViewIfNeeded(form.backgroundDecoration)
        form.backgroundDecoration?.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
    }
    
    /**
     * 更新选中状态
     * Update selected state
     */
    public func updateSelectedItemDecorationIfNeeded() {
        var indexPath: IndexPath?
        var isItemHidden = false
        for section in form.sections {
            for item in section.items {
                if item.isSelected {
                    indexPath = item.indexPath
                    isItemHidden = item.isHidden
                    break
                }
            }
            if indexPath != nil {
                break
            }
        }
        
        /**
         * 设置单选状态装饰view
         * Set single selection state decoration view
         */
        if
            let selectedItemDecoration = form.selectedItemDecoration,
            let formView = formView,
            let indexPath = indexPath,
            let layoutAttributes = self.layout.layoutAttributesForItem(at: indexPath)
        {
            formView.addDecorationViewIfNeeded(selectedItemDecoration)
            if selectedItemDecoration.bounds.width == 0 {
                selectedItemDecoration.frame = layoutAttributes.frame
                selectedItemDecoration.alpha = 0
                formView.layoutIfNeeded()
            }
            let targetZPosition = form.selectedItemDecorationPosition == .below ? CGFloat(layoutAttributes.zIndex) - 1 : CGFloat(layoutAttributes.zIndex) + 1
            if selectedItemDecoration.layer.zPosition != targetZPosition {
                UIView.animate(withDuration: form.selectedItemDecorationMoveDuration) {
                    selectedItemDecoration.alpha = 0
                    formView.layoutIfNeeded()
                } completion: { _ in
                    selectedItemDecoration.layer.zPosition = targetZPosition
                    selectedItemDecoration.frame = layoutAttributes.frame
                    formView.layoutIfNeeded()
                    UIView.animate(withDuration: self.form.selectedItemDecorationMoveDuration) {
                        selectedItemDecoration.alpha = isItemHidden ? 0 : 1
                        formView.layoutIfNeeded()
                    }
                }
            } else {
                UIView.animate(withDuration: form.selectedItemDecorationMoveDuration) {
                    selectedItemDecoration.alpha = isItemHidden ? 0 : 1
                    selectedItemDecoration.frame = layoutAttributes.frame
                    selectedItemDecoration.layer.zPosition = targetZPosition
                    formView.layoutIfNeeded()
                }
            }
        } else {
            form.selectedItemDecoration?.alpha = 0
        }
    }
    
    /**
     * 更新选中状态到指定位置
     * Update selected state to specified position
     */
    public func updateSelectedItemDecorationTo(position: CGFloat) {
        guard
            let selectedItemDecoration = form.selectedItemDecoration,
            let formView = formView,
            form.count == 1,
            let section = form.sections.first
        else {
            assertionFailure("仅支持单Section的Form使用此方法")
            return
        }
        formView.addDecorationViewIfNeeded(selectedItemDecoration)
        
        let position = max(0, min(CGFloat(section.count - 1), position))
        let floorIndex: Int = Int(floor(position))
        let ceilIndex: Int = Int(ceil(position))
        
        var alpha: CGFloat = 1
        if floorIndex == ceilIndex {
            for (index, item) in section.items.enumerated() {
                item.isSelected = index == floorIndex
            }
            if
                let layoutAttributes = self.layout.layoutAttributesForItem(at: IndexPath(item: floorIndex, section: 0))
            {
                let targetZPosition = form.selectedItemDecorationPosition == .below ? CGFloat(layoutAttributes.zIndex) - 1 : CGFloat(layoutAttributes.zIndex) + 1
                selectedItemDecoration.layer.zPosition = targetZPosition
                selectedItemDecoration.frame = layoutAttributes.frame
            }
        } else {
            let floorItem = section.items[floorIndex]
            let ceilItem = section.items[ceilIndex]
            if floorItem.isHidden && ceilItem.isHidden {
                alpha = 0
            } else if floorItem.isHidden {
                alpha = position - CGFloat(floorIndex)
            } else if ceilItem.isHidden {
                alpha = CGFloat(ceilIndex) - position
            }
            if
                let floorLayoutAttributes = self.layout.layoutAttributesForItem(at: IndexPath(item: floorIndex, section: 0)),
                let ceilLayoutAttributes = self.layout.layoutAttributesForItem(at: IndexPath(item: ceilIndex, section: 0))
            {
                let targetZIndex = min(floorLayoutAttributes.zIndex, ceilLayoutAttributes.zIndex)
                let targetZPosition = form.selectedItemDecorationPosition == .below ? CGFloat(targetZIndex) - 1 : CGFloat(targetZIndex) + 1
                selectedItemDecoration.layer.zPosition = targetZPosition
                let centerX = floorLayoutAttributes.center.x + (ceilLayoutAttributes.center.x - floorLayoutAttributes.center.x) * (position - CGFloat(floorIndex))
                let centerY = floorLayoutAttributes.center.y + (ceilLayoutAttributes.center.y - floorLayoutAttributes.center.y) * (position - CGFloat(floorIndex))
                let width = floorLayoutAttributes.size.width + (ceilLayoutAttributes.size.width - floorLayoutAttributes.size.width) * (position - CGFloat(floorIndex))
                let height = floorLayoutAttributes.size.height + (ceilLayoutAttributes.size.height - floorLayoutAttributes.size.height) * (position - CGFloat(floorIndex))
                selectedItemDecoration.frame = CGRect(x: centerX - width * 0.5, y: centerY - height * 0.5, width: width, height: height)
            }
        }
        
        form.selectedItemDecoration?.alpha = alpha
    }
    
    
    /**
     * 滚动显示Item
     * Scroll to show Item
     */
    func makeItemVisible(_ item: Item, animation: Bool = true) {
        guard
            let collectionView = formView
        else { return }
        collectionView.scrollToItem(item, at: [.centeredHorizontally, .centeredVertically], animation: animation)
    }
//    
//    // 添加长按事件
//    func addLongTapIfNeeded() {
////        addedLongTap = false
////        for section in form.sections {
////            if section is MultivalusedSection {
////                addLongTapGesture()
////                return
////            }
////        }
////        if !addedLongTap {
////            removeLongTap()
////        }
//    }
//    /// 是否已添加
//    var addedLongTap = false
//    /// 添加长按事件
//    func addLongTapGesture() {
//        removeLongTap()
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
//        formView?.addGestureRecognizer(longPress)
//        addedLongTap = true
//    }
//    /// 移除原有长按事件
//    func removeLongTap() {
//        if let gestures = formView?.gestureRecognizers {
//            for gesture in gestures {
//                if gesture is UILongPressGestureRecognizer {
//                    formView?.removeGestureRecognizer(gesture)
//                }
//            }
//        }
//    }
//    
//    // 长按响应方法(仅在CollectionMultivalusedSection中才支持)
//    @objc func handleLongGesture(_ longPress: UILongPressGestureRecognizer) {
//        guard let view = formView as? FormViewLongTapProtorol else {
//            return
//        }
//        switch longPress.state {
//        case .began:
//            /// 开始长按手势，判断section是否支持移动
//            guard
//                let indexPath = view.indexPathForItem(at: longPress.location(in: view)),
//                let section = form[indexPath.section] as? MultivalusedSection,
//                section.moveAble,
//                section.items.count > 1
//            else {
//                return
//            }
//            _ = view.beginInteractiveMovementForItem(at: indexPath)
//        case .changed:
//            view.updateInteractiveMovementTargetPosition(longPress.location(in: view))
//            /// 判断是否在可移动的section内部
//            guard
//                let indexPath = view.indexPathForItem(at: longPress.location(in: view))
//            else {
//                return
//            }
//            guard form[indexPath.section] is MultivalusedSection else {
//                view.cancelInteractiveMovement()
//                return
//            }
//        case .ended:
//            view.endInteractiveMovement()
//        case .possible:
//            view.cancelInteractiveMovement()
//        case .cancelled:
//            view.cancelInteractiveMovement()
//        case .failed:
//            view.cancelInteractiveMovement()
//        @unknown default:
//            view.cancelInteractiveMovement()
//        }
//    }
//    
//    /// cell成为第一响应者
//    public final func beginEditing(of cell: ItemCell) {
////        cell.item?.isHighlighted = true
////        cell.item?.updateCell()
////        cell.item?.callbackOnCellHighlightChanged?()
////        guard (form.inlineRowHideOptions ?? Form.defaultInlineRowHideOptions).contains(.FirstResponderChanges) else { return }
////        let row = cell.row
////        let inlineItem = row?._inlineItem
////        for r in (form.allRows as! [CollectionItem]).filter({ $0 !== row && $0 !== inlineItem && $0._inlineItem != nil }) {
////            if let inline = r as?  BaseInlineRowType {
////                inline.collapseInlineRow()
////            }
////        }
//    }
//    
//    /// cell失去第一响应者
//    public final func endEditing(of cell: ItemCell) {
////        cell.item?.isHighlighted = false
////        cell.item?.callbackOnCellHighlightChanged?()
////        cell.item?.callbackOnCellEndEditing?()
////        cell.item?.updateCell()
//    }
    
    /**
     * 在主线程执行代码块
     * Execute code block on main thread
     * - Parameters:
     *   - isAsync: 是否异步执行，默认为`true` / Whether to execute asynchronously, default `true`
     *   - execute: 在主线程执行的代码块 / Code block to execute on main thread
     */
    private func mainThread(isAsync: Bool = true, main execute: @escaping () -> Void) {
        if Thread.isMainThread {
            execute()
        } else if isAsync {
            DispatchQueue.main.async(execute: execute)
        } else {
            DispatchQueue.main.sync(execute: execute)
        }
    }
}

// MARK: - FormDelegate
extension FormViewHandler: FormDelegate {
    
    public func sectionsHaveBeenAdded(_ sections: [Section], at: IndexSet) {
        mainThread {
            self.formView?.insertSections(at)
            self.updateLayout(withAnimation: true, afterSection: at.first ?? 0)
            self.updateSelectedItemDecorationIfNeeded()
        }
    }
    
    public func sectionsHaveBeenRemoved(_ sections: [Section], at: IndexSet) {
        mainThread {
            self.formView?.deleteSections(at)
            self.updateLayout(withAnimation: true, afterSection: max(0, (at.first ?? 0) - 1))
        }
    }
    
    public func sectionsHaveBeenReplaced(oldSections: [Section], newSections: [Section], at indexes: IndexSet) {
        mainThread {
            self.formView?.reloadSections(indexes)
            self.updateLayout(withAnimation: true, afterSection: indexes.first ?? 0)
        }
    }
    
    public func itemsHaveBeenAdded(_ items: [Item], to section: Section, at: [IndexPath]) {
        mainThread {
            self.formView?.insertItems(at: at)
            self.updateLayout(withAnimation: true, afterSection: section.index ?? 0)
        }
    }
    
    public func itemsHaveBeenRemoved(_ items: [Item], to section: Section, at: [IndexPath]) {
        mainThread {
            self.formView?.deleteItems(at: at)
            self.updateLayout(withAnimation: true, afterSection: section.index ?? 0)
        }
    }
    
    public func itemsHaveBeenReplaced(oldItems: [Item], newItems: [Item], to section: Section, at indexes: [IndexPath]) {
        mainThread {
            self.formView?.reloadItems(at: indexes)
            self.updateLayout(withAnimation: true, afterSection: section.index ?? 0)
        }
    }
    
    public func updateLayout(withAnimation: Bool = false, afterSection: Int = 0) {
        if withAnimation {
            formView?.performBatchUpdates({ [weak self] in
                self?.layout.reloadSectionsAfter(index: afterSection, needOldSectionAttributes: true)
            }, completion: { [weak self] _ in
                self?.layout.oldSectionAttributes.removeAll()
            })
        } else {
            self.layout.reloadSectionsAfter(index: afterSection)
        }
    }
    
    fileprivate func representableItem(from item: Item, at indexPath: IndexPath) -> (any ItemViewRepresentable)? {
        var representableItem: (any ItemViewRepresentable)?
        if let item = item as? (any ItemViewRepresentable) {
            representableItem = item
        } else if let binder = form[indexPath.section].itemCellBinders.first(where: { $0.mateItem(item) }) {
            representableItem = binder
        } else if let binder = form.itemCellBinders.first(where: { $0.mateItem(item) }) {
            representableItem = binder
        }
        return representableItem
    }
    
    public func getViewSize() -> CGSize {
        guard let formView = self.formView else {
            return .zero
        }
        return CGSize(width: formView.bounds.width - formView.adjustedContentInset.left - formView.adjustedContentInset.right, height: formView.bounds.height - formView.adjustedContentInset.top - formView.adjustedContentInset.bottom)
    }
    
    public func getContentSize() -> CGSize {
        self.formView?.contentSize ?? .zero
    }
}

// MARK: - UICollectionViewDataSource
extension FormViewHandler: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return form.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return form[section].count
    }
    
    func emptyCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !registedCellIdentifier.contains("UICollectionViewCell") {
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let item = form[indexPath],
            let representableItem = representableItem(from: item, at: indexPath),
            let collectionView = collectionView as? QuickListView
        else {
            return emptyCell(collectionView, cellForItemAt: indexPath)
        }
        if !registedCellIdentifier.contains(representableItem.identifier) {
            representableItem.regist(to: collectionView)
            registedCellIdentifier.append(representableItem.identifier)
        }
        guard let cell = representableItem.viewForItem(item, in: collectionView, for: indexPath) as? ItemCell else {
            return emptyCell(collectionView, cellForItemAt: indexPath)
        }
        if cell.item?.cell == cell {
            cell.item?.cell = nil
        }
        cell.item = item
        item.cell = cell
        if !cell.isSetup {
            cell.setup()
        }
        if let swipedItem = item as? SwipeItemType {
            swipedItem.configureSwipe()
        }
        item.updateCell()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            let collectionView = collectionView as? QuickListView,
            let sectionIndex = indexPath.safeSection()
        else { return UICollectionReusableView() }
        if kind == QuickListReusableType.formHeader.elementKind {
            guard let header = form.header else {
                return UICollectionReusableView()
            }
            let identifier = header.identifier
            if !registedHeaderIdentifier.contains(identifier) {
                header.regist(to: collectionView, for: .formHeader)
                registedHeaderIdentifier.append(identifier)
            }
            guard let headerView = header.view(for: .formHeader, in: collectionView) else { return UICollectionReusableView() }
            headerView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 503)
            return headerView
        }
        if kind == QuickListReusableType.formFooter.elementKind {
            guard let footer = form.footer else {
                return UICollectionReusableView()
            }
            let identifier = footer.identifier
            if !registedFooterIdentifier.contains(identifier) {
                footer.regist(to: collectionView, for: .formFooter)
                registedFooterIdentifier.append(identifier)
            }
            guard let footerView = footer.view(for: .formFooter, in: collectionView) else { return UICollectionReusableView() }
            footerView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 500)
            return footerView
        }
        let section: Section = form[sectionIndex]
        if kind == QuickListReusableType.sectionHeader.elementKind {
            guard
                let header = section.header
            else {
                return UICollectionReusableView()
            }
            let identifier = header.identifier
            if !registedHeaderIdentifier.contains(identifier) {
                header.regist(to: collectionView, for: .sectionHeader)
                registedHeaderIdentifier.append(identifier)
            }
            guard let headerView = header.viewForSection(section, in: collectionView, type: .sectionHeader, for: indexPath) else { return UICollectionReusableView() }
            headerView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 502)
            return headerView
        }
        if kind == QuickListReusableType.sectionFooter.elementKind {
            guard
                let footer = section.footer
            else {
                return UICollectionReusableView()
            }
            let identifier = footer.identifier
            if !registedFooterIdentifier.contains(identifier) {
                footer.regist(to: collectionView, for: .sectionFooter)
                registedFooterIdentifier.append(identifier)
            }
            guard let footerView = footer.viewForSection(section, in: collectionView, type: .sectionFooter, for: indexPath) else { return UICollectionReusableView() }
            footerView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 501)
            return footerView
        }
        if kind == QuickListReusableType.decoration.elementKind {
            guard
                let decoration = section.decoration
            else {
                return UICollectionReusableView()
            }
            let identifier = decoration.identifier
            if !registedDecorationIdentifier.contains(identifier) {
                decoration.regist(to: collectionView, for: .decoration)
                registedDecorationIdentifier.append(identifier)
            }
            guard let decorationView = decoration.viewForSection(section, in: collectionView, type: .decoration, for: indexPath) else { return UICollectionReusableView() }
            decorationView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 498)
            return decorationView
        }
        if kind == QuickListReusableType.suspensionDecoration.elementKind {
            guard
                let decoration = section.suspensionDecoration
            else {
                return UICollectionReusableView()
            }
            let identifier = decoration.identifier
            if !registedDecorationIdentifier.contains(identifier) {
                decoration.regist(to: collectionView, for: .suspensionDecoration)
                registedDecorationIdentifier.append(identifier)
            }
            guard let decorationView = decoration.viewForSection(section, in: collectionView, type: .suspensionDecoration, for: indexPath) else { return UICollectionReusableView() }
            decorationView.layer.zPosition = CGFloat(layout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)?.zIndex ?? 497)
            return decorationView
        }
        return UICollectionReusableView()
    }
    
    /**
     * 设置是否可以移动
     * Set whether can move
     */
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard
            let item = form[indexPath],
            item.canMove
        else {
            return false
        }
        guard
            let sectionIndex = indexPath.safeSection(),
            let section = form[sectionIndex] as? MultivalusedSection,
            section.moveAble && section.count > 1
        else {
            return item.canMove
        }
        return true
    }
    
    /**
     * 移动后交换数据
     * Exchange data after moving
     */
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            let formSectionIndex = sourceIndexPath.safeSection(),
            let toSectionIndex = destinationIndexPath.safeSection(),
            let fromSection = form[formSectionIndex] as? MultivalusedSection,
            let toSection = form[toSectionIndex] as? MultivalusedSection,
            let fromItem = form[sourceIndexPath]
        else {
            return
        }
        if sourceIndexPath != destinationIndexPath {
            fromSection.remove(at: sourceIndexPath.row)
            toSection.insert(fromItem, at: destinationIndexPath.row)
            
            collectionView.reloadSections(IndexSet(integersIn: min(formSectionIndex, toSectionIndex) ... max(formSectionIndex, toSectionIndex)))
            /**
             * 动画结束后刷新布局（避免使用瀑布流时发生布局错乱）
             * Refresh layout after animation (avoid layout disorder when using waterfall flow)
             */
            let deadline = DispatchTime.now() + 0.25
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.layout.reloadAll()
            }
            
            fromSection.moveFinishClosure?(fromItem, sourceIndexPath, destinationIndexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate (including UIScrollViewDelegate)
extension FormViewHandler: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard
            let item = form[indexPath]
        else { return false }
        return !item.isDisabled
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard
            collectionView == self.formView,
            let cell = collectionView.cellForItem(at: indexPath) as? ItemCell,
            let item = form[indexPath]
        else { return }
        
        if !cell.canBecomeFirstResponder || !cell.becomeFirstResponder() {
            self.formView?.endEditing(true)
        }
        item.highlightCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard
            collectionView == self.formView,
            let cell = collectionView.cellForItem(at: indexPath) as? ItemCell,
            let item = form[indexPath]
        else { return }
        
        if !cell.canBecomeFocused || !cell.becomeFirstResponder() {
            self.formView?.endEditing(true)
        }
        item.unHighlightCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard
            let item = form[indexPath]
        else { return false }
        return !item.isDisabled
    }
    
    public func selectItem(item: Item) {
        /**
         * 设置选中状态
         * Set selected state
         */
        if item.isSelectable {
            var needUpdateLayout: Bool = false
            for section in form.sections {
                for i in section.items {
                    var targetSelect: Bool = i.isSelected
                    if form.singleSelection || form.selectedItemDecoration != nil {
                        targetSelect = item == i
                    } else if item == i {
                        targetSelect = !i.isSelected
                    }
                    if i.isSelected != targetSelect {
                        i.isSelected = targetSelect
                        if i.onSelectedChanged() {
                            i.needReSize = true
                            needUpdateLayout = true
                        }
                    }
                }
            }
            if needUpdateLayout {
                layout.reloadAll()
            }
        }
        
        item.didSelect()
        item.unHighlightCell()
        
        /**
         * 设置单选状态装饰view
         * Set single selection state decoration view
         */
        if item.isSelectable {
            if item.scrollToSelected {
                formView?.scrollToItem(item, at: [.centeredHorizontally, .centeredVertically], animation: true)
                DispatchQueue.main.async {
                    self.updateSelectedItemDecorationIfNeeded()
                }
            } else {
                self.updateSelectedItemDecorationIfNeeded()
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentOpenedSwipeCell?.closeSwipeActions()
        guard
            collectionView == self.formView,
            let cell = collectionView.cellForItem(at: indexPath) as? ItemCell,
            let item = form[indexPath]
        else { return }
        
        if !cell.canBecomeFirstResponder || !cell.becomeFirstResponder() {
            self.formView?.endEditing(true)
        }
        
        selectItem(item: item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ItemCell else {
            return
        }
        cell.willDisplay()
        cell.item?.willDisplay()
        if
            let oldFrame = self.layout.initialLayoutAttributesForItem(at: indexPath)?.frame,
            let finalAttr = self.layout.layoutAttributesForItem(at: indexPath),
            oldFrame != finalAttr.frame
        {
            let finalFrame = finalAttr.frame
            let tx = oldFrame.origin.x - finalFrame.origin.x
            let ty = oldFrame.origin.y - finalFrame.origin.y
            cell.transform = CGAffineTransform(translationX: tx, y: ty)
            cell.superview?.layoutIfNeeded()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    cell.transform = .identity
                    finalAttr.alpha = cell.item?.isHidden == true ? 0 : 1
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if
            let oldAttr = self.layout.initialLayoutAttributesForElement(ofKind: elementKind, at: indexPath),
            let finalAttr = self.layout.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        {
            let tx = oldAttr.frame.origin.x - finalAttr.frame.origin.x
            let ty = oldAttr.frame.origin.y - finalAttr.frame.origin.y
            view.transform = CGAffineTransform(translationX: tx, y: ty)
            view.alpha = 0
            view.superview?.layoutIfNeeded()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    view.transform = .identity
                    view.alpha = 1
                }
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ItemCell else {
            return
        }
        cell.didEndDisplay()
        cell.item?.didEndDisplay()
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentOpenedSwipeCell?.closeSwipeActions()
        notifyBeginScroll()
        delegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidZoom?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        notifyBeginScroll()
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyEndScroll()
        }
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyEndScroll()
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyEndScroll()
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZooming?(in: scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        notifyBeginScroll()
        delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        notifyEndScroll()
        delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }

    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
    
    /**
     * 通知滚动开始
     * Notify scroll begin
     */
    func notifyBeginScroll() {
        if !isScrolling {
            isScrolling = true
            for cell in formView?.visibleCells ?? [] {
                if let observerCell = cell as? ScrollObserverCellType {
                    observerCell.willBeginScrolling()
                }
            }
        }
    }
    
    /**
     * 通知滚动结束
     * Notify scroll end
     */
    func notifyEndScroll() {
        if isScrolling {
            isScrolling = false
            for cell in formView?.visibleCells ?? [] {
                if let observerCell = cell as? ScrollObserverCellType {
                    observerCell.didEndScrolling()
                }
            }
        }
    }
}
