//
//  DBPhotoPreviewViewController.h
//  DBImagePicker
//
//  Created by kong yan on 2018/6/25.
//  Copyright © 2018年 dbsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPhotoPreviewViewController : UIViewController
@property(strong,nonatomic)NSArray *photosURL;
@property(nonatomic,assign)NSInteger currentPhotoIndex;
@end
