//
//  SERDuratedMenu.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERDuratedMenu.h"
#import "SERDuratedMenuItem.h"
#import "SERDuratedMenuButton.h"

static const CGFloat kButtonBottomMargin  = 20;
static const CGFloat kAnimationDuration   = 0.15;
static const CGFloat kButtonDisplacement  = 90;
static const CGFloat kMinimumDisplacement = 15;

@interface SERDuratedMenu () <SERDuratedMenuButtonDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray *itemButtons;
@property (nonatomic, strong) SERDuratedMenuButton *mainButton;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapRecognizer;

@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL automaticMenu;
@property (nonatomic) UIButton *activeItemButton;

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

- (SERDuratedMenuButton *)mainButton
{
  if (!_mainButton)
  {
    _mainButton = [SERDuratedMenuButton new];
    _mainButton.userInteractionEnabled = YES;
    _mainButton.delegate = self;
    _mainButton.movementRadius = kButtonDisplacement;
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
  [self.mainButton setImage:image];
}

- (void)setHighlightedImage:(UIImage *)image
{
  [self.mainButton setHighlightedImage:image];
}

#pragma mark Automatic menu

- (void)cancelAutomaticMenu
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAutomaticMenu) object:nil];
  
  if (self.automaticMenu)
  {
    [self closeMenuAnimated:YES];
    self.automaticMenu = NO;
  }
}

- (void)startAutomaticMenu
{
  if (!self.isOpen)
  {
    self.automaticMenu = YES;
    [self openMenuAnimated:YES];
  }
}

#pragma mark Actions

- (void)itemButtonPressed:(id)sender
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
  [button addTarget:self action:@selector(itemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
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

- (NSUInteger)indexForTranslation:(CGPoint)translation
{
  NSUInteger index = NSNotFound;
  
  CGFloat displacement = sqrt(translation.x * translation.x + translation.y * translation.y);
  if (displacement >= kMinimumDisplacement)
  {
    const CGFloat offset = -0.01; // guard against wrap around extreme values might be wrong otherwise (bottom right corner)
    
    CGFloat angle = atan((translation.y + offset) / translation.x);
    if (angle < 0) angle = M_PI + angle;
    
    CGFloat angleDistance = M_PI / ([self.items count] - 1); // distance between any two items
    
    index = (int)floor((angle - angleDistance / 2) / angleDistance + 1.0);
  }

  return index;
}

- (void)reset
{
  self.activeItemButton.highlighted = NO;
  self.activeItemButton = nil;
}

#pragma mark Open/Close

- (void)openMenuAnimated:(BOOL)animated
{
  self.isOpen = YES;
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

  self.isOpen = NO;
  self.backgroundTapRecognizer.enabled = NO;
  
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

#pragma mark Delegate Protocol

- (void)showActiveItemForTranslation:(CGPoint)translation
{
  NSUInteger index = [self indexForTranslation:translation];
  
  if (index != NSNotFound)
  {
    UIButton *itemButton = self.itemButtons[index];
    
    if (itemButton != self.activeItemButton)
    {
      self.activeItemButton.highlighted = NO;
      itemButton.highlighted = YES;
      self.activeItemButton = itemButton;
    }
  }
  else
  {
    self.activeItemButton.highlighted = NO;
    self.activeItemButton = nil;
  }
}

- (void)fireActionForButtonWithTranslation:(CGPoint)translation
{
  NSUInteger index = [self indexForTranslation:translation];
  
  if (index != NSNotFound)
  {
    SERDuratedMenuItem *item = self.items[index];
    [self.delegate menu:self didSelectItem:item];
  }
  
  [self reset];
}

- (void)cancel
{
  [self closeMenuAnimated:YES];
  [self reset];
}

#pragma mark UITapGestureRecognizer

- (void)tappedBackground:(UITapGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateRecognized)
  {
    [self closeMenuAnimated:YES];
  }
}

@end
