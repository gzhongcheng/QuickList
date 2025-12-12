//
//  Operators.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

// MARK: - Custom operators
/// 定义优先级组
precedencegroup FormPrecedence {
    associativity: left                      // 结合方向:left, right or none
    higherThan: LogicalConjunctionPrecedence // 优先级,比&&运算高
//    assignment: false                   // true=赋值运算符,false=非赋值运算符
}

precedencegroup  SectionPrecedence {
    associativity: left             // 结合方向:left
    higherThan: FormPrecedence      // 优先级,比Form高
}

// MARK: - Operators
// MARK: Add
/**
 * +++  返回结果为 Form
 * +++  returns result as Form
 */
infix operator +++ : FormPrecedence
/**
 * +++! 返回结果为 Form，并通知代理
 * +++! returns result as Form, and notify delegate
 */
infix operator +++! : FormPrecedence
/**
 * <<< 返回结果为 Section
 * <<< returns result as Section
 */
infix operator <<< :  SectionPrecedence
/**
 * <<< 返回结果为 Section，并通知代理
 * <<< returns result as Section, and notify delegate
 */
infix operator <<<! :  SectionPrecedence

// MARK: Replace
/**
 * >>> 替换 元素
 * >>> replaces elements
 */
infix operator >>> : FormPrecedence
/**
 * >>> 替换 元素 并通知代理
 * >>> replaces elements and notifies delegate
 */
infix operator >>>! : FormPrecedence

// MARK: Remove
/**
 * ---- 移除所有元素
 * ---- removes all elements
 */
postfix operator ---
/**
 * ---- 移除所有元素并通知代理
 * ---- removes all elements and notifies delegate
 */
postfix operator ---!

// MARK: - Function
/**
 * 添加 Section 到 Form
 * Add Section to Form
 
 * - parameter left:  form
 * - parameter right: 需要添加的 section
 * 
 * - returns: 添加后的 form
 */
@discardableResult
public func +++ (left: Form, right: Section) -> Form {
    left.append(right)
    return left
}
/**
 * 添加 Item 到 Form 的最后一个 Section
 * Add Item to the last Section of Form
 
 * - parameter left:  form
 * - parameter right: item
 */
@discardableResult
public func +++ (left: Form, right: Item) -> Form {
    if let section = left.sections.last {
        section.append(right)
    } else {
        let section = Section()
        section.append(right)
        left.append(section)
    }
    return left
}
/**
 * 用两个Section相加创建Form
 * Create Form by adding two Sections
 
 * - parameter left:  第一个 section
 * - parameter right: 第二个 section
 * 
 * - returns: 创建好的Form
 */
@discardableResult
public func +++ (left: Section, right: Section) -> Form {
    let form = Form()
    form.append(left)
    form.append(right)
    return form
}

/**
 * 用两个Section相加创建Form, 每个Section中包含一个Item
 * Create Form by adding two Sections, each Section contains one Item
 
 * - parameter left:  第一个Section中的Item
 * - parameter right: 第二个Section中的Item
 * 
 * - returns: 创建好的Form
 */
@discardableResult
public func +++ (left: Item, right: Item) -> Form {
    let section1 = Section()
    section1.append(left)
    let section2 = Section()
    section2.append(right)
    let form = Form()
    form.append(section1)
    form.append(section2)
    return form
}

/**
 * 添加Section到Section数组
 * Add Section to Section array
 * 
 * - parameter left:  Section数组
 * - parameter right: Section
 */
public func +++ (left: inout [Section], right: Section) {
    left.append(right)
}

// MARK: - +++!
/**
 * 添加 Section 到 Form, 并通知到代理
 * Add Section to Form, and notify delegate
 
 * - parameter left:  form
 * - parameter right: 需要添加的 section
 * 
 * - returns: 添加后的 form
 */
@discardableResult
public func +++! (left: Form, right: Section) -> Form {
    left.addSection(with: right, animation: ListReloadAnimation.fade)
    return left
}
/**
 * 添加 Item 到 Form 的最后一个 Section, 并通知到代理
 * Add Item to the last Section of Form, and notify delegate
 
 - parameter left:  form
 - parameter right: item
 */
@discardableResult
public func +++! (left: Form, right: Item) -> Form {
    if let section = left.sections.last {
        section.addItem(with: right, animation: ListReloadAnimation.fade)
    } else {
        let section = Section()
        section.append(right)
        left.addSection(with: section, animation: ListReloadAnimation.fade)
    }
    return left
}

// MARK: - <<<
/**
 * 添加Item到Section
 * Add Item to Section
 * 
 * - parameter left:  section
 * - parameter right: item
 * 
 * - returns: section
 */
@discardableResult
public func <<< (left: Section, right: Item) -> Section {
    left.append(right)
    return left
}

/**
 * 用两个Item创建一个Section
 * Create Section by adding two Items
 *
 * - parameter left:  第一个 item
 * - parameter right: 第二个 item
 * 
 * - returns: 创建好的 section
 */
@discardableResult
public func <<< (left: Item, right: Item) -> Section {
    let section = Section()
    section.append(left)
    section.append(right)
    return section
}

/**
 * 添加Item到Item数组
 * Add Item to Item array
 * 
 * - parameter left:  Item数组
 * - parameter right: Item
 */
public func <<< (left: inout [Item], right: Item) {
    left.append(right)
}

// MARK: - <<<!
/**
 * 添加Item到Section, 更新界面布局
 * Add Item to Section, update interface layout
 * 
 * - parameter left:  section
 * - parameter right: item
 * 
 * - returns: section
 */
@discardableResult
public func <<<! (left: Section, right: Item) -> Section {
    left.addItems(with: [right], animation: ListReloadAnimation.fade)
    return left
}

/**
 * 添加Item数组到Section, 更新界面布局
 * Add Item array to Section, update interface layout
 * 
 * - parameter left:  section
 * - parameter right: items
 * 
 * - returns: section
 */
@discardableResult
public func <<<! (left: Section, right: [Item]) -> Section {
    left.addItems(with: right, animation: ListReloadAnimation.fade)
    return left
}

// MARK: - >>>
/**
 * 替换Form的所有Section
 * Replace all Sections of Form
 *
 * - parameter left:  form
 * - parameter right: sections
 * 
 * - returns: form
*/
@discardableResult
public func >>> (left: Form, right: [Section]) -> Form {
    let oldSections = left.sections
    left.replaceSubrange(0 ..< oldSections.count, with: right)
    return left
}
/**
 * 替换Form的所有Section, 并通知到代理
 * Replace all Sections of Form, and notify delegate
 * 
 * - parameter left:  form
 * - parameter right: sections
 * 
 * - returns: form
*/
@discardableResult
public func >>>! (left: Form, right: [Section]) -> Form {
    left.replaceSections(with: right, inAnimation: ListReloadAnimation.fade, outAnimation: ListReloadAnimation.fade)
    return left
}

/**
 * 替换Section数组到指定范围
 * Replace Section array to specified range
 * 
 * - parameter left:  form
 * - parameter right: 元组，( 范围 ，要替换的Section数组 )
 * 
 * - returns: form
 */
@discardableResult
public func >>>! (left: Form, right: (Range<Int>, [Section])) -> Form {
    left.replaceSections(with: right.1, at: right.0, inAnimation: ListReloadAnimation.fade, outAnimation: ListReloadAnimation.fade)
    return left
}

/**
 * 替换Section的所有Item
 * Replace all Items of Section
 * 
 * - parameter left:  section
 * - parameter right: items
 * 
 * - returns: section
 */
@discardableResult
public func >>> (left: Section, newItems: [Item]) -> Section {
    left.removeAll()
    left.append(contentsOf: newItems)
    return left
}
/**
 * 替换Section的所有Item，并通知到代理
 * Replace all Items of Section, and notify delegate
 * 
 * - parameter left:  section
 * - parameter right: items
 * 
 * - returns: section
 */
@discardableResult
public func >>>! (left: Section, newItems: [Item]) -> Section {
    left.replaceItems(with: newItems, animation: ListReloadAnimation.fade)
    return left
}

/**
 * 替换Item数组到指定范围
 * Replace Item array to specified range
 * 
 * - parameter left:  section
 * - parameter right: tuple, ( range, items )
 * 
 * - returns: section
 */
@discardableResult
public func >>> (left: Section, right: (Range<Int>, [Item])) -> Section {
    left.replaceSubrange(right.0, with: right.1)
    return left
}
/**
 * 替换Item数组到指定范围, 并通知到代理
 * Replace Item array to specified range, and notify delegate
 * 
 * - parameter left:  section
 * - parameter right: tuple, ( range, items )
 * 
 * - returns: section
 */
@discardableResult
public func >>>! (left: Section, right: (Range<Int>, [Item])) -> Section {
    left.replaceItems(with: right.1, at: right.0, animation: ListReloadAnimation.fade)
    return left
}

/**
 * 添加 Item 的集合到 Section
 * Add Item collection to Section
 * 
 * - parameter lhs: section
 * - parameter rhs: items collection
 * 
 * - returns: section
 */
public func += <C: Collection>(lhs: inout Section, rhs: C) where C.Iterator.Element == Item {
    lhs.append(contentsOf: rhs)
}
