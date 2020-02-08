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
    
    private let Screen_width = UIScreen.main.bounds.size.width
    private let Screen_height = UIScreen.main.bounds.size.height
    
    var videoView : VideoView?
    var tableView : UITableView?
    var avLayer : AVPlayerLayer?
    var photoImageView : UIImageView?
    
    var buttonClickBlock:((UIButton) -> ())?
    
    
    func initWithAVLayer(avPlayerlayer : AVPlayerLayer) {
        avLayer = AVPlayerLayer.init()
        self.avLayer = avPlayerlayer
        self.layer.addSublayer(avLayer!)
        
        //控件图层
        videoView = VideoView.init(frame: CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9 / 16))
        self.addSubview(videoView!)
        addButtonTarget()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //选择视频
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 60 + Screen_width * 9 / 8, width: Screen_width, height: Screen_height - 60 - Screen_width * 9 / 8), style: .plain)
        self.addSubview(tableView!)
        
        //截图
        photoImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 40 + Screen_width * 9 / 16, width: Screen_width, height: Screen_width * 9 / 16))
        photoImageView?.backgroundColor = UIColor.gray
        self.addSubview(photoImageView!)
    }
    
    //根据是否满屏，改变videoView的大小
    func changeScreen() {
        if videoView!.lockBtn!.isSelected {
            return
        }
        if videoView!.rotateBtn!.isSelected {
            avLayer?.frame = CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9/16)
            videoView?.frame = CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9/16)
            videoView!.rotateBtn!.isSelected = false
        }else {
            let currentFrame = UIScreen.main.bounds
            avLayer?.frame = currentFrame
            videoView?.frame = currentFrame
            videoView!.rotateBtn!.isSelected = true
        }
    }
    
    //按钮响应方法
    @objc func buttonClick(button : UIButton) {
        if self.buttonClickBlock != nil {
            self.buttonClickBlock!(button)
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
    
    func addButtonTarget() {
        if videoView != nil {
            videoView?.pauseBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.rotateBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.lockBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.photoBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.speedBtn?.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            videoView?.slider?.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VideoView: UIView {
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.pauseBtn = {
            let pauseBtn = UIButton.init()
            pauseBtn.tag = 101
            pauseBtn.setTitle("暂停", for: .normal)
            pauseBtn.setTitle("开始", for: .selected)
            self.addSubview(pauseBtn)
            pauseBtn.snp.makeConstraints({ (make) in
                make.left.equalTo(self).offset(5)
                make.width.equalTo(40)
                make.bottom.equalTo(self)
                make.height.equalTo(40)
            })
            return pauseBtn
        }()
        
        self.rotateBtn = {
            let rotateBtn = UIButton.init()
            rotateBtn.setTitle("旋转", for: .normal)
            rotateBtn.tag = 102
            self.addSubview(rotateBtn)
            rotateBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(self).offset(-5)
                make.width.equalTo(40)
                make.bottom.equalTo(self)
                make.height.equalTo(40)
            })
            return rotateBtn
        }()
        
        self.beginLabel = {
            let beginLabel = UILabel.init()
            beginLabel.text = "当前"
            beginLabel.textColor = UIColor.white
            beginLabel.textAlignment = .right
            self.addSubview(beginLabel)
            beginLabel.snp.makeConstraints({ (make) in
                make.left.equalTo(pauseBtn!.snp.right).offset(5)
                make.width.equalTo(40)
                make.bottom.equalTo(self)
                make.height.equalTo(40)
            })
            return beginLabel
        }()
        
        self.endLabel = {
            let endLabel = UILabel.init()
            endLabel.text = "结束"
            endLabel.textColor = UIColor.white
            self.addSubview(endLabel)
            endLabel.snp.makeConstraints({ (make) in
                make.right.equalTo(rotateBtn!.snp.left).offset(-5)
                make.width.equalTo(40)
                make.bottom.equalTo(self)
                make.height.equalTo(40)
            })
            return endLabel
        }()
        
        self.progressView = {
            let progress = UIProgressView.init()
            progress.setProgress(0, animated: true)
            progress.progressTintColor = UIColor.green
            self.addSubview(progress)
            progress.snp.makeConstraints({ (make) in
                make.left.equalTo(beginLabel!.snp.right).offset(5)
                make.right.equalTo(endLabel!.snp.left).offset(-5)
                make.bottom.equalTo(self).offset(-20)
                make.height.equalTo(2)
            })
            return progress
        }()
        
        self.slider = {
            let slider = UISlider.init()
            slider.setValue(0, animated: true)
            slider.maximumValue = 1.0
            self.addSubview(slider)
            slider.snp.makeConstraints({ (make) in
                make.left.equalTo(beginLabel!.snp.right).offset(5)
                make.right.equalTo(endLabel!.snp.left).offset(-5)
                make.bottom.equalTo(self)
                make.height.equalTo(40)
            })
            return slider
        }()
        
        self.photoBtn = {
            let photoBtn = UIButton.init()
            photoBtn.tag = 103
            photoBtn.setTitle("截图", for: .normal)
            self.addSubview(photoBtn)
            photoBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(self).offset(-5)
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
            self.addSubview(speedBtn)
            speedBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(self).offset(-5)
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
            self.addSubview(lockBtn)
            lockBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(self).offset(-5)
                make.bottom.equalTo(speedBtn!.snp.top).offset(-5)
                make.height.equalTo(40)
                make.width.equalTo(40)
            })
            return lockBtn
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
