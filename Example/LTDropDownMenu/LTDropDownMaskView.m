//
//  LTDropDownMaskView.m
//  LTDropDownMenu
//
//  Created by alicia on 2019/01/04.
//  Copyright © 2019 LeafTeam. All rights reserved.
//

#import "LTDropDownMaskView.h"
#import "LTDropDownMenuData.h"


@interface LTDropDownMaskView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) CGSize menuViewSize;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UITableView *singleTableView;
@property (nonatomic, strong) UITableView * leftTableView;
@property (nonatomic, strong) UITableView * rightTableView;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) NSMutableArray * rightDataSource;
@property (nonatomic, strong) NSIndexPath * leftIndexPath;


@end

@implementation LTDropDownMaskView

+ (instancetype)menuDetailViewWithSize:(CGSize)size {
    LTDropDownMaskView * maskView = [[LTDropDownMaskView alloc] init];
    maskView.frame = CGRectMake(0, 0, size.width, size.height);
    maskView.menuViewSize = size;
    return maskView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self addControls];
    }
    return self;
}

#pragma mark - Controls
- (void)addControls {
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    self.mainView = view;
    [self addSubview:view];
}

- (UITableView *)createTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = self.rowHeight;
    return tableView;
}

#pragma mark - Public Method
- (void)setMenuType:(LTDropDownMenuType)menuType{
    _menuType = menuType;
    if (menuType == LTDropDownMenuTypeOneCol) {
        UITableView *tableView = [self createTableView];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.mainView addSubview:tableView];
        self.singleTableView = tableView;
        
    } else {
        UITableView *leftTableView = [self createTableView];
        [leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell_left"];
        [self.mainView addSubview:leftTableView];
        self.leftTableView = leftTableView;
        
        UITableView *rightTableView = [self createTableView];
        [rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell_right"];
        [self.mainView addSubview:rightTableView];
        self.rightTableView = rightTableView;
    }
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    if (self.dataSource.count) {
        [self.dataSource removeAllObjects];
    }
    if (self.rightDataSource.count) {
        [self.rightDataSource removeAllObjects];
    }
  
    if (self.menuType == LTDropDownMenuTypeOneCol) {
        for (int i = 0; i < dataArray.count; i++) {
            LTDropDownMenuData *model = [[LTDropDownMenuData alloc] init];
            model.title = dataArray[i];
            model.isSelectedItem = NO;
            if ([model.title isEqualToString:self.menuBtnTitle]) {
                model.isSelectedItem = YES;
            }
            [self.dataSource addObject:model];
        }
        [self.singleTableView reloadData];
        
    } else {
        for (NSDictionary * dict in dataArray) {
            LTDropDownMenuData *model = [[LTDropDownMenuData alloc] init];
            model.title = [dict.allKeys lastObject];
            model.rightTableData = [dict.allValues lastObject];
            
            model.isSelectedItem = NO;
            
            if ([model.title isEqualToString:self.seletedLeftString]) {
                model.isSelectedItem = YES;
            }
            
            [self.dataSource addObject:model];
        }
        LTDropDownMenuData *data = (LTDropDownMenuData *)self.dataSource[self.leftTabIndex];
        for (int i = 0; i < data.rightTableData.count; i++) {
            LTDropDownMenuData *rightData = [[LTDropDownMenuData alloc] init];
            rightData.title = data.rightTableData[i];
            rightData.isSelectedItem = NO;
            if ([rightData.title isEqualToString:self.menuBtnTitle]) {
                rightData.isSelectedItem = YES;
            }
            [self.rightDataSource addObject:rightData];
        }
        [self.leftTableView reloadData];
        [self.rightTableView reloadData];
    }
}

- (void)changeMainViewWithAnimateClickTheSameBtn:(BOOL)isSame{
    if (isSame == NO) {
        self.mainView.frame = CGRectMake(0, 0, self.menuViewSize.width, 0);
        CGFloat height = 0;
        CGFloat tempHeight = self.menuViewSize.height * 2/3;
        CGFloat tableHeight = 0;
        
        if (self.menuType == LTDropDownMenuTypeOneCol) {
            self.singleTableView.frame = CGRectMake(0, 0, self.menuViewSize.width, 0);
            tableHeight = self.rowHeight * self.dataArray.count;
        } else {
            self.leftTableView.frame = CGRectMake(0, 0, self.menuViewSize.width * 1 / 3, 0);
            self.rightTableView.frame = CGRectMake(self.menuViewSize.width * 1 / 3, 0, self.menuViewSize.width * 2 / 3, 0);
            NSInteger tempNum = 0;
            NSInteger leftTableNum = self.dataSource.count;
            LTDropDownMenuData *data = (LTDropDownMenuData *)[self.dataSource firstObject];
            NSInteger rightTableNum = data.rightTableData.count;
            tempNum = MAX(leftTableNum, rightTableNum);
            tableHeight = self.rowHeight * tempNum;
        }
        
        if (tableHeight < tempHeight) {
            height = tableHeight;
        } else {
            height = tempHeight;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.mainView.frame = CGRectMake(0, 0, self.menuViewSize.width, height);
            if (self.menuType == LTDropDownMenuTypeOneCol) {
                self.singleTableView.frame = CGRectMake(0, 0, self.menuViewSize.width, height);
            } else {
                self.leftTableView.frame = CGRectMake(0, 0, self.menuViewSize.width * 1 / 3, height);
                self.rightTableView.frame = CGRectMake(self.menuViewSize.width * 1 / 3, 0, self.menuViewSize.width * 2 / 3, height);
            }
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(setMenuIsExpand:)]) {
                BOOL isExpend = YES;
                [self.delegate setMenuIsExpand:isExpend];
            }
        }];
    } else {
        [self setButtonUnselected];
        [UIView animateWithDuration:0.3 animations:^{
            self.mainView.frame = CGRectMake(0, 0, self.menuViewSize.width, 0);
            if (self.menuType == LTDropDownMenuTypeOneCol) {
                self.singleTableView.frame = CGRectMake(0, 0, self.menuViewSize.width, 0);
            } else {
                self.leftTableView.frame = CGRectMake(0, 0, self.menuViewSize.width * 1 / 3, 0);
                self.rightTableView.frame = CGRectMake(self.menuViewSize.width * 1 / 3, 0, self.menuViewSize.width * 2 / 3, 0);
            }
            self.hidden = YES;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(setMenuIsExpand:)]) {
                BOOL isExpend = NO;
                [self.delegate setMenuIsExpand:isExpend];
            }
            [self removeFromSuperview];
        }];
    }
}

#pragma mark - Private Method
- (void)setButtonUnselected {
    if ([self.delegate respondsToSelector:@selector(setMenuButtonUnselected)]) {
        [self.delegate setMenuButtonUnselected];
    }
}

- (void)setExpend {
    if ([self.delegate respondsToSelector:@selector(setMenuIsExpand:)]) {
        BOOL isExpend = NO;
        [self.delegate setMenuIsExpand:isExpend];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.singleTableView || tableView == self.leftTableView) {
        return self.dataSource.count;
    } else {
        return self.rightDataSource.count;
    }
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.menuType == LTDropDownMenuTypeOneCol) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        if (self.dataSource.count) {
            LTDropDownMenuData * model = self.dataSource[indexPath.row];
            cell.textLabel.text = model.title;
            UIColor * color = model.isSelectedItem ? self.selectedColor : [UIColor blackColor];
            cell.textLabel.textColor = color;
        }
        return cell;
    } else if (tableView == self.leftTableView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_left" forIndexPath:indexPath];
        if (self.dataSource.count) {
            LTDropDownMenuData *data = self.dataSource[indexPath.row];
            cell.textLabel.text = data.title;
            UIColor * color = data.isSelectedItem ? self.selectedColor : [UIColor blackColor];
            cell.textLabel.textColor = color;
        }
        return cell;
        
    } else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_right" forIndexPath:indexPath];
        if (self.rightDataSource.count) {
            LTDropDownMenuData *rightData = self.rightDataSource[indexPath.row];
            UIColor *color = rightData.isSelectedItem ? self.selectedColor : [UIColor blackColor];
            cell.textLabel.text = rightData.title;
            cell.textLabel.textColor = color;
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.menuType == LTDropDownMenuTypeOneCol) {
        // LTDropDownMenuTypeOneCol
        if ([self.delegate respondsToSelector:@selector(selectedMenuItemWitnMenuIndex:data:indexPath:)]) {
            LTDropDownMenuData *data = self.dataSource[indexPath.row];
            [self.delegate selectedMenuItemWitnMenuIndex:self.menuIndex data:data indexPath:indexPath];
        }
        [self setButtonUnselected];
        [self setExpend];
        [self removeFromSuperview];
        
    } else {
        // LTDropDownMenuTypeTwoCol
        if (tableView == self.leftTableView) {
            for (LTDropDownMenuData *data in self.dataSource) {
                if (data.isSelectedItem == YES) {
                    data.isSelectedItem = NO;
                }
            }
            LTDropDownMenuData *data = self.dataSource[indexPath.row];
            data.isSelectedItem = YES;
            [self.rightDataSource removeAllObjects];
            for (int i = 0; i < data.rightTableData.count; i++) {
                LTDropDownMenuData *rightData = [[LTDropDownMenuData alloc] init];
                rightData.title = data.rightTableData[i];
                rightData.isSelectedItem = NO;
                [self.rightDataSource addObject:rightData];
            }
            self.leftIndexPath = indexPath;
            [self.rightTableView reloadData];
            [self.leftTableView reloadData];
            
        } else if (tableView == self.rightTableView) {
            LTDropDownMenuData *lastSelected = self.dataSource[self.leftIndexPath.row];
            LTDropDownMenuData *rightTableData = self.rightDataSource[indexPath.row];
            if ([self.delegate respondsToSelector:@selector(selectedLeftTableWithMenuIndex: leftData:leftTableIndexPath:rightData:rightDataIndexPath:)]) {
                [self.delegate selectedLeftTableWithMenuIndex:self.menuIndex leftData:lastSelected leftTableIndexPath:self.leftIndexPath rightData:rightTableData rightDataIndexPath:indexPath];
            }
            
            [self setButtonUnselected];
            [self setExpend];
            [self removeFromSuperview];
        }
    }
}

#pragma mark - Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setButtonUnselected];
    [self setExpend];
    [self removeFromSuperview];
}

#pragma mark - Getters And Setters
- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray *)rightDataSource {
    if (_rightDataSource == nil) {
        _rightDataSource = [[NSMutableArray alloc] init];
    }
    return _rightDataSource;
}

@end
