//
//  SERMonster.m
//  durated-stan
//
//  Created by Stanley Rost on 12.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERDuratedMenuButton.h"

static const NSTimeInterval kAutomaticMenuDelay = 0.3;
static const CGFloat kAnimationDuration = 0.25;

@implementation SERDuratedMenuButton

BOOL _isTouching;
BOOL _hasMoved;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  _isTouching = YES;
  _hasMoved = NO;
  self.highlighted = YES;
  
  [self.delegate performSelector:@selector(startAutomaticMenu) withObject:nil afterDelay:kAutomaticMenuDelay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  _hasMoved = YES;
  UITouch *touch = [touches anyObject];
  
  CGPoint location = [touch locationInView:self];
  CGPoint previousLocation = [touch previousLocationInView:self];
  
  CGFloat dx = location.x - previousLocation.x;
  CGFloat dy = location.y - previousLocation.y;
  
  // TODO restrict movement to semi circle of the menu
  
  CGAffineTransform transform = CGAffineTransformTranslate(self.transform, dx, dy);
  transform.ty = fmin(0, transform.ty);
  self.transform = transform;
  
  [self.delegate showActiveItemForTranslation:CGPointMake(self.transform.tx, self.transform.ty)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  _isTouching = NO;
  [NSObject cancelPreviousPerformRequestsWithTarget:self.delegate selector:@selector(startAutomaticMenu) object:nil];
  
  if (_hasMoved || self.delegate.isOpen)
  {
    [self.delegate closeMenuAnimated:YES];
  }
  else if (!self.delegate.isOpen)
  {
    [self.delegate openMenuAnimated:YES];
  }
  
  [self.delegate fireActionForButtonWithTranslation:CGPointMake(self.transform.tx, self.transform.ty)];
  [self reset];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self reset];
  [self.delegate cancel];
}

- (void)reset
{
  _isTouching = NO;
  _hasMoved = NO;
  self.highlighted = NO;
  
  [NSObject cancelPreviousPerformRequestsWithTarget:self.delegate selector:@selector(startAutomaticMenu) object:nil];
  
  [UIView animateWithDuration:kAnimationDuration delay:0 usingSpringWithDamping:0.66 initialSpringVelocity:0 options:0 animations:^{
    self.transform = CGAffineTransformIdentity;
  } completion:NULL];
}

@end
