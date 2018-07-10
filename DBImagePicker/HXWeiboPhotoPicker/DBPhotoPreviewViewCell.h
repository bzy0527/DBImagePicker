//
//  DBPhotoPreviewViewCell.h
//  DBImagePicker
//
//  Created by kong yan on 2018/6/25.
//  Copyright © 2018年 dbsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPhotoPreviewViewCell : UICollectionViewCell
@property (nonatomic,strong)UIImage *image;

@property (nonatomic,copy) NSString *imageURL;
//单指点击回传block
@property (nonatomic, copy) void (^cellTapClick)();



- (void)resetScale;
@end
