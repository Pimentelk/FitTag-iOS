//
//  FTMainViewConrtollerViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 1/29/15.
//  Copyright (c) 2015 Kevin Pimentel. All rights reserved.
//

#import "FTNavigationController.h"

@interface FTMainViewController : UIViewController <FTNavigationControllerDelegate>

- (id)initWithViewController:(FTNavigationController *)viewController;

@end
