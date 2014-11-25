//
//  InspirationViewController.h
//  FitTag
//
//  Created by Kevin Pimentel on 7/3/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

@interface FTInspirationViewController : UICollectionViewController <CLLocationManagerDelegate>
@property (nonatomic, strong) NSArray *interests;
@property (nonatomic, strong) NSArray *usersToRecommend;
//@property (nonatomic, strong) NSDictionary *usersToRecommend;
//@property (nonatomic, strong) NSDictionary *usersToRecommendInterests;
//@property (nonatomic, strong) NSArray *userKeys;
@end
