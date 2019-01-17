//
//  LTDropDownMenu.m
//  LTDropDownMenu
//
//  Created by alicia on 2019/01/04.
//  Copyright © 2019 LeafTeam. All rights reserved.
//

#import "LTDropDownMenu.h"

@implementation LTDropDownMenuIndexPath
@end

static NSString * const kDropDownTableCellId = @"DropDownTableCellId";

static NSInteger const kMenuSelectedLineViewTag = 100;
static NSInteger const kMenuButtonBaseTag       = 200;

static CGFloat const kMenuTableRowHeight        = 44;
static CGFloat const kMenuTableTitleFontSize    = 14;
static CGFloat const kMenuTableRightIndex       = -1;
static CGFloat const kMenuSelectedLineWidth     = 3;
static CGFloat const kMenuButtonTitlePadding    = 5;

@interface LTDropDownMenu () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *menuBgView;
@property (nonatomic, strong) NSArray *lineArray;
@property (nonatomic, strong) NSArray *buttonArray;
@property (nonatomic, strong) NSMutableDictionary *selectRowDictionary;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *maskContentView;
@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) UITableView *rightTableView;
@property (nonatomic, assign) CGSize menuSize;
@property (nonatomic, assign) CGSize maskViewSize;
@property (nonatomic, assign) NSInteger leftTabIndex;
@property (nonatomic, assign) BOOL isExpand;
@property (nonatomic, assign) NSInteger selectedCol;
@property (nonatomic, assign) CGFloat scrollTop;

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
        self.textColor = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1];
        self.selectedColor = [UIColor blackColor];
        self.tableBackgroundColor = [UIColor colorWithRed:249.0/255 green:249.0/255 blue:249.0/255 alpha:1];
        self.tableRowHeight = kMenuTableRowHeight;
        self.titleFont = [UIFont systemFontOfSize:kMenuTableTitleFontSize];
        self.cellStyle = UITableViewCellStyleValue1;
        self.selectedCol = NSNotFound;
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addControls];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self layoutControls];
}

#pragma mark - Controls
- (void)addControls {
    UITableView *leftTableView = [self createTableView];

    UITableView *rightTableView = [self createTableView];
    
    [self.maskContentView addSubview:leftTableView];
    [self.maskContentView addSubview:rightTableView];

    self.leftTableView = leftTableView;
    self.rightTableView = rightTableView;
}

- (UITableView *)createTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = self.tableRowHeight;
    return tableView;
}

- (void)layoutControls {
    self.menuBgView.frame = self.bounds;
    
    CGFloat topHeight = 44 + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    CGFloat maskMargin = self.menuSize.height + topHeight + self.scrollTop;
    
    self.maskView.frame = CGRectMake(0, maskMargin, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - maskMargin);
    
    self.maskViewSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - maskMargin);
}

#pragma mark - Public Method
- (void)setDelegate:(id<LTDropDownMenuDelegate>)delegate{
    _delegate = delegate;
}

- (void)setDataSource:(id<LTDropDownMenuDataSource>)dataSource {
    _dataSource = dataSource;
    
    NSInteger totolCol = 1;
    if ([dataSource respondsToSelector:@selector(numberOfColInMenu:)]) {
        [_dataSource numberOfColInMenu:self];
    }
    
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
    
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:menuTitles.count];
        for (int i = 0; i < menuTitles.count; i ++) {
            CGFloat buttonOffsetX = buttonWidth * i;
            UIButton * menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(buttonOffsetX, buttonOffsetY, buttonWidth, buttonHeight);
            menuButton.tag = kMenuButtonBaseTag + i;
            menuButton.selected = NO;
            menuButton.titleLabel.font = self.titleFont;
            [menuButton setTitle:menuTitles[i] forState:UIControlStateNormal];
            [menuButton setTitleColor:self.textColor forState:UIControlStateNormal];
            [menuButton setTitleColor:self.selectedColor forState:UIControlStateSelected];
            [menuButton setImage:[UIImage imageNamed:@"menu_down"] forState:UIControlStateNormal];
            [menuButton setImage:[UIImage imageNamed:@"menu_up"] forState:UIControlStateSelected];
            menuButton.adjustsImageWhenHighlighted = NO;
            [self setButtuonEdgeInset:menuButton];
            
            [menuButton addTarget:self action:@selector(clickMenuAction:) forControlEvents:UIControlEventTouchDown];
            [array addObject:menuButton];
            [self.menuBgView addSubview:menuButton];
        }
        
        self.buttonArray = [array copy];
    }
}

#pragma mark - Private Method
- (BOOL)hasRightTable {
    if ([self.dataSource respondsToSelector:@selector(menu:hasRightRowsInCol:)]) {
        return [self.dataSource menu:self hasRightRowsInCol:self.selectedCol];
    }
    return NO;
}

- (BOOL)rightTableHasDataWithLeftRow:(NSInteger)leftRow {
    if ([self.dataSource respondsToSelector:@selector(menu:numberOfRightRowsInCol:leftRow:)]) {
        NSInteger rightRowCount = [self.dataSource menu:self numberOfRightRowsInCol:self.selectedCol leftRow:leftRow];
        if (rightRowCount > 0) {
            return YES;
        }
    }
    return NO;
}

- (void)changeMaskView {
    BOOL hasRightTable = [self hasRightTable];
    
    LTDropDownMenuIndexPath *indexPath = [self.selectRowDictionary objectForKey:[NSNumber numberWithInteger:self.selectedCol]];
    BOOL rightTableHasData = [self rightTableHasDataWithLeftRow:indexPath.leftRow];
    
    if (self.isExpand) {
        self.maskContentView.frame = CGRectMake(0, 0, self.maskViewSize.width, 0);
        
        if (!hasRightTable) {
            self.leftTableView.frame = CGRectMake(0, 0, self.maskViewSize.width, 0);
            [self.rightTableView setHidden:YES];
        } else {
            self.leftTableView.frame = CGRectMake(0, 0, self.maskViewSize.width * 1 / 3, 0);
            self.rightTableView.frame = CGRectMake(self.maskViewSize.width * 1 / 3, 0, self.maskViewSize.width * 2 / 3, 0);
            if (rightTableHasData) {
                [self.rightTableView setHidden:NO];
            } else {
                [self.rightTableView setHidden:YES];
            }
        }
        
        CGFloat tempHeight = self.maskViewSize.height * 2 / 3;
        CGFloat tableHeight = self.tableHeight > 0 ? self.tableHeight : (self.tableRowHeight * [self.dataSource menu:self numberOfRowsInCol:self.selectedCol]);
        CGFloat height = MIN(tableHeight, tempHeight);
       
        
        [UIView animateWithDuration:0.3 animations:^{
            self.maskContentView.frame = CGRectMake(0, 0, self.maskViewSize.width, height);
            if (!hasRightTable) {
                self.leftTableView.frame = CGRectMake(0, 0, self.maskViewSize.width, height);
            } else {
                self.leftTableView.frame = CGRectMake(0, 0, self.maskViewSize.width * 1 / 3, height);
                self.rightTableView.frame = CGRectMake(self.maskViewSize.width * 1 / 3, 0, self.maskViewSize.width * 2 / 3, height);
            }
        } completion:^(BOOL finished) {
//            [self setMenuIsExpand:YES];
        }];
        
        [self.leftTableView reloadData];
    } else {
        [self setMenuButtonUnselected];
        [UIView animateWithDuration:0.3 animations:^{
            self.maskContentView.frame = CGRectMake(0, 0, self.maskViewSize.width, 0);
            if (!hasRightTable) {
                self.leftTableView.frame = CGRectMake(0, 0, self.maskViewSize.width, 0);
            } else {
                self.leftTableView.frame = CGRectMake(0, 0, self.maskViewSize.width * 1 / 3, 0);
                self.rightTableView.frame = CGRectMake(self.maskViewSize.width * 1 / 3, 0, self.maskViewSize.width * 2 / 3, 0);
            }
//            self.hidden = YES;
        } completion:^(BOOL finished) {
//            [self setMenuIsExpand:NO];
            [self.maskView removeFromSuperview];
        }];
    }
}

- (void)closeMenu {
    [self setMenuButtonUnselected];
    self.isExpand = NO;
    [self.maskView removeFromSuperview];
}

- (void)addSelectedLineViewToTableView:(UITableView *)tableView cell:(UITableViewCell *)cell {
    if (self.selectedLineColor) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMenuSelectedLineWidth, [tableView rowHeight])];
        [lineView setBackgroundColor:self.selectedLineColor];
        lineView.tag = kMenuSelectedLineViewTag;
        [cell.contentView addSubview:lineView];
    }
}

- (void)setButtuonEdgeInset:(UIButton *)button {
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -button.imageView.bounds.size.width - kMenuButtonTitlePadding, 0, button.imageView.bounds.size.width + kMenuButtonTitlePadding)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, button.titleLabel.bounds.size.width + kMenuButtonTitlePadding, 0, -button.titleLabel.bounds.size.width - kMenuButtonTitlePadding)];
}

#pragma mark - Action
- (void)clickMenuAction:(UIButton *)button {
    [self.delegate menuDidSelected];
    
    NSInteger buttonIndex = button.tag - kMenuButtonBaseTag;
    // TODO Animation
    button.selected = YES;
    
    NSString *buttonTitle = [button titleForState:UIControlStateNormal];
   
    [self.maskView setHidden:NO];
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    
    
    NSInteger lastSelectedCol = self.selectedCol;
    
    self.selectedCol = buttonIndex;
   
    NSInteger selectedButtonTag = self.selectedCol + kMenuButtonBaseTag;
    UIButton *selectedButton = (UIButton *)[self viewWithTag:selectedButtonTag];
    [selectedButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    if (lastSelectedCol == self.selectedCol) {
        self.isExpand = !self.isExpand;
    } else {
         self.isExpand = YES;
    }
    
    UIButton *tempBtn = (UIButton *)[self.menuBgView viewWithTag:lastSelectedCol + kMenuButtonBaseTag];
    tempBtn.selected = NO;
    button.selected = YES;

    [self changeMaskView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTableView) {
        return [self.dataSource menu:self numberOfRowsInCol:self.selectedCol];
        
    } else if ([self.dataSource respondsToSelector:@selector(menu:numberOfRightRowsInCol:leftRow:)]) {
        
        LTDropDownMenuIndexPath *menuIndexPath = [self.selectRowDictionary objectForKey:[NSNumber numberWithInteger:self.selectedCol]];
        
        return [self.dataSource menu:self numberOfRightRowsInCol:self.selectedCol leftRow:menuIndexPath.leftRow];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDropDownTableCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:_cellStyle reuseIdentifier:kDropDownTableCellId];
        cell.textLabel.textColor = _textColor;
        cell.textLabel.font = _titleFont;
        [self addSelectedLineViewToTableView:tableView cell:cell];
    }
    
    UIView *lineView = [cell.contentView viewWithTag:kMenuSelectedLineViewTag];
    
    if (tableView == self.leftTableView) {
        cell.textLabel.text = [self.dataSource menu:self titleForCol:self.selectedCol row:indexPath.row];
       
        LTDropDownMenuIndexPath *menuIndexPath = [self.selectRowDictionary objectForKey:[NSNumber numberWithInteger:self.selectedCol]];
        if (indexPath.row != menuIndexPath.leftRow) {
            cell.textLabel.textColor = _textColor;
            [cell.contentView setBackgroundColor:self.tableBackgroundColor];
            [lineView setHidden:YES];
        } else {
            cell.textLabel.textColor = _selectedColor;
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
            [lineView setHidden:NO];
        }
    } else {
        LTDropDownMenuIndexPath *menuIndexPath = [self.selectRowDictionary objectForKey:[NSNumber numberWithInteger:self.selectedCol]];
        cell.textLabel.text = [self.dataSource menu:self titleForCol:self.selectedCol leftRow:menuIndexPath.leftRow rightRow:indexPath.row];
        if (indexPath.row != menuIndexPath.rightRow) {
             cell.textLabel.textColor = _textColor;
            [lineView setHidden:YES];
        } else {
            cell.textLabel.textColor = _selectedColor;
            [lineView setHidden:NO];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        LTDropDownMenuIndexPath *menuIndexPath = [[LTDropDownMenuIndexPath alloc] init];
        menuIndexPath.leftRow = indexPath.row;
        menuIndexPath.rightRow = kMenuTableRightIndex;
        [self.selectRowDictionary setObject:menuIndexPath forKey:[NSNumber numberWithInteger:self.selectedCol]];
        
        NSInteger selectedButtonTag = self.selectedCol + kMenuButtonBaseTag;
        UIButton *selectedButton = (UIButton *)[self viewWithTag:selectedButtonTag];
        
        NSString *menuTitle = [self.dataSource menu:self titleForCol:self.selectedCol row:indexPath.row];
        
        [selectedButton setTitle:menuTitle forState:UIControlStateNormal];
        [self setButtuonEdgeInset:selectedButton];
        
        [self.delegate menu:self didSelectRow:indexPath.row];
        
        NSInteger leftRow = indexPath.row;
        BOOL rightTableHasData = [self rightTableHasDataWithLeftRow:leftRow];
        if (!rightTableHasData) {
            [self.rightTableView setHidden:YES];
            [self closeMenu];
        } else {
            [self.rightTableView setHidden:NO];
            [self.rightTableView reloadData];
            [self.leftTableView reloadData];
        }
        
    } else  {
        LTDropDownMenuIndexPath *menuIndexPath = [self.selectRowDictionary objectForKey:[NSNumber numberWithInteger:self.selectedCol]];
        menuIndexPath.rightRow = indexPath.row;
        
        if ([self.delegate respondsToSelector:@selector(menu:titleForCol:leftRow:rightRow:)]) {
            NSString *menuTitle = [self.dataSource menu:self titleForCol:self.selectedCol leftRow:menuIndexPath.leftRow rightRow:indexPath.row];
            
            NSInteger selectedButtonTag = self.selectedCol + kMenuButtonBaseTag;
            UIButton *selectedButton = (UIButton *)[self viewWithTag:selectedButtonTag];
            [selectedButton setTitle:menuTitle forState:UIControlStateNormal];
            [self setButtuonEdgeInset:selectedButton];
        }
        
        if ([self.delegate respondsToSelector:@selector(menu:didSelectLefRow:rightRow:)]) {
            [self.delegate menu:self didSelectLefRow:menuIndexPath.leftRow rightRow:indexPath.row];
        }
        
        [self.rightTableView reloadData];
        [self closeMenu];
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

#pragma mark - Gesture
- (void)tapView:(id)sender {
    [self closeMenu];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    return YES;
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

- (UIView *)maskView {
    if (_maskView) {
        return _maskView;
    }
    
    _maskView = [[UIView alloc] init];
    _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tapGesture.delegate = self;
    [_maskView addGestureRecognizer:tapGesture];
    
    return _maskView;
}

- (UIView *)maskContentView {
    if (_maskContentView) {
        return _maskContentView;
    }
    _maskContentView = [[UIView alloc] init];
    _maskContentView.backgroundColor = [UIColor whiteColor];
    [self.maskView addSubview:_maskContentView];
    
    
    return _maskContentView;
}

- (NSMutableDictionary *)selectRowDictionary {
    if (_selectRowDictionary) {
        return _selectRowDictionary;
    }
    _selectRowDictionary = [[NSMutableDictionary alloc] init];
    return _selectRowDictionary;
}
@end
