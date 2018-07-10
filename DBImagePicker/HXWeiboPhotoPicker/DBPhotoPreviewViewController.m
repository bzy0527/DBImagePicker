//
//  DBPhotoPreviewViewController.m
//  DBImagePicker
//
//  Created by kong yan on 2018/6/25.
//  Copyright © 2018年 dbsoft. All rights reserved.
//

#import "DBPhotoPreviewViewController.h"
#import "UIView+HXExtension.h"
#import "HXPhotoDefine.h"
#import "DBPhotoPreviewViewCell.h"
#import "DBPhotoPreviewInteractiveTransition.h"

@interface DBPhotoPreviewViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *imgV;
@property (assign,nonatomic) BOOL panFlag;
@property (strong, nonatomic) NSArray *photos;

@property(nonatomic,assign)BOOL subviewsHidden;

@property (strong, nonatomic) DBPhotoPreviewInteractiveTransition *interactiveTransition;

@property (nonatomic, assign) CGFloat beginX;
@property (nonatomic, assign) CGFloat beginY;
@property (nonatomic, assign) CGPoint transitionImgViewCenter;
@property (nonatomic,weak) NSIndexPath *willDisplayCellIndexPath;
@property (nonatomic,weak) NSIndexPath *endDisplayCellIndexPath;
@property (nonatomic,weak) NSIndexPath *currentDisplayCellIndexPath;

@property (nonatomic,assign) NSInteger currentIndex;

@end

@implementation DBPhotoPreviewViewController

-(instancetype)init{
    self = [super init];
    if(self){
        //设置modal的方式，这样背后的控制器的view不会消失
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"======currentPhotoIndex:%d",self.currentPhotoIndex);
    self.subviewsHidden = NO;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    //测试用本地图片
    self.photos = [NSArray arrayWithObjects:[UIImage imageNamed:@"mojave_dynamic_1.jpeg"],[UIImage imageNamed:@"mojave_dynamic_2.jpeg"],[UIImage imageNamed:@"mojave_dynamic_3.jpeg"],[UIImage imageNamed:@"mojave_dynamic_4.jpeg"],[UIImage imageNamed:@"mojave_dynamic_5.jpeg"],[UIImage imageNamed:@"mojave_dynamic_6.jpeg"],[UIImage imageNamed:@"mojave_dynamic_7.jpeg"],[UIImage imageNamed:@"mojave_dynamic_8.jpeg"],[UIImage imageNamed:@"mojave_dynamic_9.jpeg"], nil];
    [self setupUI];
    
    
}
//UI
-(void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"图片预览";
    [self.view addSubview:self.collectionView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self changeSubviewFrame];
    
    [self.collectionView layoutIfNeeded];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:false];
}

-(void)changeSubviewFrame{
    CGFloat bottomMargin = kBottomMargin;
    //    CGFloat leftMargin = 0;
    //    CGFloat rightMargin = 0;
    CGFloat width = self.view.hx_w;
    CGFloat itemMargin = 20;
//    if (kDevice_Is_iPhoneX && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
//        bottomMargin = 21;
//        //        leftMargin = 35;
//        //        rightMargin = 35;
//        //        width = self.view.hx_w - 70;
//    }
    self.flowLayout.itemSize = CGSizeMake(width, self.view.hx_h - kTopMargin - bottomMargin);
    self.flowLayout.minimumLineSpacing = itemMargin;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
}

-(void)setCurrentPhotoIndex:(NSInteger)currentPhotoIndex{
    _currentPhotoIndex = currentPhotoIndex;
    if (currentPhotoIndex>=self.photosURL.count) {
        self.currentIndex = self.photosURL.count-1;
    }else if (currentPhotoIndex < 0){
        self.currentIndex = 0;
    }else{
        self.currentIndex = currentPhotoIndex;
    }
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //1.
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //初始化手势过渡的代理
//        self.interactiveTransition = [[DBPhotoPreviewInteractiveTransition alloc] init];
//        //给当前控制器的视图添加手势
//        [self.interactiveTransition addPanGestureForViewController:self];
//    });
    
    
    
    //2.添加拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecognizeDidUpdate:)];
    [self.view addGestureRecognizer:panGesture];
}


//拖动手势处理
- (void)gestureRecognizeDidUpdate:(UIPanGestureRecognizer *)gestureRecognizer {
    
    CGFloat scale = 0;
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGFloat transitionY = translation.y;

    
    //用于判断向上(<0) 还是向下拖动(>0)
    scale = transitionY / ((gestureRecognizer.view.frame.size.height - 50) / 2);
    if (scale > 1.f) {
        scale = 1.f;
    }
    DBPhotoPreviewViewCell *cell = (DBPhotoPreviewViewCell*)self.collectionView.visibleCells.firstObject;
    
    
    //获取cell上的imageview
    UIScrollView *scrollV = cell.contentView.subviews[0];
    UIImageView *imgV = scrollV.subviews[0];
    self.imgV = imgV;
//    NSLog(@"缩放比例：%f",scale);
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"开始拖拽时scale:%f",scale);
            if (scale < 0) {
                [gestureRecognizer cancelsTouchesInView];
//                gestureRecognizer.cancelsTouchesInView = false;
//                [self.view removeGestureRecognizer:gestureRecognizer];
                return;
            }
            self.panFlag = true;
            self.transitionImgViewCenter = imgV.center;
            self.beginX = [gestureRecognizer locationInView:gestureRecognizer.view].x;
            self.beginY = [gestureRecognizer locationInView:gestureRecognizer.view].y;
//            self.interation = YES;
//            [self.navigationController popViewControllerAnimated:true];
//            [self dismissViewControllerAnimated:NO completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
        if(self.panFlag){
            CGFloat moveX = [gestureRecognizer locationInView:gestureRecognizer.view].x;
            CGFloat moveY = [gestureRecognizer locationInView:gestureRecognizer.view].y;
            if (scale < 0.f) {
                scale = 0.f;
            }
            
//            NSLog(@"centerX:%f,centerY:%f",self.transitionImgViewCenter.x,self.transitionImgViewCenter.y);
//            imgV.center = CGPointMake(imgV.center.x + (moveX-self.beginX), imgV.center.y + (moveY-self.beginY));
          
            imgV.center = CGPointMake(self.transitionImgViewCenter.x+translation.x, self.transitionImgViewCenter.y+translation.y);
            CGFloat imageViewScale = 1 - scale * 0.5;
            if (imageViewScale < 0.4) {
                imageViewScale = 0.4;
            }
            
            [self updateInterPercent:1 - scale * scale];
            imgV.transform = CGAffineTransformMakeScale(imageViewScale, imageViewScale);
            self.beginX = moveX;
            self.beginY = moveY;
        }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"UIGestureRecognizerStateEnded");
            if (self.panFlag) {
                if (scale < 0.f) {
                    scale = 0.f;
                }
                self.panFlag = false;
                if (scale < 0.15f){
                    [self interPercentCancel];
                }else {
                    [self interPercentFinish];
                }
            }
            
            break;
        default:
            if (self.panFlag) {
                self.panFlag = false;
                [self interPercentCancel];
            }
            
            break;
    }
}
//取消
-(void)interPercentCancel{
    NSLog(@"拖拽取消");
    [UIView animateWithDuration:0.2f animations:^{
        self.view.alpha = 1.0f;
        self.imgV.transform=CGAffineTransformIdentity;
        self.imgV.center = self.view.center;
    } completion:^(BOOL finished) {
        
    }];
}

//结束
-(void)interPercentFinish{
    NSLog(@"拖拽结束");
//    self.view.alpha = 1.0f;
//    self.imgV.transform=CGAffineTransformIdentity;
//    self.imgV.center = self.view.center;
    [self dismissViewControllerAnimated:true completion:nil];
}
//修改其他View透明度
- (void)updateInterPercent:(CGFloat)scale{
    if(scale < 0.3){
        scale = 0.3;
    }
    self.view.alpha = scale;
    self.navigationController.navigationBar.alpha = 1 - scale;
}

//UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return self.photos.count;
    return self.photosURL.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DBPhotoPreviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PreviewCellId" forIndexPath:indexPath];
//    cell.backgroundColor = (UIColor*)self.photos[indexPath.item];
//    cell.image = self.photos[indexPath.item];
    cell.imageURL = self.photosURL[indexPath.item];
    __weak typeof(self) weakself = self;
    
    //设置cell的单指点击block
    [cell setCellTapClick:^{
        //方案1：
//        [weakself setSubviewAlphaAnimate:YES];
        //方案2 直接退出当前控制器
        [weakself dismissViewControllerAnimated:false completion:nil];
    }];

    return cell;
    
}

//UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"当前选中cell位置:%lu",indexPath.item);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    DBPhotoPreviewViewCell *dbCell = (DBPhotoPreviewViewCell*)cell;
    [dbCell resetScale];
    
    self.willDisplayCellIndexPath = indexPath;
    NSLog(@"将要展示cell位置:%lu",self.willDisplayCellIndexPath.item);
    self.currentDisplayCellIndexPath = indexPath;
    
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

    self.endDisplayCellIndexPath = indexPath;
    NSLog(@"展示完毕的cell位置:%lu",self.endDisplayCellIndexPath.item);
    
}


- (void)setSubviewAlphaAnimate:(BOOL)animete {
    if(animete){
        NSLog(@"隐藏状态栏");
        [[UIApplication sharedApplication] setStatusBarHidden:!self.subviewsHidden withAnimation:UIStatusBarAnimationFade];
        
        [self.navigationController setNavigationBarHidden:!self.subviewsHidden animated:true];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:!self.subviewsHidden];
        [self.navigationController setNavigationBarHidden:!self.subviewsHidden animated:false];
    }
    self.subviewsHidden = !self.subviewsHidden;
}

-(void)back{
    [self dismissViewControllerAnimated:true completion:nil];
//    [self.navigationController popViewControllerAnimated:true];
    
}

#pragma mark - < 懒加载 >
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, kTopMargin,self.view.hx_w + 20, self.view.hx_h - kTopMargin - kBottomMargin) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[DBPhotoPreviewViewCell class] forCellWithReuseIdentifier:@"PreviewCellId"];
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
#else
            if ((NO)) {
#endif
            } else {
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
        }
        return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
        if (!_flowLayout) {
            _flowLayout = [[UICollectionViewFlowLayout alloc] init];
            _flowLayout.minimumInteritemSpacing = 0;
            _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//            _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
           _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
#else
            if ((NO)) {
#endif
                _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
            }else {
                _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
                }
        }
           
            return _flowLayout;
}

        


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
