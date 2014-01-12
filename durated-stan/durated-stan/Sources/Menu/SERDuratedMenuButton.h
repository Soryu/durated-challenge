//
//  SERMonster.h
//  durated-stan
//
//  Created by Stanley Rost on 12.01.14.
//  Copyright (c) 2014 Stanley Rost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SERDuratedMenuButtonDelegate <NSObject>

- (BOOL)isOpen;
- (void)startAutomaticMenu;
- (void)openMenuAnimated:(BOOL)animated;
- (void)closeMenuAnimated:(BOOL)animated;
- (void)fireActionForButtonWithTranslation:(CGPoint)translation;
- (void)showActiveItemForTranslation:(CGPoint)translation;
- (void)cancel;

@end

@interface SERDuratedMenuButton : UIImageView

@property (nonatomic, weak) NSObject<SERDuratedMenuButtonDelegate> *delegate;
@property (nonatomic) CGFloat movementRadius;

@end
