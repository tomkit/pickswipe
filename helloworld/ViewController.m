//
//  ViewController.m
//  helloworld
//
//  Created by Thomas Chen on 2/17/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//

//
// V1.2 TODO:
// 1. fix full image to scale to original image size
// 2. add indicators back in

// V1.5 TODO:
// 1. add share to friend's FB pickswipe app functionality
// 2. add in queue for each user to see if there's any images
// 3. add in 'thank you' functionality

// V2.0 TODO:
// 1. allow users to select ppl to share via facebook/twitter friends
// 2. allow people to keep track of ones they liked


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

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;

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
NSString *currentImageURL;
NSMutableArray *items;
NSMutableArray *urls;
NSString *ownId;
int TOP = 6;

-(void) setupDraggableView:(DraggableView *)imageView {
    // ImageView
    imageView.backgroundColor = [UIColor orangeColor];
    imageView.clipsToBounds = YES;
    imageView.frame = CGRectMake(0,0,280,189);
    imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    imageView.layer.borderWidth = 4.0;
    imageView.layer.cornerRadius = 10.0;
    imageView.layer.masksToBounds = YES;
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


- (void)ownIdChanged:(NSNotification*)notification {
    NSLog(@"ownId changed");
//    ownId = uid;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(ownIdChanged:)
     name:OwnIdStateChangeNotification
     object:nil];
    
    // Navigation Bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"title.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.center = CGPointMake(self.view.center.x,self.navigationBar.frame.size.height/2);
    
    items = [[NSMutableArray alloc] init];
    urls = [[NSMutableArray alloc] init];
    
//    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    self.shareButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.shareButton.layer.borderWidth = 4.0;
    self.shareButton.layer.cornerRadius = 10.0;
    self.shareButton.layer.masksToBounds = YES;
    
    [self setupDraggableView:self.imageView2];
    [self setupDraggableView:self.imageView];
    self.imageView.center = self.view.center;
    self.imageView2.center = self.view.center;
    
//    instructionOverlay = [self createOverlay:@" dislike                       like" forView:self.imageView withSize:25];
    
    // Overlay 1
    yesOverlay = [self createOverlay:@"=)" forView:self.imageView withSize:75 xOffset:80.0];
    noOverlay = [self createOverlay:@"=(" forView:self.imageView withSize:75 xOffset:140.0];
    yesOverlay.alpha = 0;
    noOverlay.alpha = 0;

    // Overlay 2
    yesOverlay2 = [self createOverlay:@"=)" forView:self.imageView2 withSize:75 xOffset:80.0];
    noOverlay2 = [self createOverlay:@"=(" forView:self.imageView2 withSize:75 xOffset:140.0];
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
    [self.view addSubview:self.navigationBar];
    [self.view addSubview:self.imageView3];
    [self.view addSubview:self.imageView2];
    [self.view addSubview:self.imageView];
    [self.view bringSubviewToFront:self.imageView];
    
//    [self removeInstructionOverlay];
    
    self.userProfileImage.alpha = 0.0;
    self.friendLabel.alpha = 0.0;
    self.friendLabel.numberOfLines = 0;
//    TOP = self.imageView.subviews.count-1;
    
    if(items.count < 10) {
        [self getNext:nil];
    }
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
            [self.imageView setFrame:largeFrame];
            
            [self updateViewCenter:self.imageView];
        } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2) {
            largeFrame = self.imageView2.superview.bounds;
            original = self.imageView2.frame;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [self.imageView2 setFrame:largeFrame];
            
            [self updateViewCenter:self.imageView2];
        }
        
        [UIView commitAnimations];
    }
}

- (void)makeSmallNow {
    if([self.view.subviews objectAtIndex:TOP] == self.imageView) {
        [self.imageView setFrame:original];
        [self updateViewCenter:self.imageView];
    } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2) {
        [self.imageView2 setFrame:original];
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

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if(theTextField == self.textField) {
        [theTextField resignFirstResponder];
    }
    
    return YES;
}

- (void)updateZOrder {
    if([self.view.subviews objectAtIndex:TOP] == self.imageView) { // ImageView is top
        [self.view exchangeSubviewAtIndex:(TOP-1) withSubviewAtIndex:TOP];
        self.imageView.center = self.view.center;
        self.imageView.alpha = 1.0;
    } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2){ // ImageView2 is top
        [self.view exchangeSubviewAtIndex:TOP withSubviewAtIndex:(TOP-1)];
        self.imageView2.center = self.view.center;
        self.imageView2.alpha = 1.0;
    }
}

- (IBAction)getNext:(id)sender {
    NSMutableString *url = [[NSMutableString alloc] init];
    if(ownId) {
        [url appendString:@"http://"];
        [url appendString:SITE_DOMAIN];
        [url appendString:@"/ritelike/funny?u_id="];
        [url appendString:ownId];
    } else {
        [url appendString:@"http://"];
        [url appendString:SITE_DOMAIN];
        [url appendString:@"/ritelike/funny"];
    }
    // Request to get image URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod:@"GET"];


    
    // Asynchronous
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if(error) {
                // do nothing
            } else {
                NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error: nil];
                NSLog(@"datadict%@", JSON);
//                NSArray *argsArray = [[NSArray alloc] initWithArray:[dataDictionary objectForKey:@"args"]];
//                NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:JSON];
                
                NSString *responseString = [JSON objectForKey:@"url"];
                NSString *from = [JSON objectForKey:@"from_id"];
                NSLog(@"from:%@", from);
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

                if(scaledImage) {
                    [items addObject:scaledImage];
                    [urls addObject:JSON];
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
    
    DraggableView *view = [self.view.subviews objectAtIndex:TOP];
    if(view.image == nil) {
        if(items.count > 0) {
            if((imageToDisplay = [items objectAtIndex:0])) {
                NSDictionary *urlObject = [urls objectAtIndex:0];
                currentImageURL = [urlObject objectForKey:@"url"];
                
                [items removeObjectAtIndex:0];
                [urls removeObjectAtIndex:0];
                
                if((from_id = [urlObject objectForKey:@"from_id"])) {
                    NSLog(@"Got from ID:%@", from_id);
                    self.userProfileImage.profileID = from_id;
                    self.friendLabel.text = @"From your friend!";
                    self.userProfileImage.alpha = 1.0;
                    self.friendLabel.alpha = 1.0;
                } else {
                    self.friendLabel.text = @"";
                    self.userProfileImage.alpha = 0.0;
                    self.friendLabel.alpha = 0.0;
                }
                
                if([self.view.subviews objectAtIndex:TOP] == self.imageView) {
                    [indicator startAnimating];
                    [self.imageView setImage:imageToDisplay];
                    [indicator stopAnimating];
                    self.imageView2.image = nil;
                } else if([self.view.subviews objectAtIndex:TOP] == self.imageView2){
                    [indicator startAnimating];
                    [self.imageView2 setImage:imageToDisplay];
                    [indicator stopAnimating];
                    self.imageView.image = nil;
                }
                
                
            }
        } else if(items.count < 10){
            [self getNext:nil];
        }
    }
}

- (IBAction)shareClicked:(id)sender {    
    // Overridden by Segue
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showShareView"]) {
        UINavigationController *destViewController = segue.destinationViewController;
        [(ShareViewController *)destViewController.topViewController setShareUrl:currentImageURL];
    }
}

- (void)viewDidUnload {
    [self setImageView3:nil];
    [self setFriendLabel:nil];
    [super viewDidUnload];
}
@end
