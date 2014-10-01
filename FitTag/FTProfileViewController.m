//
//  ProfileViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 7/17/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTProfileViewController.h"
#import "FTCamViewController.h"

@interface FTProfileViewController ()
@end

@implementation FTProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle: @"ME"];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *backIndicator = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigate_back"] style:UIBarButtonItemStylePlain target:self action:@selector(returnHome:)];
    [backIndicator setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backIndicator];
    
    // Set Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Load Camera
    UIBarButtonItem *loadCamera = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fittag_button"] style:UIBarButtonItemStylePlain target:self action:@selector(loadCamera:)];
    [loadCamera setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:loadCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Get the classname of the next view controller
    NSUInteger numberOfViewControllersOnStack = [self.navigationController.viewControllers count];
    UIViewController *parentViewController = self.navigationController.viewControllers[numberOfViewControllersOnStack-1];
    Class parentVCClass = [parentViewController class];
    NSString *className = NSStringFromClass(parentVCClass);
    
    if([className isEqual: @"FTCamViewController"]){
        [self.navigationController setToolbarHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)returnHome:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadCamera:(id)sender
{
    FTCamViewController *cameraViewController = [[FTCamViewController alloc] init];
    [self.navigationController pushViewController:cameraViewController animated:YES];
}

@end
