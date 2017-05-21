//
//  ViewController.m
//  helloworld
//
//  Created by Thomas Chen on 2/17/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//
// V1.3.6 TODO:
// 1. add gif support
// 2. Make first image from friend notification.
// 7. Show friends who are registered with pickswipe. Send FB notif to the ones who aren't and chosen.

// V1.3.7 TODO:
// 1. Add most recent 5 images users liked/disliked
// 2. Add in categories /r/aww for example
// 3. Add in sending a message with an image.

// V1.3.7 TODO:
// 1. Fix getting notification and having to swipe before you see the one from your friend.
// 2. Fix full image to scale to original image size
// 3. Fix updating # thanks to when you launch the app.
// 4. Update FB friend picker: non-friends on pickswipe get an email instead.
// 5. update FB friend picker to show 'most recent'/or search field?
// 6. after sharing via email, dismiss shareview

// FUTURE:
// -allow people to keep track of ones they liked
// -show who thanked instead of simply a number


#import "AppDelegate.h"
#import "ViewController.h"
#import "ShareViewController.h"
#import "DraggableView.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet DraggableView *imageView3;
@property (weak, nonatomic) IBOutlet DraggableView *imageView2;
@property (weak, nonatomic) IBOutlet DraggableView *imageView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *numThanksLabel;
- (IBAction)thanksClicked:(id)sender;

//@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
//@property (weak, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIButton *thanksButton;

@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;

//@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeLeftRecognizer;
//@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
//@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapRecognizer;
- (IBAction)shareClicked:(id)sender;

@end

@implementation ViewController
@synthesize imageView3 = _imageView3;
@synthesize imageView2 = _imageView2;
@synthesize imageView = _imageView;
@synthesize navigationBar = _navigationBar;
@synthesize shareButton = _shareButton;
@synthesize friendLabel = _friendLabel;
@synthesize thanksButton = _thanksButton;
//@synthesize userProfileImage = _userProfileImage;

DraggableView *imageView2;
DraggableView *imageView;
CGPoint originPoint;
UIActivityIndicatorView *indicator;
UIActivityIndicatorView *indicator2;
bool isLarge = NO;
CGRect original;
UILabel *instructionOverlay;
UILabel *yesOverlay;
UILabel *noOverlay;
UILabel *yesOverlay2;
UILabel *noOverlay2;
NSDictionary *currentURLObject;
NSMutableArray *items;
NSMutableArray *urls;
//NSDictionary<FBGraphUser> *ownUser;
int TOP;

-(void) setupDraggableView:(DraggableView *)imageView {
    // ImageView
    imageView.backgroundColor = [UIColor orangeColor];
    imageView.clipsToBounds = YES;
    imageView.frame = CGRectMake(0,0,280,280);
    imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    imageView.layer.borderWidth = 4.0;
    imageView.layer.cornerRadius = 10.0;
    imageView.layer.masksToBounds = YES;
}

-(void)keepSwiping {
    self.friendLabel.text = @"Keep swiping!";
    self.friendLabel.alpha = 1.0;
}

-(UILabel *) createOverlay:(NSString *)text forView:(UIView *)view withSize:(CGFloat)size xOffset:(CGFloat)xOffset{
    // Overlay
    UILabel *overlay = [[UILabel alloc] initWithFrame:view.frame];
    overlay = [[UILabel alloc] initWithFrame:view.frame];
    overlay.text = text;
    [view addSubview:overlay];
    [view sendSubviewToBack:overlay];
    // indicator - 2
    // :) - 1
    // :( - 0
    overlay.center = CGPointMake(view.frame.size.width/2+xOffset,view.frame.size.height/2);
    overlay.backgroundColor = [UIColor clearColor];
    
    if([text isEqualToString:@"=)"]) {
        overlay.textColor = [UIColor greenColor];
    } else if([text isEqualToString:@"=("]) {
        overlay.textColor = [UIColor redColor];
    } else {
        overlay.textColor = [UIColor blackColor];        
    }
    
    overlay.font = [UIFont systemFontOfSize:size];
    
    return overlay;
}

-(UIActivityIndicatorView *) createIndicator:(UIView *)view {
    UIActivityIndicatorView *localIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    localIndicator.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
    localIndicator.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    [view addSubview:localIndicator];
    [localIndicator bringSubviewToFront:view];
    
    return localIndicator;
}

-(UITapGestureRecognizer *) createTapRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGestureForTapRecognizer:)];
    tap.cancelsTouchesInView = NO;
    
    return tap;
}

-(UISwipeGestureRecognizer *) createSwipeLeftRecognizer {
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
    swipe.cancelsTouchesInView = NO;
    [swipe setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    return swipe;
}

-(UISwipeGestureRecognizer *) createSwipeRightRecognizer {
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
    swipe.cancelsTouchesInView = NO;
    [swipe setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    return swipe;
}


- (void)ownUserChanged:(NSNotification*)notification {
//    ownUser = (NSDictionary <FBGraphUser>*)[notification userInfo];
    
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate setOwnUser:(NSDictionary <FBGraphUser>*)[notification userInfo]];

    [self getThanksCount];
    
    NSLog(@"set own user");

    
//    ownId = uid;
}

-(void)updateCount:(NSString*)count {
    if(!count || [count isEqualToString:@"null"] || [count isEqualToString:@"(null)"] || [count isEqualToString:@""]) {
        count = @"0";
    }
    self.numThanksLabel.text = [NSString stringWithFormat:@"%@ Thanks Received", count];
}

-(void)getThanksCount {
    NSLog(@"getting thanks count");
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary<FBGraphUser> *ownUser = [appDelegate getOwnUser];
    
    if(ownUser) {
        NSMutableString *url = [[NSMutableString alloc] init];
        [url appendString:@"http://"];
        [url appendString:SITE_DOMAIN];
        [url appendString:@"/ritelike/funny/thanks?u_id="];
        [url appendString:ownUser.id];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        
        // Asynchronous
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                                   NSLog(@"inner get next");
                                   if(error) {
                                       NSLog(@"error with get next");
                                       // do nothing
                                   } else {

                                       NSString *num = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                                       NSLog(@"gotnum:%@",num);
                                       if (![NSThread isMainThread]) {
                                           [self performSelectorOnMainThread:@selector(updateCount:) withObject:num waitUntilDone:NO];
                                       }
                                   }
                               }];
    }

    
    
    

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(ownUserChanged:)
     name:OwnUserStateChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(tryGetSession:)
     name:TryGetSessionNotification
     object:nil];
    
//    [self getNext:nil];
    
//    [self getThanksCount];
    
//    [self tryGetSession];
}

-(void)tryGetSession {
    NSLog(@"trygetsession");
//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:NO
                                      completionHandler:
         ^(FBSession *session,
           FBSessionState state, NSError *error) {
                 NSLog(@"trygetsession2");
             if(error) {
                 
             } else {
                 [[FBRequest requestForMe] startWithCompletionHandler:
                  ^(FBRequestConnection *connection,
                    NSDictionary<FBGraphUser> *user,
                    NSError *error) {
                      if(error) {
                          
                      } else {
                          
                          AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                          [appDelegate setOwnUser:user];
                          
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:OwnUserStateChangeNotification
                           object:nil userInfo:user];
                          
//                          [self getThanksCount];
                      }
                  }];
             }
         }];
//    } else {
//        // show login
//    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    // Navigation Bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"title.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.center = CGPointMake(self.view.center.x,self.navigationBar.frame.size.height/2);
    
    if(!items) {
        items = [[NSMutableArray alloc] init];
    }
    if(!urls) {
        urls = [[NSMutableArray alloc] init];        
    }
    
//    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    self.shareButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.shareButton.layer.borderWidth = 4.0;
    self.shareButton.layer.cornerRadius = 10.0;
    self.shareButton.layer.masksToBounds = YES;
    
    self.thanksButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.thanksButton.layer.borderWidth = 4.0;
    self.thanksButton.layer.cornerRadius = 10.0;
    self.thanksButton.layer.masksToBounds = YES;
    
    // Setup DraggableViews
    [self setupDraggableView:self.imageView3];
    [self setupDraggableView:self.imageView2];
    [self setupDraggableView:self.imageView];
    
    if ([Constants resolution] == UIDeviceResolution_iPhoneRetina5) {
        self.imageView.center = self.view.center;
        self.imageView2.center = self.view.center;
        self.imageView3.center =self.view.center;
    } else {
        self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y+21);
        self.imageView2.center = CGPointMake(self.view.center.x, self.view.center.y+21);
        self.imageView3.center = CGPointMake(self.view.center.x, self.view.center.y+21);
        self.shareButton.center = CGPointMake(self.shareButton.center.x, self.view.center.y+185);
        self.numThanksLabel.center = CGPointMake(self.numThanksLabel.center.x, self.view.center.y+185);
    }

    
//    instructionOverlay = [self createOverlay:@" dislike                       like" forView:self.imageView withSize:25];
    
    // Overlay 1
    yesOverlay = [self createOverlay:@"=)" forView:self.imageView withSize:125 xOffset:20.0];
    noOverlay = [self createOverlay:@"=(" forView:self.imageView withSize:125 xOffset:140.0];
    yesOverlay.alpha = 0;
    noOverlay.alpha = 0;

    // Overlay 2
    yesOverlay2 = [self createOverlay:@"=)" forView:self.imageView2 withSize:125 xOffset:20.0];
    noOverlay2 = [self createOverlay:@"=(" forView:self.imageView2 withSize:125 xOffset:140.0];
    yesOverlay2.alpha = 0;
    noOverlay2.alpha = 0;
    
    // Swipe left
    [self.imageView registerSwipeCallback:^{
        [self showGestureForSwipeRecognizer:nil];
    }];
    [self.imageView setParentCenter:self.view.center];
    
    // Swipe right
    [self.imageView2 registerSwipeCallback:^{
        [self showGestureForSwipeRecognizer:nil];
    }];
    [self.imageView2 setParentCenter:self.view.center];
    
    // Tap
    UITapGestureRecognizer *tap = [self createTapRecognizer];
    [self.imageView addGestureRecognizer:tap];
    UITapGestureRecognizer *tap2 = [self createTapRecognizer];
    [self.imageView2 addGestureRecognizer:tap2];
    
    // Progress Indicator
    indicator = [self createIndicator:self.imageView];
    indicator2 = [self createIndicator:self.imageView2];
    [self.imageView sendSubviewToBack:yesOverlay];
    [self.imageView sendSubviewToBack:noOverlay];
    
    // Order Subviews
    [self.view addSubview:self.numThanksLabel];
    [self.view addSubview:self.thanksButton];
    [self.view addSubview:self.userProfileImage];
    [self.view addSubview:self.friendLabel];
    [self.view addSubview:self.shareButton];
    [self.view addSubview:self.navigationBar];
    [self.view addSubview:self.imageView3];
    [self.view addSubview:self.imageView2];
    [self.view addSubview:self.imageView];
    [self.view bringSubviewToFront:self.imageView];
    TOP = self.view.subviews.count-1;
    [indicator startAnimating];
    
    self.userProfileImage.alpha = 0.0;
    self.friendLabel.alpha = 0.0;
    self.friendLabel.numberOfLines = 0;
    self.thanksButton.alpha = 0.0;    
    
    [self getNext:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

-(void) updateViewCenter:(DraggableView *)imageView{
    // Update overlay center
    CGPoint oldCenter = [(UIView *)[imageView.subviews objectAtIndex:0] center];
    CGPoint newCenter = CGPointMake(oldCenter.x, imageView.frame.size.height/2);
    [[imageView.subviews objectAtIndex:0] setCenter:newCenter];
    
    oldCenter = [(UIView *)[imageView.subviews objectAtIndex:1] center];
    newCenter = CGPointMake(oldCenter.x, imageView.frame.size.height/2);
    [[imageView.subviews objectAtIndex:1] setCenter:newCenter];
}

- (void)makeFull {
    if(!isLarge) {
        isLarge = YES;
        CGRect largeFrame;
        
        if([self.view.subviews objectAtIndex:TOP] == self.imageView) {
            largeFrame = self.imageView.superview.bounds;
            original = self.imageView.frame;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [self.imageView setFrame:largeFrame isLarge:YES];
            
            [self updateViewCenter:self.imageView];
        } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2) {
            largeFrame = self.imageView2.superview.bounds;
            original = self.imageView2.frame;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [self.imageView2 setFrame:largeFrame isLarge:YES];
            
            [self updateViewCenter:self.imageView2];
        }
        
        [UIView commitAnimations];
    }
}

- (void)makeSmallNow {
    if([self.view.subviews objectAtIndex:TOP] == self.imageView) {
        [self.imageView setFrame:original isLarge:NO];
        [self updateViewCenter:self.imageView];
    } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2) {
        [self.imageView2 setFrame:original isLarge:NO];
        [self updateViewCenter:self.imageView2];
    }
}

- (void)makeSmall:(Boolean)now {
    if(isLarge) {
        isLarge = NO;
        
        if(now) {
            [self makeSmallNow];
        } else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [self makeSmallNow];
            [UIView commitAnimations];
        }
        
        
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

-(void) removeInstructionOverlay {
    if(instructionOverlay) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];        
        instructionOverlay.alpha = 0;
        [UIView setAnimationDidStopSelector:@selector(instructionAnimationDidStop:finished:context:)];
        [UIView commitAnimations];
    }
}

- (void)instructionAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    instructionOverlay.hidden = YES;
    [self.imageView bringSubviewToFront:instructionOverlay];
    [instructionOverlay removeFromSuperview];

}

- (IBAction)showGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer {
    
    if (isLarge) {
        [self makeSmall:NO];
    }
    else {
        [self makeFull];
    }
}

- (IBAction)showGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
    
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    
    if([self.view.subviews objectAtIndex:TOP] == self.imageView) {
        self.imageView.alpha = 0.0;
    } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2){
        self.imageView2.alpha = 0.0;
    }
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self makeSmall:YES];
    [self updateZOrder];
    [self tryToDisplayImage:nil];
    isLarge = NO;
    [self updateViewCenter:self.imageView];
    [self updateViewCenter:self.imageView2];
    
}

- (void)drawImageForGestureRecognizer:(UIGestureRecognizer *)recognizer atPoint:(CGPoint)centerPoint {
    
    NSString *imageName;
    
    if ([recognizer isMemberOfClass:[UITapGestureRecognizer class]]) {
        imageName = @"tap.png";
    }
    else if ([recognizer isMemberOfClass:[UIRotationGestureRecognizer class]]) {
        imageName = @"rotation.png";
    }
    else if ([recognizer isMemberOfClass:[UISwipeGestureRecognizer class]]) {
        imageName = @"swipe.png";
    }    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
//    if(theTextField == self.textField) {
//        [theTextField resignFirstResponder];
//    }
//    
//    return YES;
//}

- (void)updateZOrder {
    if([self.view.subviews objectAtIndex:TOP] == self.imageView) { // ImageView is top
        [self.view exchangeSubviewAtIndex:(TOP-1) withSubviewAtIndex:TOP];
        if([Constants resolution] == UIDeviceResolution_iPhoneRetina5) {
            self.imageView.center = self.view.center;
        } else {
            self.imageView.center = CGPointMake(self.view.center.x, self.view.center.y+21);
        }

        self.imageView.alpha = 1.0;
    } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2){ // ImageView2 is top
        [self.view exchangeSubviewAtIndex:TOP withSubviewAtIndex:(TOP-1)];        
        if([Constants resolution] == UIDeviceResolution_iPhoneRetina5) {
            self.imageView2.center = self.view.center;
        } else {
            self.imageView2.center = CGPointMake(self.view.center.x, self.view.center.y+21);
        }
        
        self.imageView2.alpha = 1.0;
    }
    
//    self.shareButton.alpha = 1.0;
//    self.shareButton.enabled = YES;
}

- (IBAction)getNext:(id)sender {
    [self getNext];
}

-(void) getNext {
    NSMutableString *url = [[NSMutableString alloc] init];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary<FBGraphUser> *ownUser = [appDelegate getOwnUser];
    
    if(ownUser) {
        [url appendString:@"http://"];
        [url appendString:SITE_DOMAIN];
        [url appendString:@"/ritelike/funny?u_id="];
        [url appendString:ownUser.id];
        [self innerGetNext:url];
    } else {
        [url appendString:@"http://"];
        [url appendString:SITE_DOMAIN];
        [url appendString:@"/ritelike/funny"];
        [self innerGetNext:url];
        
        
    }
}

-(void) innerGetNext:(NSString *)url {
    // Request to get image URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod:@"GET"];


    
    // Asynchronous
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//            NSLog(@"inner get next");
            if(error) {
                NSLog(@"error with get next");
                // do nothing
            } else {
                NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error: nil];
//                NSLog(@"datadict%@", JSON);
//                NSArray *argsArray = [[NSArray alloc] initWithArray:[dataDictionary objectForKey:@"args"]];
//                NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:JSON];
                
                NSString *responseString = [JSON objectForKey:@"url"];
                NSString *from = [JSON objectForKey:@"from_id"];
//                NSLog(@"from:%@", from);
//                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                // Request to get image data
                NSURL *funnyURL = [NSURL URLWithString:responseString];

                NSData *imageData = [NSData dataWithContentsOfURL:funnyURL];
                UIImage *image = [UIImage imageWithData:imageData];
                
//                CGSize newSize = CGSizeMake(600,400);
//                UIGraphicsBeginImageContext(newSize);
//                CGContextRef context = CGContextRetain(UIGraphicsGetCurrentContext());
//                CGContextTranslateCTM(context, 0.0, newSize.height);
//                CGContextScaleCTM(context, 1.0, -1.0);
//                CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, newSize.width, newSize.height), image.CGImage);
//                
//                CGContextSetInterpolationQuality(context, kCGInterpolationLow);
//                
//                UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//                
//                UIGraphicsEndImageContext();
//                CGContextRelease(context);
                
                UIImage *scaledImage = image;
                
//                UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//                animatedImageView.animationImages = [NSArray arrayWithObjects:
//                                                     [UIImage imageNamed:@"image1.gif"],
//                                                     [UIImage imageNamed:@"image2.gif"],
//                                                     [UIImage imageNamed:@"image3.gif"],
//                                                     [UIImage imageNamed:@"image4.gif"], nil];
//                animatedImageView.animationDuration = 1.0f;
//                animatedImageView.animationRepeatCount = 0;
//                [animatedImageView startAnimating];
//                [self.view addSubview: animatedImageView];

                if(scaledImage) {
                    if(from) {
                        [items insertObject:scaledImage atIndex:0];
                        [urls insertObject:JSON atIndex:0];
                    } else {
                        [items addObject:scaledImage];
                        [urls addObject:JSON];
                    }
                    
                    if(items.count > 10) {
                        [items removeLastObject];
                        [urls removeLastObject];
                    }

                }
            
                if (![NSThread isMainThread]) {
                    [self performSelectorOnMainThread:@selector(tryToDisplayImage:) withObject:nil waitUntilDone:NO];
                }                
                
                if(items.count < 10) {
                    [self getNext:nil];
                }
            }
        }];
}

-(void)tryToDisplayImage:(NSString *)from_id {
    UIImage *imageToDisplay;
//    NSLog(@"try to display");
    DraggableView *view = [self.view.subviews objectAtIndex:TOP];
    BOOL shouldSkip = false;
    for(int i = 0; i < urls.count; i++) {
        if([[urls objectAtIndex:i] objectForKey:@"from_id"] != nil) {
            shouldSkip = true;
            break;
        }
    }
    
    if(view.image == nil) {
        if(items.count > 0) {
            if((imageToDisplay = [items objectAtIndex:0])) {
                NSDictionary *urlObject = [urls objectAtIndex:0];
                currentURLObject = urlObject;
                
                [items removeObjectAtIndex:0];
                [urls removeObjectAtIndex:0];
                NSLog(@"url:%@", currentURLObject);
                
                if((from_id = [urlObject objectForKey:@"from_id"])) {
                    
                    self.friendLabel.text = @"From your friend!";
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.1];
                    self.userProfileImage.alpha = 1.0;
                    self.friendLabel.alpha = 1.0;
                    self.thanksButton.alpha = 1.0;
                    self.thanksButton.enabled = YES;
                    [UIView commitAnimations];
                    
//                    NSLog(@"Got from ID:%@", from_id);
                    if (FBSession.activeSession.isOpen) {
                        [[FBRequest requestForMyFriends] startWithCompletionHandler:
                         ^(FBRequestConnection *connection,
                           NSDictionary *result,
                           NSError *error) {
                             
                             if (!error) {
                                 NSArray* friends = [result objectForKey:@"data"];
                                 // TODO: make this more efficient
                                 for (NSDictionary<FBGraphUser> *friend in friends) {
//                                     NSLog(@"ids:%@",friend.id);
                                     if([friend.id isEqualToString:from_id]) {
                                         self.userProfileImage.profileID = friend.id;
//                                         self.friendLabel.text = @"From your friend!";
                                         break;
                                     }
                                 }
                             

                             }
                         }];
                    }
                    
                } else {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.5];
                    self.userProfileImage.alpha = 0.0;
                    self.friendLabel.alpha = 0.0;
                    self.thanksButton.alpha = 0.0;
                    [UIView commitAnimations];
                }
                
                if([self.view.subviews objectAtIndex:TOP] == self.imageView) {
                    [self.imageView setImage:imageToDisplay];
                    [indicator stopAnimating];
                    self.imageView2.image = nil;
                    [indicator2 startAnimating];
                } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2){
                    [self.imageView2 setImage:imageToDisplay];
                    [indicator2 stopAnimating];
                    self.imageView.image = nil;
                    [indicator startAnimating];
                }
                
                if(items.count < 10) {
                    [self getNext:nil];
                }
                
            }
        } else if(items.count < 10){
            [self getNext:nil];
        }
    }
}

- (IBAction)shareClicked:(id)sender {    
    // Overridden by Segue
//    self.shareButton.alpha = 0.4;
//    self.shareButton.enabled = NO;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"showShareView"]) {
        if(self.imageView.image == nil && self.imageView2.image == nil) {
            return NO;
        }
    }
    
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showShareView"]) {
        
        UINavigationController *destViewController = segue.destinationViewController;
        [(ShareViewController *)destViewController.topViewController setShareUrl:[currentURLObject objectForKey:@"url"]];
    }
}

- (void)viewDidUnload {
    [self setImageView3:nil];
    [self setFriendLabel:nil];
    [self setUserProfileImage:nil];
    [self setThanksButton:nil];
    [self setNumThanksLabel:nil];
    [super viewDidUnload];
}
- (IBAction)thanksClicked:(id)sender {
    
    if(currentURLObject) {
        NSMutableString *postURL = [[NSMutableString alloc] init];
        [postURL appendString:@"http://"];
        [postURL appendString:SITE_DOMAIN];
        [postURL appendString:@"/ritelike/funny"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        NSDictionary *initialLogAsJSON = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[currentURLObject objectForKey:@"from_id"], @"thanks", nil] forKeys:[NSArray arrayWithObjects:@"from_id", @"type",nil]];
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
                                       NSLog(@"thanks post error");
                                   } else {
//                                       NSLog(@"thanks post success");

                                   }
                               }];
        
        self.thanksButton.enabled = NO;
        self.thanksButton.alpha = 0.4;
    }
    
    
}
@end
