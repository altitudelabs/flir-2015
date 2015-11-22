//
//  SelectBabyViewController.m
//  FlirOne
//
//  Created by Altitude Labs on 21/11/15.
//  Copyright © 2015 Victor. All rights reserved.
//

#import "SelectBabyViewController.h"
#import "AppDelegate.h"
#import <Sinch/Sinch.h>

#define LynkAppCall_IncomingRingtone @"business_ring_03.wav"

@interface SelectBabyViewController () <SINCallDelegate, SINCallClientDelegate>

@end

@implementation SelectBabyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Nav bar
    self.title = @"Profile";
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = kColorTextPink;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : kColorTextPink}];
    self.navigationController.navigationBar.translucent = NO;
    
    self.client.callClient.delegate = self;
}

#pragma mark - UIAction

- (IBAction)babyButtonClicked:(id)sender {
    
}

- (id<SINClient>)client {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] client];
}

#pragma mark - SINCallClientDelegate

- (void)client:(id<SINCallClient>)client didReceiveIncomingCall:(id<SINCall>)call {
    
}

- (SINLocalNotification *)client:(id<SINCallClient>)client localNotificationForIncomingCall:(id<SINCall>)call {
    SINLocalNotification *notification = [[SINLocalNotification alloc] init];
    notification.alertAction = @"Alert";
    notification.alertBody = @"Alert";
    notification.soundName = LynkAppCall_IncomingRingtone;
    return notification;
}

#pragma mark - SINCallDelegate

- (void)callDidProgress:(id<SINCall>)call {
    
}

- (void)callDidEstablish:(id<SINCall>)call {
    
}

@end
