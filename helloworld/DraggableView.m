//
//  DraggableView.m
//  helloworld
//
//  Created by Thomas Chen on 2/27/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//

#import "DraggableView.h"

@interface DraggableView ()

@end

@implementation DraggableView
CGPoint offset;
CGPoint endOffset;
CGPoint parentCenter;
void(^swipeCallback)(void);

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {

    }
    return self;
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
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    
    [UIView beginAnimations:@"Dragging A DraggableView" context:nil];
    self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,
                            self.frame.size.width, self.frame.size.height);
    
    if(location.x-offset.x>0) {
        [[self.subviews objectAtIndex:1] setAlpha:0.01*(location.x-offset.x)]; // =)
        [[self.subviews objectAtIndex:0] setAlpha:0.0]; // =(
    } else if(offset.x-location.x>0) {
        [[self.subviews objectAtIndex:1] setAlpha:0.0];
        [[self.subviews objectAtIndex:0] setAlpha:0.01*(offset.x-location.x)];
    } else {
        [[self.subviews objectAtIndex:1] setAlpha:0.0]; 
        [[self.subviews objectAtIndex:0] setAlpha:0.0]; 
    }
    [UIView commitAnimations];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    endOffset = [[touches anyObject] locationInView: nil];
    
    [[self.subviews objectAtIndex:1] setAlpha:0];
    [[self.subviews objectAtIndex:0] setAlpha:0];
    
    if(fabs(endOffset.x - offset.x) >= 100) {
        if(swipeCallback) {
            swipeCallback();
        }
    } else {
        self.center = parentCenter;
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
