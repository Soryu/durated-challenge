//
//  SERDuratedMenuItem.h
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SERDuratedMenuItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic) NSUInteger tag;

- (id)initWithImage:(UIImage *)image tag:(NSInteger)tag;
- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage tag:(NSInteger)tag;

@end
