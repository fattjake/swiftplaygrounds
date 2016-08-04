import UIKit
import AVFoundation
import PlaygroundSupport

public class PlayerController {
    let player = AVPlayer()
    public let playerLayer : AVPlayerLayer
    var playerItem : AVPlayerItem?
    
    init() {
        playerLayer = AVPlayerLayer(player: player)
    }
    
    public func playURL(url : URL) {
        playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.volume = 0.5
        player.play()
    }
    
    public func setVolume(volume : Float) {
        player.volume = volume
    }
}

public class PlayerViewController : UIViewController {
    public let playerController = PlayerController()
    
    public override func viewDidLoad() {
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(playerController.playerLayer)

        playerController.playerLayer.bounds = view.bounds
        playerController.playerLayer.position = view.center
    }
}
