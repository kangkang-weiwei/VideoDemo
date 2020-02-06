//
//  ViViewModel.swift
//  Video
//
//  Created by 康思婉 on 2020/2/4.
//  Copyright © 2020年 康思婉. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class ViViewModel: NSObject {
    
    var urlString : NSString?
    var url : URL?
    var speed : Float?
    
    var playerItem : AVPlayerItem?
    var player : AVPlayer?
    var avLayer : AVPlayerLayer?
    
    let Screen_width = UIScreen.main.bounds.size.width
    let Screen_height = UIScreen.main.bounds.size.height
    
    var model : ViModel?
    
    override init() {
        model = ViModel.init()
        speed = 1.0
        super.init()
    }
    
    func getPlayerWithPath(index : IndexPath) -> AVPlayerLayer {
        
        url = model!.getUrlWithIndexPath(index: index)
        playerItem = AVPlayerItem(url: url! as URL)
        player = AVPlayer.init(playerItem: playerItem)
        avLayer = AVPlayerLayer(player: player)
        avLayer?.videoGravity = .resizeAspect
        avLayer?.frame = CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9/16)
        
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        return avLayer!
    }
    
    func changePlayerWithPath(index : IndexPath) -> AVAssetImageGenerator {
        // -> (imageGenerator:AVAssetImageGenerator, isBegin:Bool)
        
        self.playerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        self.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        
        url = model?.getUrlWithIndexPath(index: index)
        let item = AVPlayerItem(url: url! as URL)
        self.player?.replaceCurrentItem(with: item)
        
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        self.playerItem = item
        
        let asset = AVAsset(url: url!)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        return imageGenerator
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
        }else if keyPath == "loadedTimeRanges" {
            
        }
    }
    
    func playAndPause(button : UIButton){
        //双击或者按钮暂停
        if button.isSelected {
            player?.play()
        }else{
            player?.pause()
        }
    }
    
}
class VideoViewModel: NSObject {
    //进度条
    var progressView : UIProgressView?
    var slider : UISlider?
    
    //控件
    var beginLabel : UILabel?   //开始label
    var endLabel : UILabel?     //结束label
    var pauseBtn : UIButton?    //暂停按钮
    var rotateBtn : UIButton?   //旋转按钮
    
    //右侧按钮
    var photoBtn : UIButton?    //截图按钮
    var speedBtn : UIButton?    //倍速按钮
    var lockBtn : UIButton?     //锁屏按钮
    
    func createPlayerView(view : UIView) {
        self.pauseBtn = {
            let pauseBtn = UIButton.init()
            pauseBtn.tag = 101
            pauseBtn.setTitle("暂停", for: .normal)
            pauseBtn.setTitle("开始", for: .selected)
            view.addSubview(pauseBtn)
            pauseBtn.snp.makeConstraints({ (make) in
                make.left.equalTo(view).offset(5)
                make.width.equalTo(40)
                make.bottom.equalTo(view)
                make.height.equalTo(40)
            })
            return pauseBtn
        }()
        
        self.rotateBtn = {
            let rotateBtn = UIButton.init()
            rotateBtn.setTitle("旋转", for: .normal)
            rotateBtn.tag = 102
            view.addSubview(rotateBtn)
            rotateBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(view).offset(-5)
                make.width.equalTo(40)
                make.bottom.equalTo(view)
                make.height.equalTo(40)
            })
            return rotateBtn
        }()
        
        self.beginLabel = {
            let beginLabel = UILabel.init()
            beginLabel.text = "当前"
            beginLabel.textColor = UIColor.white
            beginLabel.textAlignment = .right
            view.addSubview(beginLabel)
            beginLabel.snp.makeConstraints({ (make) in
                make.left.equalTo(pauseBtn!.snp.right).offset(5)
                make.width.equalTo(40)
                make.bottom.equalTo(view)
                make.height.equalTo(40)
            })
            return beginLabel
        }()
        
        self.endLabel = {
            let endLabel = UILabel.init()
            endLabel.text = "结束"
            endLabel.textColor = UIColor.white
            view.addSubview(endLabel)
            endLabel.snp.makeConstraints({ (make) in
                make.right.equalTo(rotateBtn!.snp.left).offset(-5)
                make.width.equalTo(40)
                make.bottom.equalTo(view)
                make.height.equalTo(40)
            })
            return endLabel
        }()
        
        self.progressView = {
            let progress = UIProgressView.init()
            progress.setProgress(0, animated: true)
            progress.progressTintColor = UIColor.green
            view.addSubview(progress)
            progress.snp.makeConstraints({ (make) in
                make.left.equalTo(beginLabel!.snp.right).offset(5)
                make.right.equalTo(endLabel!.snp.left).offset(-5)
                make.bottom.equalTo(view).offset(-20)
                make.height.equalTo(2)
            })
            return progress
        }()
        
        self.slider = {
            let slider = UISlider.init()
            slider.setValue(0, animated: true)
            slider.maximumValue = 1.0
            view.addSubview(slider)
            slider.snp.makeConstraints({ (make) in
                make.left.equalTo(beginLabel!.snp.right).offset(5)
                make.right.equalTo(endLabel!.snp.left).offset(-5)
                make.bottom.equalTo(view)
                make.height.equalTo(40)
            })
            return slider
        }()
        
        
        self.photoBtn = {
            let photoBtn = UIButton.init()
            photoBtn.tag = 103
            photoBtn.setTitle("截图", for: .normal)
            view.addSubview(photoBtn)
            photoBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(view).offset(-5)
                make.bottom.equalTo(rotateBtn!.snp.top).offset(-5)
                make.width.equalTo(40)
                make.height.equalTo(40)
            })
            return photoBtn
        }()
        
        self.speedBtn = {
            let speedBtn = UIButton.init()
            speedBtn.tag = 104
            speedBtn.setTitle("倍速", for: .normal)
            speedBtn.setTitle("2.0", for: .selected)
            view.addSubview(speedBtn)
            speedBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(view).offset(-5)
                make.bottom.equalTo(photoBtn!.snp.top).offset(-5)
                make.height.equalTo(40)
                make.width.equalTo(40)
            })
            return speedBtn
        }()
        
        self.lockBtn = {
            let lockBtn = UIButton.init()
            lockBtn.tag = 105
            lockBtn.setTitle("锁屏", for: .normal)
            lockBtn.setTitle("已锁", for: UIControlState.selected)
            view.addSubview(lockBtn)
            lockBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(view).offset(-5)
                make.bottom.equalTo(speedBtn!.snp.top).offset(-5)
                make.height.equalTo(40)
                make.width.equalTo(40)
            })
            return lockBtn
        }()
    }
}










