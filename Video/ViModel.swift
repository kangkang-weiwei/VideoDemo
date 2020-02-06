//
//  ViModel.swift
//  Video
//
//  Created by 康思婉 on 2020/2/4.
//  Copyright © 2020年 康思婉. All rights reserved.
//

import UIKit

class ViModel: NSObject {
    var linkArray = ["/Users/kangsiwan/Downloads/QQ空间视频.mp4",
                     "https://v-cdn.zjol.com.cn/280443.mp4",
                     "https://www.w3school.com.cn/example/html5/mov_bbb.mp4",
                     "/Users/kangsiwan/Downloads/catVideo.mp4",
                     "https://v-cdn.zjol.com.cn/276982.mp4",
                     "https://v-cdn.zjol.com.cn/276984.mp4",
                     "https://v-cdn.zjol.com.cn/276996.mp4"]
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
