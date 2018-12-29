//
//  PPCountDownTimer.m
//  PatPat
//
//  Created by patpat on 15/11/14.
//  Copyright © 2015年 http://www.patpat.com. All rights reserved.
//

#import "PPCountDownTimer.h"

@interface PPCountDownTimer()
{
    dispatch_source_t _timer;
    int suspend_cnt;
}
@property (nonatomic, copy) PPCountDownEndBlock         endBlock;
@property (nonatomic, copy) PPCountingBlock             countingBlock;
@property (nonatomic, assign) NSTimeInterval            timeValue;

@end

@implementation PPCountDownTimer

-(instancetype)init
{
    self = [super init];
    if (self) {
        if (_timer) {
            long result = dispatch_source_testcancel(_timer);
            if (result) {
                [self setUp];
            }
        }else {
            [self setUp];
        }
    }
    return self;
}

- (void)setUp
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    suspend_cnt = 1;
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if (self.timeValue <=0) {
            [self pause];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.endBlock) {
                    self.endBlock(self.timeValue);
                }
            });
        }else {
            //秒为单位
            int days = (int)self.timeValue / (3600 * 24);
            int hours = (int)((self.timeValue-days*24*3600)/3600);
            int minute = (int)(self.timeValue-days*24*3600-hours*3600)/60;
            int second = (int)self.timeValue-days*24*3600-hours*3600-minute*60;
           dispatch_async(dispatch_get_main_queue(), ^{
                if (self.countingBlock) {
                    self.countingBlock(days,hours,minute,second);
                }
            });
            (self.timeValue)--;
        }
    });
}

- (void)start
{
    if (suspend_cnt>0) {
        [self resume];
    }
}

- (void)startWithCountDownEndBlock:(PPCountDownEndBlock)block
{
    self.endBlock = block;
}

- (void)startWithCountingBlock:(PPCountingBlock)block
{
    self.countingBlock = block;
}

- (void)pause
{
    if (suspend_cnt ==0) {
        dispatch_suspend(_timer);
        suspend_cnt++;
    }
}

- (void)resume
{
    if (suspend_cnt>0) {
        dispatch_resume(_timer);
        suspend_cnt--;
    }
}

- (void)free
{
    dispatch_source_set_cancel_handler(_timer, ^{
    });
    dispatch_source_cancel(_timer);
}

- (void)setCountDownTime:(NSTimeInterval)time
{
    self.timeValue = time>0?time:0;
}

- (void)changeCountDownTimer:(NSTimeInterval)time callBack:(void(^)(BOOL result))block
{
    if (time > 0) {
        self.timeValue = self.timeValue - time;
        if (self.timeValue <=0) {
            dispatch_suspend(_timer);
            suspend_cnt++;
            if (block) {
                block(YES);
            }
        }
    }
}

- (void)resumeSuspendCnt
{
    //恢复计数
    if (suspend_cnt < 1) {
         suspend_cnt = 1;
    }
}

- (void)destory
{
    _endBlock = nil;
    _countingBlock = nil;
    _countEndBlock = nil;
    [self free];
}


@end
