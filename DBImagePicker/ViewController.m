//
//  ViewController.m
//  DBImagePicker
//
//  Created by kong yan on 2018/6/12.
//  Copyright © 2018年 dbsoft. All rights reserved.
//

#import "ViewController.h"
#import "HXPhotoPicker.h"
#import "AFNetworking.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSDate+HXExtension.h"
#import "Reachability.h"
#import "DBPhotoPreviewViewController.h"
@interface ViewController ()<HXAlbumListViewControllerDelegate>
@property (strong, nonatomic) HXDatePhotoToolManager *toolManager;
@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) UIColor *bottomViewBgColor;
@property (strong,nonatomic) Reachability *hostReachability;
@property (strong,nonatomic) Reachability *routerReachability;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [loading startAnimating];
//    [self.view addSubview:loading];
    //{"currentIndex":2,"photoURLs":["http://pic6.nipic.com/20100312/1295091_091105821505_2.jpg","http://img1.imgtn.bdimg.com/it/u=2585068979,3076850682&fm=27&gp=0.jpg","http://pic.58pic.com/58pic/13/16/18/62M58PICUB3_1024.jpg","http://img.mp.sohu.com/upload/20170720/72bb4e3fff2d4387830bdc3335655556_th.png"]}
    NSString *jsonString = @"{\"currentIndex\":2,\"photoURLs\":[\"http://pic6.nipic.com/20100312/1295091_091105821505_2.jpg\",\"http://img1.imgtn.bdimg.com/it/u=2585068979,3076850682&fm=27&gp=0.jpg\",\"http://pic.58pic.com/58pic/13/16/18/62M58PICUB3_1024.jpg\",\"http://img.mp.sohu.com/upload/20170720/72bb4e3fff2d4387830bdc3335655556_th.png\"]}";
    NSLog(@"jsonStr:%@",jsonString);
   
    if ([jsonString isKindOfClass:[NSString class]]) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
       NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        int index = (int)retDict[@"currentIndex"];
        NSLog(@"currentIndex====%@",retDict[@"currentIndex"]);
        NSArray *urls = retDict[@"photoURLs"];
        NSLog(@"photoURLs====%@",urls[0]);
    }
  
}

/// 取消通知
- (void)dealloc {
    NSLog(@"viewcontroller-dealloc");
}


//显示图片
- (IBAction)showPhoto:(id)sender {
    //不能加载图片http://img1.imgtn.bdimg.com/it/u=2585068979,3076850682&fm=27&gp=0.jpg
    NSArray *photosURL = @[@"http://pic6.nipic.com/20100312/1295091_091105821505_2.jpg",@"http://img1.imgtn.bdimg.com/it/u=2585068979,3076850682&fm=27&gp=0.jpg",@"http://pic.58pic.com/58pic/13/16/18/62M58PICUB3_1024.jpg",@"http://img.mp.sohu.com/upload/20170720/72bb4e3fff2d4387830bdc3335655556_th.png"];
    DBPhotoPreviewViewController *ppvc = [[DBPhotoPreviewViewController alloc]init];
    ppvc.photosURL = photosURL;
    ppvc.currentPhotoIndex = arc4random()%4;
//    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:ppvc] animated:YES completion:nil];
    [self presentViewController:ppvc animated:false completion:nil];
//    [self.navigationController pushViewController:ppvc animated:true];

}

//点击上传按钮
- (IBAction)uploadBtn:(id)sender {
    
    HXAlbumListViewController *vc = [[HXAlbumListViewController alloc] init];
    vc.UploadUrl = @"http://wx.dbazure.com.cn:8210/upload.do";
    vc.MsgBody = @"msgbody";
    vc.callBack = @"callback";
    vc.delegate = self;
    vc.manager = self.manager;
    
    //获取通知中心单例对象
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self selector:@selector(takeAndPickPhotosNotice:) name:@"TakeAndPickPhotos" object:nil];
    
    [self presentViewController:[[HXCustomNavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

-(void)takeAndPickPhotosNotice:(NSNotification*)sender{
    NSLog(@"%@--++++--%@",sender.userInfo[@"callback"],sender.userInfo[@"ary"]);
    if([sender.userInfo[@"ary"] isKindOfClass:[NSArray class]]){
        NSLog(@"shuzu");
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sender.userInfo[@"ary"] options:kNilOptions error:nil];
    NSString *JsonPic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    [self.myWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');",sender.userInfo[@"callback"],JsonPic]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (HXDatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[HXDatePhotoToolManager alloc] init];
    }
    return _toolManager;
}

// 懒加载 照片管理类
- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.maxNum = 9;
//        _manager.configuration.photoMaxNum = 1;
//        _manager.configuration.videoMaxNum = 0;
        //如果设置头像 可以设置此选项
//        _manager.configuration.singleSelected = true;
        _manager.configuration.reverseDate = true;
        
    }
    return _manager;
}

//上传图片
- (void)uploadPhotos:(NSArray<HXPhotoModel*>*)photos{
    NSLog(@"上传图片");
    
    int __block sucCount = 0;
    
    for(int i=0;i<photos.count;i++){
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html",nil];
        
        NSMutableDictionary *parDic = [[NSMutableDictionary alloc] init];
        HXPhotoModel *model = photos[i];
        NSData *imageData = UIImageJPEGRepresentation(model.thumbPhoto,1.0);
        NSLog(@"%@",imageData);
        //上传地址：http://wx.dbazure.com.cn:8210/upload.do
        
        [parDic setObject:@"tupian" forKey:@"Display_Name"];
        [parDic setObject:model.fileURL forKey:@"filepath"];
        [parDic setObject:@0 forKey:@"_ID"];
        [manager POST:@"http://wx.dbazure.com.cn:8210/upload.do" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            // 上传文件
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat            = @"yyyyMMddHHmmssSSS";
            NSString *str                         = [formatter stringFromDate:[NSDate date]];
            NSString *fileName               = [NSString stringWithFormat:@"dbsoft_%@.jpg", str];
            
            
            [formData appendPartWithFileData:imageData name:@"ImageFile" fileName:fileName mimeType:@"image/jpeg"];
            
            NSLog(@"文件名：%@",fileName);
        } progress:^(NSProgress * _Nonnull uploadProgress) {//上传进度
            
            NSLog(@"上传比例：%f",uploadProgress.fractionCompleted);
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {//上传成功
            
            NSString *test =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            sucCount++;
            NSLog(@"上传成功:%@",test);
            
            
                NSLog(@"上传成功的图片数量：%d",sucCount);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {//上传失败
            NSLog(@"上传失败");
        }];
        
    }
    
}


//实现相册代理方法
//- (void)albumListViewController:(HXAlbumListViewController *)albumListViewController didDoneAllList:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photoList videos:(NSArray<HXPhotoModel *> *)videoList original:(BOOL)original
//{
//    NSLog(@"%@",albumListViewController.parentViewController);
//
//    NSLog(@"隐藏当前的图片选择控制器");
//
//    [self.toolManager writeSelectModelListToTempPathWithList:allList requestType:HXDatePhotoToolManagerRequestTypeHD success:^(NSArray<NSURL *> *allURL, NSArray<NSURL *> *photoURL, NSArray<NSURL *> *videoURL) {
//        NSLog(@"写入成功:%@",allURL);
//        NSLog(@"写入成功photoURL:%@",photoURL);
//        NSLog(@"写入成功videoURL:%@",videoURL);
//
//    } failed:^{
//        NSLog(@"写入失败");
//    }];
//
//    for (HXPhotoModel *model in photoList) {
//        //照片在相机里路径
//        NSLog(@"照片路径%@",model.fileURL);
//        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:model.fileURL]];
//        NSLog(@"%@",image);
//        NSLog(@"创建日期：%@",model.creationDate);
//    }
//
//}
@end
