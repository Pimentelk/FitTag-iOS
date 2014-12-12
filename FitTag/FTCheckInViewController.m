//
//  FTCheckInViewController.m
//  FitTag
//
//  Created by Kevin Pimentel on 12/7/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTCheckInViewController.h"

@interface FTCheckInViewController ()

@end

@implementation FTCheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
    [backButtonItem setStyle:UIBarButtonItemStylePlain];
    [backButtonItem setTarget:self];
    [backButtonItem setAction:@selector(didTapBackButtonAction:)];
    [backButtonItem setImage:[UIImage imageNamed:NAVIGATION_BAR_BUTTON_BACK]];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    CGRect headerViewFrame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    
    UIView *headerView = [[UIView alloc] initWithFrame:headerViewFrame];
    
    UITextField *locationTextField = [[UITextField alloc] initWithFrame:headerView.frame];
    locationTextField.font = [UIFont fontWithName:@"Gill Sans" size:11];
    locationTextField.returnKeyType = UIReturnKeySend;
    locationTextField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
    locationTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [locationTextField becomeFirstResponder];
    [headerView addSubview:locationTextField];
    
    [self.tableView setTableHeaderView:headerView];
    [self.tableView.tableHeaderView setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate


#pragma mark - ()

- (void)didTapBackButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
