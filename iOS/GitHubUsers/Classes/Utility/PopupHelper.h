//
//  PopupHelper.h
//
//  Created by Viktor Gubriienko on 5/24/12.
//  Copyright (c) 2012 All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PopupHelper : NSObject

+ (void)popupView:(UIView*)view withTimeInterval:(NSTimeInterval)time;
+ (void)popupText:(NSString*)text withTimeInterval:(NSTimeInterval)time;

+ (void)popupModalSpinner;
+ (void)removeModalSpinner;

@end
