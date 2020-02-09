//
//  ViModel.swift
//  Video
//
//  Created by 康思婉 on 2020/2/4.
//  Copyright © 2020年 康思婉. All rights reserved.
//

import UIKit

class ViModel: NSObject {
    
    private var linkArray : NSMutableArray?
    
    func getLinkArray() -> NSMutableArray {
//        let a = ("/Users/kangsiwan/Desktop/快速的/Video/QQ空间视频1.mp4", "博君一肖")
//        let b = ("/Users/kangsiwan/Desktop/快速的/Video/catVideo.mp4", "萌萌猫")
        let c = ("https://v-cdn.zjol.com.cn/280443.mp4", "iPhone11")
        let d = ("https://www.w3school.com.cn/example/html5/mov_bbb.mp4", "动画片")
        let e = ("https://v-cdn.zjol.com.cn/276982.mp4", "杭州建房")
        let f = ("https://v-cdn.zjol.com.cn/276984.mp4", "梅城宣传")
        let h = ("https://v-cdn.zjol.com.cn/276996.mp4", "我是中国人")
        
        linkArray = [c, d, e, f, h]
        
        return linkArray!
    }
    
    
    func getUrlWithIndexPath(index : IndexPath) -> URL {
        let str : (String, String) = linkArray![index.row] as! (String, String)
        let subStr : String = String(str.0.prefix(4))
        let url : URL
        
        if subStr.compare("http").rawValue == 0 {   //网络视频
            url = URL(string: str.0)!
        }else {
            url = URL(fileURLWithPath: str.0)
        }
        return url
    }
}
