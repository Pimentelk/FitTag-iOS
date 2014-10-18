//
//  FitTagLoginViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 6/12/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface FTConfigViewController : UIViewController <PFLogInViewControllerDelegate,/*PFSignUpViewControllerDelegate,*/CLLocationManagerDelegate>
@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;
@end
