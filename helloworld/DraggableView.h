//
//  DraggableView.h
//  helloworld
//
//  Created by Thomas Chen on 2/27/13.
//  Copyright (c) 2013 Thomas Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DraggableView : UIImageView
-(void) registerSwipeCallback:(void(^)(void))callback;
-(void) setParentCenter:(CGPoint)center;
@end
