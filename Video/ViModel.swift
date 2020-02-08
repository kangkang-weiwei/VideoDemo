//
//  ViModel.swift
//  Video
//
//  Created by 康思婉 on 2020/2/4.
//  Copyright © 2020年 康思婉. All rights reserved.
//

import UIKit

class ViModel: NSObject {
    
    private var linkArray = ["/Users/kangsiwan/Desktop/快速的/Video/QQ空间视频.mp4",
                     "/Users/kangsiwan/Desktop/快速的/Video/catVideo.mp4",
                     "https://v-cdn.zjol.com.cn/280443.mp4",
                     "https://www.w3school.com.cn/example/html5/mov_bbb.mp4",
                     "https://v-cdn.zjol.com.cn/276982.mp4",
                     "https://v-cdn.zjol.com.cn/276984.mp4",
                     "https://v-cdn.zjol.com.cn/276996.mp4",
                     ]
    
//    var nameLink = ["博君一肖 萌萌猫 iPhone11 动画片 杭州建房 梅城宣传 我是中国人"]
    
    func getLinkArray() -> NSArray {
        let a = ("/Users/kangsiwan/Desktop/快速的/Video/QQ空间视频.mp4", "博君一肖")
        let b = ("/Users/kangsiwan/Desktop/快速的/Video/catVideo.mp4", "萌萌猫")
        let c = ("https://v-cdn.zjol.com.cn/280443.mp4", "iPhone11")
        let d = ("https://www.w3school.com.cn/example/html5/mov_bbb.mp4", "动画片")
        let e = ("https://v-cdn.zjol.com.cn/276982.mp4", "杭州建房")
        let f = ("https://v-cdn.zjol.com.cn/276984.mp4", "梅城宣传")
        let h = ("https://v-cdn.zjol.com.cn/276996.mp4", "我是中国人")
        
        let array : NSArray = [a, b, c, d, e, f, h]
        
        return array
    }
    
    
    func getUrlWithIndexPath(index : IndexPath) -> URL {
        let str = linkArray[index.row]
        let subStr : String = String(str.prefix(4))
        let url : URL
        
        if subStr.compare("http").rawValue == 0 {
            url = URL(string: str)!
        }else {
            url = URL(fileURLWithPath: str)
        }
        return url
    }
}
