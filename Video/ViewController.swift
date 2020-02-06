//
//  ViewController.swift
//  Video
//
//  Created by 康思婉 on 2020/2/4.
//  Copyright © 2020年 康思婉. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var view1 : ViView?
    var model1 : ViModel?
    var viewModel : ViViewModel?
//    var avPlayerLayer : 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view1 = ViView.init()
        self.view.addSubview(view1!)
        view1?.snp.makeConstraints({ (make) in
            make.top.bottom.left.right.equalTo(self.view)
        })
        view1?.tableView?.dataSource = self
        view1?.tableView?.delegate = self
        model1 = view1!.viewModel!.model
        viewModel = view1!.viewModel!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model1!.linkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : ViTableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as? ViTableViewCell
        if cell == nil {
            cell = ViTableViewCell.init(style: .subtitle, reuseIdentifier: "cellId")
        }
        cell?.textLabel?.text = model1?.linkArray[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view1?.imageGenerator = view1?.viewModel?.changePlayerWithPath(index: indexPath)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

