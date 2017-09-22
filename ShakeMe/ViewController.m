//
//  ViewController.m
//  ShakeMe
//
//  Created by truwind on 2017. 9. 22..
//  Copyright © 2017년 truwind. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

#define MAX_NUM_PRINTING    20
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface ViewController ()

@property (nonatomic, strong) CMMotionManager * motion;
@property (nonatomic, strong) NSTimer * timer;

@property (nonatomic, assign) BOOL isFirstDataSaved;
@property (nonatomic, assign) double oldXAngle;
@property (nonatomic, assign) double oldZAngle;

@property (nonatomic, assign) NSInteger printPercent;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self startAccelerometers];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startAccelerometers {
    if(!self.motion) self.motion = [CMMotionManager new];
    self.printPercent = 0;
    self.isFirstDataSaved = NO;
    // Make sure the accelerometer hardware is available
    if(self.motion.isAccelerometerAvailable){
        self.motion.accelerometerUpdateInterval = 1.0/100.0 ; // 60Hz
#if 1
        WS(weakSelf);
        [self.motion startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                          withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                                              
                                              double x = accelerometerData.acceleration.x;
                                              double y = accelerometerData.acceleration.y;
                                              double z = accelerometerData.acceleration.z;
                                              
                                              // Use the accelerometer data in your app.
//                                              NSLog(@"Accelerometer Data ] x : %lf, y : %lf, z : %lf", x, y, z);
//                                              double xyrotaion = atan2(x, y) - M_PI;
//                                              double zyrotaion = atan2(z, y) - M_PI;
//                                              NSLog(@"xy-Rotaion : %lf, zy-Rotaion : %lf", xyrotaion, zyrotaion );
                                              
                                              double newXangle = atan2(x, y) * (180/M_PI);
                                              double newZangle = atan2(z, y) * (180/M_PI);
                                              if(!self.isFirstDataSaved){
                                                  NSLog(@"자~~~ 처음이니깐 저장하자...");
                                                  weakSelf.isFirstDataSaved = YES;
                                                  weakSelf.oldXAngle = newXangle;
                                                  weakSelf.oldZAngle = newZangle;
                                                  // skip first receive data
                                              } else {
                                                  
                                                  double xDelta = fabs(fabs(newXangle) - fabs(weakSelf.oldXAngle));
                                                  double zDelta = fabs(fabs(newZangle) - fabs(weakSelf.oldZAngle));
                                                  
                                                  if(xDelta > 25 || zDelta > 25) {
                                                      weakSelf.printPercent++;
                                                      NSLog(@"xDelta : %lf, zDelta : %lf", xDelta, zDelta);
                                                      NSLog(@"self.oldXAngle : %lf, self.oldZAngle : %lf,  newXangle : %lf, newZangle : %lf"
                                                            , weakSelf.oldXAngle, weakSelf.oldXAngle, newXangle, newZangle );
                                                      weakSelf.oldXAngle = newXangle;
                                                      weakSelf.oldZAngle = newZangle;
                                                  }
                                              }

                                              if(weakSelf.printPercent >  MAX_NUM_PRINTING) {
                                                  NSLog(@"++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
                                                  NSLog(@"충분히 흔들었어 이제 인화하자~~~~~\n");
                                                  NSLog(@"++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
                                                  [weakSelf endMotionUpdate];
                                              }

                                          }];
        
#else
        [self.motion startAccelerometerUpdates];
        // Configure a timer to fetch the data.
        self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:(1.0/60.0) repeats:YES block:^(NSTimer * _Nonnull timer) {
            // Get the accelerometer data.
            CMAccelerometerData *accelerometerData = self.motion.accelerometerData;
            if(accelerometerData){
                double x = accelerometerData.acceleration.x;
                double y = accelerometerData.acceleration.y;
                double z = accelerometerData.acceleration.z;
                
                // Use the accelerometer data in your app.
                NSLog(@"Accelerometer Data ] x : %lf, y : %lf, z : %lf", x, y, z);
                double xyrotaion = atan2(x, y) - M_PI;
                double zyrotaion = atan2(z, y) - M_PI;

                NSLog(@"xy-Rotaion : %lf, zy-Rotaion : %lf", xyrotaion, zyrotaion );
            }
        }];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
#endif
    } else {
        
    }
}

- (void) endMotionUpdate {
    NSLog(@"모션 감지 종료하자~~~~");
    self.isFirstDataSaved = NO;
    self.printPercent = 0;
    [self.motion stopAccelerometerUpdates];
#if 0
    [self.timer invalidate];
    self.timer = nil;
#endif
}

- (IBAction)onClickedStart:(id)sender {
    [self startAccelerometers];
}

- (IBAction)onClickedEnd:(id)sender {
    [self endMotionUpdate];
}

@end
