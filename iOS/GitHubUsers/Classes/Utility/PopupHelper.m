//
//  PopupHelper.m
//
//  Created by Viktor Gubriienko on 5/24/12.
//  Copyright (c) 2012 All rights reserved.
//

#import "PopupHelper.h"
#import <QuartzCore/QuartzCore.h>

static NSMutableArray *_messageQueue;
static BOOL _showing = NO;
static NSInteger _showingSpinnerCounter = 0;
static UIWindow *_popupWindow;

static const CGFloat kPopupBorder = 10.0f;
static const NSTimeInterval kStartAnimationDuration = 0.1;
static const NSTimeInterval kFinishAnimationDuration = 0.3;

@interface PopupHelper ()

@end


@implementation PopupHelper

#pragma mark - Initialize

+ (void)initialize {
    if (self == [PopupHelper class]) {
        
        _messageQueue = [NSMutableArray new];
        
    }
}

#pragma mark - Public

+ (void)popupView:(UIView*)view withTimeInterval:(NSTimeInterval)time {
    
    if ( _showing ) {
        SEL sel = @selector(popupView:withTimeInterval:);
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:sel]];
        [inv setSelector:sel];
        [inv setTarget:self];
        [inv setArgument:&view atIndex:2]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        [inv setArgument:&time atIndex:3]; // arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        [inv retainArguments];
        [_messageQueue addObject:inv];
        return;
    }
    
    _popupWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _popupWindow.userInteractionEnabled = NO; // NO MODAL
    [_popupWindow makeKeyAndVisible];
    _showing = YES;
    
    CGSize popupSize = CGSizeMake(view.bounds.size.width + 2 * kPopupBorder, view.bounds.size.height + 2 * kPopupBorder);
    
    // Make popup view
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(ceilf((_popupWindow.frame.size.width - popupSize.width) / 2),
                                                                 ceilf((_popupWindow.frame.size.height - popupSize.height) / 2), 
                                                                 popupSize.width,
                                                                 popupSize.height)];
    popupView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    popupView.layer.cornerRadius = 10.0f;
    [_popupWindow addSubview:popupView];
    
    // Set context view
    [popupView addSubview:view];
    view.frame = CGRectMake(kPopupBorder, kPopupBorder, view.frame.size.width, view.frame.size.height);

    // Prepare for animation
    popupView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    popupView.alpha = 0.0f;
    
    //Animation
    [UIView animateWithDuration:kStartAnimationDuration
                     animations:
     ^{
         popupView.transform = CGAffineTransformIdentity;
         popupView.alpha = 1.0f;
     } 
                     completion:
     ^(BOOL finished) {
         [UIView animateWithDuration:kFinishAnimationDuration
                               delay:time
                             options:0
                          animations:
          ^{
              popupView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
              popupView.alpha = 0.0f;
          } 
                          completion:
          ^(BOOL finished) {
              _popupWindow = nil;
              _showing = NO;
              if ( [_messageQueue count] > 0 ) {
                  NSInvocation *inv = [_messageQueue objectAtIndex:0];
                  [_messageQueue removeObjectAtIndex:0];
                  [inv invoke];
              }
          }];
     }];
}

+ (void)popupText:(NSString*)text withTimeInterval:(NSTimeInterval)time {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:16.0f];
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    [self popupView:label withTimeInterval:time];
}

+ (void)popupModalSpinner {
    
    if ( _showingSpinnerCounter++ > 0 ) {
        return;
    }
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner startAnimating];
    
    _popupWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_popupWindow makeKeyAndVisible];
    
    CGSize popupSize = CGSizeMake(spinner.bounds.size.width + 2 * kPopupBorder, spinner.bounds.size.height + 2 * kPopupBorder);
    
    // Make popup view
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(ceilf((_popupWindow.frame.size.width - popupSize.width) / 2),
                                                                 ceilf((_popupWindow.frame.size.height - popupSize.height) / 2),
                                                                 popupSize.width,
                                                                 popupSize.height)];
    popupView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    popupView.layer.cornerRadius = 10.0f;
    [_popupWindow addSubview:popupView];
    
    // Set context view
    [popupView addSubview:spinner];
    spinner.frame = CGRectMake(kPopupBorder, kPopupBorder, spinner.frame.size.width, spinner.frame.size.height);
    
    // Prepare for animation
    popupView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    popupView.alpha = 0.0f;
    
    //Animation
    [UIView animateWithDuration:kStartAnimationDuration
                     animations:^{
                         popupView.transform = CGAffineTransformIdentity;
                         popupView.alpha = 1.0f;
                     }];
    
    
}

+ (void)removeModalSpinner {
    
    if ( --_showingSpinnerCounter > 0 ) {
        return;
    }
    
    [UIView animateWithDuration:kFinishAnimationDuration
                     animations:^{
                         UIView *popupView = _popupWindow.subviews[0];
                         popupView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                         popupView.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
                         _popupWindow = nil;
                         _showingSpinnerCounter = 0;
                     }];
}

@end
