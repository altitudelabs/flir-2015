//
//  ViewController.m
//  FlirOne
//
//  Created by Altitude Labs on 20/11/15.
//  Copyright © 2015 Victor. All rights reserved.
//

#import "CameraViewController.h"
#import "MyImageProcessing.h"
#import <FLIROneSDK/FLIROneSDK.h>
#import <FLIROneSDK/FLIROneSDKSimulation.h>
#import <Sinch/Sinch.h>
#import "AppDelegate.h"
@import CoreImage;
@import QuartzCore;
//#import <QuartzCore/QuartzCore.h>

@interface CameraViewController () <FLIROneSDKImageReceiverDelegate, FLIROneSDKStreamManagerDelegate, RatingViewControllerDelegate, SINCallDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

// Debugging
@property (weak, nonatomic) IBOutlet UILabel *labelLogging;

@property (weak, nonatomic) IBOutlet UIButton *btnStartOrStop;

// Display data
@property (weak, nonatomic) IBOutlet UILabel *labelTemperature;
@property (weak, nonatomic) IBOutlet UILabel *labelFacePercentage;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;

// Rating
@property (strong, nonatomic) RatingViewController *ratingVC;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Nav bar
    self.title = @"Start Monitoring";
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = kColorTextPink;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : kColorTextPink}];
    self.navigationController.navigationBar.translucent = NO;
    
    // Left nav button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backButtonClicked)];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:@"Back" forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // Right nav button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Rate" style:UIBarButtonItemStylePlain target:self action:@selector(rateButtonClicked)];
//    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontBold size:15],
//                                            NSForegroundColorAttributeName: kColorTextPink}
//                                 forState:UIControlStateNormal];

    
    // Default
    self.pageState = State_Spare;
    self.alertDialog.hidden = YES;
    self.labelAlertBabyText.text = @"OF THE\nBABY FACE IS\nCOVERED";
    
    [self updateUI];
    
    // Setup camera
    
    [[FLIROneSDKStreamManager sharedInstance] addDelegate:self];
    
    // You may not use the FLIROneSDKImageOptionsBlendedMSXRGBA8888Image and FLIROneSDKImageOptionsThermalRGBA8888Image concurrently.
    [[FLIROneSDKStreamManager sharedInstance] setImageOptions:
     FLIROneSDKImageOptionsBlendedMSXRGBA8888Image |
     FLIROneSDKImageOptionsThermalLinearFlux14BitImage|
     FLIROneSDKImageOptionsThermalRadiometricKelvinImage];
    
    // Simualating
//    [[FLIROneSDKSimulation sharedInstance] connectWithFrameBundleName:@"sampleframes_hq" withBatteryChargePercentage:@42];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // SHow camera frame
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_crosshair"]];
    imageView.center = self.view.center;
    
    CGRect fromRect = CGRectMake(30, 30, 400, 400);
    CGRect destRect = CGRectMake(70, 100, CGRectGetWidth(self.view.frame) - 70*2, CGRectGetWidth(self.view.frame) - 70*2);
    imageView.frame = fromRect;
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = destRect;
    } completion:^(BOOL finished) {
    }];
    
    // End of Show camera frame
    
}

#pragma mark -UI


- (void)updateUI {
    // Btn
    if (self.pageState == State_Spare) {
        [self.btnStartOrStop setTitle:@"START RECORDING" forState:UIControlStateNormal];
    } else {
        [self.btnStartOrStop setTitle:@"STOP RECORDING" forState:UIControlStateNormal];
    }
    
    // Time
    int minutes = self.recordingTime / 60;
    int seconds = self.recordingTime % 60;
    
    NSString *timeStr = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    self.labelTime.text = timeStr;
}

#pragma mark - UIAction

- (void)rateButtonClicked {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.ratingVC = [sb instantiateViewControllerWithIdentifier:@"RatingViewController"];
    self.ratingVC.delegate = self;
    [self addChildViewController:self.ratingVC];
    [self.view addSubview:self.ratingVC.view];
}

#pragma mark RatingViewControllerDelegate

- (void)RatingViewControllerConfirmClicked {
    [self.ratingVC.view removeFromSuperview];
    [self.ratingVC removeFromParentViewController];
    self.ratingVC = nil;
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnStartOrStopClicked:(id)sender {
    if (self.pageState == State_Spare) {
        // Record now
        
        self.pageState = State_Recording;
        
        // Get initial human pixel
        self.initialHumanBodyPixel = [self numberOfHumanBodyPixel:self.imageGray];
        self.currentHumanBodyPixel = self.initialHumanBodyPixel;
        
        // Timer
        [self stopTimer];
        [self startTimer];
        
    } else {
        // Stop record
        
        self.pageState = State_Spare;
        
        [self stopTimer];
    }
    
    [self updateUI];
}

- (void)startTimer {
    self.recordingTime = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTimer) userInfo:nil repeats:YES];
}

- (void)countTimer {
    self.recordingTime++;
    [self updateUI];
}

- (void)stopTimer {
    [self.timer invalidate];
}


- (IBAction)buttonAlertDialogCloseClicked:(id)sender {
    self.alertDialog.hidden = YES;
}

#pragma mark - FLIROneSDKImageReceiverDelegate

- (void) FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveFrameWithOptions:(FLIROneSDKImageOptions)options metadata:(FLIROneSDKImageMetadata *)metadata {
    
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveBlendedMSXRGBA8888Image:(NSData *)msxImage imageSize:(CGSize)size {
    
    // Display
    
    self.imageDisplay = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsBlendedMSXRGBA8888Image andData:msxImage andSize:size];
    
    //perform ui update on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = self.imageDisplay;
    });
}

// Gray image

- (void) FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveThermal14BitLinearFluxImage:(NSData *)linearFluxImage imageSize:(CGSize)size {
    
    // Content tracking
    
    self.imageGray = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsThermalLinearFlux14BitImage andData:linearFluxImage andSize:size];
    
    self.currentHumanBodyPixel = [self numberOfHumanBodyPixel:self.imageGray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self logPercentage];
        
        if (self.pageState == State_Recording) {
            AlertType alertType = [self babyIsSafe];
            if (alertType == AlertType_BlanketCoverHead) {
                // Stop recording anymore
                self.pageState = State_Spare;
                [self updateUI];
                [self alertParent:alertType];
            }
        }
         });
}

- (void) FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveThermalRGBA8888Image:(NSData *)thermalImage imageSize:(CGSize)size {
    
}

- (void) FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveVisualJPEGImage:(NSData *)visualJPEGImage {
    
}

- (void) FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveVisualYCbCr888Image:(NSData *)visualYCbCr888Image imageSize:(CGSize)size {
    
}

// Measuree temp
- (void) FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveRadiometricData:(NSData *)radiometricData imageSize:(CGSize)size {
    @synchronized(self) {
        
        // Get temperature
        
        NSString *tempStr = [self performTemperatureCalculationsWithThermalData:radiometricData thermalSize:size];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self logTemperature:tempStr];
        });
    }
}

#pragma mark - <FLIROneSDKStreamManagerDelegate>

- (void)FLIROneSDKDidConnect {
}

- (void)FLIROneSDKDidDisconnect {
}

//#pragma mark - Image processing
//- (void)detectFace:(UIImage *)inputImage {
//    CIImage* image = [CIImage imageWithCGImage:inputImage.CGImage];
//    
//    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
//                                              context:nil
//                                              options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
//                                                                                  forKey:CIDetectorAccuracy]];
//}

#pragma mark - Image math

- (NSString *)performTemperatureCalculationsWithThermalData:(NSData *)thermalData thermalSize:(CGSize)thermalSize {
    uint16_t *tempData = (uint16_t *)[thermalData bytes];
    uint16_t temp = tempData[0];
    uint16_t hottestTemp = temp;
    uint16_t coldestTemp = temp;
    int index = 0;
    int coldIndex = 0;
    
    uint16_t minRegion = UINT16_MAX;
    int minRegionIndex = 0;
    uint16_t maxRegion = 0;
    int maxRegionIndex = 0;
    NSInteger regionCount = 0;
    NSInteger regionSum = 0;
    
    for(int i=0;i<thermalSize.width*thermalSize.height;i++) {
        temp = tempData[i];
        if(temp > hottestTemp) {
            hottestTemp = temp;
            index = i;
        }
        if(temp < coldestTemp) {
            coldestTemp = temp;
            coldIndex = i;
        }
        CGFloat x = (i % (int)thermalSize.width)/thermalSize.width;
        CGFloat y = (i / thermalSize.width)/thermalSize.height;
        
//        if(x > self.regionOfInterest.origin.x
//           && x < self.regionOfInterest.origin.x + self.regionOfInterest.size.width
//           && y > self.regionOfInterest.origin.y
//           && y < self.regionOfInterest.origin.y + self.regionOfInterest.size.height)
//        {
            regionCount += 1;
            regionSum += temp;
            if(temp > maxRegion) {
                maxRegion = temp;
                maxRegionIndex = i;
            }
            if(temp < minRegion) {
                minRegion = temp;
                minRegionIndex = i;
            }
//        }
    }
//    uint16_t regionAverage = (regionSum/regionCount);
//    
//    self.regionMaxLabel.text = [NSString stringWithFormat:@"%0.2fºK", maxRegion/100.0];
//    self.regionMinLabel.text = [NSString stringWithFormat:@"%0.2fºK", minRegion/100.0];
//    self.regionAverageLabel.text = [NSString stringWithFormat:@"%0.2fºK", regionAverage/100.0];
//    
//    NSInteger column = index % (int)self.thermalSize.width;
//    NSInteger row = index / self.thermalSize.width;
//    //update the thinger
//    CGPoint location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
//    //self.hottestPoint.frame = CGRectMake(
//    self.pixelOfInterest = location;
//    column = coldIndex % (int)self.thermalSize.width;
//    row = coldIndex / self.thermalSize.width;
//    
//    location = CGPointMake(column/self.thermalSize.width, row/self.thermalSize.height);
//    self.coldPixel = location;
//    
//    self.coldestTemperature = coldestTemp/100.0;
//    self.pixelTemperature = hottestTemp/100.0;
    
    return [NSString stringWithFormat:@"%0.2fºC", hottestTemp/100.0 - 273.0];
}

- (NSInteger)numberOfHumanBodyPixel:(UIImage *)inputImage {
    
    uint32_t *inputPixels = [MyImageProcessing getPixelsFromUIImage:inputImage withSize:inputImage.size];
    
    int w = inputImage.size.width;
    int h = inputImage.size.height;
    
    NSInteger pixelCountMeetThreshold = 0;
    
    for (int i = 0; i < w * h; i++) {
        int refBlue = (inputPixels[i] >> 16) & 0xff;
        if (refBlue > kHumanBodyWhiteThreshold * 255) {
//            inputPixels[i] = 0xff00f000;
            pixelCountMeetThreshold ++;
        }
    }
    
    free(inputPixels);
    
//    inputImage = [MyImageProcessing getUIImageFromPixels:inputPixels size:inputImage.size];
//    self.imageDisplay = inputImage;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.imageView.image = self.imageDisplay;
//    });
    
    
    
//    // OLD CODE
//    
//    NSArray *array = [MyImageProcessing getRGBAsFromImage:inputImage atX:0 andY:0 count:
//     inputImage.size.width*inputImage.size.height];
//    
//    NSInteger pixelCountMeetThreshold = 0;
//    
//    for (UIColor *color in array) {
//        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
//        [color getRed:&red green:&green blue:&blue alpha:&alpha];
//        if (red >= kHumanBodyWhiteThreshold) {
//            pixelCountMeetThreshold += 1;
//        }
//    }
    
    return pixelCountMeetThreshold;
}

- (AlertType)babyIsSafe {
    CGFloat humanBodyPercentage = (CGFloat)self.currentHumanBodyPixel / (CGFloat)self.initialHumanBodyPixel;
    if (humanBodyPercentage <= kBlanketCoverHeadThreshold) {
        return AlertType_BlanketCoverHead;
    } else {
        return AlertType_None;
    }
}

- (void)alertParent:(AlertType)alertType {
    if (alertType == AlertType_BlanketCoverHead) {
        
        self.alertDialog.hidden = NO;
        [self.view bringSubviewToFront:self.alertDialog];
        self.labelAlertDialogPercentage.text = self.labelFacePercentage.text;
        
        id<SINCallClient> callClient = [[self client] callClient];
        id<SINCall> call = [callClient callUserWithId:SINCH_UserIdCallTo];
        call.delegate = self;
        
//        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Blanket cover baby's head!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - SINCallDelegate

- (void)callDidProgress:(id<SINCall>)call {
    
}

- (void)callDidEstablish:(id<SINCall>)call {
    
}

#pragma - Helper

- (void)logPercentage {
//    self.labelLogging.text = [NSString stringWithFormat:@"initialHumanPixel: %zd\n currentHumanBodyPixel: %zd\n percent:%f", self.initialHumanBodyPixel, self.currentHumanBodyPixel, (CGFloat)self.currentHumanBodyPixel / (CGFloat)self.initialHumanBodyPixel];
    
    if (self.pageState == State_Recording) {
        
        NSInteger value = 100 - (NSInteger)((CGFloat)self.currentHumanBodyPixel / (CGFloat)self.initialHumanBodyPixel * 100);
        if (value < 0) {
            value = 0;
        }
        
        self.labelFacePercentage.text = [NSString stringWithFormat:@"%zd%%", value];
    }
    
}

- (void)logTemperature:(NSString *)temp {
    self.labelTemperature.text = temp;
}

- (id<SINClient>)client {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] client];
}

@end
