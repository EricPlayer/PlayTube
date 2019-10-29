//
//  MMPlayerItem.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/16.
//

import UIKit
import AVFoundation

protocol MMPlayerItemProtocol: class {
    func status(change: AVPlayerItem.Status)
    func isPlaybackKeepUp(isKeepUp: Bool)
    func isPlaybackEmpty(isEmpty: Bool)
}

class MMPlayerItem: AVPlayerItem {
    var statusObservation: NSKeyValueObservation?
    var keepUpObservation: NSKeyValueObservation?
    var emptyObservation: NSKeyValueObservation?

    weak var delegate: MMPlayerItemProtocol?
    convenience init(asset: AVAsset, delegate: MMPlayerItemProtocol?) {
        self.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        self.delegate = delegate
      
        statusObservation = self.observe(\.status, changeHandler: { [weak self] (item, _) in
            self?.delegate?.status(change: item.status)
        })
        keepUpObservation = self.observe(\.isPlaybackLikelyToKeepUp, changeHandler: { [weak self] (item, change) in
            self?.delegate?.isPlaybackKeepUp(isKeepUp: item.isPlaybackLikelyToKeepUp)
        })
        emptyObservation = self.observe(\.isPlaybackBufferEmpty, changeHandler: { [weak self] (item, change) in
            self?.delegate?.isPlaybackEmpty(isEmpty: item.isPlaybackBufferEmpty)
        })
    }
    
    deinit {
        if let observer = statusObservation {
            observer.invalidate()
            self.removeObserver(observer, forKeyPath: "status")
            self.statusObservation = nil
        }
        if let observer = keepUpObservation {
            observer.invalidate()
            self.removeObserver(observer, forKeyPath: "playbackLikelyToKeepUp")
            self.keepUpObservation = nil
        }
        if let observer = emptyObservation {
            observer.invalidate()
            self.removeObserver(observer, forKeyPath: "playbackBufferEmpty")
            self.emptyObservation = nil
        }
    }
}
