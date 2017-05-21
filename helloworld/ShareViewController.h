//
//  ShareViewController.h
//  pickswipe
//
//  Created by Thomas Chen on 3/4/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ShareViewController : UIViewController <FBFriendPickerDelegate>
-(void) setShareUrl:(NSString *)url;
- (void)loginFailed;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) NSArray* selectedFriends;
@end
