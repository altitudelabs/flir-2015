//
//  ViewController.h
//  FlirOne
//
//  Created by Altitude Labs on 20/11/15.
//  Copyright © 2015 Victor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RatingViewController.h"

#define kHumanBodyWhiteThreshold 0.7
#define kBlanketCoverHeadThreshold 0.55

typedef enum : NSUInteger {
    State_Spare,
    State_Recording,
} State;

typedef enum : NSUInteger {
    AlertType_None,
    AlertType_BlanketCoverHead
} AlertType;

@interface CameraViewController : BaseViewController

@property (assign, nonatomic) State pageState;

// Manipulate image

@property (assign, nonatomic) NSInteger initialHumanBodyPixel;

@property (assign, nonatomic) NSInteger currentHumanBodyPixel;

@property (strong, nonatomic) UIImage *imageGray; // For manipulating image

@property (strong, nonatomic) UIImage *imageDisplay;

// Count time
@property (assign, nonatomic) NSInteger recordingTime;
@property (strong, nonatomic) NSTimer *timer;

// Alert view
@property (weak, nonatomic) IBOutlet UIView *alertDialog;
@property (weak, nonatomic) IBOutlet UILabel *labelAlertDialogPercentage;
@property (weak, nonatomic) IBOutlet UILabel *labelAlertBabyText;
@property (weak, nonatomic) IBOutlet UIButton *buttonAlertDialogClose;




@end

