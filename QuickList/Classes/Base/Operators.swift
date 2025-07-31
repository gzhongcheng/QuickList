//
//  Operators.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

// MARK: - 自定义运算符
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

// MARK: - 声明操作符
// 增加
/// +++  返回结果为 Form
infix operator +++ : FormPrecedence
/// +++! 返回结果为 Form，并通知代理
infix operator +++! : FormPrecedence
/// <<< 返回结果为 Section
infix operator <<< :  SectionPrecedence
/// <<< 返回结果为 Section，并通知代理
infix operator <<<! :  SectionPrecedence

// 替换
/// >>> 替换 元素
infix operator >>> : FormPrecedence
/// >>> 替换 元素 并通知代理
infix operator >>>! : FormPrecedence

// 移除
/// ---- 移除所有元素
postfix operator ---
/// ---- 移除所有元素并通知代理
postfix operator ---!

// MARK: - +++
/**
 添加 Section 到 Form
 
 - parameter left:  form
 - parameter right: 需要添加的 section
 
 - returns: 添加后的 form
 */
@discardableResult
public func +++ (left: Form, right: Section) -> Form {
    left.append(right)
    return left
}
/**
 添加 Item 到 Form 的最后一个 Section
 
 - parameter left:  form
 - parameter right: item
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
 用两个Section相加创建Form
 
 - parameter left:  第一个 section
 - parameter right: 第二个 section
 
 - returns: 创建好的Form
 */
@discardableResult
public func +++ (left: Section, right: Section) -> Form {
    let form = Form()
    form.append(left)
    form.append(right)
    return form
}

/**
 用两个Section相加创建Form, 每个Section中包含一个Item
 
 - parameter left:  第一个Section中的Item
 - parameter right: 第二个Section中的Item
 
 - returns: 创建好的Form
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

// MARK: - +++!
/**
 添加 Section 到 Form, 并通知到代理
 
 - parameter left:  form
 - parameter right: 需要添加的 section
 
 - returns: 添加后的 form
 */
@discardableResult
public func +++! (left: Form, right: Section) -> Form {
    left.append(right, updateUI: true)
    return left
}
/**
 添加 Item 到 Form 的最后一个 Section, 并通知到代理
 
 - parameter left:  form
 - parameter right: item
 */
@discardableResult
public func +++! (left: Form, right: Item) -> Form {
    if let section = left.sections.last {
        section.append(right, updateUI: true)
    } else {
        let section = Section()
        section.append(right)
        left.append(section, updateUI: true)
    }
    return left
}

// MARK: - <<<
/**
 添加Item到Section
 
 - parameter left:  section
 - parameter right: item
 
 - returns: section
 */
@discardableResult
public func <<< (left: Section, right: Item) -> Section {
    left.append(right)
    return left
}

/**
 两个Item创建Section
 
 - parameter left:  第一个 item
 - parameter right: 第二个 item
 
 - returns: 创建好的 section
 */
@discardableResult
public func <<< (left: Item, right: Item) -> Section {
    let section = Section()
    section.append(left)
    section.append(right)
    return section
}

// MARK: - <<<!
/**
 添加Item到Section, 并通知到代理
 使用 <<<!前，
 ***如果section已经被添加到form中***，请确认collectionView已经刷新过（section的信息已经在collectionView上，否则会闪退）
 ***如果section还没有被添加到form中***，就没关系
 
 - parameter left:  section
 - parameter right: item
 
 - returns: section
 */
@discardableResult
public func <<<! (left: Section, right: Item) -> Section {
    left.append(right, updateUI: true)
    return left
}

/**
 添加Item数组到Section, 并通知到代理
 使用 <<<!前，
 ***如果section已经被添加到form中***，请确认collectionView已经刷新过（section的信息已经在collectionView上，否则会闪退）
 ***如果section还没有被添加到form中***，就没关系
 
 - parameter left:  section
 - parameter right: item数组
 
 - returns: section
 */
@discardableResult
public func <<<! (left: Section, right: [Item]) -> Section {
    left.append(contentsOf: right, updateUI: true)
    return left
}

// MARK: - >>>
/**
 替换Form的所有Section

- parameter left:  form
- parameter right: 要替换的Section数组

- returns: form
*/
@discardableResult
public func >>> (left: Form, right: [Section]) -> Form {
    let oldSections = left.sections
    left.replaceSubrange(0 ..< oldSections.count, with: right)
    return left
}
/**
 替换Form的所有Section, 并通知到代理

- parameter left:  form
- parameter right: 要替换的Section数组

- returns: form
*/
@discardableResult
public func >>>! (left: Form, right: [Section]) -> Form {
    let oldSections = left.sections
    left.replaceSubrange(0 ..< oldSections.count, with: right, updateUI: true)
    return left
}

/**
 替换Section数组到指定范围

- parameter left:  form
- parameter right: 元组，( 范围 ，要替换的Section数组 )

- returns: form
*/
@discardableResult
public func >>> (left: Form, right: (Range<Int>, [Section])) -> Form {
    left.replaceSubrange(right.0, with: right.1)
    return left
}
/**
 替换Section数组到指定范围, 并通知到代理

- parameter left:  form
- parameter right: 元组，( 范围 ，要替换的Section数组 )

- returns: form
*/
@discardableResult
public func >>>! (left: Form, right: (Range<Int>, [Section])) -> Form {
    left.replaceSubrange(right.0, with: right.1, updateUI: true)
    return left
}

/**
 替换Section的所有Item

- parameter left:  section
- parameter right: 要替换的Item数组

- returns: section
*/
@discardableResult
public func >>> (left: Section, newItems: [Item]) -> Section {
    left.removeAll()
    left.append(contentsOf: newItems)
    return left
}
/**
 替换Section的所有Item，并通知到代理

- parameter left:  section
- parameter right: 要替换的Item数组

- returns: section
*/
@discardableResult
public func >>>! (left: Section, newItems: [Item]) -> Section {
    left.removeAll(updateUI: true)
    left.append(contentsOf: newItems, updateUI: true)
    return left
}

/**
 替换Item数组到指定范围

- parameter left:  section
- parameter right: 元组，( 范围 ，要替换的Item数组 )

- returns: section
*/
@discardableResult
public func >>> (left: Section, right: (Range<Int>, [Item])) -> Section {
    left.replaceSubrange(right.0, with: right.1)
    return left
}
/**
 替换Item数组到指定范围, 并通知到代理

- parameter left:  section
- parameter right: 元组，( 范围 ，要替换的Item数组 )

- returns: section
*/
@discardableResult
public func >>>! (left: Section, right: (Range<Int>, [Item])) -> Section {
    left.replaceSubrange(right.0, with: right.1, updateUI: true)
    return left
}

/**
 添加 Item 的集合到 Section
 
 - parameter lhs: section
 - parameter rhs: items 的集合
 */
public func += <C: Collection>(lhs: inout Section, rhs: C) where C.Iterator.Element == Item {
    lhs.append(contentsOf: rhs)
}

/**
 添加 Section 的集合到 Form
 
 - parameter lhs: form
 - parameter rhs: sections 的集合
 */
public func += <C: Collection>(lhs: inout Form, rhs: C) where C.Iterator.Element == Section {
    lhs.append(contentsOf: rhs)
}
