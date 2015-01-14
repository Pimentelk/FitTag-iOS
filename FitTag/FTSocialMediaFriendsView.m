//
//  FTSocialMediaFriendsView.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import "FTSocialMediaFriendsView.h"

#define DATACELL_IDENTIFIER @"FollowCell"

@interface FTSocialMediaFriendsView()
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSArray *friends;
@end

@implementation FTSocialMediaFriendsView
@synthesize hud;
@synthesize headerView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    //self = [super initWithFrame:frame style:UITableViewStylePlain];
    self = [super initWithFrame:frame];
    
    if (self) {
        //[self setSeparatorColor:[UIColor clearColor]];
        
        UIView *headerViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        
        // Show gray line
        UIView *topLineViewGray = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        topLineViewGray.backgroundColor = [UIColor lightGrayColor];
        
        [headerViewContainer addSubview:topLineViewGray];
        
        // Show white line
        UIView *topLineViewWhite = [[UIView alloc] initWithFrame:CGRectMake(0, 1, frame.size.width, 1)];
        topLineViewWhite.backgroundColor = [UIColor whiteColor];
        
        [headerViewContainer addSubview:topLineViewWhite];
        
        UILabel *messageHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, frame.size.width, 24)];
        messageHeader.numberOfLines = 0;
        messageHeader.text = @"FRIENDS ON FITTAG";
        messageHeader.font = MULIREGULAR(20);
        messageHeader.backgroundColor = [UIColor clearColor];
        messageHeader.textAlignment = NSTextAlignmentCenter;
        
        [headerViewContainer addSubview:messageHeader];
        
        // Show gray line
        UIView *bottomLineViewGray = [[UIView alloc] initWithFrame:CGRectMake(0, headerViewContainer.frame.size.height-1, frame.size.width, 1)];
        bottomLineViewGray.backgroundColor = [UIColor lightGrayColor];
        
        [headerViewContainer addSubview:bottomLineViewGray];
        
        // Show white line
        UIView *bottomLineViewWhite = [[UIView alloc] initWithFrame:CGRectMake(0, headerViewContainer.frame.size.height, frame.size.width, 1)];
        bottomLineViewWhite.backgroundColor = [UIColor whiteColor];
        
        [headerViewContainer addSubview:bottomLineViewWhite];
        self.headerView = headerViewContainer;
        
        [self addSubview:self.headerView];
        
        if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    [self facebookRequestDidLoad:result];
                } else {
                    [self facebookRequestDidFailWithError:error];
                }
            }];
        } else {
            NSLog(@"is not linked with user...");
            [[[UIAlertView alloc] initWithTitle:@"Facebook Not Linked"
                                        message:@"Please visit the shared settings to link your FaceBook account."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }
    return self;
}

- (void)facebookRequestDidLoad:(id)result {
    PFUser *user = [PFUser currentUser];
    NSArray *data = [result objectForKey:@"data"];

    //NSLog(@"result:%@",result);
    //NSLog(@"data:%@",data);
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[FTCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if ([user objectForKey:kFTUserFacebookFriendsKey]) {
                [user removeObjectForKey:kFTUserFacebookFriendsKey];
            }
            
            // friends already on the app
            PFQuery *facebookFriendsQuery = [PFUser query];
            [facebookFriendsQuery whereKey:kFTUserFacebookIDKey containedIn:facebookIds];
            [facebookFriendsQuery findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
                if (!error) {
                    
                    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, self.frame.size.height - 30)];
                    [tableView setBackgroundColor:[UIColor clearColor]];
                    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
                    [tableView setSeparatorColor:[UIColor clearColor]];
                    [tableView setScrollEnabled:YES];
                    [tableView setRowHeight:40];
                    [tableView setDataSource:self];
                    [tableView setDelegate:self];
                    [tableView reloadData];
                    [self addSubview:tableView];
                    
                    //NSLog(@"friends:%@",friends);
                    
                    self.friends = friends;
                    [tableView reloadData];
                }
            }];
        }
    } else {
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"%@::facebookRequestDidFailWithError:",APPDELEGATE_RESPONDER);
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"tableView:cellForRowAtIndexPath:");
    
    FTFollowCell *cell = (FTFollowCell *)[tableView dequeueReusableCellWithIdentifier:DATACELL_IDENTIFIER];
    if (cell == nil) {
        cell = [[FTFollowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DATACELL_IDENTIFIER];
        cell.delegate = self;
    }
    
    if(indexPath.row != self.friends.count-1){
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        line.backgroundColor = [UIColor whiteColor];
        [cell addSubview:line];
    }
    
    [cell setUser:self.friends[indexPath.row]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

#pragma mark - FTFollowCellDelegate

- (void)followCell:(FTFollowCell *)inviteCell didTapProfileImage:(UIButton *)button user:(PFUser *)aUser {
    NSLog(@"%@::followCell:didTapProfileImage:user",VIEWCONTROLLER_INVITE);
    if (delegate && [delegate respondsToSelector:@selector(socialMediaFriendsView:didTapProfileImage:user:)]) {
        [delegate socialMediaFriendsView:self didTapProfileImage:button user:aUser];
    }
}

@end
