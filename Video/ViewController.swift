//
//  ViewController.swift
//  Video
//
//  Created by 康思婉 on 2020/2/4.
//  Copyright © 2020年 康思婉. All rights reserved.
//
//  还没写的：
//  手势添加（双击暂停，左/右侧滑快进/倒退，上/下华东调节声音大小）
//  隐藏videoView（定时器，定时5秒之后消失，单击也隐藏）
//  试试缓存，边播放变缓存


import UIKit
import SnapKit

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var view1 : ViView?
    var model1 : ViModel?
    var viewModel : ViViewModel?
    var linkArray : NSArray?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view1 = ViView.init()
        self.view.addSubview(view1!)
        view1?.snp.makeConstraints({ (make) in
            make.top.bottom.left.right.equalTo(self.view)
        })
        view1?.tableView?.dataSource = self
        view1?.tableView?.delegate = self
        
        viewModel = ViViewModel()
        model1 = viewModel?.model
        linkArray = model1?.getLinkArray()
        let index : IndexPath = IndexPath.init(row: 0, section: 0)
        view1?.initWithAVLayer(avPlayerlayer: viewModel!.getPlayerWithPath(index: index))
        view1?.buttonClickBlock = { button in
            if button.tag == 101 {    //暂停按钮
                self.viewModel?.playAndPause(button: button)
                button.isSelected = !button.isSelected
            }else if button.tag == 102 {    //旋转按钮
                self.viewModel?.rotation(button: button, lockBtnIsSelector: self.view1!.videoView!.lockBtn!.isSelected)
            }else if button.tag == 103 {    //截图按钮
                self.view1?.photoImageView?.image = self.viewModel?.screenShot(button: button)
            }else if button.tag == 104 {    //倍速按钮
                self.viewModel?.speed(button: button)
            }else if button.tag == 105 {    //锁屏按钮
                self.viewModel?.lock(button: button)
            }
        }
        
        viewModel?.periodWithValue = { beginLabelText, endLabelText, sliderValue, progressValue in
            self.view1?.videoView?.beginLabel?.text = beginLabelText
            self.view1?.videoView?.endLabel?.text = endLabelText
            self.view1?.videoView?.slider?.setValue(sliderValue, animated: true)
            self.view1?.videoView?.progressView?.setProgress(progressValue, animated: true)
        }
        self.listeningRotating()
    }
    
    func listeningRotating() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    //监听屏幕旋转响应的方法
    @objc func onDeviceOrientation() {
        let orientation = UIDevice.current.orientation
        if orientation == .portrait || orientation == .landscapeLeft || orientation == .landscapeRight || orientation == .portraitUpsideDown {
            view1?.changeScreen()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : ViTableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as? ViTableViewCell
        if cell == nil {
            cell = ViTableViewCell.init(style: .subtitle, reuseIdentifier: "cellId")
        }
        let yuanzu : (String, String) = linkArray![indexPath.row] as! (String, String)
        cell?.textLabel?.text = yuanzu.1
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.changePlayerWithPath(index: indexPath)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

