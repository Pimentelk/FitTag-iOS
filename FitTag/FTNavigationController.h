//
//  FitTagNavigationBar.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchViewController.h"

@class FTMapViewController;
@class FTFeedViewController;

@protocol FTNavigationControllerDelegate;
@interface FTNavigationController : UINavigationController

/*! @name Delegate */
@property (nonatomic,weak) id <FTNavigationControllerDelegate> myDelegate;

@property (nonatomic, strong) UISearchBar *searchBar;

- (id)initWithMapViewController:(FTMapViewController *)mapViewController;
- (id)initWithFeedViewController:(FTFeedViewController *)feedViewController;

@end

@protocol FTNavigationControllerDelegate <NSObject>
@optional
/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)navigationController:(FTNavigationController *)navigationController
            didTapMenuButton:(UIBarButtonItem *)button;

@end
