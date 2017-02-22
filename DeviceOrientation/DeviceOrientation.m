//
//  DeviceOrientation.m
//  DeviceOrientation
//
//  Created by Tg W on 17/2/22.
//  Copyright © 2017年 oopsr. All rights reserved.
//

#import "DeviceOrientation.h"
#import <CoreMotion/CoreMotion.h>

@interface DeviceOrientation () {
    
    CMMotionManager *_motionManager;
    TgDirection _direction;

}
@end
//sensitive 灵敏度
static const float sensitive = 0.77;

@implementation DeviceOrientation

+ (instancetype)shareInstance {
    
    static  DeviceOrientation *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[DeviceOrientation alloc] init];
        }
    });
    return instance;
}

- (void)startMonitor {
    
    [self startMotionManager];
}

- (void)stop {
    
    [_motionManager stopDeviceMotionUpdates];
}


//陀螺仪 每隔一个间隔做轮询
- (void)startMotionManager{
    
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    if (_motionManager.deviceMotionAvailable) {
        NSLog(@"Device Motion Available");
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                            }];
    } else {
        NSLog(@"No device motion on device.");
    }
}
- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (y < 0 ) {
        if (fabs(y) > sensitive) {
            if (_direction != TgDirectionPortrait) {
                _direction = TgDirectionPortrait;
                if ([self.delegate respondsToSelector:@selector(directionChange:)]) {
                    [self.delegate directionChange:_direction];
                }
            }
        }
    }else {
        if (y > sensitive) {
            if (_direction != TgDirectionDown) {
                _direction = TgDirectionDown;
                if ([self.delegate respondsToSelector:@selector(directionChange:)]) {
                    [self.delegate directionChange:_direction];
                }
            }
        }
    }
    if (x < 0 ) {
        if (fabs(x) > sensitive) {
            if (_direction != TgDirectionleft) {
                _direction = TgDirectionleft;
                if ([self.delegate respondsToSelector:@selector(directionChange:)]) {
                    [self.delegate directionChange:_direction];
                }
            }
        }
    }else {
        if (x > sensitive) {
            if (_direction != TgDirectionRight) {
                _direction = TgDirectionRight;
                if ([self.delegate respondsToSelector:@selector(directionChange:)]) {
                    [self.delegate directionChange:_direction];
                }
            }
        }
    }    
}

@end
