//
//  RatingViewController.h
//  FlirOne
//
//  Created by Altitude Labs on 21/11/15.
//  Copyright © 2015 Victor. All rights reserved.
//

#import "BaseViewController.h"

@protocol RatingViewControllerDelegate <NSObject>

- (void)RatingViewControllerConfirmClicked;

@end

@interface RatingViewController : BaseViewController

@property (strong, nonatomic) id<RatingViewControllerDelegate> delegate;

@end
