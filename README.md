# VideoDemo
## 横竖屏配置
- [参考博客链接](https://www.jianshu.com/p/1993144ea35e)
- [参考博客链接](https://www.jianshu.com/p/fb7eac7ead11)
### 方向枚举：UIInterfaceOrientation,UIInterfaceOrientationMask,UIDeviceOrientation
1. UIInterfaceOrientation（视图方向） & UIDeviceOrientation（设备方向）
```
typedef NS_ENUM(NSInteger, UIInterfaceOrientation) {
    UIInterfaceOrientationUnknown            = UIDeviceOrientationUnknown,              
    //未知
    UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,             
    //竖直
    UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,   
    //上下翻转
    UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,       
    //设备向右转（home键在左侧），页面向左转，保证呈现正确的画面
    UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft         
    //同上
    UIInterfaceOrientationFaceUp                                                        
    //屏幕朝上
    UIInterfaceOrientationFaceDown                                                      
    //屏幕朝下
}
```
2. UIInterfaceOrientationMask
```
typedef NS_OPTIONS(NSUInteger, UIInterfaceOrientationMask) {
    UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
}
```
3. 
### 监听设备
1. 获取当前屏幕方向的方法:
- 通过控制器的interfaceOrientation只读属性获取,iOS8后过期

```
controller.interfaceOrientation //获取特定controller的方向
```

- 通过状态栏的方向间接获取,UIApplication的只读属性statusBarOrientation,iOS9后过期
```
UIApplication.shared.statusBarOrientation //获取状态条的方向
```
- 通过UIDevice只读属性orientation获取.需主动调用beginGeneratingDeviceOrientationNotifications开启通知
```
//获取设备方向
UIDevice.current.beginGeneratingDeviceOrientationNotifications()
NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientation), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    
@objc func onDeviceOrientation() {
    let orientation = UIDevice.current.orientation
    switch orientation {
        case .portraitUpsideDown:
            print("监听到了UpsideDown")
        case .landscapeLeft:
            print("监听到了Left")
        case .landscapeRight:
            print("监听到了Right")
        case .portrait:
            print("监听到了portrait")
        default:
    }
}
```
    
- 通过根控制器的view宽高推导获取,当高>宽为竖屏否则为横屏

```
//当发生转屏事件"改变"时，系统的回调方法是：
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    if size.width > size.height {
        print("横屏")
    }else {
        print("竖屏")
    }
}
```


### 屏幕旋转
1. 物理设备方向的改变，引起视图方向发生变化，用户没有开启横竖屏锁定

配置方法
- Xcode
> Xcode->工程->General->Deployment Info->Device Orientation 在其中勾选需要的方向（这里不是设备方向，而是视图方向）

- 代码

```
//这里的allowRoration,currentOrientation是单独定义的，用于锁屏时设备旋转，视图不旋转的情况
/*
调用时如下：
let appde = UIApplication.shared.delegate as! AppDelegate
appde.allowRotation = true
appde.currentOrientation = .portrait
*/
var allowRotation = Bool()
var currentOrientation = UIInterfaceOrientationMask()
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    if allowRotation {
        return .allButUpsideDown
    }
    return currentOrientation
}
```

- 声明
> 在声明代码方式后会覆盖Xcode方式

- 在Controller中控制方向

```
// 开启自动转屏（是否支持转屏）
- (BOOL)shouldAutorotate {
    return YES;
}
// 在支持转屏的前提下，返回设备支持方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
//以上代码，放在决定视图方向的controller中
/*
通过present方式推入的controller，最近一次present操作对应的controller决定视图方向
不通过present方式推入的controller，rootViewController支持的方向决定视图方向
*/


//此方法只对present方式进入界面的viewController有效果
// 默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait; 
}
```
- 关于优先级
> general == appDelegate >> rootViewController >> nomalViewController   
也就是rootViewController没有的视图权限nomalViewController也不会有

2. 用户开启横竖屏锁定，此时强制旋转

例如demo中视频横置满屏状态，以及大图预览

```
+ (void) interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
/*
调用时：
let orientation = UIDevice.current.orientation
switch orientation {
    case .portraitUpsideDown:   //上下翻转
        DeviceTool.interfaceOrientation(.portrait)
        break
    ...
}
*/
```

## 关于生成缩略图
- [参考博客](https://my.oschina.net/starmier/blog/203774)
- [参考博客](https://www.jianshu.com/p/e9e3907f4142)
- [参考博客](https://www.jianshu.com/p/14f0240d8bd8)
- [参考博客](https://www.jianshu.com/p/943a1f03ec00)
- [参考博客](https://www.jianshu.com/p/aa64fd3dd621)

1. 给定图片按照比例进行缩放

```
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize {
    UIImage *newImage;
    if (image == nil) {
        return image;
    }
    
    CGRect rect;
    if (asize.width/asize.height > oldSize.width/oldSize.height) {
        //进行比例缩放rect
    }else {
        //rect
    }
    
    //begin to creat newImage
    //必备步骤一：
    UIGraphicsBeginImageContext(asize);
    CGContextRef context = UIGraphicsGetCurrentContext();//获取上下文
    CGContextSetFillColorWithColor(context, [[UIColor clearColor]CGColor]);//填充颜色
    UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//矩形填充
    //必备步骤二：进行绘图
    [image drawInRect:rect];
    //必备步骤三：获取绘制的新图
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    //必备步骤四：清空图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}
```

2. AVAssetImageGenerator

```

let url = self.currentUrl   //当前视频的url
let asset = AVAsset(url: url!)  //类型：AVAsset
let imageGenerator = AVAssetImageGenerator(asset: asset)    //类型：AVAssetImageGenerator

//截取一张图片
let currentTime = avLayer?.player?.currentTime()    //获取当前视频时间
let imageRef = try! imageGenerator?.copyCGImage(at: currentTime!, actualTime: nil)    //
photoImageView?.image = UIImage(cgImage: imageRef!)

//截取一组图片
let array : NSMutableArray = NSMutableArray.init()
imageGenerator?.generateCGImagesAsynchronously(forTimes: array as! [NSValue], completionHandler: { (requestTime, image, actualTime, AVAssetImageGeneratorResult, error) in
    array.addObjects(from: image as! [Any])
//  let newImage = UIImage(cgImage: image!)
    print(array)
})


/*
//保存到相册
UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil);
*/
```

3. 截取图片的一部分
```
-(UIImage *)getPartOfImage:(UIImage *)img rect:(CGRect)partRect {
    CGImageRef imageRef = img.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, partRect);
    UIImage *retImg = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    return retImg;
}
```
4. 截取界面

```
- (UIImage *)convertViewToImage:(UIView *)view {
    CGSize size = CGSizeMake(view.width, view.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 2);    //创建上下文
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];  
    /*
    下面的只能截取UIKit中的view（例如在WKWebView中就不能正常截取），上面为iOS7新添加的方法
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    但依然建议在不含有WKWebView的界面中，使用renderInContext
    含有WKWebView的界面中使用drawViewHierarchyInRect
    */
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();   //根据上下文获取新图
    UIGraphicsEndImageContext();
    return image;
}
/*
递归判断是否包含WKWebView
public func swContainsWKWebView() -> Bool {
    if self.isKindOfClass(WKWebView) {
        return true
    }
    for subView in self.subviews {
        if (subView.swContainsWKWebView()) {
            return true
        }
    }
    return false
}
*/
```
5. 

## 对于MVVM框架的理解
- [参考链接](https://www.jianshu.com/p/caaa173071f3)
- [参考链接](https://www.jianshu.com/p/f1d0f7f01130)
- [参考链接](https://www.jianshu.com/p/b7421a8aec91)
- [参考链接](https://www.jianshu.com/p/db8400e1d40e)
```
graph TD
A[View & ViewController]-->|User Action| B[ViewModel]
B -->|Updata| A
B -->|Update| C[Model]
C -->|Notify| B
```

> 解决massive View Controller问题的办法就是将Controller中的==展示逻辑==抽取出来，放在viewModel中

进一步使UI和逻辑的分离，
1. View：视图展示，由controller控制
2. Model：请求的原始数据
3. ViewModel：放置用户输入验证逻辑，视图显示逻辑，发起网络请求，数据缓存
> viewModel从必要的资源（数据库，网络请求等）获取原始数据，根据视图的展示逻辑，并处理成view（controller）的展示数据。它（通过属性）暴露给视图控制器需要知道的仅关于显示视图工作的信息（不回暴露data-model对象）
4. ViewController：负责事件绑定以及UI的展示

> viewModel存在的目的在于抽离controller中的展示业务逻辑，而不是替代viewController。既不负责视图操作逻辑，viewModel中不应该存在===任何==View对象，更不应该存在Push/Present等视图跳转逻辑


    注意事项：
    1. view引用viewModel。不要在viewModel中引用UIKit，任何视图本身的引用不应该放在viewModel中
    2. viewModel引用model，反过来不可以

    建议：
    1. viewController尽量不涉及业务逻辑，让viewModel去做
    2. viewController只是中间人，接收view的事件，调用viewModel的方法，响应viewModel的变化
    3. viewModel之间可以有依赖
    4. viewModel尽量避免过于臃肿，否则重蹈覆辙ViewController 

> 优势要发挥
    
    1. 低耦合：view独立于model的变化和修改，一个viewModel可以绑定到不同的view上
    2. 可重用：将一些视图逻辑放在一个viewModel中，让很多view重用这段逻辑
    3. 独立开发：开发者可以专注于业务逻辑和数据开发viewModel，设计人员专注于页面设计
    4. 可测试：可以针对viewModel进行测试

重构！！
1. addTarget 放在controller中响应
2. 时时监听，应该谁做？viewModel，再让controller响应变化，改变view
3. 


## AVplayer应用层
- 必备方法，实用监听
1. url->playerItem->player->playerLayer

```
import AVFoundation

func getPlayerWithUrl(url : URL) -> AVPlayerLayer {
    let playerItem = AVPlayerItem(url: url)
    let player = AVPlayer.init(playerItem: playerItem)
    let avLayer = AVPlayerLayer(player: player)
    avLayer?.videoGravity = .resizeAspect   //设置填充模式
    avLayer?.frame = CGRect.init(x: 0, y: 20, width: Screen_width, height: Screen_width * 9/16)  //设置Layer的大小
        
    playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)    //添加监听
    return avLayer!
}
```

2. status，loadTimeRange
```
override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    var playerItem : AVPlayerItem?
    playerItem = object as? AVPlayerItem
        
    if keyPath == "status" {
        switch playerItem?.status{
        case .readyToPlay?: //准备完成
            player?.play()
        case .none: //位置情况
        case .some(.unknown):   //未知错误
        case .some(.failed):    //视频加载失败
        }
    }else if keyPath == "loadedTimeRanges" {
        //可以获取视频加载情况
    }
}
```
3. rate
```
//视频速度的设置
play.rate = 2.0 //2倍速
```

4. player.addPeriodicTimeObserver
```
//时时监听
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
            //缓冲进度
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
```

5. 

## CMTime
1. CMTime
- 创建

```
//参数1:时长（视频的帧数）。参数2:每秒的帧数
CMTime time1 = CMTimeMake(1800, 600);   //CMTimeMake(int64_t value, int32_t timescale)
CMTimeShow(time1);  //1800/600=3.000

//参数1:时长（视频的帧数）。参数2:建议每秒的帧数
CMTime time2 = CMTimeMakeWithSeconds(5, 1) //CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimescale)
CMTimeShow(time2);  //{5/1 = 5.000}

//
CMTime time3 = CMTimeMakeWithEpoch()   //CMTimeMakeWithEpoch(int64_t value, int32_t timescale, int64_t epoch)
CMTimeShow(time3);

NSDictionary *time = @{
    (id)kCMTimeValueKey: @2,
    (id)kCMTimeScaleKey: @1,
    (id)kCMTimeFlagsKey: @1,
    (id)kCMTimeEpochKey: @0,
};
CMTime time4 = CMTimeMakeFromDictionary((__bridge CFDictionaryRef)time)  //CMTimeMakeFromDictionary(CFDictionaryRef  _Nullable dict)
CMTimeShow(time4);
```
- 运算

```
CMTime time5 = CMTimeAdd(t1, t2)
CMTime time6 = CMTimeSubtract(t1, t2)
CMTime time7 = CMTimeMultiply(t1, t2)
```

- 比较

```
CMTimeCompare(t1, t2)
//t1 < t2 => -1

//CMTIME_COMPARE_INLINE(time1, comparator, time2)
CMTIME_COMPARE_INLINE(t1, >, t2)
```

- 转换
```
转换为秒
Float64 CMTimeGetSeconds( CMTime time)

CMTime t1 = CMTimeMake(3001, 100);
NSLog(@"second : %f",CMTimeGetSeconds(t1));//second : 30.010000


转换为NSValue
CMTime structTime = CMTimeMake(1, 3);
NSValue *valueTime = [NSValue valueWithCMTime:structTime];//转换为NSValue
CMTime time = [valueTime CMTimeValue];//转换为CMTime


转换为NSDictionary
CMTime structTime = CMTimeMake(1, 3);
NSDictionary *timeDict = CFBridgingRelease(CMTimeCopyAsDictionary(structTime, NULL));//转换为Dic对象
structTime = CMTimeMakeFromDictionary((__bridge CFDictionaryRef)(timeDict));//转换为CMTime

```

2. CMTimeRange
- 创建
```
CMTime time = CMTimeMake(5, 1);
CMTimeRange range = CMTimeRangeMake(time, time);    //5秒开始持续5秒
CMTime time2 = CMTimeMake(12, 1);
CMTimeRange range2 = CMTimeRangeFromTimeToTime(time, time2); //5秒开始12秒结束
```

- 运算
```
CMTimeRange range3 = CMTimeRangeGetIntersection(range, range2); //取交集
CMTimeRangeShow(range3);    //{{5/1 = 5.000}, {5/1 = 5.000}}，结果：5秒开始持续5秒

CMTimeRange range4 = CMTimeRangeGetUnion(range, range2);    //取并集
CMTimeRangeShow(range4);    //{{5/1 = 5.000}, {7/1 = 7.000}}，结果：5秒开始持续7秒
```

- 转换
```
转换为NSValue
NSValue *valueRang2 = [NSValue valueWithCMTimeRange:range4];//转换为NSValue对象
range3 = [valueRang2 CMTimeRangeValue];//转换为CMTimeRange


转换为NSDictionary
NSDictionary *timeRangeDict = CFBridgingRelease(CMTimeRangeCopyAsDictionary(structTimeRange, NULL));
```

## 关于AVplayer别的一些
- [AVAsset](https://www.jianshu.com/p/d22d4e0a8593)

![image](https://upload-images.jianshu.io/upload_images/1244124-7d687439ec929a73.png?imageMogr2/auto-orient/strip|imageView2/2/w/1054)


## 手势、隐藏videoView
- 还没写

## bug
- 不能将本地视频添加进入项目，从而不能找到绝对路径，此时项目中只有网络视频
