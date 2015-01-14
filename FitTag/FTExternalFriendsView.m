//
//  FTExternalFriendsView.m
//  FitTag
//
//  Created by Kevin Pimentel on 11/25/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "FTExternalFriendsView.h"
#import "UIView+FormScroll.h"

#define REUSABLE_IDENTIFIER @"ExternalCell"

// INVITE FRIENDS BUTTONS
#define INVITE_CONTACT_ACTIVE @"invite_contact_active"
#define INVITE_CONTACT_INACTIVE @"invite_contact_inactive"

#define INVITE_FACEBOOK_ACTIVE @"invite_facebook_active"
#define INVITE_FACEBOOK_INACTIVE @"invite_facebook_inactive"
#define INVITE_FACEBOOK_SHARE @"invite_share_button"

#define INVITE_TWITTER_TWEET @"invite_tweet_button"
#define INVITE_TWITTER_ACTIVE @"invite_post_tweet"
#define INVITE_TWITTER_INACTIVE @"invite_twitter_inactive"

#define TABBAR_HEIGHT 0
#define TAB_COUNT 3
#define TAB_BUTTON_WIDTH 95
#define TAB_BUTTON_HEIGHT 29

#define FB_SHAREIT_BUTTON_WIDTH 94
#define FB_SHAREIT_BUTTON_HEIGHT 20
#define FACEBOOKSHAREITX(w,w1) (w - w1) / 2
#define FACEBOOKSHAREITY(h,h1) h + h1 + 10

// Formula to calculate tab button X's
// ALLOWEDAREA = ViewWidth / Tabs
// x = Position * ALLOWEDAREA
// Padding = (ALLOWEDAREA - TAB_BUTTON_WIDTH ) / 2
// Xn = x + Padding
// (Position * ALLOWEDAREA(W)) + ((ALLOWEDAREA - TAB_BUTTON_WIDTH ) / 2)
// (p * a) + ((a - TAB_BUTTON_WIDTH) / 2)

#define ALLOWEDAREA(s) s / TAB_COUNT
#define GET_TAB_BUTTON_X(p,a) (p * a) + ((a - TAB_BUTTON_WIDTH) / 2)
//(shareItContainer.frame.size.width - TextViewWidth) / 2
#define SOCIALTEXTVIEWX(w,w1) (w1 - w) / 2

@interface FTExternalFriendsView()
@property (nonatomic, strong) UIButton *contactsButton;
@property (nonatomic, strong) UIButton *twitterButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIView *shareItContainer;
@property (nonatomic, strong) PFObject *invitePost;
@property (nonatomic, strong) UITextView *facebookTextView;
@property (nonatomic, strong) UITextView *twitterTextView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contactLabels;
@end

@implementation FTExternalFriendsView
@synthesize contactsButton;
@synthesize twitterButton;
@synthesize facebookButton;
@synthesize shareItContainer;
@synthesize facebookTextView;
@synthesize twitterTextView;
@synthesize tableView;
@synthesize selectedContacts;
@synthesize contactLabels;
//@synthesize selectedContact;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    //self = [super initWithFrame:frame style:UITableViewStylePlain];
    self = [super initWithFrame:frame];
    
    if (self) {
        //[self setSeparatorColor:[UIColor clearColor]];
        
        contactLabels = [[NSMutableArray alloc] init];
        selectedContacts = [[NSMutableArray alloc] init];
        
        UIView *headerViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 65)];
        
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
        messageHeader.text = @"INVITE FRIENDS TO FITTAG";
        messageHeader.font = MULIREGULAR(18);
        messageHeader.backgroundColor = [UIColor clearColor];
        messageHeader.textAlignment = NSTextAlignmentCenter;

        [headerViewContainer addSubview:messageHeader];
        
        CGFloat tabButtonsY = messageHeader.frame.origin.y + messageHeader.frame.size.height + 5;
        CGFloat tabButtonsWidth = TAB_BUTTON_WIDTH;
        CGFloat tabButtonsHeight = TAB_BUTTON_HEIGHT;
        CGFloat tabButtonsAllowedArea = ALLOWEDAREA(self.frame.size.width);
        
        contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [contactsButton setFrame:CGRectMake(GET_TAB_BUTTON_X(0,tabButtonsAllowedArea), tabButtonsY, tabButtonsWidth, tabButtonsHeight)];
        [contactsButton setImage:[UIImage imageNamed:INVITE_CONTACT_INACTIVE] forState:UIControlStateNormal];
        [contactsButton setImage:[UIImage imageNamed:INVITE_CONTACT_ACTIVE] forState:UIControlStateSelected];
        [contactsButton addTarget:self action:@selector(didTapContactButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerViewContainer addSubview:contactsButton];
        
        twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [twitterButton setFrame:CGRectMake(GET_TAB_BUTTON_X(1,tabButtonsAllowedArea), tabButtonsY, tabButtonsWidth, tabButtonsHeight)];
        [twitterButton setImage:[UIImage imageNamed:INVITE_TWITTER_INACTIVE] forState:UIControlStateNormal];
        [twitterButton setImage:[UIImage imageNamed:INVITE_TWITTER_ACTIVE] forState:UIControlStateSelected];
        [twitterButton addTarget:self action:@selector(didTapTwitterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [twitterButton setSelected:NO];
        
        [headerViewContainer addSubview:twitterButton];
        
        facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [facebookButton setFrame:CGRectMake(GET_TAB_BUTTON_X(2,tabButtonsAllowedArea), tabButtonsY, tabButtonsWidth, tabButtonsHeight)];
        [facebookButton setImage:[UIImage imageNamed:INVITE_FACEBOOK_INACTIVE] forState:UIControlStateNormal];
        [facebookButton setImage:[UIImage imageNamed:INVITE_FACEBOOK_ACTIVE] forState:UIControlStateSelected];
        [facebookButton addTarget:self action:@selector(didTapFacebookButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [facebookButton setSelected:NO];
        
        [headerViewContainer addSubview:facebookButton];
        
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
        
        CGRect headerFrame = self.headerView.frame;
        CGFloat rectY = headerFrame.size.height + headerFrame.origin.y;
        CGFloat rectHeight = self.frame.size.height - headerFrame.size.height - TABBAR_HEIGHT;
        CGRect rect = CGRectMake(0, rectY, headerFrame.size.width, rectHeight);
        
        shareItContainer = [[UIView alloc] initWithFrame:rect];
        [self addSubview:shareItContainer];
        
        tableView = [[UITableView alloc] initWithFrame:rect];
        [tableView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:tableView];
        
        //NSLog(@"self.headerView.frame.size.height - self.frame.size.height: %f",self.headerView.frame.size.height - self.frame.size.height);
        
        [self didTapContactButtonAction:nil];
        [contactsButton setSelected:YES];
    }
    return self;
}

- (void)clearSelectedButtons {
    [contactsButton setSelected:NO];
    [facebookButton setSelected:NO];
    [twitterButton setSelected:NO];
}

- (void)didTapContactButtonAction:(UIButton *)button {
    [self clearSelectedButtons];
    [button setSelected:![button isSelected]];
    
    // Clear subviews
    for (UIView *view in shareItContainer.subviews) {
        [view removeFromSuperview];
    }
    [shareItContainer setHidden:YES];
    [self sendSubviewToBack:shareItContainer];
    
    //NSLog(@"didTapContactButtonAction:");
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if (status == kABAuthorizationStatusDenied) {
        // if you got here, user had previously denied/revoked permission for your
        // app to access the contacts, and all you can do is handle this gracefully,
        // perhaps telling the user that they have to go to settings to grant access
        // to contacts
        
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"Permission is required to access the contacts. Please visit to the \"Privacy\" section in the iPhone Settings app."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (error) {
        //NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
        if (addressBook) CFRelease(addressBook);
        return;
    }
    
    if (status == kABAuthorizationStatusNotDetermined) {
        
        // present the user the UI that requests permission to contacts        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                //NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
            }
            
            if (granted) {
                [self listPeopleInAddressBook:addressBook];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:@"Permission is required to access the contacts. Please visit to the \"Privacy\" section in the iPhone Settings app."
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                });
            }
            
            if (addressBook) CFRelease(addressBook);
        });
        
    } else if (status == kABAuthorizationStatusAuthorized) {
        [self listPeopleInAddressBook:addressBook];
        if (addressBook) CFRelease(addressBook);
    } else {
        if (addressBook) CFRelease(addressBook);
    }
}

- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook {
    
    // Clear subviews
    for (UIView *view in shareItContainer.subviews) {
        [view removeFromSuperview];
    }
    [shareItContainer setHidden:YES];
    [self sendSubviewToBack:shareItContainer];
    
    [tableView setHidden:NO];
    [self bringSubviewToFront:tableView];
    
    if (self.contacts) {
        return;
    }
    
    self.contacts = [[NSMutableArray alloc] init];
    
    //NSInteger numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    NSArray *contacts = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    
    int i = 0;
    for (NSArray *contact in contacts) {
        UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 240, 40)];
        [contactLabel setTextAlignment: NSTextAlignmentLeft];
        [contactLabel setUserInteractionEnabled: YES];
        [contactLabel setFont:SYSTEMFONTBOLD(16)];
        [contactLabel setTextColor: [UIColor blackColor]];
        [contactLabel setAdjustsFontSizeToFitWidth:NO];
        [contactLabel setNumberOfLines:0];
        
        ABRecordRef person = (__bridge ABRecordRef)contact;
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            
            //NSLog(@"phoneNumber:%@ Length:%ld",phoneNumber,phoneNumber.length);
            
            if (!phoneNumber || phoneNumber.length < 10) {
                continue;
            }
            
            [contactLabel setText:[NSString stringWithFormat:@"%@\n%@",firstName, phoneNumber]];
            [self.contacts addObject:phoneNumber];
            [contactLabels addObject:contactLabel];
        }
        
        CFRelease(phoneNumbers);
        i++;
    }
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setScrollEnabled:YES];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [tableView setRowHeight:40];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView reloadData];
}

- (void)didTapTwitterButtonAction:(UIButton *)button {
    [self clearSelectedButtons];
    [button setSelected:![button isSelected]];
    
    [shareItContainer setHidden:NO];
    [self bringSubviewToFront:shareItContainer];
    
    [tableView setHidden:YES];
    [self sendSubviewToBack:tableView];
    
    // Clear subviews
    for (UIView *view in shareItContainer.subviews) {
        [view removeFromSuperview];
    }
    
    // UITextViews
    twitterTextView = [[UITextView alloc] initWithFrame:CGRectMake(SOCIALTEXTVIEWX(300,self.frame.size.width), 0, 300, 75)];
    [twitterTextView setBackgroundColor:[UIColor whiteColor]];
    [twitterTextView setText:@"I am ready to start my journey with fittag! I will earn rewards just by being healthy. Join me!"];
    [twitterTextView setFont:MULIREGULAR(16)];
    [twitterTextView setTextAlignment:NSTextAlignmentCenter];
    [twitterTextView setEditable:YES];
    
    [shareItContainer addSubview:twitterTextView];
    
    UIButton *twitterShareItButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterShareItButton setFrame:CGRectMake(FACEBOOKSHAREITX(shareItContainer.frame.size.width,FB_SHAREIT_BUTTON_WIDTH),
                                               FACEBOOKSHAREITY(twitterTextView.frame.origin.y,twitterTextView.frame.size.height),
                                               FB_SHAREIT_BUTTON_WIDTH, FB_SHAREIT_BUTTON_HEIGHT)];
    [twitterShareItButton setImage:[UIImage imageNamed:INVITE_TWITTER_TWEET] forState:UIControlStateNormal];
    [twitterShareItButton addTarget:self action:@selector(didTapTwitterShareItButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [shareItContainer addSubview:twitterShareItButton];
}

- (void)didTapFacebookButtonAction:(UIButton *)button {
    NSLog(@"didTapFacebookButtonAction");
    
    [self clearSelectedButtons];
    
    [button setSelected:![button isSelected]];
    
    [shareItContainer setHidden:NO];
    [self bringSubviewToFront:shareItContainer];
    
    [tableView setHidden:YES];
    [self sendSubviewToBack:tableView];
    
    
    // Clear subviews
    for (UIView *view in shareItContainer.subviews) {
        [view removeFromSuperview];
    }
    
    // UITextViews
    facebookTextView = [[UITextView alloc] initWithFrame:CGRectMake(SOCIALTEXTVIEWX(300, self.frame.size.width), 0, 300, 75)];
    [facebookTextView setBackgroundColor:[UIColor whiteColor]];
    [facebookTextView setText:@"I am ready to start my journey with #FitTag! I will earn rewards just by being healthy. Join me!"];
    [facebookTextView setFont:MULIREGULAR(16)];
    [facebookTextView setTextAlignment:NSTextAlignmentCenter];
    [facebookTextView setEditable:NO];
    
    [shareItContainer addSubview:facebookTextView];
    
    UIButton *facebookShareItButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookShareItButton setFrame:CGRectMake(FACEBOOKSHAREITX(shareItContainer.frame.size.width,FB_SHAREIT_BUTTON_WIDTH),
                                               FACEBOOKSHAREITY(facebookTextView.frame.origin.y,facebookTextView.frame.size.height),
                                               FB_SHAREIT_BUTTON_WIDTH, FB_SHAREIT_BUTTON_HEIGHT)];
    [facebookShareItButton setImage:[UIImage imageNamed:INVITE_FACEBOOK_SHARE] forState:UIControlStateNormal];
    [facebookShareItButton addTarget:self action:@selector(didTapFacebookShareItButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareItContainer addSubview:facebookShareItButton];
}

- (void)didTapTwitterShareItButtonAction:(UIButton *)button {
    //NSLog(@"didTapTwitterShareButtonAction:");
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSString *url = @"http://fittag.com";
        NSString *status = [NSString stringWithFormat:@"I am ready to start my journey with #FitTag! I will earn rewards just by being healthy. Join me! %@",url];
        [FTUtility shareCapturedMomentOnTwitter:status];
    } else {
        // Twitter account is not linked
        [[[UIAlertView alloc] initWithTitle:@"Twitter Not Linked"
                                    message:@"Please visit the shared settings to link your Twitter account."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
}

- (void)didTapFacebookShareItButtonAction:(UIButton *)button {
    //NSLog(@"didTapFacebookShareItButtonAction:");
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // Facebook account is linked
        NSString *description = facebookTextView.text;
        [FTUtility shareCapturedMomentOnFacebook:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  @"Starting My #FitTag Journey", @"name",
                                                  @"Changing The Way You Get Fit", @"caption",
                                                  description, @"description",
                                                  @"http://fittag.com", @"link",
                                                  @"http://fittag.com/images/fittag_shareable.png", @"picture", nil]];
        
    } else {
        NSLog(@"is not linked with user...");
        [[[UIAlertView alloc] initWithTitle:@"Facebook Not Linked"
                                    message:@"Please visit the shared settings to link your FaceBook account."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
}

- (void)querySearchForUser {
    // List of all users on fittag that are also friends on facebook or followed on twitter
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FTContactCell *cell = [[FTContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSABLE_IDENTIFIER];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setDelegate:self];
    [cell setTag:indexPath.row];
    [cell setContactLabel:contactLabels[indexPath.row]];
    [cell.selectUserButton setSelected:NO];
    
    if ([selectedContacts containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
        [cell.selectUserButton setSelected:YES];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contactLabels.count;
}

#pragma mark - FTContactCellDelegate

- (void)contactCell:(FTContactCell *)contactCell didTapSelectButton:(UIButton *)button index:(NSInteger)index {
    [selectedContacts addObject:[NSString stringWithFormat:@"%ld",(long)index]];
}

- (void)contactCell:(FTContactCell *)contactCell didTapUnselectButton:(UIButton *)button index:(NSInteger)index {
    NSString *indexString = [NSString stringWithFormat:@"%ld",(long)index];
    if ([selectedContacts containsObject:indexString]) {
        [selectedContacts removeObject:indexString];
    }    
}

@end
