//
//  DBPhotoPreviewViewCell.m
//  DBImagePicker
//
//  Created by kong yan on 2018/6/25.
//  Copyright © 2018年 dbsoft. All rights reserved.
//

#import "DBPhotoPreviewViewCell.h"
#import "UIView+HXExtension.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface DBPhotoPreviewViewCell()<UIScrollViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGPoint imageCenter;

@end

@implementation DBPhotoPreviewViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //    self.playerLayer.frame = self.bounds;
    //    self.videoPlayBtn.frame = self.bounds;
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.hx_w, self.hx_h);
}

- (void)setImage:(UIImage *)image{
    NSLog(@"%@",image);
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = image.size.width;
    CGFloat imgHeight = image.size.height;
    CGFloat w;
    CGFloat h;
    
    imgHeight = width / imgWidth * imgHeight;
    if (imgHeight > height) {
        w = height / image.size.height * imgWidth;
        h = height;
        self.scrollView.maximumZoomScale = width / w + 0.5;
    }else {
        w = width;
        h = imgHeight;
        self.scrollView.maximumZoomScale = 2.5;
    }

    self.imageView.frame = CGRectMake(0, 0, w, h);
    self.imageView.center = CGPointMake(width / 2, height / 2);
    self.imageView.image = image;
    self.imageView.hidden = NO;
    
}

-(void)setImageURL:(NSString *)imageURL{
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"photo_load_failed_text.png"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        if (image) {
            CGFloat width = self.frame.size.width;
            CGFloat height = self.frame.size.height;
            CGFloat imgWidth = image.size.width;
            CGFloat imgHeight = image.size.height;
            CGFloat w;
            CGFloat h;
            
            imgHeight = width / imgWidth * imgHeight;
            if (imgHeight > height) {
                w = height / image.size.height * imgWidth;
                h = height;
                self.scrollView.maximumZoomScale = width / w + 0.5;
            }else {
                w = width;
                h = imgHeight;
                self.scrollView.maximumZoomScale = 2.5;
            }
            
            self.imageView.frame = CGRectMake(0, 0, w, h);
            self.imageView.center = CGPointMake(width / 2, height / 2);
            self.imageView.hidden = NO;
        }else{
            UIImage *placeHolderImg = [UIImage imageNamed:@"photo_load_failed_text.png"];
            CGFloat width = self.frame.size.width;
            CGFloat height = self.frame.size.height;
//            CGFloat imgWidth = placeHolderImg.size.width;
//            CGFloat imgHeight = placeHolderImg.size.height;
//            CGFloat w;
//            CGFloat h;
//
//            imgHeight = width / imgWidth * imgHeight;
//            if (imgHeight > height) {
//                w = height / placeHolderImg.size.height * imgWidth;
//                h = height;
//                self.scrollView.maximumZoomScale = 1.0;
//            }else {
//                w = width;
//                h = imgHeight;
//                self.scrollView.maximumZoomScale = 1.0;
//            }
            
//            self.imageView.frame = CGRectMake(0, 0, w, h);
//            self.imageView.center = CGPointMake(width / 2, height / 2);
            self.scrollView.maximumZoomScale = 1.000001;
            self.imageView.frame = CGRectMake(0, 0, 100, 100);
            self.imageView.center = CGPointMake(width / 2, height / 2);
            self.imageView.hidden = NO;
            self.imageView.image = placeHolderImg;
            
        }
    }];

}
#pragma mark - 处理点击手势
//单指点击
- (void)singleTap:(UITapGestureRecognizer *)tap{
    if(self.cellTapClick){
        self.cellTapClick();
    }
}

//双击
- (void)doubleTap:(UITapGestureRecognizer *)tap{
    NSLog(@"双击,放大倍数：%f",_scrollView.zoomScale);
    
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        CGPoint touchPoint;
        touchPoint = [tap locationInView:self.imageView];
        
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = width / newZoomScale;
        CGFloat ysize = height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - < UIScrollViewDelegate >
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSLog(@"viewForZoomingInScrollView");
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidZoom");
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    
}

- (void)resetScale{
    [self.scrollView setZoomScale:1.0f animated:NO];
}

#pragma mark - < 懒加载 >
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bouncesZoom = YES;
        _scrollView.minimumZoomScale = 1;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [_scrollView addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [_scrollView addGestureRecognizer:tap2];
    }
    return _scrollView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

@end
