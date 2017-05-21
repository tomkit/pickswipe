//
//  DraggableView.m
//  helloworld
//
//  Created by Thomas Chen on 2/27/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//

#import "Constants.h"
#import "DraggableView.h"

@interface DraggableView ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation DraggableView
CGPoint offset;
CGPoint endOffset;
CGPoint parentCenter;
int SMILE;
int SAD;
void(^swipeCallback)(void);
//UIImageView *imageView;
BOOL isLarge;
@synthesize imageView = _imageView;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
//        UIImage *corner = [UIImage imageNamed:@"corner.png"];
//        UIImageView *cornerView = [[UIImageView alloc] initWithImage:corner];
//        [self addSubview:cornerView];
//        cornerView.center = CGPointMake(self.frame.size.width, self.frame.size.height);
//         [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)];
        [self setContentSize:CGSizeMake(280,280)];
//        [scrollView.addSubview:self];
        self.imageView = [[UIImageView alloc] init];
        [self.imageView setFrame:CGRectMake(0,0,280,280)];
        [self addSubview:self.imageView];
        [self.imageView sendSubviewToBack:self];
        
        isLarge = NO;
        SAD = 0;
        SMILE = SAD+1;
        
    }
    return self;
}

-(void)setFrame:(CGRect)rect isLarge:(BOOL)isLarge {
    [super setFrame:rect];
    self.imageView.frame = rect;
    isLarge = isLarge;
}

-(void)setCenter:(CGPoint)point {
    [super setCenter:point];
    
    [self.imageView setCenter:parentCenter];
}

-(void)image:i {
    self.imageView.image = i;
}

-(UIImage*)image {
    return self.imageView.image;
}

-(void)setImage:img {
    [self.imageView setImage:img];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch = [touches anyObject];
    
    offset = [aTouch locationInView: self];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(isLarge) {
        return;
    }
    
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    
    [UIView beginAnimations:@"Dragging A DraggableView" context:nil];
    self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,
                            self.frame.size.width, self.frame.size.height);
    
    if(location.x-offset.x>0) {
        [[self.subviews objectAtIndex:SMILE] setAlpha:0.01*(location.x-offset.x)]; // =)
        [[self.subviews objectAtIndex:SAD] setAlpha:0.0]; // =(
    } else if(offset.x-location.x>0) {
        [[self.subviews objectAtIndex:SMILE] setAlpha:0.0];
        [[self.subviews objectAtIndex:SAD] setAlpha:0.01*(offset.x-location.x)];
    } else {
        [[self.subviews objectAtIndex:SMILE] setAlpha:0.0];
        [[self.subviews objectAtIndex:SAD] setAlpha:0.0];
    }
    [UIView commitAnimations];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(isLarge) {
        return;
    }
    
    endOffset = [[touches anyObject] locationInView: nil];
    
    [[self.subviews objectAtIndex:SMILE] setAlpha:0];
    [[self.subviews objectAtIndex:SAD] setAlpha:0];
    
    if(fabs(endOffset.x - offset.x) >= 100) {
        if(swipeCallback) {
            swipeCallback();
        }
    } else {
        if([Constants resolution] == UIDeviceResolution_iPhoneRetina5) {
            self.center = parentCenter;
        } else {
            self.center = CGPointMake(parentCenter.x, parentCenter.y+21);
        }

    }
    
}

-(void) registerSwipeCallback:(void(^)(void))callback {
    if(callback) {
        swipeCallback = callback;
    }
}

-(void) setParentCenter:(CGPoint)center {
    parentCenter = center;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
