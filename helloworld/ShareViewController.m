//
//  ShareViewController.m
//  pickswipe
//
//  Created by Thomas Chen on 3/4/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ShareViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface ShareViewController ()
- (IBAction)backClicked:(id)sender;
- (IBAction)performLogin:(id)sender;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;

- (IBAction)emailClicked:(id)sender;
@end

@implementation ShareViewController
@synthesize friendPickerController = _friendPickerController;
@synthesize selectedFriends = _selectedFriends;
@synthesize emailButton = _emailButton;
@synthesize facebookButton = _facebookButton;
@synthesize feedbackLabel = _feedbackLabel;
NSString *shareUrl;
NSString *ownId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.emailButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.emailButton.layer.borderWidth = 4.0;
    self.emailButton.layer.cornerRadius = 10.0;
    self.emailButton.layer.masksToBounds = YES;
    
    self.facebookButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.facebookButton.layer.borderWidth = 4.0;
    self.facebookButton.layer.cornerRadius = 10.0;
    self.facebookButton.layer.masksToBounds = YES;
    
    self.userProfileImage.alpha = 0.0;
    self.feedbackLabel.alpha = 0.0;
    
    self.feedbackLabel.numberOfLines = 0;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:SessionStateChangedNotification
     object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if (FBSession.activeSession.isOpen) {
            NSLog(@"got in herE");
        [self populateUserDetails];
    }
}

- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)performLogin:(id)sender {
    [self openSession];
}

- (void)loginFailed {
    NSLog(@"login failed");
}

-(void) setShareUrl:(NSString *)url {
    shareUrl = url;
}

- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {

             if (!error) {
                 ownId = user.id;
                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:OwnIdStateChangeNotification
                  object:nil];
                 
//                 NSLog(@"%lu", (unsigned long)self.selectedFriends.count);
                 if(self.selectedFriends.count > 0) {
                     NSDictionary<FBGraphUser> *friend1 = [self.selectedFriends objectAtIndex:0];
                     NSLog(@"id:%@", friend1.id);
                     self.userProfileImage.profileID = friend1.id;
                     self.feedbackLabel.text = @"Sent to your friend!";
                     self.feedbackLabel.alpha = 1.0;
                     self.userProfileImage.alpha = 1.0;
                 } else {
//                     NSLog(@"id:%@", user.id);
//                     self.userProfileImage.profileID = user.id;
                     self.feedbackLabel.alpha = 0.0;
                     self.userProfileImage.alpha = 0.0;
                 }
             }
         }];
    }
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
//    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
//    for (id<FBGraphUser> user in self.friendPickerController.selection) {
//        if ([text length]) {
//            [text appendString:@", "];
//        }
//        [text appendString:user.name];
//    }
    self.selectedFriends = self.friendPickerController.selection;
    [self populateUserDetails];
    [self sendToFriend];
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"FB done");
}

- (void)facebookViewControllerCancelWasPressed:(id)sender{
    NSLog(@"FB canceled");
    self.feedbackLabel.alpha = 0.0;
    self.userProfileImage.alpha = 0.0;
    [self dismissModalViewControllerAnimated:YES];
}

-(void)sendToFriend {

    if(self.selectedFriends.count > 0) {
        NSDictionary<FBGraphUser> *friend1 = [self.selectedFriends objectAtIndex:0];
        
        NSMutableString *postURL = [[NSMutableString alloc] init];
        [postURL appendString:@"http://"];
        [postURL appendString:SITE_DOMAIN];
        [postURL appendString:@"/ritelike/funny"];
        NSLog(@"URL:%@", postURL);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        
        NSDictionary *initialLogAsJSON = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:shareUrl, friend1.id, ownId, nil] forKeys:[NSArray arrayWithObjects:@"url", @"to_id", @"from_id", nil]];
        
        NSLog(@"posting:%@", initialLogAsJSON);
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:initialLogAsJSON options:NSJSONWritingPrettyPrinted error:&error];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: jsonData];
        
        // Asynchronous
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(error) {
                                       NSLog(@"error post");
                                    } else {
                                        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   
                                        NSLog(@"success post %@", responseString);
                                    }
                               }];
    }
    
    
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{

    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"open state");
            if (!self.friendPickerController) {
                
                self.friendPickerController = [[FBFriendPickerViewController alloc]
                                               initWithNibName:nil bundle:nil];
                self.friendPickerController.title = @"Select friends";
                self.friendPickerController.delegate = self;
            }
            
            [self.friendPickerController loadData];
            [self.friendPickerController clearSelection];
            self.selectedFriends = [[NSArray alloc] init];
            
//            [self.navigationController pushViewController:self.friendPickerController animated:true];
            [self presentModalViewController:self.friendPickerController animated:YES];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
//            [[[[UIApplication sharedApplication] delegate] getNavController] popToRootViewControllerAnimated:NO];
            
//            [FBSession.activeSession closeAndClearTokenInformation];
            
//            [self showLoginView];
            NSLog(@"closed/error state");
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }    
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (IBAction)emailClicked:(id)sender {
    NSString *htmlBody = @"";
    NSLog(@"%@", shareUrl);
    NSString *currentImageURL = shareUrl;
    htmlBody = [htmlBody stringByAppendingString:currentImageURL];
    
    // First escape the body using a CF call
    NSString *escapedBody = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  (CFStringRef)htmlBody, NULL,  CFSTR("?=&+"), kCFStringEncodingUTF8));
    
    // Then escape the prefix using the NSString method
    NSString *mailtoPrefix = [@"mailto:?subject=hope you get a laugh from this :)&body=" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // Finally, combine to create the fully escaped URL string
    NSString *mailtoStr = [mailtoPrefix stringByAppendingString:escapedBody];
    
    // And let the application open the merged URL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoStr]];
}

//- (void)friendPickerViewControllerSelectionDidChange:
//(FBFriendPickerViewController *)friendPicker
//{
//    self.selectedFriends = friendPicker.selection;
//    NSLog(@"changed");
////    [self updateSelections];
//}

- (void)sessionStateChanged:(NSNotification*)notification {
    NSLog(@"session state changed");
    [self populateUserDetails];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.friendPickerController = nil;
    
    [self setUserProfileImage:nil];
    [self setEmailButton:nil];
    [self setFacebookButton:nil];
    [self setFeedbackLabel:nil];
    [super viewDidUnload];
    
}
@end
