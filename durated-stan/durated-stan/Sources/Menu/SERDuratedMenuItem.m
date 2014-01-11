//
//  SERDuratedMenuItem.m
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import "SERDuratedMenuItem.h"

@implementation SERDuratedMenuItem

- (id)initWithImage:(UIImage *)image tag:(NSInteger)tag
{
  return [self initWithImage:image highlightedImage:nil tag:tag];
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage tag:(NSInteger)tag
{
  self = [super init];
  if (self)
  {
    self.image = image;
    self.highlightedImage = highlightedImage;
    self.tag = tag;
  }
  
  return self;
}

@end
