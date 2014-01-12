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

// state as ivars w/o properties for speed, touch methods are called in quick succession
BOOL _isTouching;
BOOL _hasMoved;
CGPoint _originalCenter;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  _isTouching = YES;
  _hasMoved = NO;
  _originalCenter = self.center;

  self.highlighted = YES;

  [self.delegate performSelector:@selector(startAutomaticMenu) withObject:nil afterDelay:kAutomaticMenuDelay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  _hasMoved = YES;
  UITouch *touch = [touches anyObject];
  
  CGPoint superLocation = [touch locationInView:self.superview];
  CGPoint offset = CGPointMake(superLocation.x - _originalCenter.x, superLocation.y - _originalCenter.y);
  
  // restrict movement to semi circle area
  offset.x = fmax(-_movementRadius, fmin(_movementRadius, offset.x));
  CGFloat maxY = sqrt(_movementRadius * _movementRadius - offset.x * offset.x);
  offset.y = fmax(-maxY, fmin(0, offset.y));
  self.transform = CGAffineTransformMakeTranslation(offset.x, offset.y);
  
  [self.delegate showActiveItemForTranslation:offset];
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
