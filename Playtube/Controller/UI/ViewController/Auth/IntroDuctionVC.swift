//
//  ViewController.swift
//  Playtube


import UIKit
import AVFoundation

class IntroDuctionVC: UIViewController {


    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
     var agree = false
    let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theURL = URL(fileURLWithPath: Bundle.main.path(forResource: "MainVideo", ofType: ".mp4")!)
        
        avPlayer = AVPlayer(url: theURL)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 25
        avPlayer.actionAtItemEnd = .none
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }
   
   
    
    // video player func
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        
        p.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    
    @IBAction func registerButtonAction(_ sender: Any) {
        let vc = self.storyBoard.instantiateViewController(withIdentifier: "RegisterVC")as! RegisterVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func logiInButtonAction(_ sender: Any) {
        let vc = self.storyBoard.instantiateViewController(withIdentifier: "LoginVC")as! LoginVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func skipButtonAction(_ sender: Any) {
        
              let storyBoard = UIStoryboard(name: "Tabbar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "TabbarVC") as! TabbarVC
              navigationController?.pushViewController(vc, animated: true)
            
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        paused = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
        paused = true
    }
}

