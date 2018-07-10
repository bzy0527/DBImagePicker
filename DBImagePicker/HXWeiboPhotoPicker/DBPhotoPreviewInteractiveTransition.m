//
//  DBPhotoPreviewInteractiveTransition.m
//  DBImagePicker
//
//  Created by kong yan on 2018/6/26.
//  Copyright © 2018年 dbsoft. All rights reserved.
//

#import "DBPhotoPreviewInteractiveTransition.h"
#import "DBPhotoPreviewViewCell.h"
@interface DBPhotoPreviewInteractiveTransition()
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic,strong) UIImageView *imgV;
@property (nonatomic, assign) CGFloat beginX;
@property (nonatomic, assign) CGFloat beginY;

@end

@implementation DBPhotoPreviewInteractiveTransition
- (void)addPanGestureForViewController:(UIViewController *)viewController{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizeDidUpdate:)];
    self.vc = viewController;
    UICollectionView *collV = self.vc.view.subviews[0];
    DBPhotoPreviewViewCell *cell = collV.subviews[0];
    UIScrollView *scrollV = cell.contentView.subviews[0];
    UIImageView *imgV = scrollV.subviews[0];
    self.imgV = imgV;
    [viewController.view addGestureRecognizer:pan];
}

- (void)gestureRecognizeDidUpdate:(UIPanGestureRecognizer *)gestureRecognizer {

    CGFloat scale = 0;
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    CGFloat transitionY = translation.y;
    //用于判断向上(<0) 还是向下拖动(>0)
    scale = transitionY / ((gestureRecognizer.view.frame.size.height - 50) / 2);
    if (scale > 1.f) {
        scale = 1.f;
    }
    
    NSLog(@"缩放比例：%f",scale);
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            
            if (scale < 0) {
                [gestureRecognizer cancelsTouchesInView];
                return;
            }
            
            self.beginX = [gestureRecognizer locationInView:gestureRecognizer.view].x;
            self.beginY = [gestureRecognizer locationInView:gestureRecognizer.view].y;
            self.interation = YES;
           
//            [self.vc.navigationController popViewControllerAnimated:true];
//            [self.vc dismissViewControllerAnimated:true completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            
            if (scale < 0.f) {
                scale = 0.f;
            }
            CGFloat imageViewScale = 1 - scale * 0.5;
            if (imageViewScale < 0.4) {
                imageViewScale = 0.4;
            }
           
            self.imgV.center = CGPointMake(self.imgV.center.x + translation.x, self.imgV.center.y + translation.y);
//            self.tempImageView.transform = CGAffineTransformMakeScale(imageViewScale, imageViewScale);
//
//            [self updateInterPercent:1 - scale * scale];
            self.imgV.transform = CGAffineTransformMakeScale(imageViewScale, imageViewScale);
            [self updateInteractiveTransition:scale];
            
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"UIGestureRecognizerStateEnded");
            
            
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"UIGestureRecognizerStateCancelled");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"UIGestureRecognizerStateFailed");
            break;
        default:
            
            break;
            
    }
    
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    NSLog(@"startInteractiveTransition");
}
@end
