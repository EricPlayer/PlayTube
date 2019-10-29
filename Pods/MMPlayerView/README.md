# MMPlayerView
[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=W5C6A3FB8H4DQ)

[![CI Status](http://img.shields.io/travis/millmanyang@gmail.com/MMPlayerView.svg?style=flat)](https://travis-ci.org/millmanyang@gmail.com/MMPlayerView)
[![Version](https://img.shields.io/cocoapods/v/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
[![License](https://img.shields.io/cocoapods/l/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
[![Platform](https://img.shields.io/cocoapods/p/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
## Demo

## List / Shrink / Transition / Landscape
![list](https://github.com/MillmanY/MMPlayerView/blob/master/demo/list_demo.gif)
![shrink](https://github.com/MillmanY/MMPlayerView/blob/master/demo/shrink_demo.gif) 
![transition](https://github.com/MillmanY/MMPlayerView/blob/master/demo/transition_demo.gif)
![landscape](https://github.com/MillmanY/MMPlayerView/blob/master/demo/landscape_demo.gif)

## MMPlayerLayer       
    ex. use when change player view frequently like tableView / collectionView
    import MMPlayerView
    mmPlayerLayer.playView = cell.imgView
    mmPlayerLayer.getStatusBlock { [weak self] (status) in

    }
    self.mmPlayerLayer.set(url: DemoSource.shared.demoData[indexPath.row].play_Url)
    self.mmPlayerLayer.resume()


## MMPlayerView
    let url = URL.init(string: "http://www.html5videoplayer.net/videos/toystory.mp4")!
    playView.replace(cover: CoverA.instantiateFromNib())
    playView.set(url: url, thumbImage: #imageLiteral(resourceName: "seven")) { (status) in
        switch status {
           case ....
        }
    }
    
    
    playView.startLoading()
## Transition
    
    ##PresentedViewController
    1. Set transition config
        required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
            self.mmPlayerTransition.present.pass { (config) in
                // setting
                .....
            }
        }
    2. Set MMPLayerToProtocol on PresentedViewController
    3. Set MMPlayerPrsentFromProtocol on PresentingViewController

## Shrink
    ex. only set present transition can use shrink video
    (self.presentationController as? PassViewPresentatinController)?.shrinkView()
## Landscape
    1.Set AppDelegate
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) ->        
        UIInterfaceOrientationMask {
        if window == MMLandscapeWindow.shared {
            return .allButUpsideDown
        } else {
            return ....
        }
     }
    2. Observer orientation when landscape call function
        MMLandscapeWindow.shared.makeKey(root: full, playLayer: self.mmPlayerLayer, completed: {
        })
## Cover View
![landscape](https://github.com/MillmanY/MMPlayerView/blob/master/demo/cover.png)

    ## add cover item view on player
    play.replace(cover: CoverA.instantiateFromNib())

## Progress
    // Custom your progress view and it will add on player center
    // view need to implement ProgressProtocol, and add progress in this view, when start/stop control what need to do
    .custom(view: <#T##MMProgressProtocol#>)
     public protocol MMProgressProtocol {
         func start()
         func stop()
     }
     
## Cache
    playerLayer.cacheType = .memory(count: 10)
    public enum MMPlayerCacheType {
        case none
        case memory(count: Int) // set this to cache seek time in memory and if cache out of count will remove first you    
        stored
    }
## Layer Protocol
    // detect if touch in videoRect
    // if touch out of videoRect will not trigger show/hide cover view event
    public protocol MMPlayerLayerProtocol: class {
    
    func touchInVideoRect(contain: 
    
    ) // 
    }
 
## Parameter
    
    public enum MMPlayerCoverAutoHideType {
        case autoHide(after: TimeInterval)
        case disable
    }

    public enum MMPlayerCacheType {
       case none // set no cache and remove all
       case memory(count: Int) // cache player seek time in memory
    }
    public enum CoverViewFitType {
      case fitToPlayerView // coverview fit with playerview
      case fitToVideoRect // fit with VideoRect
    }
         
    public enum ProgressType {
       case `default`
       case none
       case custom(view: ProgressProtocol)
    }
    public var autoHideCoverType = MMPlayerCoverAutoHideType.autoHide(after: 3.0) // Default hide after 3.0 , set disable to close auto hide cover            
    public var progressType: MMPlayerView.ProgressType  
    public var coverFitType: MMPlayerView.CoverViewFitType
    lazy public var thumbImageView: UIImageView 
    public var playView: UIView?
    public var coverView: UIView? { get }
    public var autoPlay: Bool // when MMPlayerView.MMPlayerPlayStatus == ready auto play video
    public var currentPlayStatus: MMPlayerView.MMPlayerPlayStatus 
    public var cacheType: MMPlayerCacheType = .none
    public var playUrl: URL?
    public func showCover(isShow: Bool)
    public func setCoverView(enable: Bool)
    public func delayHideCover()
    public func replace<T: UIView>(cover:T) where T: CoverViewProtocol
    public func set(url: URL?, state: ((MMPlayerView.MMPlayerPlayStatus) -> Swift.Void)?)
    public func resume() // if loading finish autoPlay = false, need call playerLayer.player.play() where you want
    public weak var mmDelegate: MMPlayerLayerProtocol?
    public func download(observer status: @escaping ((MMPlayerDownloader.DownloadStatus)->Void)) -> MMPlayerObservation? //Downlaod and observer

## Downloader
            var downloadObservation: MMPlayerObservation?

            downloadObservation = MMPlayerDownloader.shared.observe(downloadURL: downloadURL) { [weak self] (status) in
                switch status {
                case .cancelled:
                    print("Canceld")
                case .completed:
                    DispatchQueue.main.async {
                        self?.downloadBtn.setTitle("Delete", for: .normal)
                        self?.downloadBtn.isHidden = false
                        self?.progress.isHidden = true
                    }
                case .downloading(let value):
                    self?.downloadBtn.isHidden = true
                    self?.progress.isHidden = false
                    self?.progress.progress = value
                    print("Exporting \(value) \(downloadURL)")
                case .failed(let err):
                    DispatchQueue.main.async {
                        self?.downloadBtn.setTitle("Download", for: .normal)
                    }
                    
                    self?.downloadBtn.isHidden = false
                    self?.progress.isHidden = true
                    print("Download Failed \(err)")
                case .none:
                    DispatchQueue.main.async {
                        self?.downloadBtn.setTitle("Download", for: .normal)
                    }
                    self?.downloadBtn.isHidden = false
                    self?.progress.isHidden = true
                case .exist:
                    DispatchQueue.main.async {
                        self?.downloadBtn.setTitle("Delete", for: .normal)
                    }
                    self?.downloadBtn.isHidden = false
                    self?.progress.isHidden = true
                }
## Delete
            if let info = MMPlayerDownloader.shared.localFileFrom(url: downloadURL)  {
                MMPlayerDownloader.shared.deleteVideo(info)
            }

## Requirements

    iOS 10.0+
    Swift 4.0+
    
## Installation

MMPlayerView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
Swift 3 
pod 'MMPlayerView', '~> 2.1.8'
Swift 4 (> 3.0.1)
pod 'MMPlayerView'
```
## Author

millmanyang@gmail.com

## License

MMPlayerView is available under the MIT license. See the LICENSE file for more info.
