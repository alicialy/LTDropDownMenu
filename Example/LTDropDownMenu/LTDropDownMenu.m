//
//  LTDropDownMenu.m
//  LTDropDownMenu
//
//  Created by alicia on 2019/01/04.
//  Copyright © 2019 LeafTeam. All rights reserved.
//

#import "LTDropDownMenu.h"
#import "LTDropDownMaskView.h"
#import "LTDropDownMenuData.h"


static NSInteger const kMenuButtonBaseTag   = 200;
static CGFloat const kMenuTableRowHeight    = 44;
static CGFloat const kMenuTableFontSize     = 13;

@interface LTDropDownMenu () <LTDropDownMaskViewDelegate>

@property (nonatomic, strong) UIView *menuBgView;
@property (nonatomic, strong) NSArray *lineArray;
@property (nonatomic, strong) NSArray *buttonArray;
@property (nonatomic, strong) LTDropDownMaskView *maskView;
@property (nonatomic, copy) NSString *leftSelectedString;
@property (nonatomic, assign) CGSize menuSize;
@property (nonatomic, assign) NSInteger tempSelectedBtnIndex;
@property (nonatomic, assign) NSInteger leftTabIndex;
@property (nonatomic, assign) BOOL isExpand;

@end

@implementation LTDropDownMenu

+ (instancetype)menuWithSize:(CGSize)size {
    LTDropDownMenu *menu = [[LTDropDownMenu alloc] init];
    menu.frame = CGRectMake(0, 0, size.width, size.height);
    menu.menuSize = size;
    return menu;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedColor = [UIColor redColor];
        self.tableRowHeight = kMenuTableRowHeight;
        self.titleFont = [UIFont systemFontOfSize:kMenuTableFontSize];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.menuBgView.frame = self.bounds;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method
- (void)setDelegate:(id<LTDropDownMenuDelegate>)delegate{
    _delegate = delegate;
    NSInteger totolCol = [delegate numberOfColInMenu];

    for (UIView *lineView in self.lineArray) {
        [lineView removeFromSuperview];
    }

    CGFloat lineOffsetY = 5;
    CGFloat lineOffsetX = self.menuSize.width / totolCol;
    CGFloat lineHeight = self.menuSize.height - lineOffsetY * 2;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:totolCol - 1];
    for (int i = 0; i < totolCol - 1; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(lineOffsetX * (i + 1), lineOffsetY, 0.5, lineHeight)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [array addObject:lineView];
        [self.menuBgView addSubview:lineView];
    }
    self.lineArray = [array copy];
}

- (void)setMenuTitles:(NSArray *)menuTitles {
    _menuTitles = menuTitles;
    
    if (menuTitles.count) {
        for (UIButton *button in self.buttonArray) {
            [button removeFromSuperview];
        }
        
        CGFloat buttonOffsetY = 0.5;
        CGFloat buttonWidth = self.menuSize.width / menuTitles.count;
        CGFloat buttonHeight = self.menuSize.height - 1.0;
        CGFloat buttonImgWidthHeight = 5.0f;
    
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:menuTitles.count];
        for (int i = 0; i < menuTitles.count; i ++) {
            CGFloat buttonOffsetX = buttonWidth * i;
            UIButton * menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(buttonOffsetX, buttonOffsetY, buttonWidth, buttonHeight);
            menuButton.tag = kMenuButtonBaseTag + i;
            menuButton.selected = NO;
            menuButton.titleLabel.font = self.titleFont;
            [menuButton setTitle:menuTitles[i] forState:UIControlStateNormal];
            [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [menuButton setTitleColor:self.selectedColor forState:UIControlStateSelected];
            [menuButton setImage:[UIImage imageNamed:@"home_menu_down"] forState:UIControlStateNormal];
            [menuButton setImage:[UIImage imageNamed:@"home_menu_up"] forState:UIControlStateSelected];
            menuButton.adjustsImageWhenHighlighted = NO;
            menuButton.imageEdgeInsets = UIEdgeInsetsMake((buttonHeight - buttonImgWidthHeight)/2, buttonWidth - 15, (buttonHeight - buttonImgWidthHeight) / 2, 5);
            menuButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
            [menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchDown];
            [array addObject:menuButton];
            [self.menuBgView addSubview:menuButton];
        }
        
        self.buttonArray = [array copy];
    }
}

#pragma mark - Action
- (void)menuButtonAction:(UIButton *)button {
    NSInteger buttonIndex = button.tag - kMenuButtonBaseTag;
    button.selected = YES;
    
    NSString *buttonTitle = [button titleForState:UIControlStateNormal];
   
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    
    [self.delegate menuDidSelected];
    
    self.maskView.menuIndex = buttonIndex;
    
    if ([self.delegate respondsToSelector:@selector(menuItemTypeForRowsAtMenuBtnIndex:)]) {
        if ([self.delegate menuItemTypeForRowsAtMenuBtnIndex:buttonIndex] == LTDropDownMenuTypeOneCol) {
            self.maskView.menuType = LTDropDownMenuTypeOneCol;
            self.maskView.menuBtnTitle = buttonTitle;
        } else {
            self.maskView.leftTabIndex = self.leftTabIndex;
            self.maskView.seletedLeftString = self.leftSelectedString;
            self.maskView.menuBtnTitle = buttonTitle;
            self.maskView.menuType = LTDropDownMenuTypeTwoCol;
        }
    } else {
        self.maskView.menuType = LTDropDownMenuTypeOneCol;
        self.maskView.menuBtnTitle = buttonTitle;
    }
    
    if ([self.delegate respondsToSelector:@selector(menuDataSourceAtMenuButtonIndex:)]) {
        NSArray * dataArray = [self.delegate menuDataSourceAtMenuButtonIndex:buttonIndex];
        self.maskView.dataArray = dataArray;
    }
    

    if (buttonIndex != self.tempSelectedBtnIndex) {
        UIButton *tempBtn = (UIButton *)[self.menuBgView viewWithTag:self.tempSelectedBtnIndex+kMenuButtonBaseTag];
        tempBtn.selected = NO;
        self.tempSelectedBtnIndex = buttonIndex;
        button.selected = YES;
        [self.maskView changeMainViewWithAnimateClickTheSameBtn:NO];
        
    } else {
        // Click The Same Button
        [self.maskView changeMainViewWithAnimateClickTheSameBtn:self.isExpand];
    }
}

#pragma mark - LTDropDownMaskViewDelegate
- (void)setMenuButtonUnselected {
    for (UIView * subView in self.menuBgView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subView;
            if (button.selected) {
                button.selected = NO;
            }
        }
    }
}

- (void)selectedMenuItemWitnMenuIndex:(NSInteger)menuIndex data:(LTDropDownMenuData *)data indexPath:(NSIndexPath *)indexPath {
    NSInteger hasSelectedBtnTag = menuIndex + kMenuButtonBaseTag;
    UIButton *hasSelectedBtn = (UIButton*)[self viewWithTag:hasSelectedBtnTag];
    
    // Selected Item
    NSString *menuItem = data.title;
    
    [hasSelectedBtn setTitle:menuItem forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(menuDidSelectedItemWithMenuButtonIndex:leftMenuIndexPath:leftMenuItemString:)]) {
        [self.delegate menuDidSelectedItemWithMenuButtonIndex:menuIndex leftMenuIndexPath:indexPath leftMenuItemString:menuItem];
    }
}

- (void)selectedLeftTableWithMenuIndex:(NSInteger)menuIndex leftData:(LTDropDownMenuData *)leftData leftTableIndexPath:(NSIndexPath *)leftIndexPath rightData:(LTDropDownMenuData *)rightData rightDataIndexPath:(NSIndexPath *)rightIndexPath{
    NSInteger hasSelectedBtnTag = menuIndex + kMenuButtonBaseTag;
    UIButton *hasSelectedBtn = (UIButton*)[self viewWithTag:hasSelectedBtnTag];
   
    // Selected Item
    NSString *menuItem = rightData.title;
    
    [hasSelectedBtn setTitle:menuItem forState:UIControlStateNormal];

    self.leftTabIndex = leftIndexPath.row;
    self.leftSelectedString = leftData.title;
    
    if ([self.delegate respondsToSelector:@selector(menuDidSelectedItemWithMenuButtonIndex:leftMenuIndexPath:leftMenuItemString:)]) {
        [self.delegate menuDidSelectedItemWithMenuButtonIndex:menuIndex leftMenuIndexPath:leftIndexPath leftMenuItemString:self.leftSelectedString];
    }
}

- (void)setMenuIsExpand:(BOOL)isExpand{
    self.isExpand = isExpand;
}

#pragma mark - Getters and Setters
- (UIView *)menuBgView {
    if (_menuBgView) {
        return _menuBgView;
    }
    
    _menuBgView = [[UIView alloc] init];
    [self addSubview:_menuBgView];
    return _menuBgView;
}

- (LTDropDownMaskView *)maskView {
    if (_maskView) {
        return _maskView;
    }
    
    // TODO Nav
    CGFloat maskMargin = self.menuSize.height + 64 + self.maskOffsetY;
    
    CGSize maskViewSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - maskMargin);
    
    _maskView = [LTDropDownMaskView menuDetailViewWithSize:maskViewSize];
    _maskView.frame = CGRectMake(0, maskMargin,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - maskMargin);
    _maskView.selectedColor = self.selectedColor;
    _maskView.rowHeight = self.tableRowHeight;
   
    _maskView.delegate = self;
    
    return _maskView;
}

@end
