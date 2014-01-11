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

static const CGFloat kButtonBottomMargin = 20;

@interface SERDuratedMenu ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray *itemButtons;
@property (nonatomic, strong) UIButton *mainButton;

@property (nonatomic) BOOL isOpen;
@end

@implementation SERDuratedMenu

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [UIColor colorFromHexString:@"#00000040"]; // FIXME Debug
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.contentView];
    [self addSubview:self.mainButton];
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
  
  CGPoint p = [self pointByRotatingVector:CGSizeMake(100, 0) aroundPoint:center angle:angle];
  
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
  DLog(@".");
  self.isOpen = YES;
  
  CGPoint center = self.mainButton.center;
  DLog(@"%@", NSStringFromCGPoint(center));
  NSUInteger total = [self.itemButtons count];
  for (NSUInteger index = 0; index < total; ++index)
  {
    UIButton *itemButton = self.itemButtons[index];
    itemButton.center = [self positionForButtonAtIndex:index total:total center:center];
    DLog(@"%d %@", index, NSStringFromCGPoint(itemButton.center));
    [self.contentView addSubview:itemButton];
  }
}

- (void)closeMenuAnimated:(BOOL)animated
{
  if (!self.isOpen)
    return;
  
  DLog(@".");
  self.isOpen = NO;
  
  for (UIView *view in self.contentView.subviews)
  {
    [view removeFromSuperview];
  }
}

@end
