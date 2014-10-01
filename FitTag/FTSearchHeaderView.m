//
//  FTSearchHeaderView.m
//  FitTag
//
//  Created by Kevin Pimentel on 9/2/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSearchHeaderView.h"
#import "FTProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "FTUtility.h"

@interface FTSearchHeaderView()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *filterView;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *popularButton;
@property (nonatomic, strong) UIButton *trendingButton;
@property (nonatomic, strong) UIButton *userButtons;
@property (nonatomic, strong) UIButton *businessButton;
@property (nonatomic, strong) UIButton *ambassadorButton;
@property (nonatomic, strong) UIButton *nearbyButton;
@end

@implementation FTSearchHeaderView
@synthesize delegate;
@synthesize containerView;
@synthesize filterView;
@synthesize filterButton;
@synthesize popularButton;
@synthesize trendingButton;
@synthesize userButtons;
@synthesize businessButton;
@synthesize ambassadorButton;
@synthesize nearbyButton;
@synthesize searchbar;

- (id)initWithFrame:(CGRect)frame {
    NSLog(@"FTSearchHeaderView::initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        
        containerView = [[UIView alloc] initWithFrame:frame];
        
        UIImageView *searchbarBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar"]];
        [searchbarBackground setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 35.0f)];
        [searchbarBackground setUserInteractionEnabled:YES];
        [containerView addSubview:searchbarBackground];
        
        searchbar = [[UITextField alloc] init];
        [searchbar setFrame:CGRectMake(7.0f, 1.0f, 280.0f, 31.0f)];
        [searchbar setFont:[UIFont systemFontOfSize:12.0f]];
        [searchbar setReturnKeyType:UIReturnKeyGo];
        [searchbar setTextColor:[UIColor blackColor]];
        [searchbar setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [searchbar setBackgroundColor:[UIColor clearColor]];
        [searchbar setPlaceholder:@"Search..."];
        //[searchbar setDelegate:self];
        [containerView addSubview:searchbar];
        [containerView bringSubviewToFront:searchbar];
        
        filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterButton setFrame: CGRectMake( self.containerView.bounds.size.width - 30.0f, 7.0f, 20.0f, 20.0f)];
        [filterButton setBackgroundColor:[UIColor clearColor]];
        [filterButton setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        [filterButton addTarget:self action:@selector(showFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:filterButton];
        [containerView bringSubviewToFront:filterButton];
        
        filterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.containerView.bounds.size.height, self.frame.size.width, 56.0f)];
        [filterView setBackgroundColor:[UIColor clearColor]];
        [filterView setUserInteractionEnabled:YES];
        [containerView addSubview:filterView];
        [containerView setUserInteractionEnabled:YES];
        [containerView bringSubviewToFront:filterView];
        
        popularButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [popularButton setFrame: CGRectMake( 0.0f, 0.0f, 50.0f, 56.0f)];
        [popularButton setBackgroundColor:[UIColor clearColor]];
        [popularButton setBackgroundImage:[UIImage imageNamed:@"search_popular"] forState:UIControlStateNormal];
        [popularButton setBackgroundImage:[UIImage imageNamed:@"search_popular_selected"] forState:UIControlStateSelected];
        [popularButton setBackgroundImage:[UIImage imageNamed:@"search_popular_selected"] forState:UIControlStateHighlighted];
        [popularButton addTarget:self action:@selector(popularButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:popularButton];
        [filterView bringSubviewToFront:popularButton];
        [filterView setUserInteractionEnabled:YES];
        
        trendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [trendingButton setFrame: CGRectMake( popularButton.frame.origin.x + popularButton.frame.size.width, 0.0f, 48.0f, 56.0f)];
        [trendingButton setBackgroundColor:[UIColor clearColor]];
        [trendingButton setBackgroundImage:[UIImage imageNamed:@"search_trending"] forState:UIControlStateNormal];
        [trendingButton setBackgroundImage:[UIImage imageNamed:@"search_trending_selected"] forState:UIControlStateSelected];
        [trendingButton setBackgroundImage:[UIImage imageNamed:@"search_trending_selected"] forState:UIControlStateHighlighted];
        [trendingButton addTarget:self action:@selector(trendingButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:trendingButton];
        [filterView bringSubviewToFront:trendingButton];
        [filterView setUserInteractionEnabled:YES];
        
        userButtons = [UIButton buttonWithType:UIButtonTypeCustom];
        [userButtons setFrame: CGRectMake( trendingButton.frame.origin.x + trendingButton.frame.size.width, 0.0f, 62.0f, 56.0f)];
        [userButtons setBackgroundColor:[UIColor clearColor]];
        [userButtons setBackgroundImage:[UIImage imageNamed:@"search_users"] forState:UIControlStateNormal];
        [userButtons setBackgroundImage:[UIImage imageNamed:@"search_users_selected"] forState:UIControlStateSelected];
        [userButtons setBackgroundImage:[UIImage imageNamed:@"search_users_selected"] forState:UIControlStateHighlighted];
        [userButtons addTarget:self action:@selector(userButtonsHandler:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:userButtons];
        [filterView bringSubviewToFront:userButtons];
        [filterView setUserInteractionEnabled:YES];
        
        businessButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [businessButton setFrame: CGRectMake( userButtons.frame.origin.x + userButtons.frame.size.width, 0.0f, 56.0f, 56.0f)];
        [businessButton setBackgroundColor:[UIColor clearColor]];
        [businessButton setBackgroundImage:[UIImage imageNamed:@"search_business"] forState:UIControlStateNormal];
        [businessButton setBackgroundImage:[UIImage imageNamed:@"search_business_selected"] forState:UIControlStateSelected];
        [businessButton setBackgroundImage:[UIImage imageNamed:@"search_business_selected"] forState:UIControlStateHighlighted];
        [businessButton addTarget:self action:@selector(businessButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:businessButton];
        [filterView bringSubviewToFront:businessButton];
        [filterView setUserInteractionEnabled:YES];
        
        ambassadorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [ambassadorButton setFrame: CGRectMake( businessButton.frame.origin.x + businessButton.frame.size.width, 0.0f, 56.0f, 56.0f)];
        [ambassadorButton setBackgroundColor:[UIColor clearColor]];
        [ambassadorButton setBackgroundImage:[UIImage imageNamed:@"search_ambassador"] forState:UIControlStateNormal];
        [ambassadorButton setBackgroundImage:[UIImage imageNamed:@"search_ambassador_selected"] forState:UIControlStateSelected];
        [ambassadorButton setBackgroundImage:[UIImage imageNamed:@"search_ambassador_selected"] forState:UIControlStateHighlighted];
        [ambassadorButton addTarget:self action:@selector(ambassadorButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:ambassadorButton];
        [filterView bringSubviewToFront:ambassadorButton];
        [filterView setUserInteractionEnabled:YES];
        
        nearbyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nearbyButton setFrame: CGRectMake( ambassadorButton.frame.origin.x + ambassadorButton.frame.size.width, 0.0f, 48.0f, 56.0f)];
        [nearbyButton setBackgroundColor:[UIColor clearColor]];
        [nearbyButton setBackgroundImage:[UIImage imageNamed:@"search_nearby"] forState:UIControlStateNormal];
        [nearbyButton setBackgroundImage:[UIImage imageNamed:@"search_nearby_selected"] forState:UIControlStateSelected];
        [nearbyButton setBackgroundImage:[UIImage imageNamed:@"search_nearby_selected"] forState:UIControlStateHighlighted];
        [nearbyButton addTarget:self action:@selector(nearbyButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [nearbyButton setEnabled:NO];
        [nearbyButton setUserInteractionEnabled:NO];
        
        [filterView addSubview:nearbyButton];
        [filterView bringSubviewToFront:nearbyButton];
        [filterView setUserInteractionEnabled:YES];
        [filterView setHidden:YES];
        
        [self addSubview:containerView];
    }
    return self;
}

#pragma mark - ()

- (void)clearSelectedFilters{
    [popularButton setSelected:NO];
    [trendingButton setSelected:NO];
    [userButtons setSelected:NO];
    [businessButton setSelected:NO];
    [ambassadorButton setSelected:NO];
    [nearbyButton setSelected:NO];
}

- (void)popularButtonHandler:(id)sender{
    if(![popularButton isSelected]){
        [popularButton setSelected:YES];
    } else {
        [popularButton setSelected:NO];
    }
}

- (void)trendingButtonHandler:(id)sender{
    if(![trendingButton isSelected]){
        [trendingButton setSelected:YES];
    } else {
        [trendingButton setSelected:NO];
    }
}

- (void)userButtonsHandler:(id)sender{
    if(![userButtons isSelected]){
        [userButtons setSelected:YES];
    } else {
        [userButtons setSelected:NO];
    }
}

- (void)businessButtonHandler:(id)sender{
    if(![businessButton isSelected]){
        [businessButton setSelected:YES];
    } else {
        [businessButton setSelected:NO];
    }
}

- (void)ambassadorButtonHandler:(id)sender{
    if(![ambassadorButton isSelected]){
        [ambassadorButton setSelected:YES];
    } else {
        [ambassadorButton setSelected:NO];
    }
}

- (void)nearbyButtonHandler:(id)sender{
    if(![nearbyButton isSelected]){
        [nearbyButton setSelected:YES];
    } else {
        [nearbyButton setSelected:NO];
    }
}

- (BOOL)isPopularButtonSelected{
    return [popularButton isSelected];
}

- (BOOL)isTrendingButtonSelected{
    return [trendingButton isSelected];
}

- (BOOL)isUserButtonSelected{
    return [userButtons isSelected];
}

- (BOOL)isBusinessButtonSelected{
    return [businessButton isSelected];
}

- (BOOL)isAmbassadorButtonSelected{
    return [ambassadorButton isSelected];
}

- (BOOL)isNearbyButtonSelected{
    return [nearbyButton isSelected];
}

- (void)showFilterOptions:(id)sender{
    [filterButton setBackgroundImage:[UIImage imageNamed:@"cancelfilter"] forState:UIControlStateNormal];
    [filterButton setFrame: CGRectMake( self.containerView.bounds.size.width - 30.0f, 7.0f, 23.0f, 21.0f)];
    
    // Resize frame
    CGRect frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 91.0f);
    [self didChangeFrameAction:frame];
    [self.containerView setFrame:frame];
    
    [filterButton removeTarget:self action:@selector(showFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterButton addTarget:self action:@selector(hideFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterView setHidden:NO];
}

-(void)hideFilterOptions:(id)sender{
    [filterButton setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [filterButton setFrame: CGRectMake( self.containerView.bounds.size.width - 30.0f, 7.0f, 23.0f, 21.0f)];
    
    // Resize frame
    CGRect frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 35.0f);
    [self didChangeFrameAction:frame];
    [self.containerView setFrame:frame];
    
    [filterButton removeTarget:self action:@selector(hideFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterButton addTarget:self action:@selector(showFilterOptions:) forControlEvents:UIControlEventTouchUpInside];
    [filterView setHidden:YES];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - ()

- (void)didChangeFrameAction:(CGRect)rect {
    NSLog(@"(void)didChangeFrameAction:(CGRect)rect");
    if (delegate && [delegate respondsToSelector:@selector(searchHeaderView:didChangeFrameSize:)]) {
        [delegate searchHeaderView:self didChangeFrameSize:rect];
    }
}

@end
