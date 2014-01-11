//
//  SERDuratedMenu.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERDuratedMenu.h"
#import "SERDuratedMenuItem.h"
#import "UIColor+SER.h"

static const CGFloat kButtonBottomMargin  = 20;
static const CGFloat kAnimationDuration   = 0.15;
static const CGFloat kButtonDisplacement  = 90;
static const CGFloat kMinimumDisplacement = 33;

@interface SERDuratedMenu ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray *itemButtons;
@property (nonatomic, strong) UIButton *mainButton;
@property (nonatomic, strong) UIPanGestureRecognizer *mainButtonPanRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapRecognizer;

@property (nonatomic) BOOL isOpen;
@end

@implementation SERDuratedMenu

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.contentView];
    [self addSubview:self.mainButton];
    
    self.mainButtonPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panningMainButton:)];
    [self.mainButton addGestureRecognizer:self.mainButtonPanRecognizer];
    
    self.backgroundTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackground:)];
    self.backgroundTapRecognizer.enabled = NO;
    [self.contentView addGestureRecognizer:self.backgroundTapRecognizer];
  }
  return self;
}

#pragma mark UI

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  [self.mainButton sizeToFit];

  self.mainButton.center = ({
    CGRect frame      = self.mainButton.frame;
    CGRect superFrame = self.mainButton.superview.frame;
    
    CGPoint center;
    center.x = CGRectGetMidX(superFrame);
    center.y = CGRectGetHeight(superFrame) - CGRectGetHeight(frame) / 2 - kButtonBottomMargin;
    center;
  });
}

- (UIButton *)mainButton
{
  if (!_mainButton)
  {
    _mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mainButton setTitle:@"Button" forState:UIControlStateNormal];
    [_mainButton addTarget:self action:@selector(mainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  }
  
  return _mainButton;
}

#pragma mark Interface

- (void)setItems:(NSArray *)items
{
  NSAssert([items count] > 1, @"menu must have at least two items");
  
  [self closeMenuAnimated:NO];
  
  _items = items;
  
  NSMutableArray *buttons = [NSMutableArray new];
  
  for (SERDuratedMenuItem *item in items)
  {
    UIButton *button = [self createButtonForItem:item];
    [buttons addObject:button];
  }
  
  self.itemButtons = buttons;
}

- (void)setImage:(UIImage *)image
{
  [self.mainButton setImage:image forState:UIControlStateNormal];
  [self.mainButton setTitle:image ? nil : @"Button" forState:UIControlStateNormal];
}

#pragma mark Actions

- (void)mainButtonPressed:(id)sender
{
  if (self.isOpen)
  {
    [self closeMenuAnimated:YES];
  }
  else
  {
    [self openMenuAnimated:YES];
  }
}

- (void)menuButtonPressed:(id)sender
{
  NSUInteger index = [self.itemButtons indexOfObject:sender];
  NSAssert(index != NSNotFound, @"menu button not found");
  
  SERDuratedMenuItem *item = self.items[index];
  
  [self.delegate menu:self didSelectItem:item];
  [self closeMenuAnimated:YES];
}

#pragma mark Helpers

- (UIButton *)createButtonForItem:(SERDuratedMenuItem *)item
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button setImage:item.image forState:UIControlStateNormal];

  if (item.highlightedImage)
    [button setImage:item.highlightedImage forState:UIControlStateHighlighted];
  
  [button sizeToFit];
  [button addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  return button;
}

- (CGPoint)positionForButtonAtIndex:(NSUInteger)index total:(NSUInteger)total center:(CGPoint)center
{
  NSParameterAssert(total > 1);

  CGFloat startAngle = M_PI;
  CGFloat angleDistance = M_PI / (total - 1); // distance between any two items
  CGFloat angle = startAngle + index * angleDistance;
  
  CGPoint p = [self pointByRotatingVector:CGSizeMake(kButtonDisplacement, 0) aroundPoint:center angle:angle];
  
  CGFloat scale = [[UIScreen mainScreen] scale];
  return CGPointMake(round(p.x * scale) / scale, round(p.y * scale) / scale); // round to pixels
}

- (CGPoint)pointByRotatingVector:(CGSize)vector aroundPoint:(CGPoint)center angle:(CGFloat)theta
{
  CGFloat x = vector.width * cos(theta) - vector.height * sin(theta);
  CGFloat y = vector.width * sin(theta) + vector.height * cos(theta);
  
  return CGPointMake(center.x + x, center.y + y);
}

#pragma mark Open/Close

- (void)openMenuAnimated:(BOOL)animated
{
  self.isOpen = YES;
  
  self.mainButtonPanRecognizer.enabled = NO;
  self.backgroundTapRecognizer.enabled = YES;
  
  CGPoint center = self.mainButton.center;
  NSUInteger total = [self.itemButtons count];
  
  if (animated)
  {
    for (UIButton *itemButton in self.itemButtons)
    {
      itemButton.center = center;
      itemButton.alpha = 0.0;
      [self.contentView addSubview:itemButton];
    }
    
    CGFloat delay = 0.0;
    CGFloat delayIncrement = kAnimationDuration / total;
    for (NSUInteger index = 0; index < total; ++index)
    {
      UIButton *itemButton = self.itemButtons[index];
      [UIView animateWithDuration:kAnimationDuration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        itemButton.center = [self positionForButtonAtIndex:index total:total center:center];
        itemButton.alpha = 1.0;
      } completion:NULL];
      delay += delayIncrement;
    }
  }
  else
  {
    for (NSUInteger index = 0; index < total; ++index)
    {
      UIButton *itemButton = self.itemButtons[index];
      itemButton.alpha = 1.0;
      itemButton.center = [self positionForButtonAtIndex:index total:total center:center];
      [self.contentView addSubview:itemButton];
    }
  }
}

- (void)closeMenuAnimated:(BOOL)animated
{
  if (!self.isOpen)
    return;

  self.mainButtonPanRecognizer.enabled = YES;
  self.backgroundTapRecognizer.enabled = NO;

  self.isOpen = NO;
  
  if (animated)
  {
    NSUInteger total = [self.itemButtons count];
    CGFloat delay = 0.0;
    CGFloat delayIncrement = kAnimationDuration / total;
    CGPoint center = self.mainButton.center;
    for (UIButton *itemButton in self.itemButtons.reverseObjectEnumerator)
    {
      [UIView animateWithDuration:kAnimationDuration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        itemButton.center = center;
        itemButton.alpha = 0.0;
      } completion:^(BOOL finished) {
        itemButton.alpha = 1.0;
        [itemButton removeFromSuperview];
      }];
      delay += delayIncrement;
    }
  }
  else
  {
    for (UIView *view in self.contentView.subviews)
    {
      [view removeFromSuperview];
    }
  }
}

#pragma mark UITapGestureRecognizer

- (void)tappedBackground:(UITapGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateRecognized)
  {
    [self closeMenuAnimated:YES];
  }
}

#pragma mark UIPangestureRecognizer

- (void)panningMainButton:(UIPanGestureRecognizer *)recognizer
{
  UIView *view = recognizer.view;
  NSAssert(view == self.mainButton, @"panning something other than the main button");
  
  if (recognizer.state == UIGestureRecognizerStateBegan)
  {
    // TODO: show actions after the user plays around with the button for more than half a second?
  }
  else if (recognizer.state == UIGestureRecognizerStateChanged)
  {
    CGPoint translation = [recognizer translationInView:view];

    // TODO restrict button movement to a half circle around the center
    CGPoint cleanedTranslation = [self boundedTranslationForTranslation:translation];
    view.transform = CGAffineTransformMakeTranslation(cleanedTranslation.x, cleanedTranslation.y);

    // if showing actions above then we'd need to highlight the current one
  }
  else if (recognizer.state == UIGestureRecognizerStateEnded)
  {
    CGPoint translation = [recognizer translationInView:view];
    [self fireActionForButtonWithTranslation:translation];
  }
  else if (recognizer.state == UIGestureRecognizerStateCancelled)
  {
    [self resetMainButton];
  }
}

- (void)fireActionForButtonWithTranslation:(CGPoint)translation
{
  [self resetMainButton];
  
  CGPoint cleanTranslation = [self boundedTranslationForTranslation:translation];
  
  CGFloat displacement = sqrt(cleanTranslation.x * cleanTranslation.x + cleanTranslation.y * cleanTranslation.y);
  if (displacement >= kMinimumDisplacement)
  {
    NSUInteger index = [self indexForTranslation:cleanTranslation];
    SERDuratedMenuItem *item = self.items[index];
    
    [self.delegate menu:self didSelectItem:item];
  }
}

- (void)resetMainButton
{
  [UIView animateWithDuration:kAnimationDuration animations:^{
    self.mainButton.transform = CGAffineTransformIdentity;
  }];
}

- (CGPoint)boundedTranslationForTranslation:(CGPoint)translation
{
  CGFloat cleanX = fmax(-kButtonDisplacement, fmin(kButtonDisplacement, translation.x));
  CGFloat cleanY = fmax(-kButtonDisplacement, fmin(0, translation.y));
  
  return CGPointMake(cleanX, cleanY);
}

- (NSUInteger)indexForTranslation:(CGPoint)translation
{
  const CGFloat offset = -0.01; // guard against wrap around extreme values might be wrong otherwise (bottom right corner)

  CGFloat angle = atan((translation.y + offset) / translation.x);
  if (angle < 0) angle = M_PI + angle;

  CGFloat angleDistance = M_PI / ([self.items count] - 1); // distance between any two items
  
  NSUInteger segmentIndex = (int)floor((angle - angleDistance / 2) / angleDistance + 1.0);
  return segmentIndex;
}

@end
