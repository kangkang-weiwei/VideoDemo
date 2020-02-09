//
//  ViViewModel.swift
//  Video
//
//  Created by 康思婉 on 2020/2/4.
//  Copyright © 2020年 康思婉. All rights reserved.
//

//import UIKit
import SnapKit
import AVFoundation

class ViViewModel: NSObject {
    
    var periodWithValue:((String, String, Float, Float) -> ())?
    private var url : URL?
    private var speed : Float?
    
    private var playerItem : AVPlayerItem?
    private var player : AVPlayer?
    private var avLayer : AVPlayerLayer?
    private var imageGenerator : AVAssetImageGenerator?
    
    private let Screen_width = UIScreen.main.bounds.size.width
    private let Screen_height = UIScreen.main.bounds.size.height
    
    var model : ViModel?
    
    override init() {
        super.init()
        model = ViModel.init()
        speed = 1.0
        let appde = UIApplication.shared.delegate as! AppDelegate
        appde.allowRotation = true
        appde.currentOrientation = .portrait
    }
    
    func getPlayerWithPath(index : IndexPath) -> AVPlayerLayer {
        url = model!.getUrlWithIndexPath(index: index)
        playerItem = AVPlayerItem(url: url! as URL)
        player = AVPlayer.init(playerItem: playerItem)
        avLayer = AVPlayerLayer(player: player)
        avLayer?.videoGravity = .resizeAspect
        avLayer?.frame = CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9/16)
        
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.observe(player: player!)
        
        let asset = AVAsset(url: url!)
        imageGenerator = AVAssetImageGenerator(asset: asset)
        
        return avLayer!
    }
    
    //添加监听
    private func observe(player : AVPlayer) {
        weak var weakSelf = self
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main) { (time : CMTime) in
            
            if player.currentItem?.status == .readyToPlay{
                let playItem = player.currentItem
                //当前时间
                let currentTime = CMTimeGetSeconds(player.currentTime())
                let beginLabelText = weakSelf?.formatPlayTime(duration: currentTime)
                
                //总时间
                let allTime = CMTimeGetSeconds((player.currentItem?.duration)!)
                //进度条
                let endLabelText = weakSelf?.formatPlayTime(duration: allTime)
                let sliderValue = Float(currentTime / allTime)
                
                var progressValue : Float = 0.0
                //缓冲进度
                let loadTimeRange = playItem?.loadedTimeRanges
                let timeRange = loadTimeRange?.first?.timeRangeValue
                if timeRange != nil {
                    let loadStartSecond = CMTimeGetSeconds((timeRange?.start)!)
                    let loadDurationSeconds = CMTimeGetSeconds((timeRange?.duration)!)
                    let currentLoadTotalTime = loadStartSecond + loadDurationSeconds
                    progressValue = Float(currentLoadTotalTime / allTime)
                }
                if self.periodWithValue != nil {
                    self.periodWithValue!(beginLabelText!, endLabelText!, sliderValue, progressValue)
                }
            }
        }
    }
    
    //时间转换方法
    private func formatPlayTime(duration : TimeInterval) -> String {
        //再完善：进行补0操作。如7:6应写为07:06
        if duration.isNaN {
            return "0:0"
        }
        var minute = 0, second = Int(duration)
        minute = Int(second / 60)
        second = second % 60
        var str : String?
        str = "\(minute):\(second)"
        return str!
    }
    
    func changePlayerWithPath(index : IndexPath) {
        self.playerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        
        url = model?.getUrlWithIndexPath(index: index)
        let item = AVPlayerItem(url: url! as URL)
        self.player?.replaceCurrentItem(with: item)
        
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.playerItem = item
        
        let asset = AVAsset(url: url!)
        imageGenerator = AVAssetImageGenerator(asset: asset)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        var playerItem : AVPlayerItem?
        playerItem = object as? AVPlayerItem
        
        if keyPath == "status" {
            switch playerItem?.status{
            case .readyToPlay?:
                print("准备完成")
                player?.play()
                player?.rate = speed!
                break
            case .none:
                print("位置情况")
            case .some(.unknown):
                print("未知错误")
            case .some(.failed):
                print("视频加载失败")
            }
        }
    }
    
    func playAndPause(button : UIButton){
        if button.isSelected {
            player?.rate = speed!
        }else{
            player?.pause()
        }
        button.isSelected = !button.isSelected
    }
    
    func getDeviceOrientation() -> UIDeviceOrientation {
        let orientation = UIDevice.current.orientation
        return orientation
    }
    
    func rotation(button : UIButton, lockBtnIsSelector : Bool) {
        if lockBtnIsSelector {
            return
        }
        let orientation = getDeviceOrientation()
        switch orientation {
        case .portraitUpsideDown:   //上下翻转
            DeviceTool.interfaceOrientation(.portrait)
            break
        case .portrait: //竖屏
            if button.isSelected {
                DeviceTool.interfaceOrientation(.portrait)
            }else {
                DeviceTool.interfaceOrientation(.landscapeRight)
            }
            break
        case .landscapeLeft:
            if button.isSelected {
                DeviceTool.interfaceOrientation(.portrait)
            }else{
                DeviceTool.interfaceOrientation(.landscapeLeft)
            }
            break
        case .landscapeRight:
            if button.isSelected {
                DeviceTool.interfaceOrientation(.portrait)
            }else {
                DeviceTool.interfaceOrientation(.landscapeRight)
            }
            break
        default: break
        }
    }
    
    func screenShot(button : UIButton) -> UIImage {
        let currentTime = player?.currentTime()
        print(CMTimeGetSeconds(currentTime!))
        let imageRef = try! imageGenerator!.copyCGImage(at: currentTime!, actualTime: nil)
        print(imageRef)
        let image = UIImage(cgImage: imageRef)
        print(image)
        return image
    }
    
    func changeSpeedWithPlayBtnIsSelector(button : UIButton, isSelector : Bool) {
        if button.isSelected {
            self.speed = 1.0
        }else {
            self.speed = 2.0
        }
        
        if isSelector { // 此时已经暂停
            
        } else {
            player?.rate = speed!
        }
        
        button.isSelected = !button.isSelected
    }
    
    func lock(button : UIButton) {
        let appde = UIApplication.shared.delegate as! AppDelegate
        if button.isSelected {  //锁了，将要打开
            appde.allowRotation = true
        }else { //没锁，将要锁
            let orientation = UIApplication.shared.statusBarOrientation
            appde.allowRotation = false
            if orientation == .portrait {
                appde.currentOrientation = .portrait
            }else if orientation == .landscapeLeft {
                appde.currentOrientation = .landscapeLeft
            }else if orientation == .landscapeRight {
                appde.currentOrientation = .landscapeRight
            }
        }
        button.isSelected = !button.isSelected
    }
}
