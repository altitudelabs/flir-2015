//
//  HomeViewController.m
//  FlirOne
//
//  Created by Altitude Labs on 21/11/15.
//  Copyright © 2015 Victor. All rights reserved.
//

#import "HomeViewController.h"
#import "CameraViewController.h"

@interface HomeViewController ()

//@property (strong, nonatomic) CameraViewController *cameraVC;
@property (weak, nonatomic) IBOutlet UIButton *btnMoniterSleep;

// Sleep detail
@property (weak, nonatomic) IBOutlet UIView *dialogSleepDetail;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewSleepDetail;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI
    
    self.btnMoniterSleep.clipsToBounds = YES;
    self.btnMoniterSleep.layer.cornerRadius = 7;
    
    // Scroller of date bar
    self.scrollView.contentSize = CGSizeMake(681, 65);
    UIImageView *imgDateBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"date"]];
    imgDateBar.frame = CGRectMake(0, 0, 681, 65);
    [self.scrollView addSubview:imgDateBar];
    
    // Scroller of sleep detail
    
    self.scrollViewSleepDetail.contentSize = CGSizeMake(584, 237);
    UIImageView *imageSleepDetail = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sleep_detail_graph"]];
    imageSleepDetail.frame = CGRectMake(0, 0, 584, 237);
    [self.scrollViewSleepDetail addSubview:imageSleepDetail];
    
    self.dialogSleepDetail.hidden = YES;
    
    // Nav bar
    self.title = @"Home";
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = kColorTextPink;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : kColorTextPink}];
    self.navigationController.navigationBar.translucent = NO;
    
    // Setup
    
//    self.cameraVC = [[CameraViewController alloc] init];
}

#pragma mark - UIAction

- (IBAction)btnSleepGraphClicked:(id)sender {
    self.dialogSleepDetail.hidden = NO;
}

- (IBAction)backOfSleepDetailClicked:(id)sender {
    self.dialogSleepDetail.hidden = YES;
}


//- (IBAction)monitorNewSleepClicked:(id)sender {
//    [self.navigationController pushViewController:self.cameraVC animated:YES];
//}

@end
