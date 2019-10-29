//
//  CoverA.swift
//  PlayTube
//


import UIKit
import MMPlayerView
import AVFoundation

class CoverA: UIView, MMPlayerCoverViewProtocol {
    weak var playLayer: MMPlayerLayer?
    fileprivate var isUpdateTime = false

    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var playSlider: UISlider!
    @IBOutlet weak var labTotal: UILabel!
    @IBOutlet weak var labCurrent: UILabel!
    
      var offsetObservation: NSKeyValueObservation?
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        
        l.cacheType = .memory(count: 5)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravity.resizeAspect
        l.replace(cover: CoverA.instantiateFromNib())
        return l
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        btnPlay.imageView?.tintColor = UIColor.white
    }
    @IBAction func btnAction() {
        self.playLayer?.delayHideCover()
        if playLayer?.player?.rate == 0{
            self.playLayer?.player?.play()
        } else {
            self.playLayer?.player?.pause()
        }
    }
    
    func currentPlayer(status: MMPlayerLayer.PlayStatus) {
        switch status {
        case .playing:
            self.btnPlay.setImage(UIImage(named: "pause"), for: .normal)
        default:
            self.btnPlay.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    func timerObserver(time: CMTime) {
        if let duration = self.playLayer?.player?.currentItem?.asset.duration ,
            !duration.isIndefinite ,
            !isUpdateTime {
            if self.playSlider.maximumValue != Float(duration.seconds) {
                self.playSlider.maximumValue = Float(duration.seconds)
            }
            self.labCurrent.text = self.convert(second: time.seconds)
            self.labTotal.text = self.convert(second: duration.seconds-time.seconds)
            self.playSlider.value = Float(time.seconds)
        }
    }

    fileprivate func convert(second: Double) -> String {
        let component =  Date.dateComponentFrom(second: second)
        if let hour = component.hour ,
            let min = component.minute ,
            let sec = component.second {
            
            let fix =  hour > 0 ? NSString(format: "%02d:", hour) : ""
            return NSString(format: "%@%02d:%02d", fix,min,sec) as String
        } else {
            return "-:-"
        }
    }
    
    @IBAction func sliderValueChange(slider: UISlider) {
        self.isUpdateTime = true
        self.playLayer?.delayHideCover()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(delaySeekTime), object: nil)
        self.perform(#selector(delaySeekTime), with: nil, afterDelay: 0.1)
    }
    
    @objc func delaySeekTime() {
        let time =  CMTimeMake(value: Int64(self.playSlider.value), timescale: 1)
        self.playLayer?.player?.seek(to: time, completionHandler: { [unowned self] (finish) in
            self.isUpdateTime = false
        })
    }
    
    func player(isMuted: Bool) {
        
    }
    @IBAction func fullScreenPressed(_ sender: Any) {
    self.landscapeAction()
    }
   
    fileprivate func landscapeAction() {
     
        if UIDevice.current.orientation.isLandscape {
             let full = UIStoryboard.init(name: "LoggedInTabbar", bundle: nil).instantiateViewController(withIdentifier: "FullScreenVC") as! FullScreenVC
            MMLandscapeWindow.shared.makeKey(root: full, playLayer: self.mmPlayerLayer, completed: {
                print("landscape completed")
            })
        }
    }
    
    deinit {
        offsetObservation?.invalidate()
        offsetObservation = nil
        print("ViewController deinit")
    }
}


extension Date {
    static func dateComponentFrom(second: Double) -> DateComponents {
        let interval = TimeInterval(second)
        let date1 = Date()
        let date2 = Date(timeInterval: interval, since: date1)
        let c = NSCalendar.current
        
        var components = c.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday], from: date1, to: date2)
        components.calendar = c
        return components
    }
}
