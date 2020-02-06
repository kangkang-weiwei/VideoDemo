//
//  ViView.swift
//  Video
//
//  Created by 康思婉 on 2020/2/4.
//  Copyright © 2020年 康思婉. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class ViView: UIView{

    
    let Screen_width = UIScreen.main.bounds.size.width
    let Screen_height = UIScreen.main.bounds.size.height
    
    var videoView : VideoView?
    var tableView : UITableView?
    var viewModel : ViViewModel?
    var avLayer : AVPlayerLayer?
    var photoImageView : UIImageView?
    var imageGenerator : AVAssetImageGenerator?
    
    var isFullScreen : Bool?    //是否满屏
    var isLock : Bool?         //是否锁屏
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //选择视频
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 60 + Screen_width * 9 / 8, width: Screen_width, height: Screen_height - 60 - Screen_width * 9 / 8), style: .plain)
        tableView?.backgroundColor = UIColor.gray
        self.addSubview(tableView!)
        
        //初始化
        viewModel = ViViewModel()
        let index : IndexPath = IndexPath.init(row: 0, section: 0)
        avLayer = AVPlayerLayer.init()
        avLayer = viewModel!.getPlayerWithPath(index: index)
        self.observe(player: avLayer!.player!)   //添加监听
        self.layer.addSublayer(avLayer!)
        
        //截图
        photoImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 40 + Screen_width * 9 / 16, width: Screen_width, height: Screen_width * 9 / 16))
        photoImageView?.backgroundColor = UIColor.gray
        self.addSubview(photoImageView!)
        
        let url = viewModel?.model?.getUrlWithIndexPath(index: index)
        let asset = AVAsset(url: url!)
        imageGenerator = AVAssetImageGenerator(asset: asset)
        
        //控件图层
        videoView = VideoView.init(frame: CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9 / 16))
        self.addSubview(videoView!)
        addButtonTarget()
        
        self.listeningRotating()
        isFullScreen = false
        isLock = false
        let appde = UIApplication.shared.delegate as! AppDelegate
        appde.allowRotation = true
        appde.currentOrientation = .portrait
    }
    
    //添加监听，屏幕旋转时
    func listeningRotating() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    //监听屏幕旋转响应的方法
    @objc func onDeviceOrientation() {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portraitUpsideDown:
            print("监听到了UpsideDown")
            if !isLock! {
                changeScreen()
            }
            break
        case .landscapeLeft:
            print("监听到了Left")
            if !isLock! {
                changeScreen()
            }
            break
        case .landscapeRight:
            print("监听到了Right")
            if !isLock! {
                changeScreen()
            }
            break
        case .portrait:
            print("监听到了portrait")
            if !isLock! {
                changeScreen()
            }
            break
        default:
            break
        }
    }
    
    //根据是否满屏，改变videoView的大小
    func changeScreen() {
        if isFullScreen! {
            avLayer?.frame = CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9/16)
            videoView?.frame = CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9/16)
            isFullScreen = false
        }else {
            let currentFrame = UIScreen.main.bounds
            avLayer?.frame = currentFrame
            videoView?.frame = currentFrame
            isFullScreen = true
        }
    }
    
    //按钮响应方法
    @objc func buttonClick(button : UIButton) {
        if button.tag == 101 {    //暂停按钮
            if avLayer?.player?.rate == 1.0 {
                button.isSelected = false
            }
            viewModel?.playAndPause(button: button)
            button.isSelected = !button.isSelected
        }else if button.tag == 102 {    //旋转按钮
            if isLock! {
                return
            }
            let orientation = UIDevice.current.orientation
            
            switch orientation {
            case .portraitUpsideDown:   //上下翻转
                DeviceTool.interfaceOrientation(.portrait)
                break
            case .portrait: //竖屏
                if isFullScreen! {
                    DeviceTool.interfaceOrientation(.portrait)
                }else {
                    DeviceTool.interfaceOrientation(.landscapeRight)
                }
                break
            case .landscapeLeft:
                if isFullScreen! {
                    DeviceTool.interfaceOrientation(.portrait)
                }else{
                    DeviceTool.interfaceOrientation(.landscapeLeft)
                }
                break
            case .landscapeRight:
                if isFullScreen! {
                    DeviceTool.interfaceOrientation(.portrait)
                }else {
                    DeviceTool.interfaceOrientation(.landscapeRight)
                }
                break
            default: break
            }
        }else if button.tag == 103 {    //截图按钮
            let currentTime = avLayer?.player?.currentTime()
            let imageRef = try! imageGenerator?.copyCGImage(at: currentTime!, actualTime: nil)
            photoImageView?.image = UIImage(cgImage: imageRef!)
        }else if button.tag == 104 {    //倍速按钮
            if button.isSelected {
                avLayer?.player?.rate = 1.0
                viewModel?.speed = 1.0
            } else {
                avLayer?.player?.rate = 2.0
                viewModel?.speed = 2.0
            }
            button.isSelected = !button.isSelected
        }else if button.tag == 105 {    //锁屏按钮
            button.isSelected = !button.isSelected
            let appde = UIApplication.shared.delegate as! AppDelegate
            if isLock! {
                appde.allowRotation = true
                isLock = false
            }else {
                appde.allowRotation = false
                isLock = true
                
                let oritation : UIInterfaceOrientation
                oritation = UIApplication.shared.statusBarOrientation
                if oritation == .portrait {
                    print("portrait")
                    appde.currentOrientation = .portrait
                }else if oritation == .landscapeLeft {
                    print("left")
                    appde.currentOrientation = .landscapeLeft
                }else if oritation == .landscapeRight {
                    print("right")
                    appde.currentOrientation = .landscapeRight
                }
            }
        }
    }
    
    //改变slider的调用方法
    @objc func sliderValueChanged(slider : UISlider) {
        if avLayer!.player!.status == .readyToPlay {
            let duration = slider.value * Float(CMTimeGetSeconds(avLayer!.player!.currentItem!.duration))
            avLayer?.player?.seek(to: CMTimeMake(Int64(duration), 1), completionHandler: { (finish) in
            })
        }
    }
    
    //添加监听
    func observe(player : AVPlayer) {
        weak var weakSelf = self
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main) { (time : CMTime) in
            
            if player.currentItem?.status == .readyToPlay{
                let playItem = player.currentItem
                //当前时间
                let currentTime = CMTimeGetSeconds(player.currentTime())
                weakSelf?.videoView?.videoViewModel.beginLabel?.text = weakSelf?.formatPlayTime(duration: currentTime)
                //总时间
                let allTime = CMTimeGetSeconds((player.currentItem?.duration)!)
                weakSelf?.videoView?.videoViewModel.endLabel?.text = weakSelf?.formatPlayTime(duration: allTime)
                //进度条
                weakSelf?.videoView?.videoViewModel.slider?.setValue(Float(currentTime / allTime), animated: true)
                //缓冲进度，还没写
                let loadTimeRange = playItem?.loadedTimeRanges
                let timeRange = loadTimeRange?.first?.timeRangeValue
                if timeRange != nil {
                    let loadStartSecond = CMTimeGetSeconds((timeRange?.start)!)
                    let loadDurationSeconds = CMTimeGetSeconds((timeRange?.duration)!)
                    let currentLoadTotalTime = loadStartSecond + loadDurationSeconds
                    weakSelf?.videoView?.videoViewModel.progressView?.setProgress(Float(currentLoadTotalTime / allTime), animated: true)
                }
            }
        }
    }
    
    //时间转换方法
    func formatPlayTime(duration : TimeInterval) -> String {
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
    
    func addButtonTarget() {
        if videoView != nil {
            videoView?.videoViewModel.pauseBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.videoViewModel.rotateBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.videoViewModel.lockBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.videoViewModel.photoBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.videoViewModel.speedBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.videoViewModel.slider?.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VideoView: UIView {
    
    public let videoViewModel = VideoViewModel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        videoViewModel.createPlayerView(view: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


