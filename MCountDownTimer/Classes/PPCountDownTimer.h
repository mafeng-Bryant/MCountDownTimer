//
//  PPCountDownTimer.h
//  PatPat
//
//  Created by patpat on 15/11/14.
//  Copyright © 2015年 http://www.patpat.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PPCountDownEndBlock)(NSTimeInterval time);
typedef void (^PPCountingBlock)(NSInteger days, NSInteger hours,NSInteger minutes,NSInteger seconds);

@interface PPCountDownTimer : NSObject
@property(nonatomic,copy) PPCountDownEndBlock countEndBlock;

- (void)start;

- (void)startWithCountDownEndBlock:(PPCountDownEndBlock)block;

- (void)startWithCountingBlock:(PPCountingBlock)block;

- (void)pause;

- (void)resume;

- (void)free;

- (void)setCountDownTime:(NSTimeInterval)time;

- (void)resumeSuspendCnt;

//前后台切换调用
- (void)changeCountDownTimer:(NSTimeInterval)time callBack:(void(^)(BOOL result))block;

- (void)destory;


@end
