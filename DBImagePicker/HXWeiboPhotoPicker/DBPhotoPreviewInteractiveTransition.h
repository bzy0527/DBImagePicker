//
//  DBPhotoPreviewInteractiveTransition.h
//  DBImagePicker
//
//  Created by kong yan on 2018/6/26.
//  Copyright © 2018年 dbsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPhotoPreviewInteractiveTransition : UIPercentDrivenInteractiveTransition
/**记录是否开始手势，判断pop操作是手势触发还是返回键触发*/
@property (nonatomic, assign) BOOL interation;
- (void)addPanGestureForViewController:(UIViewController *)viewController;
@end
