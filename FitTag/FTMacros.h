//
//  FTMacros.h
//  FitTag
//
//  Created by Kevin Pimentel on 10/23/14.
//  Copyright (c) 2014 Kevin Pimentel. All rights reserved.
//

#ifndef FitTag_FTMacros_h
#define FitTag_FTMacros_h

#define APP_NAME @"FitTag"
#define APP_VERSION @"2.0"
#define APP_STORE_ID @"com.library.FitTag"
#define FITTAG_LOGO @"fittag_logo"

// Font
#define BENDERSOLID(s) [UIFont fontWithName:@"BenderSolid" size:s]

// Blog
#define FITTAG_BLOG_URL @"http://www.fittag.com/blog"

// Backgrounds
#define BACKGROUND_FIND_FRIENDS @"login_background_image_05"

// Current Device Version
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_6_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_5_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)

// Delegate
#define APPDELEGATE_RESPONDER @"AppDelegate"

// ERROR CODES
#define ERROR_MESSAGE @"::::ERROR::::"

// Navigation Items
#define BACK_NAVIGATION_ITEM @"back_navigation_item"
#define FORWARD_NAVIGATION_ITEM @"forward_navigation_item"
#define REFRESH_NAVIGATION_ITEM @"refresh_navigation_item"

// UITabBar Tabs
#define TAB_NOTIFICATIONS 0
#define TAB_MAP 1
#define TAB_FEED 2
#define TAB_PROFILE 3
#define TAB_Rewards 4

// VIEW CONTROLLERS NAMES
#define VIEWCONTROLLER_NAVIGATION @"FTNavigationController"
#define VIEWCONTROLLER_POST_HEADER @"FTPostDetailsHeaderView"
#define VIEWCONTROLLER_ACTIVITY @"FTActivityFeedViewController"
#define VIEWCONTROLLER_MAP @"FTMapViewController"
#define VIEWCONTROLLER_CAM @"FTCamViewController"
#define VIEWCONTROLLER_CIRCLE @"FTCircleOverlay"
#define VIEWCONTROLLER_REWARDS @"FTRewardsCollectionViewController"
#define VIEWCONTROLLER_BUSINESS_ANNOTATION @"FTBusinessAnnotationView"
#define VIEWCONTROLLER_CONFIG @"FTConfigViewController"
#define VIEWCONTROLLER_TABBAR @"FTTabBarController"
#define VIEWCONTROLLER_REWARDS_DETAIL @"FTRewardsDetailView"
#define VIEWCONTROLLER_USER @"FTUserProfileCollectionViewController"
#define VIEWCONTROLLER_BUSINESS @"FTUserBusinessProfileCollectionViewController"
#define VIEWCONTROLLER_LOGIN @"FTLoginViewController"
#define VIEWCONTROLLER_SIGNUP @"FTSignupViewController"
#define VIEWCONTROLLER_INTERESTS @"FTInterestsViewController"
#define VIEWCONTROLLER_INSPIRATION @"FTInspirationViewController"
#define VIEWCONTROLLER_CAM_ROLL @"FTCamRollViewController"
#define VIEWCONTROLLER_EDIT_POST @"FTEditPostViewController"
#define VIEWCONTROLLER_EDIT_PHOTO @"FTEditPhotoViewController"
#define VIEWCONTROLLER_EDIT_VIDEO @"FTEditVideoViewController"
#define VIEWCONTROLLER_SETTINGS @"FTSettingsViewController"
#define VIEWCONTROLLER_SETTINGS_DETAIL @"FTSettingsDetailViewController"
#define VIEWCONTROLLER_USER_HEADER @"FTUserProfileHeaderView"
#define VIEWCONTROLLER_BUSINESS_HEADER @"FTUserProfileHeaderView"
#define VIEWCONTROLLER_COMMENT @"FTPostDetailsViewController"
#define VIEWCONTROLLER_POST_DETAIL @"FTPostDetailsViewController"
#define VIEWCONTROLLER_INVITE @"FTInviteFriendsViewController"
#define VIEWCONTROLLER_FOLLOW_CELL @"FTFollowCell"

// ACTION BUTTONS
#define ACTION_HEART @"heart_white"
#define ACTION_HEART_SELECTED @"heart_selected"
#define ACTION_LIKE_COMMENT_BOX @"like_comment_box"
#define ACTION_COMMENT_BUBBLE @"comment_bubble"
#define ACTION_MORE @"more_button"

#define COUNTER_ZERO 0

// NOTIFICATION TEXT
#define NOTIFICATION_TEXT_LIKED @"likes my post"
#define NOTIFICATION_TEXT_MENTION @"mentions me"
#define NOTIFICATION_TEXT_COMMENT @"comments on my post"
#define NOTIFICATION_TEXT_FOLLOW @"starts to follow me"

// SETTINGS FIELDS
#define SECTION_SETTINGS @"SETTINGS"
#define SECTION_EDIT_PROFILE @"EDIT PROFILE"
#define SECTION_APP_SETTINGS @"APP SETTINGS"
#define SECTION_ADDITIONAL_INFO @"ADDITIONAL INFO"

#define PROFILE_PICTURE @"Change Profile Picture"
#define COVER_PHOTO @"Change Cover Photo"
#define EDIT_BIO @"Edit Bio"

#define ADD_INTERESTS @"Add Interests"
#define INVITE_FRIENDS @"Invite Your Friends to FitTag"

#define SHARE_SETTINGS @"Share Settings"
#define NOTIFICATION_SETTINGS @"Notification Settings"
#define REWARD_SETTIGNS @"Reward Settings"

#define REVIEW_US @"Review Us"
#define GIVE_FEEDBACK @"Give Us Some Feedback"
#define ABOUT_US @"About #FitTag"
#define FITTAG_BLOG @"FitTag Blog"

// FT COLORS
#define FT_RED_COLOR_RED 234.0f/255.0f
#define FT_RED_COLOR_BLUE 37.0f/255.0f
#define FT_RED_COLOR_GREEN 37.0f/255.0f

#define FT_GRAY_COLOR_RED 234/255.0f
#define FT_GRAY_COLOR_BLUE 234/255.0f
#define FT_GRAY_COLOR_GREEN 234/255.0f

#define FT_DARKGRAY_COLOR_RED 154/255.0f
#define FT_DARKGRAY_COLOR_BLUE 154/255.0f
#define FT_DARKGRAY_COLOR_GREEN 154/255.0f

// LOCATION
#define LOCATION_USERS_WITHIN_MILES 10

// IMAGES
#define IMAGE_FOLLOW_SELECTED @"follow_selected"
#define IMAGE_FOLLOW_UNSELECTED @"follow_unselected"
#define IMAGE_PROFILE_DEFAULT @"posts_active"
#define IMAGE_TIMELINE_BLANK @"HomeTimelineBlank.png"
#define IMAGE_USERNAME_RIBBON @"username_ribbon"
#define IMAGE_PROFILE_EMPTY @"empty_profile"

// TAB NAVIGATION BAR BUTTONS
#define BUTTON_IMAGE_NOTIFICATIONS_SELECTED @"notifications_selected"
#define BUTTON_IMAGE_SEARCH_SELECTED @"search_selected"
#define BUTTON_IMAGE_USER_PROFILE_SELECTED @"profile_selected"
#define BUTTON_IMAGE_REWARDS_SELECTED @"rewards_selected"
#define BUTTON_IMAGE_FEED_SELECTED @"feed_selected"

#define BUTTON_IMAGE_NOTIFICATIONS @"notifications_unselected"
#define BUTTON_IMAGE_SEARCH @"search_unselected"
#define BUTTON_IMAGE_USER_PROFILE @"profile_unselected"
#define BUTTON_IMAGE_REWARDS @"rewards_unselected"
#define BUTTON_IMAGE_FEED @"feed_unselected"

// TAB NAVIGATION VIEW CONTROLLER TITLES
#define NAVIGATION_TITLE_MAP @"MAP"
#define NAVIGATION_TITLE_FEED @"FEED"
#define NAVIGATION_TITLE_SEARCH @"SEARCH"
#define NAVIGATION_TITLE_USER_PROFILE @"PROFILE"
#define NAVIGATION_TITLE_REWARDS @"REWARDS"
#define NAVIGATION_TITLE_NOTIFICATIONS @"NOTIFICATIONS"
#define NAVIGATION_TITLE_CAM @"TAG YOUR FIT"
#define NAVIGATION_TITLE_SETTINGS @"SETTINGS"
#define NAVIGATION_TITLE_COMMENT @"COMMENT"
#define NAVIGATION_TITLE_PROFILE @"PROFILE"

// NAVIGATION BAR BUTTONS
#define NAVIGATION_BAR_BUTTON_BACK @"navigate_back"
#define NAVIGATION_BAR_BUTTON_ADD_CONTACTS @"add_contacts"
#define NAVIGATION_BAR_BUTTON_CAMERA @"fittag_button"
#define NAVIGATION_BAR_BUTTON_TRASH @"trash"

// Messages
#define MESSAGE_TITTLE_MISSING_INFO @"Missing Information"
#define MESSAGE_MISSING_INFORMATION @"Make sure you fill out all required information!"
#define MESSAGE_CONFIRMED_MATCH @"Passwords entered to not match, please try again."
#define MESSAGE_NAME_EMPTY @"First and last name are required fields."
#define EMPTY_STRING @""
#define IF_USER_NOT_SET_MESSAGE @"user cannot be nil"
#define DEFAULT_BIO_TEXT_A @"Tell us about yourself"
#define DEFAULT_BIO_TEXT_B @"WHAT MAKES YOU, YOU?"
#define USER_DID_LOGIN @"User is logged in."
#define USER_NOT_LOGGEDIN @"User is NOT logged in."
#define USER_DID_LOGIN_FACEBOOK @"User is logged in with facebook"
#define USER_NOT_LOGIN_FACEBOOK @"User is not logged in to facebook"
#define USER_DID_LOGIN_TWITTER @"User is logged in with Twitter"
#define USER_NOT_LOGIN_TWITTER @"User is not logged in to Twitter"
#define RETURNING_USER @"This is a returning user."
#define FIRSTTIME_USER @"This is a firsttime user."

// File
#define FILE_SMALL_JPEG @"medium.jpeg"
#define FILE_MEDIUM_JPEG @"small.jpeg"
#define FILE_COVER_JPEG @"cover.jpeg"

// Mail
#define MAIL_CANCELLED @"Mail cancelled: you cancelled the operation and no email message was queued."
#define MAIL_SAVED @"Mail saved: you saved the email message in the drafts folder."
#define MAIL_SEND @"Mail send: the email message is queued in the outbox. It is ready to send."
#define MAIL_SENT @"Mail sent"
#define MAIL_FAIL @"Mail not sent"
#define MAIL_FEEDBACK_EMAIL @"feedback@fittag.com"
#define MAIL_TECH_EMAIL @"kevin@fittag.com"
#define MAIL_FEEDBACK_SUBJECT @"FitTag IOS Feedback"
#define MAIL_NOT_SUPPORTED @"Your device doesn't support the composer sheet"

#define HUD_MESSAGE_BIOGRAPHY_LIMIT @"150 character limit"
#define HUD_MESSAGE_BIOGRAPHY_UPDATED @"Biography updated.."
#define HUD_MESSAGE_INTERESTS_UPDATED @"Interests updated.."
#define HUD_EMPTY_BIOGRAPHY_TITLE @"Empty Biography"
#define HUD_EMPTY_BIOGRAPHY_MESSAGE @"You can not submit an empty biography."

// Switch messages
#define SWITCH_REWARD_ON @"rewards enabled"
#define SWITCH_REWARD_OFF @"rewards disabled"
#define SWITCH_NOTIFICATIONS_ON @"notifications enabled"
#define SWITCH_NOTIFICATIONS_OFF @"notifications disabled"
#define SWITCH_FACEBOOK_ON @"facebook sharing enabled"
#define SWITCH_FACEBOOK_OFF @"facebook sharing disabled"
#define SWITCH_TWITTER_ON @"twitter sharing enabled"
#define SWITCH_TWITTER_OFF @"twitter sharing disabled"

// Socail
#define SOCIAL_TWITTER @"Twitter"
#define SOCIAL_FACEBOOK @"Facebook"

// Twitter Object Keys
#define TWITTER_PROFILE_HTTPS @"profile_image_url_https"

#define PARSE_HOST @"api.parse.com"
#define FACEBOOK_GRAPH_PICTURES_URL @"https://graph.facebook.com/%@/picture?type=large&width=600&height=600"
#define TWITTER_API_USERS @"https://api.twitter.com/1.1/users/show.json?screen_name=%@"

/****************** KEYS *********************/

// GOOGLE
#define GOOGLE_ANALYTICS_TRACKING_ID @"UA-55852213-1"

// PARSE
#define PARSE_APPLICATION_ID @"9Cii0KKJr09vtACtVRSccu1BHGFJYR6c6XYkafb1"
#define PARSE_CLIENT_KEY @"eJxD9HcQ5ZK8GPYxaMz4RkrOjo2mMtujGsgn1HZe"

// TWITTER
#define TWITTER_CONSUMER_KEY @"oNqZ0kZQxrAEHeMggEvls5VdJ"
#define TWITTER_CONSUMER_SECRET @"cvltCUyuouYILtFlsf05G1eA1C7J7ZCDUQkO5iawD9RRabnPte"

/****************** KEYS END ******************/

#endif
