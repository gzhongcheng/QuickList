//
//  PresentationMode.swift
//  QuickList
//
//  Created by ZhongCheng Guo on 2024/8/7.
//

import Foundation
import UIKit

/**
 *  Item弹出的Controller的基础协议
 */
public protocol ItemControllerType: NSObjectProtocol {

    /// Controller消失时回调的block
    var onDismissCallback: ((UIViewController) -> Void)? { get set }
}

/**
 *  Item弹出控制器的关联协议
 */
public protocol TypedItemControllerType: ItemControllerType {
    /// 弹出这个控制器的item
    var item: Item! { get set }
}

/**
 *  Item弹出控制器传值的关联协议
 */
public protocol TypedCollectionValueItemType {
    associatedtype Value: Equatable
    
    /// Value
    var sendValue: Value? { get set }
}

/**
 定义应如何创建控制器的枚举

 - Callback -> VCType:    由block代码的返回值创建控制器
 - NibFile:                         由xib文件创建控制器
 - StoryBoard:                  由StoryBoard中的storyboard id创建控制器
 */
public enum ControllerProvider<VCType: UIViewController> {

    /// 指定block中创建控制器
    case callback(builder: (() -> VCType))

    /// 指定xibName和Bundle
    case nibFile(name: String, bundle: Bundle?)

    /// 指定storyboardName、Bundle和其中的storyboard id
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
 定义控制器如何显示

 - Show?:                       使用`show(_:sender:)`方法跳转（自动选择push和present）
 - PresentModally?:       使用Present方式跳转
 - SegueName?:            使用StoryBoard中的Segue identifier跳转
 - SegueClass?:            使用UIStoryboardSegue类跳转
 - popover?:                  使用popoverPresentationController方式展示
 */
public enum PresentationMode<VCType: UIViewController> {

    /// 根据指定的Provider创建控制器，并使用`show(_:sender:)`方法进行跳转
    case show(controllerProvider: ControllerProvider<VCType>, onDismiss: ((VCType) -> Void)?)

    /// 根据指定的Provider创建控制器，并使用Present方式跳转
    case presentModally(controllerProvider: ControllerProvider<VCType>, onDismiss: ((VCType) -> Void)?)

    /// 使用StoryBoard中的Segue identifier跳转
    case segueName(segueName: String, onDismiss: ((VCType) -> Void)?)

    /// 使用UIStoryboardSegue类执行跳转
    case segueClass(segueClass: UIStoryboardSegue.Type, onDismiss: ((VCType) -> Void)?)

    /// popoverPresentationController(小窗口)方式展示
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
     自定义Item的点击事件中调用此方法进行跳转
     
     - parameter viewController:           跳转目标控制器
     - parameter item:                     关联的Item
     - parameter presentingViewController: 跳转来源，通常当前控制器
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
     自定义Item中获取控制器的方法，会根据当前枚举的值获取对应的控制器

     - returns: 创建好的控制器，或nil
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
