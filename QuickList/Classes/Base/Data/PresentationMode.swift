//
//  PresentationMode.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import Foundation
import UIKit

/**
 * Item弹出的Controller的基础协议
 * Base protocol for Item popup Controller
 */
public protocol ItemControllerType: NSObjectProtocol {

    /**
     * Controller消失时回调的block
     * Block callback when Controller disappears
     */
    var onDismissCallback: ((UIViewController) -> Void)? { get set }
}

/**
 * Item弹出控制器的关联协议
 * Association protocol for Item popup controller
 */
public protocol TypedItemControllerType: ItemControllerType {
    /**
     * 弹出这个控制器的item
     * Item that pops up this controller
     */
    var item: Item! { get set }
}

/**
 * Item弹出控制器传值的关联协议
 * Association protocol for Item popup controller value passing
 */
public protocol TypedCollectionValueItemType {
    associatedtype Value: Equatable
    
    /**
     * Value
     * 值
     */
    var sendValue: Value? { get set }
}

/**
 * 定义应如何创建控制器的枚举
 * Define enumeration for how to create controllers
 *
 * - Callback -> VCType:    由block代码的返回值创建控制器
 * - NibFile:               由xib文件创建控制器
 * - StoryBoard:            由StoryBoard中的storyboard id创建控制器
 *
 * - Callback -> VCType:    Create controller from block code return value
 * - NibFile:               Create controller from xib file
 * - StoryBoard:            Create controller from StoryBoard storyboard id
 */
public enum ControllerProvider<VCType: UIViewController> {

    /**
     * 指定block中创建控制器
     * Create controller in specified block
     */
    case callback(builder: (() -> VCType))

    /**
     * 指定xibName和Bundle
     * Specify xibName and Bundle
     */
    case nibFile(name: String, bundle: Bundle?)

    /**
     * 指定storyboardName、Bundle和其中的storyboard id
     * Specify storyboardName, Bundle and storyboard id in it
     */
    case storyBoard(storyboardId: String, storyboardName: String, bundle: Bundle?)

    func makeController() -> VCType {
        switch self {
            case .callback(let builder):
                return builder()
            case .nibFile(let nibName, let bundle):
                return VCType.init(nibName: nibName, bundle:bundle ?? Bundle(for: VCType.self))
            case .storyBoard(let storyboardId, let storyboardName, let bundle):
                let sb = UIStoryboard(name: storyboardName, bundle: bundle ?? Bundle(for: VCType.self))
                return sb.instantiateViewController(withIdentifier: storyboardId) as! VCType
        }
    }
}

/**
 * 定义控制器如何显示
 * Define how controllers are displayed
 *
 * - Show?:                 使用`show(_:sender:)`方法跳转（自动选择push和present）
 * - PresentModally?:       使用Present方式跳转
 * - SegueName?:            使用StoryBoard中的Segue identifier跳转
 * - SegueClass?:           使用UIStoryboardSegue类跳转
 * - popover?:              使用popoverPresentationController方式展示
 *
 * - Show?:                 Use `show(_:sender:)` method to jump (automatically choose push and present)
 * - PresentModally?:       Use Present method to jump
 * - SegueName?:            Use Segue identifier in StoryBoard to jump
 * - SegueClass?:           Use UIStoryboardSegue class to jump
 * - popover?:              Use popoverPresentationController method to display
 */
public enum PresentationMode<VCType: UIViewController> {

    /**
     * 根据指定的Provider创建控制器，并使用`show(_:sender:)`方法进行跳转
     * Create controller based on specified Provider and jump using `show(_:sender:)` method
     */
    case show(controllerProvider: ControllerProvider<VCType>, onDismiss: ((VCType) -> Void)?)

    /**
     * 根据指定的Provider创建控制器，并使用Present方式跳转
     * Create controller based on specified Provider and jump using Present method
     */
    case presentModally(controllerProvider: ControllerProvider<VCType>, onDismiss: ((VCType) -> Void)?)

    /**
     * 使用StoryBoard中的Segue identifier跳转
     * Jump using Segue identifier in StoryBoard
     */
    case segueName(segueName: String, onDismiss: ((VCType) -> Void)?)

    /**
     * 使用UIStoryboardSegue类执行跳转
     * Execute jump using UIStoryboardSegue class
     */
    case segueClass(segueClass: UIStoryboardSegue.Type, onDismiss: ((VCType) -> Void)?)

    /**
     * popoverPresentationController(小窗口)方式展示
     * Display using popoverPresentationController (small window) method
     */
    case popover(controllerProvider: ControllerProvider<VCType>, onDismiss: ((VCType) -> Void)?)

    public var onDismissCallback: ((VCType) -> Void)? {
        switch self {
            case .show(_, let completion):
                return completion
            case .presentModally(_, let completion):
                return completion
            case .segueName(_, let completion):
                return completion
            case .segueClass(_, let completion):
                return completion
            case .popover(_, let completion):
                return completion
        }
    }

    /**
     * 自定义Item的点击事件中调用此方法进行跳转
     * Call this method in custom Item click event to jump
     *
     * - parameter viewController:           跳转目标控制器
     * - parameter item:                     关联的Item
     * - parameter presentingViewController: 跳转来源，通常当前控制器
     *
     * - parameter viewController:           Target controller to jump to
     * - parameter item:                     Associated Item
     * - parameter presentingViewController: Source of jump, usually current controller
     */
    public func present(_ viewController: VCType!, item: Item, presentingController: UIViewController) {
        switch self {
            case .show(_, _):
                presentingController.show(viewController, sender: item)
            case .presentModally(_, _):
                presentingController.present(viewController, animated: true)
            case .segueName(let segueName, _):
                presentingController.performSegue(withIdentifier: segueName, sender: item)
            case .segueClass(let segueClass, _):
                let segue = segueClass.init(identifier: item.tag, source: presentingController, destination: viewController)
                presentingController.prepare(for: segue, sender: item)
                segue.perform()
            case .popover(_, _):
                guard viewController.popoverPresentationController != nil else {
                    fatalError()
                }
                presentingController.present(viewController, animated: true)
            }

    }

    /**
     * 自定义Item中获取控制器的方法，会根据当前枚举的值获取对应的控制器
     * Method to get controller in custom Item, will get corresponding controller based on current enumeration value
     *
     * - returns: 创建好的控制器，或nil
     * - returns: Created controller, or nil
     */
    public func makeController() -> VCType? {
        switch self {
            case .show(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                let completionController = controller as? ItemControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = {
                        guard let vc = $0 as? VCType else {
                            assertionFailure("onDismissCallback should return a \(VCType.self), but got \($0)")
                            return
                        }
                        callback(vc)
                    }
                }
                return controller
            case .presentModally(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                let completionController = controller as? ItemControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = {
                        guard let vc = $0 as? VCType else {
                            assertionFailure("onDismissCallback should return a \(VCType.self), but got \($0)")
                            return
                        }
                        callback(vc)
                    }
                }
                return controller
            case .popover(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                controller.modalPresentationStyle = .popover
                let completionController = controller as? ItemControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = {
                        guard let vc = $0 as? VCType else {
                            assertionFailure("onDismissCallback should return a \(VCType.self), but got \($0)")
                            return
                        }
                        callback(vc)
                    }
                }
                return controller
            default:
                return nil
        }
    }
}
