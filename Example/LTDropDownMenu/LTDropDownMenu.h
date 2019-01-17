//
//  LTDropDownMenu.h
//  LTDropDownMenu
//
//  Created by alicia on 2019/01/04.
//  Copyright © 2019 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LTDropDownMenuType) {
    LTDropDownMenuTypeOneCol,
    LTDropDownMenuTypeTwoCol
};

@protocol LTDropDownMenuDelegate <NSObject>

- (NSInteger)numberOfColInMenu;
- (NSArray *)menuDataSourceAtMenuButtonIndex:(NSInteger)buttonIndex;

@optional
- (void)menuDidSelected;

- (void)menuDidSelectedItemWithMenuButtonIndex:(NSInteger)menuBtnIndex leftMenuIndexPath:(NSIndexPath *)leftMenuIndexPath leftMenuItemString:(NSString *)leftItemString;

/**
 Note : When LTDropDownMenuType is LTDropDownMenuTypeTwoCol, Data Format must be @[@{@"Jackie == 0" : @[@"Jackie == 0 --- 1",@"Jackie == 0 --- 2", @"Jackie == 0 --- 3", @"Jackie == 0 --- 4"]}];
 */
- (LTDropDownMenuType)menuItemTypeForRowsAtMenuBtnIndex:(NSInteger)menuBtnIndex;

@end

@interface LTDropDownMenu : UIView

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) UIFont *titleFont;    // Default is SystemFontSize 13
@property (nonatomic, weak) id <LTDropDownMenuDelegate> delegate;
@property (nonatomic, assign) CGFloat tableRowHeight;   // Default is 44
@property (nonatomic, assign) CGFloat maskOffsetY;
@property (nonatomic, assign) UIColor *selectedColor;    // Title Selected Color, Default is Red

+ (instancetype)menuWithSize:(CGSize)size;


@end
