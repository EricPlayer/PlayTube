//
//  MMPushAnimator.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/25.
//
//

import UIKit

public class MMPlayerPushAnimator: NSObject, UINavigationControllerDelegate {
    public var config: MMPlayerNavConfig?
    unowned let base: UINavigationController
    var transition: UIViewControllerAnimatedTransitioning?
    lazy var _proxy: NavigationDelegateProxy = {
        return NavigationDelegateProxy(parent: self, forward: self.base.delegate)
    }()
    
    public init(_ base: UINavigationController) {
        self.base = base
        super.init()
    }
    
    public func pass<T: MMPlayerPassViewPushConfig>(setting: (_ config: T)->Void) {
        self.base.delegate = _proxy
        self.config = MMPlayerPassViewPushConfig()
        self.transition = nil
        setting(self.config! as! T)
    }
    
    public func removeAnimate() {
        self.config = nil
        self.transition = nil
        self.base.delegate = nil
    }
    
    public var enableCustomTransition: Bool = true {
        didSet {
            if enableCustomTransition {
                base.delegate = _proxy
            } else {
                base.delegate = nil
            }
        }
    }

    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationController.Operation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        if let proxy = self.base.navigationController?.delegate as? NavigationDelegateProxy,
            let childTransition = proxy.forward?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC) {
            return childTransition
        } else if self.enableCustomTransition == false || fromVC.fromProtocolVC == nil || toVC.toProtocolVC == nil {
            return nil
        }
        if let t = self.transition as? MMPlayerBaseNavTransition {
            t.operation = operation
        } else {
            let t = MMPlayerPassViewPushTransition(config: config!, operation: operation)
            transition = t
        }
        return transition
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}

