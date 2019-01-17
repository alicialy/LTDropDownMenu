//
//  LTDropDownMaskView.h
//  LTDropDownMenu
//
//  Created by alicia on 2019/01/04.
//  Copyright © 2019 LeafTeam. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "LTDropDownMenu.h"

@class LTDropDownMenuData;


@protocol LTDropDownMaskViewDelegate <NSObject>

@optional

- (void)setMenuButtonUnselected;

- (void)setMenuIsExpand:(BOOL)isExpand;

// For LTDropDownMenuTypeOneCol
- (void)selectedMenuItemWitnMenuIndex:(NSInteger)menuIndex
                                 data:(LTDropDownMenuData *)data
                            indexPath:(NSIndexPath*)indexPath;

// For LTDropDownMenuTypeTwoCol
- (void)selectedLeftTableWithMenuIndex:(NSInteger)menuIndex
                              leftData:(LTDropDownMenuData *)leftData
                    leftTableIndexPath:(NSIndexPath *)leftIndexPath
                             rightData:(LTDropDownMenuData *)rightData
                    rightDataIndexPath:(NSIndexPath*)rightIndexPath;

@end

@interface LTDropDownMaskView : UIView


+ (instancetype)menuDetailViewWithSize:(CGSize)size;
- (void)changeMainViewWithAnimateClickTheSameBtn:(BOOL)isSame;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSIndexPath *singleIndexPath;
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, copy) NSString *menuBtnTitle;
@property (nonatomic, copy) NSString *seletedLeftString;

@property (nonatomic, assign) NSInteger leftTabIndex;
@property (nonatomic, assign) NSInteger menuIndex;
@property (nonatomic, assign) CGFloat rowHeight; // Table Row Height, Default is 44
@property (nonatomic, assign) LTDropDownMenuType menuType;

@property (nonatomic, weak) id <LTDropDownMaskViewDelegate> delegate;


@end
