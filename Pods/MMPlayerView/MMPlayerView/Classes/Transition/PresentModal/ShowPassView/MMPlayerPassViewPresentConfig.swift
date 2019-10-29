//
//  PassViewConfig.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/16.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class MMPlayerPassViewPresentConfig: NSObject ,MMPlayerPresentConfig {

    weak public var passOriginalSuper: UIView?
    weak public var playLayer: MMPlayerLayer?
    public var margin: CGFloat = 10.0
    public var isMarginNeedArea = true
    public var duration:TimeInterval = 0.3
    public var defaultShrinkSize = CGSize(width: 150, height: 100)
    public var shrinkMaxWidth: CGFloat = 150
    weak public var source: UIViewController?

    var _dismissGesture = false
    public var dismissGesture: Bool {
        get {
            return _dismissGesture
        }
    }
}
