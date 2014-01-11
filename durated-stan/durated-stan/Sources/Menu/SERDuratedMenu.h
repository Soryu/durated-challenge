//
//  SERDuratedMenu.h
//  durated-stan
//
//  Created by Stanley Rost on 11.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SERDuratedMenu, SERDuratedMenuItem;
@protocol SERDuratedMenuDelegate <NSObject>

- (void)menu:(SERDuratedMenu *)menu didSelectItem:(SERDuratedMenuItem *)item;

@end


@interface SERDuratedMenu : UIView

@property (nonatomic, weak) id<SERDuratedMenuDelegate> delegate;
@property (nonatomic, copy) NSArray *items;

- (void)setImage:(UIImage *)image;
- (void)setHighlightedImage:(UIImage *)image;

@end
