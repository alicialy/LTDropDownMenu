//
//  LTDropDownMenu.h
//  LTDropDownMenu
//
//  Created by alicia on 2019/01/04.
//  Copyright © 2019 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LTDropDownMenu;

@interface LTDropDownMenuIndexPath : NSObject

@property (nonatomic, assign) NSInteger leftRow;
@property (nonatomic, assign) NSInteger rightRow;

@end

@protocol LTDropDownMenuDataSource <NSObject>

@required


- (NSString *)menu:(LTDropDownMenu *)menu titleForCol:(NSInteger)col row:(NSInteger)row;

- (NSInteger)menu:(LTDropDownMenu *)menu numberOfRowsInCol:(NSInteger)col;

@optional

- (NSInteger)numberOfColInMenu:(LTDropDownMenu *)menu;

- (BOOL)menu:(LTDropDownMenu *)menu hasRightRowsInCol:(NSInteger)col;

- (NSInteger)menu:(LTDropDownMenu *)menu numberOfRightRowsInCol:(NSInteger)col leftRow:(NSInteger)leftRow;

- (NSString *)menu:(LTDropDownMenu *)menu titleForCol:(NSInteger)col leftRow:(NSInteger)leftRow rightRow:(NSInteger)rightRow;


@end


@protocol LTDropDownMenuDelegate <NSObject>


- (void)menu:(LTDropDownMenu *)menu didSelectRow:(NSInteger)row;

@optional

- (void)menuDidSelected;

- (void)menu:(LTDropDownMenu *)menu didSelectLefRow:(NSInteger)leftRow rightRow:(NSInteger)rightRow;

@end


@interface LTDropDownMenu : UIView

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) UIFont *titleFont;    // Default is SystemFontSize 13
@property (nonatomic, strong) UIColor *selectedColor;    // Title Selected Color, Default is Black
@property (nonatomic, strong) UIColor *textColor;    // Title Color, Default is #4a4a4a
@property (nonatomic, strong) UIColor *tableBackgroundColor;    // Default is #f9f9f9
@property (nonatomic, strong) UIColor *selectedLineColor; // If Not set, no selected line
@property (nonatomic, weak) id <LTDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <LTDropDownMenuDelegate> delegate;
@property (nonatomic, assign) UITableViewCellStyle cellStyle; // default value1
@property (nonatomic, assign) CGFloat tableRowHeight;   // Default is 44
@property (nonatomic, assign) CGFloat tableHeight;   // Default is LeftTable Adapted Height
@property (nonatomic, assign) CGFloat maskOffsetY;
+ (instancetype)menuWithSize:(CGSize)size;


@end
