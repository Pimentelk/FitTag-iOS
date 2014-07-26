//
//  FitTagToolBar.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/13/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@protocol FitTagToolBarDelegate <UIToolbarDelegate>
@required
-(void)viewNotifications;
-(void)viewSearch;
-(void)viewMyProfile;
-(void)viewOffers;
@end

@interface FitTagToolBar : UIToolbar
@property (weak, nonatomic) id <FitTagToolBarDelegate> delegate;
@end
